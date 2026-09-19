package generate

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/CommRogue/recipe-app/backend/internal/profile"
	"github.com/CommRogue/recipe-app/backend/internal/prompt"
	"github.com/CommRogue/recipe-app/backend/internal/recipe"
)

type fakeProfiles struct {
	p   profile.Profile
	err error
}

func (f fakeProfiles) Load(context.Context, string) (profile.Profile, error) { return f.p, f.err }

type fakeGenerator struct {
	body   json.RawMessage
	err    error
	gotPr  prompt.Prompt
	called int
}

func (f *fakeGenerator) GenerateRecipe(_ context.Context, p prompt.Prompt) (json.RawMessage, Usage, error) {
	f.called++
	f.gotPr = p
	return f.body, Usage{Model: "fake"}, f.err
}

type recordingStore struct {
	uid       string
	effective profile.EffectiveSet
	version   string
}

func (r *recordingStore) StoreFirstDraft(_ context.Context, uid string, _ *recipe.Draft, e profile.EffectiveSet, v string) (string, error) {
	r.uid, r.effective, r.version = uid, e, v
	return "chain-1", nil
}

// exampleBody is the example Draft with the service-owned fields stripped, as
// the model would return it.
func exampleBody(t *testing.T) json.RawMessage {
	t.Helper()
	raw, err := os.ReadFile("../recipe/testdata/draft.json")
	if err != nil {
		t.Fatal(err)
	}
	var m map[string]any
	if err := json.Unmarshal(raw, &m); err != nil {
		t.Fatal(err)
	}
	for _, k := range []string{"id", "schemaVersion", "source", "createdAt"} {
		delete(m, k)
	}
	b, _ := json.Marshal(m)
	return b
}

func newService(gen *fakeGenerator, profiles profile.Loader, store DraftStore) *Service {
	fixed := time.Date(2026, 9, 19, 12, 0, 0, 0, time.UTC)
	return &Service{
		Profiles:  profiles,
		Quota:     AlwaysAllow{},
		Generator: gen,
		Store:     store,
		Log:       slog.New(slog.NewTextHandler(io.Discard, nil)),
		Now:       func() time.Time { return fixed },
		NewID:     func() (string, error) { return "01994f5e-7c3a-7b2e-9d41-5a6f0c2e8b17", nil },
	}
}

func TestGenerateHappyPathComposesAValidDraft(t *testing.T) {
	gen := &fakeGenerator{body: exampleBody(t)}
	store := &recordingStore{}
	svc := newService(gen, fakeProfiles{p: profile.Profile{Listed: []string{"allergen.peanuts"}}}, store)

	six := 6
	res, err := svc.Generate(context.Background(), "user-1", Request{Ask: "noodles", Limits: Limits{MaxIngredients: &six}})
	if err != nil {
		t.Fatal(err)
	}
	d := res.Draft
	if d.ID != "01994f5e-7c3a-7b2e-9d41-5a6f0c2e8b17" || d.SchemaVersion != 1 || d.Source.Kind != "generated" {
		t.Fatalf("service-owned fields wrong: %+v", d)
	}
	if !d.CreatedAt.Equal(time.Date(2026, 9, 19, 12, 0, 0, 0, time.UTC)) {
		t.Fatalf("createdAt %v", d.CreatedAt)
	}
	if d.Cover.Kind != "emoji" || d.Macros.Source != "model_estimate" {
		t.Fatalf("post-process must pin cover.kind and macros.source: %+v %+v", d.Cover, d.Macros)
	}
	encoded, _ := json.Marshal(d)
	if err := recipe.ValidateDraft(encoded); err != nil {
		t.Fatalf("delivered draft must validate: %v", err)
	}
	if res.ChainID != "chain-1" || store.uid != "user-1" || store.version != prompt.Version {
		t.Fatalf("store not called correctly: %+v", store)
	}
	if !strings.Contains(gen.gotPr.User, "No peanuts") || !strings.Contains(gen.gotPr.User, "At most 6 ingredients") {
		t.Fatalf("prompt did not carry the profile and limits:\n%s", gen.gotPr.User)
	}
	if res.Usage.PromptVersion != prompt.Version {
		t.Fatalf("usage should carry the prompt version: %+v", res.Usage)
	}
}

func TestGenerateAppliesOverridesBeforeThePrompt(t *testing.T) {
	gen := &fakeGenerator{body: exampleBody(t)}
	store := &recordingStore{}
	p := profile.Profile{Listed: []string{"allergen.peanuts"}, Liked: map[string]string{"l1": "garlic"}}
	svc := newService(gen, fakeProfiles{p: p}, store)

	_, err := svc.Generate(context.Background(), "u", Request{Overrides: Overrides{
		Off: []string{"allergen.peanuts", "l1"}, AddCustom: []string{"no mushrooms"},
	}})
	if err != nil {
		t.Fatal(err)
	}
	if strings.Contains(gen.gotPr.User, "peanut") || strings.Contains(gen.gotPr.User, "garlic") {
		t.Fatalf("switched-off entries leaked into the prompt:\n%s", gen.gotPr.User)
	}
	if !strings.Contains(gen.gotPr.User, `"no mushrooms"`) {
		t.Fatalf("one-off constraint missing:\n%s", gen.gotPr.User)
	}
	if len(store.effective.Listed) != 0 || len(store.effective.CustomConstraints) != 1 {
		t.Fatalf("effective set handed to the store is wrong: %+v", store.effective)
	}
}

