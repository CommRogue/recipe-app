// Package httpapi exposes the service over HTTP: an unauthenticated health
// check and the versioned API under /v1/ (H20), every route of which needs a
// Firebase ID token.
package httpapi

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"time"

	"github.com/CommRogue/recipe-app/backend/internal/auth"
	"github.com/CommRogue/recipe-app/backend/internal/generate"
)

// Deps are what the handler needs.
type Deps struct {
	Verifier auth.Verifier
	Generate *generate.Service
	Log      *slog.Logger
	// GenerateTimeout bounds one /v1/generate call end to end. Zero means
	// 90 seconds.
	GenerateTimeout time.Duration
}

// MaxRequestBody bounds a JSON request body.
const MaxRequestBody = 64 << 10

// NewHandler builds the routing table.
func NewHandler(d Deps) http.Handler {
	if d.Log == nil {
		d.Log = slog.Default()
	}
	if d.GenerateTimeout == 0 {
		d.GenerateTimeout = 90 * time.Second
	}
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
	})

	requireAuth := auth.Middleware(d.Verifier, d.Log)
	mux.Handle("POST /v1/generate", requireAuth(http.HandlerFunc(d.handleGenerate)))

	return logRequests(d.Log, mux)
}

type generateResponse struct {
	Draft   any    `json:"draft"`
	ChainID string `json:"chainId,omitempty"`
}

func (d Deps) handleGenerate(w http.ResponseWriter, r *http.Request) {
	uid := auth.UIDFromContext(r.Context())
	var req generate.Request
	if err := decodeJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_argument", err.Error())
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), d.GenerateTimeout)
	defer cancel()

	res, err := d.Generate.Generate(ctx, uid, req)
	if err != nil {
		status, code := classify(err)
		if status >= 500 {
			d.Log.ErrorContext(ctx, "generate failed", "uid", uid, "status", status, "error", err.Error())
		}
		writeError(w, status, code, publicMessage(err, status))
		return
	}
	writeJSON(w, http.StatusOK, generateResponse{Draft: res.Draft, ChainID: res.ChainID})
}

// classify maps pipeline errors to HTTP status and a stable error code the
// app can switch on.
func classify(err error) (int, string) {
	switch {
	case errors.Is(err, generate.ErrInvalidRequest):
		return http.StatusBadRequest, "invalid_argument"
	case errors.Is(err, generate.ErrConsentRequired):
		return http.StatusForbidden, "consent_required"
	case errors.Is(err, generate.ErrQuotaExceeded):
		return http.StatusTooManyRequests, "quota_exceeded"
	case errors.Is(err, generate.ErrModelOutput):
		return http.StatusBadGateway, "no_draft"
	case errors.Is(err, generate.ErrModelUnavailable), errors.Is(err, context.DeadlineExceeded):
		return http.StatusServiceUnavailable, "model_unavailable"
	default:
		return http.StatusInternalServerError, "internal"
	}
}

// publicMessage keeps model and infrastructure detail out of responses.
func publicMessage(err error, status int) string {
	if status < 500 {
		return err.Error()
	}
	switch status {
	case http.StatusBadGateway:
		return "the model did not return a usable recipe; try again"
	case http.StatusServiceUnavailable:
		return "the model is unavailable right now; try again shortly"
	default:
		return "internal error"
	}
}

func decodeJSON(r *http.Request, v any) error {
	if ct := r.Header.Get("Content-Type"); ct != "" && ct != "application/json" && !hasJSONPrefix(ct) {
		return errors.New("Content-Type must be application/json")
	}
	body, err := io.ReadAll(http.MaxBytesReader(nil, r.Body, MaxRequestBody))
	if err != nil {
		return errors.New("request body is too large or unreadable")
	}
	if len(body) == 0 {
		return errors.New("request body is empty")
	}
	// Unknown fields are tolerated so an older service survives a newer
	// app (H19); wrong types are not.
	if err := json.Unmarshal(body, v); err != nil {
		return errors.New("request body is not the expected JSON: " + err.Error())
	}
	return nil
}

func hasJSONPrefix(ct string) bool {
	return len(ct) >= len("application/json") && ct[:len("application/json")] == "application/json"
}

type errorBody struct {
	Error struct {
		Code    string `json:"code"`
		Message string `json:"message"`
	} `json:"error"`
}

func writeError(w http.ResponseWriter, status int, code, msg string) {
	var b errorBody
	b.Error.Code = code
	b.Error.Message = msg
	writeJSON(w, status, b)
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(status)
	enc := json.NewEncoder(w)
	enc.SetEscapeHTML(false)
	_ = enc.Encode(v)
}

type statusRecorder struct {
	http.ResponseWriter
	status int
}

func (s *statusRecorder) WriteHeader(code int) {
	s.status = code
	s.ResponseWriter.WriteHeader(code)
}

func logRequests(log *slog.Logger, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/healthz" {
			next.ServeHTTP(w, r)
			return
		}
		rec := &statusRecorder{ResponseWriter: w, status: http.StatusOK}
		started := time.Now()
		next.ServeHTTP(rec, r)
		attrs := []any{
			"method", r.Method, "path", r.URL.Path, "status", rec.status,
			"durationMs", time.Since(started).Milliseconds(),
		}
		if trace := r.Header.Get("X-Cloud-Trace-Context"); trace != "" {
			attrs = append(attrs, "trace", trace)
		}
		log.InfoContext(r.Context(), "request", attrs...)
	})
}
