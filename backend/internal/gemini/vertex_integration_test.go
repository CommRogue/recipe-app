package gemini

import (
	"context"
	"encoding/json"
	"os"
	"testing"
	"time"

	"github.com/CommRogue/recipe-app/backend/internal/profile"
	"github.com/CommRogue/recipe-app/backend/internal/prompt"
	"github.com/CommRogue/recipe-app/backend/internal/recipe"
)

// TestVertexRoundTrip calls the real model. It runs only with
// RUN_VERTEX_TESTS=1 and Application Default Credentials for a project that
// has Vertex AI enabled (GOOGLE_CLOUD_PROJECT). The deployed service is the
// usual place to exercise this; see scripts/e2e-generate.sh.
func TestVertexRoundTrip(t *testing.T) {
	if os.Getenv("RUN_VERTEX_TESTS") != "1" {
		t.Skip("set RUN_VERTEX_TESTS=1 to call Vertex AI")
	}
	project := os.Getenv("GOOGLE_CLOUD_PROJECT")
	if project == "" {
		t.Fatal("GOOGLE_CLOUD_PROJECT is required")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Minute)
	defer cancel()

	c, err := New(ctx, Config{Project: project, Model: os.Getenv("GEMINI_MODEL")})
	if err != nil {
		t.Fatal(err)
	}
	thirty := 30
	p, _ := prompt.Build(prompt.Input{
		Ask:       "something Asian for tonight",
		Limits:    prompt.Limits{MaxTotalMinutes: &thirty},
		Effective: profile.EffectiveSet{Listed: []string{"allergen.peanuts"}, Qualities: []string{"high protein"}},
	})
	body, usage, err := c.GenerateRecipe(ctx, p)
	if err != nil {
		t.Fatal(err)
	}
	t.Logf("usage: %+v", usage)

	var b recipe.Body
	if err := json.Unmarshal(body, &b); err != nil {
		t.Fatalf("decode: %v\n%s", err, body)
	}
	d := recipe.Draft{ID: "01994f5e-7c3a-7b2e-9d41-5a6f0c2e8b17", SchemaVersion: 1, Source: recipe.Source{Kind: "generated"}, CreatedAt: time.Now().UTC(), Body: b}
	d.Cover.Kind = recipe.CoverKindEmoji
	d.Macros.Source = recipe.MacrosSourceModelEstimate
	enc, _ := json.Marshal(d)
	if err := recipe.ValidateDraft(enc); err != nil {
		t.Fatalf("model output failed the validator: %v\n%s", err, enc)
	}
	t.Logf("draft: %s", enc)
}