func TestGenerateRejectsInvalidRequestBeforeLoadingAnything(t *testing.T) {
	gen := &fakeGenerator{body: exampleBody(t)}
	svc := newService(gen, fakeProfiles{err: errors.New("must not be called")}, NopDraftStore{})
	zero := 0
	_, err := svc.Generate(context.Background(), "u", Request{Limits: Limits{MaxCookware: &zero}})
	if !errors.Is(err, ErrInvalidRequest) {
		t.Fatalf("want ErrInvalidRequest, got %v", err)
	}
	if gen.called != 0 {
		t.Fatal("model must not be called for an invalid request")
	}
}

func TestGenerateMapsModelFailureToUnavailable(t *testing.T) {
	gen := &fakeGenerator{err: errors.New("429 resource exhausted")}
	svc := newService(gen, fakeProfiles{}, NopDraftStore{})
	_, err := svc.Generate(context.Background(), "u", Request{})
	if !errors.Is(err, ErrModelUnavailable) {
		t.Fatalf("want ErrModelUnavailable, got %v", err)
	}
}

func TestGenerateRejectsAnInvalidDraftFromTheModel(t *testing.T) {
	var m map[string]any
	_ = json.Unmarshal(exampleBody(t), &m)
	steps := m["steps"].([]any)
	steps[0].(map[string]any)["ingredientIds"] = []any{"i1", "i42"}
	bad, _ := json.Marshal(m)

	svc := newService(&fakeGenerator{body: bad}, fakeProfiles{}, NopDraftStore{})
	_, err := svc.Generate(context.Background(), "u", Request{})
	if !errors.Is(err, ErrModelOutput) || !strings.Contains(err.Error(), "i42") {
		t.Fatalf("want ErrModelOutput naming i42, got %v", err)
	}
}

func TestGenerateRejectsNonJSONFromTheModel(t *testing.T) {
	svc := newService(&fakeGenerator{body: json.RawMessage("Sure! Here is a recipe")}, fakeProfiles{}, NopDraftStore{})
	_, err := svc.Generate(context.Background(), "u", Request{})
	if !errors.Is(err, ErrModelOutput) {
		t.Fatalf("want ErrModelOutput, got %v", err)
	}
}

func TestGenerateSurvivesAFailingStore(t *testing.T) {
	svc := newService(&fakeGenerator{body: exampleBody(t)}, fakeProfiles{}, failingStore{})
	res, err := svc.Generate(context.Background(), "u", Request{})
	if err != nil || res.Draft == nil || res.ChainID != "" {
		t.Fatalf("a store failure must not lose the Draft: %v %+v", err, res)
	}
}

func TestGenerateDefaultsTheSeamsAndRecordsTheChargeKind(t *testing.T) {
	svc := &Service{
		Profiles:  fakeProfiles{},
		Generator: &fakeGenerator{body: exampleBody(t)},
		Log:       slog.New(slog.NewTextHandler(io.Discard, nil)),
	}
	res, err := svc.Generate(context.Background(), "u", Request{})
	if err != nil {
		t.Fatalf("a Service with only Profiles and Generator set must work: %v", err)
	}
	if res.Usage.Kind != ChargeKindGeneration {
		t.Fatalf("usage kind %q", res.Usage.Kind)
	}
	if res.ChainID != "" {
		t.Fatal("the default store must store nothing")
	}
}

type failingStore struct{}

func (failingStore) StoreFirstDraft(context.Context, string, *recipe.Draft, profile.EffectiveSet, string) (string, error) {
	return "", errors.New("firestore down")
}

func TestRequestValidate(t *testing.T) {
	one, big := 1, 10_000
	cases := map[string]struct {
		req Request
		ok  bool
	}{
		"empty":                {Request{}, true},
		"long ask":             {Request{Ask: strings.Repeat("a", MaxAskChars+1)}, false},
		"limits at 1":          {Request{Limits: Limits{MaxTotalMinutes: &one, MaxIngredients: &one, MaxCookware: &one}}, true},
		"minutes too big":      {Request{Limits: Limits{MaxTotalMinutes: &big}}, false},
		"unknown catalogue id": {Request{Overrides: Overrides{AddListed: []string{"allergen.nope"}}}, false},
		"known catalogue id":   {Request{Overrides: Overrides{AddListed: []string{"allergen.soy"}}}, true},
		"blank custom":         {Request{Overrides: Overrides{AddCustom: []string{"  "}}}, false},
		"long custom":          {Request{Overrides: Overrides{AddCustom: []string{strings.Repeat("x", 81)}}}, false},
		"too many custom":      {Request{Overrides: Overrides{AddCustom: make([]string, 21)}}, false},
	}
	for name, c := range cases {
		t.Run(name, func(t *testing.T) {
			err := c.req.Validate()
			if (err == nil) != c.ok {
				t.Fatalf("ok=%v err=%v", c.ok, err)
			}
			if err != nil && !errors.Is(err, ErrInvalidRequest) {
				t.Fatalf("validation errors must wrap ErrInvalidRequest: %v", err)
			}
		})
	}
}
