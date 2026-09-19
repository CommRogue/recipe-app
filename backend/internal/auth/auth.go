// Package auth verifies Firebase ID tokens on incoming requests (ADR 0002,
// H20). Every API route is called with `Authorization: Bearer <ID token>`,
// from any client, not only the mobile app.
package auth

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"strings"

	firebase "firebase.google.com/go/v4"
	firebaseauth "firebase.google.com/go/v4/auth"
)

// Verifier checks an ID token and returns the uid it was issued to.
type Verifier interface {
	Verify(ctx context.Context, idToken string) (uid string, err error)
}

// ErrInvalidToken is returned by a Verifier for a token that is malformed,
// expired, revoked or issued for another project.
var ErrInvalidToken = errors.New("invalid ID token")

// FirebaseVerifier verifies tokens with the Firebase Admin SDK, which fetches
// and caches Google's public keys and checks issuer, audience and expiry.
type FirebaseVerifier struct {
	client *firebaseauth.Client
}

// NewFirebaseVerifier builds a verifier for projectID. On Cloud Run the
// Admin SDK uses the runtime service account; verifying tokens needs no IAM
// permission, only the project id.
func NewFirebaseVerifier(ctx context.Context, projectID string) (*FirebaseVerifier, error) {
	app, err := firebase.NewApp(ctx, &firebase.Config{ProjectID: projectID})
	if err != nil {
		return nil, err
	}
	client, err := app.Auth(ctx)
	if err != nil {
		return nil, err
	}
	return &FirebaseVerifier{client: client}, nil
}

// Verify implements Verifier.
func (v *FirebaseVerifier) Verify(ctx context.Context, idToken string) (string, error) {
	tok, err := v.client.VerifyIDToken(ctx, idToken)
	if err != nil {
		return "", errors.Join(ErrInvalidToken, err)
	}
	return tok.UID, nil
}

type ctxKey struct{}

// UIDFromContext returns the verified uid the Middleware stored, or "" when
// the request did not pass through it.
func UIDFromContext(ctx context.Context) string {
	uid, _ := ctx.Value(ctxKey{}).(string)
	return uid
}

// ContextWithUID is for tests and internal callers that bypass the
// middleware.
func ContextWithUID(ctx context.Context, uid string) context.Context {
	return context.WithValue(ctx, ctxKey{}, uid)
}

// Middleware rejects requests without a valid bearer token with 401 and puts
// the uid of the rest in the request context.
func Middleware(v Verifier, log *slog.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			token, ok := bearerToken(r.Header.Get("Authorization"))
			if !ok {
				unauthorized(w, "missing bearer token")
				return
			}
			uid, err := v.Verify(r.Context(), token)
			if err != nil {
				log.InfoContext(r.Context(), "rejected ID token", "error", err.Error())
				unauthorized(w, "invalid or expired token")
				return
			}
			next.ServeHTTP(w, r.WithContext(ContextWithUID(r.Context(), uid)))
		})
	}
}

func bearerToken(header string) (string, bool) {
	const prefix = "bearer "
	if len(header) <= len(prefix) || !strings.EqualFold(header[:len(prefix)], prefix) {
		return "", false
	}
	token := strings.TrimSpace(header[len(prefix):])
	return token, token != ""
}

func unauthorized(w http.ResponseWriter, msg string) {
	w.Header().Set("WWW-Authenticate", `Bearer realm="panwise"`)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusUnauthorized)
	_, _ = w.Write([]byte(`{"error":{"code":"unauthenticated","message":"` + msg + `"}}` + "\n"))
}
