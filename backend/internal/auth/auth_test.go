package auth

import (
	"context"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

type fakeVerifier map[string]string // token -> uid

func (f fakeVerifier) Verify(_ context.Context, token string) (string, error) {
	if uid, ok := f[token]; ok {
		return uid, nil
	}
	return "", ErrInvalidToken
}

func handler(t *testing.T) http.Handler {
	t.Helper()
	echo := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, _ = io.WriteString(w, "uid="+UIDFromContext(r.Context()))
	})
	return Middleware(fakeVerifier{"good-token": "user-1"}, slog.New(slog.NewTextHandler(io.Discard, nil)))(echo)
}

func TestMiddlewarePassesTheUIDThrough(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	req.Header.Set("Authorization", "Bearer good-token")
	rec := httptest.NewRecorder()
	handler(t).ServeHTTP(rec, req)
	if rec.Code != http.StatusOK || rec.Body.String() != "uid=user-1" {
		t.Fatalf("got %d %q", rec.Code, rec.Body.String())
	}
}

func TestMiddlewareAcceptsLowercaseScheme(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	req.Header.Set("Authorization", "bearer good-token")
	rec := httptest.NewRecorder()
	handler(t).ServeHTTP(rec, req)
	if rec.Code != http.StatusOK {
		t.Fatalf("got %d", rec.Code)
	}
}

func TestMiddlewareRejects(t *testing.T) {
	cases := map[string]string{
		"no header":     "",
		"wrong scheme":  "Basic abc",
		"empty token":   "Bearer ",
		"unknown token": "Bearer bad-token",
	}
	for name, header := range cases {
		t.Run(name, func(t *testing.T) {
			req := httptest.NewRequest(http.MethodGet, "/", nil)
			if header != "" {
				req.Header.Set("Authorization", header)
			}
			rec := httptest.NewRecorder()
			handler(t).ServeHTTP(rec, req)
			if rec.Code != http.StatusUnauthorized {
				t.Fatalf("got %d, want 401", rec.Code)
			}
			if !strings.Contains(rec.Body.String(), `"unauthenticated"`) || rec.Header().Get("WWW-Authenticate") == "" {
				t.Fatalf("bad 401 body or headers: %q", rec.Body.String())
			}
		})
	}
}

func TestUIDFromContextWithoutMiddlewareIsEmpty(t *testing.T) {
	if UIDFromContext(context.Background()) != "" {
		t.Fatal("expected empty uid")
	}
}
