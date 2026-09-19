package httpapi

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/CommRogue/recipe-app/backend/internal/auth"
	"github.com/CommRogue/recipe-app/backend/internal/generate"
	"github.com/CommRogue/recipe-app/backend/internal/profile"
	"github.com/CommRogue/recipe-app/backend/internal/prompt"
)

type fakeVerifier struct{}

func (fakeVerifier) Verify(_ context.Context, token string) (string, error) {
	if token == "ok" {
		return "user-1", nil
	}
	return "", auth.ErrInvalidToken
}

type fakeProfiles struct{}

func (fakeProfiles) Load(context.Context, string) (profile.Profile, error) {
	return profile.Profile{}, nil
}

type fakeGenerator struct {
	body json.RawMessage
	err  error
}

func (f fakeGenerator) GenerateRecipe(context.Context, prompt.Prompt) (json.RawMessage, generate.Usage, error) {
	return f.body, generate.Usage{}, f.err
}

func exampleBody(t *testing.T) json.RawMessage {
	t.Helper()
	raw, err := os.ReadFile("../recipe/testdata/draft.json")
	if err != nil {
		t.Fatal(err)
	}
	var m map[string]any
	_ = json.Unmarshal(raw, &m)
	for _, k := range []string{"id", "schemaVersion", "source", "createdAt"} {
		delete(m, k)
	}
	b, _ := json.Marshal(m)
	return b
}

func newHandler(t *testing.T, gen generate.Generator) http.Handler {
	t.Helper()
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	svc := &generate.Service{
		Profiles:  fakeProfiles{},
		Quota:     generate.AlwaysAllow{},
		Generator: gen,
		Store:     generate.NopDraftStore{},
		Log:       log,
		Now:       func() time.Time { return time.Date(2026, 9, 19, 12, 0, 0, 0, time.UTC) },
	}
	return NewHandler(Deps{Verifier: fakeVerifier{}, Generate: svc, Log: log})
}

func post(h http.Handler, token, body string) *httptest.ResponseRecorder {
	req := httptest.NewRequest(http.MethodPost, "/v1/generate", strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	return rec
}

func TestHealthzIsOpen(t *testing.T) {
	h := newHandler(t, fakeGenerator{})
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/healthz", nil))
	if rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"ok"`) {
		t.Fatalf("%d %s", rec.Code, rec.Body.String())
	}
}

func TestGenerateNeedsAToken(t *testing.T) {
	h := newHandler(t, fakeGenerator{body: exampleBody(t)})
	if rec := post(h, "", `{"ask":"x"}`); rec.Code != http.StatusUnauthorized {
		t.Fatalf("no token: %d", rec.Code)
	}
	if rec := post(h, "bad", `{"ask":"x"}`); rec.Code != http.StatusUnauthorized {
		t.Fatalf("bad token: %d", rec.Code)
	}
}

func TestGenerateReturnsTheDraftInAnEnvelope(t *testing.T) {
	h := newHandler(t, fakeGenerator{body: exampleBody(t)})
	rec := post(h, "ok", `{"ask":"something Asian for tonight","limits":{"maxTotalMinutes":30},"futureField":1}`)
	if rec.Code != http.StatusOK {
		t.Fatalf("%d %s", rec.Code, rec.Body.String())
	}
	var out struct {
		Draft struct {
			ID            string `json:"id"`
			SchemaVersion int    `json:"schemaVersion"`
			Title         string `json:"title"`
			CreatedAt     string `json:"createdAt"`
		} `json:"draft"`
		ChainID *string `json:"chainId"`
	}
	if err := json.Unmarshal(rec.Body.Bytes(), &out); err != nil {
		t.Fatal(err)
	}
	if out.Draft.ID == "" || out.Draft.SchemaVersion != 1 || out.Draft.Title == "" || out.Draft.CreatedAt != "2026-09-19T12:00:00Z" {
		t.Fatalf("unexpected envelope: %s", rec.Body.String())
	}
	if out.ChainID != nil {
		t.Fatal("chainId should be omitted while nothing is stored")
	}
	if ct := rec.Header().Get("Content-Type"); ct != "application/json" {
		t.Fatalf("content type %q", ct)
	}
}

func TestGenerateStatusCodes(t *testing.T) {
	cases := []struct {
		name string
		gen  generate.Generator
		body string
		want int
		code string
	}{
		{"malformed json", fakeGenerator{body: exampleBody(t)}, `{"ask":`, 400, "invalid_argument"},
		{"wrong type", fakeGenerator{body: exampleBody(t)}, `{"ask":42}`, 400, "invalid_argument"},
		{"empty body", fakeGenerator{body: exampleBody(t)}, ``, 400, "invalid_argument"},
		{"limit out of range", fakeGenerator{body: exampleBody(t)}, `{"limits":{"maxCookware":0}}`, 400, "invalid_argument"},
		{"model down", fakeGenerator{err: errors.New("boom")}, `{}`, 503, "model_unavailable"},
		{"model garbage", fakeGenerator{body: json.RawMessage(`{"title":"x"}`)}, `{}`, 502, "no_draft"},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			rec := post(newHandler(t, c.gen), "ok", c.body)
			if rec.Code != c.want {
				t.Fatalf("status %d want %d: %s", rec.Code, c.want, rec.Body.String())
			}
			var eb errorBody
			if err := json.Unmarshal(rec.Body.Bytes(), &eb); err != nil || eb.Error.Code != c.code {
				t.Fatalf("error code %q want %q (%v): %s", eb.Error.Code, c.code, err, rec.Body.String())
			}
			if c.want >= 500 && strings.Contains(eb.Error.Message, "boom") {
				t.Fatal("internal detail leaked into a 5xx message")
			}
		})
	}
}

func TestGenerateRejectsOversizedBody(t *testing.T) {
	h := newHandler(t, fakeGenerator{body: exampleBody(t)})
	big := `{"ask":"` + strings.Repeat("a", MaxRequestBody) + `"}`
	if rec := post(h, "ok", big); rec.Code != http.StatusBadRequest {
		t.Fatalf("%d", rec.Code)
	}
}

func TestUnknownRouteIs404(t *testing.T) {
	h := newHandler(t, fakeGenerator{})
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/v1/nope", nil))
	if rec.Code != http.StatusNotFound {
		t.Fatalf("%d", rec.Code)
	}
}
