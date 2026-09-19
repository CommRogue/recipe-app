// Command server is the Panwise Go service (ADR 0002): one Cloud Run service
// that turns a Generation Request into a Draft. It verifies Firebase ID
// tokens, loads the Profile from Firestore, calls Gemini on Vertex AI and
// returns the Draft; everything else is client-direct Firestore (ADR 0001).
package main

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"cloud.google.com/go/compute/metadata"
	"cloud.google.com/go/firestore"

	"github.com/CommRogue/recipe-app/backend/internal/auth"
	"github.com/CommRogue/recipe-app/backend/internal/gemini"
	"github.com/CommRogue/recipe-app/backend/internal/generate"
	"github.com/CommRogue/recipe-app/backend/internal/httpapi"
	"github.com/CommRogue/recipe-app/backend/internal/profile"
)

func main() {
	log := newLogger(os.Getenv("LOG_LEVEL"))
	slog.SetDefault(log)
	if err := run(log); err != nil {
		log.Error("server exited", "error", err.Error())
		os.Exit(1)
	}
}

func run(log *slog.Logger) error {
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	project, err := projectID(ctx)
	if err != nil {
		return err
	}
	port := envOr("PORT", "8080")

	verifier, err := auth.NewFirebaseVerifier(ctx, project)
	if err != nil {
		return fmt.Errorf("firebase auth: %w", err)
	}
	fs, err := firestore.NewClient(ctx, project)
	if err != nil {
		return fmt.Errorf("firestore: %w", err)
	}
	defer fs.Close()

	gen, err := gemini.New(ctx, gemini.Config{
		Project:       project,
		Location:      envOr("VERTEX_LOCATION", gemini.DefaultLocation),
		Model:         envOr("GEMINI_MODEL", gemini.DefaultModel),
		ThinkingLevel: os.Getenv("GEMINI_THINKING_LEVEL"),
	})
	if err != nil {
		return err
	}

	svc := &generate.Service{
		Profiles:  profile.FirestoreLoader{Client: fs},
		Quota:     generate.AlwaysAllow{},
		Generator: gen,
		Store:     generate.NopDraftStore{},
		Log:       log,
	}
	handler := httpapi.NewHandler(httpapi.Deps{Verifier: verifier, Generate: svc, Log: log})

	srv := &http.Server{
		Addr:              ":" + port,
		Handler:           handler,
		ReadHeaderTimeout: 10 * time.Second,
		ReadTimeout:       30 * time.Second,
		WriteTimeout:      120 * time.Second,
		IdleTimeout:       120 * time.Second,
	}

	errc := make(chan error, 1)
	go func() {
		log.Info("listening", "port", port, "project", project, "model", gen.Model())
		errc <- srv.ListenAndServe()
	}()

	select {
	case err := <-errc:
		if !errors.Is(err, http.ErrServerClosed) {
			return err
		}
	case <-ctx.Done():
		log.Info("shutting down")
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 25*time.Second)
		defer cancel()
		if err := srv.Shutdown(shutdownCtx); err != nil {
			return fmt.Errorf("shutdown: %w", err)
		}
	}
	return nil
}

// projectID comes from GOOGLE_CLOUD_PROJECT, or from the metadata server on
// Cloud Run, which does not set that variable by itself.
func projectID(ctx context.Context) (string, error) {
	if p := os.Getenv("GOOGLE_CLOUD_PROJECT"); p != "" {
		return p, nil
	}
	if metadata.OnGCE() {
		p, err := metadata.ProjectIDWithContext(ctx)
		if err == nil && p != "" {
			return p, nil
		}
	}
	return "", errors.New("GOOGLE_CLOUD_PROJECT is not set and no metadata server is available")
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

// newLogger writes JSON that Cloud Logging parses: severity and message
// instead of slog's level and msg.
func newLogger(level string) *slog.Logger {
	var lvl slog.Level
	switch strings.ToLower(level) {
	case "debug":
		lvl = slog.LevelDebug
	case "warn", "warning":
		lvl = slog.LevelWarn
	case "error":
		lvl = slog.LevelError
	default:
		lvl = slog.LevelInfo
	}
	h := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: lvl,
		ReplaceAttr: func(_ []string, a slog.Attr) slog.Attr {
			switch a.Key {
			case slog.LevelKey:
				a.Key = "severity"
				if l, ok := a.Value.Any().(slog.Level); ok && l == slog.LevelWarn {
					a.Value = slog.StringValue("WARNING")
				}
			case slog.MessageKey:
				a.Key = "message"
			}
			return a
		},
	})
	return slog.New(h)
}
