// Package generate is the staged generation pipeline of the Go service (H14):
// verify the user, load the Profile, apply Overrides, check consent and
// Quota, build the prompt, call the model, post-process, store, return.
//
// Each stage is its own function, the model sits behind Generator, and
// persistence sits behind DraftStore, so later endpoints (Refinement, ideas,
// imports) reuse the stages they need and the not-yet-specified work (Quota
// accounting, Draft Chains, consent) drops into its seam.
package generate

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"time"

	"github.com/google/uuid"

	"github.com/CommRogue/recipe-app/backend/internal/profile"
	"github.com/CommRogue/recipe-app/backend/internal/prompt"
	"github.com/CommRogue/recipe-app/backend/internal/recipe"
)

// Generator turns a rendered prompt into the JSON of a recipe Body. It is the
// only stage that talks to a model.
type Generator interface {
	GenerateRecipe(ctx context.Context, p prompt.Prompt) (body json.RawMessage, usage Usage, err error)
}

// ChargeKind names what kind of operation a model call was, so a Quota
// charge can weigh it (H15, #5). The scaffold only ever generates.
type ChargeKind string

// ChargeKindGeneration is a full recipe generation.
const ChargeKindGeneration ChargeKind = "generation"

// Usage is what a model call cost, for logs and, later, Quota charges by
// kind (H15).
type Usage struct {
	Kind              ChargeKind
	Model             string
	PromptTokens      int
	CandidateTokens   int
	ThoughtTokens     int
	TotalTokens       int
	ModelLatency      time.Duration
	PromptVersion     string
	FinishReason      string
	ResponseTruncated bool
}

// DraftStore is the persistence seam for Draft Chains (ADR 0007). The
// scaffold only has NopDraftStore; writing users/{uid}/draftChains/** with
// the 7-day expireAt is implementation work behind #25.
type DraftStore interface {
	// StoreFirstDraft records a Draft as the start of a new Draft Chain and
	// returns the chain id, or "" when nothing is stored.
	StoreFirstDraft(ctx context.Context, uid string, d *recipe.Draft, effective profile.EffectiveSet, promptVersion string) (chainID string, err error)
}

// NopDraftStore stores nothing.
type NopDraftStore struct{}

// StoreFirstDraft implements DraftStore.
func (NopDraftStore) StoreFirstDraft(context.Context, string, *recipe.Draft, profile.EffectiveSet, string) (string, error) {
	return "", nil
}

// QuotaChecker is the Quota seam. The Quota rules (#5: rolling week, charges
// with kind and weight, 3 Refinements per chain) are decided but the
// accounting lives in users/{uid}/server/quota and is not yet specified on
// the map, so the scaffold ships AlwaysAllow only. A real checker reserves a
// charge here and confirms it only once a Draft is delivered (ADR 0006).
type QuotaChecker interface {
	Check(ctx context.Context, uid string) error
}

// AlwaysAllow is the QuotaChecker of the scaffold.
type AlwaysAllow struct{}

// Check implements QuotaChecker.
func (AlwaysAllow) Check(context.Context, string) error { return nil }

// Errors the HTTP layer maps to status codes.
var (
	// ErrModelOutput means the model answered but not with a valid Draft; 502.
	ErrModelOutput = errors.New("model output is not a valid Draft")
	// ErrModelUnavailable means the model call itself failed; 503.
	ErrModelUnavailable = errors.New("model call failed")
	// ErrQuotaExceeded is reserved for the QuotaChecker; 429.
	ErrQuotaExceeded = errors.New("quota exceeded")
	// ErrConsentRequired is reserved for the consent stage; 403.
	ErrConsentRequired = errors.New("consent required")
)

// Service wires the stages.
type Service struct {
	Profiles  profile.Loader
	Quota     QuotaChecker
	Generator Generator
	Store     DraftStore
	Log       *slog.Logger
	// Now is injectable for tests.
	Now func() time.Time
	// NewID mints Draft ids; UUIDv7 in production (ADR 0004).
	NewID func() (string, error)
}

// Result is a delivered Draft plus what the caller may want to log or, later,
// charge.
type Result struct {
	Draft   *recipe.Draft
	ChainID string
	Usage   Usage
	Prompt  prompt.Prompt
}

// Generate runs the pipeline for one Generation Request from uid.
func (s *Service) Generate(ctx context.Context, uid string, req Request) (*Result, error) {
	log := s.logger().With("uid", uid)

	if err := req.Validate(); err != nil {
		return nil, err
	}

	p, err := s.loadProfile(ctx, uid)
	if err != nil {
		return nil, err
	}
	effective := applyOverrides(p, req)

	if err := s.checkConsent(ctx, uid); err != nil {
		return nil, err
	}
	if err := s.checkQuota(ctx, uid); err != nil {
		return nil, err
	}

	pr := s.buildPrompt(req, effective, log)

	body, usage, err := s.callModel(ctx, pr)
	if err != nil {
		return nil, err
	}
	usage.PromptVersion = pr.Version
	usage.Kind = ChargeKindGeneration

	draft, err := s.postProcess(body, req, log)
	if err != nil {
		return nil, err
	}

	chainID, err := s.store().StoreFirstDraft(ctx, uid, draft, effective, pr.Version)
	if err != nil {
		// The user still gets the Draft; losing the chain record is logged,
		// not fatal, until Draft Chains are implemented for real.
		log.ErrorContext(ctx, "store draft chain", "error", err.Error())
	}

	log.InfoContext(ctx, "draft delivered",
		"draftId", draft.ID, "chainId", chainID, "promptVersion", pr.Version, "model", usage.Model, "kind", usage.Kind,
		"promptTokens", usage.PromptTokens, "candidateTokens", usage.CandidateTokens, "thoughtTokens", usage.ThoughtTokens,
		"modelLatencyMs", usage.ModelLatency.Milliseconds(), "finishReason", usage.FinishReason,
		"responseTruncated", usage.ResponseTruncated)

	return &Result{Draft: draft, ChainID: chainID, Usage: usage, Prompt: pr}, nil
}

// Stage: load the Profile. The service never trusts a client copy (H14).
func (s *Service) loadProfile(ctx context.Context, uid string) (profile.Profile, error) {
	p, err := s.Profiles.Load(ctx, uid)
	if err != nil {
		return profile.Profile{}, fmt.Errorf("load profile: %w", err)
	}
	return p, nil
}

// Stage: apply Overrides to get the effective set (ADR 0005).
func applyOverrides(p profile.Profile, req Request) profile.EffectiveSet {
	return profile.Apply(p, req.profileOverrides())
}

// Stage: consent. docs/firestore-data-model.md says the service refuses a
// Generation Request while users/{uid}.consent is null or older than the
// current consent version. The consent screen (#13) does not exist yet, so
// this stage allows everything; it returns ErrConsentRequired once wired.
func (s *Service) checkConsent(context.Context, string) error { return nil }

// Stage: Quota (seam, see QuotaChecker).
func (s *Service) checkQuota(ctx context.Context, uid string) error {
	if err := s.quota().Check(ctx, uid); err != nil {
		return fmt.Errorf("%w: %v", ErrQuotaExceeded, err)
	}
	return nil
}

// Stage: build the prompt (pure).
func (s *Service) buildPrompt(req Request, effective profile.EffectiveSet, log *slog.Logger) prompt.Prompt {
	pr, skipped := prompt.Build(prompt.Input{Ask: req.Ask, Limits: req.promptLimits(), Effective: effective})
	if len(skipped) > 0 {
		log.Warn("listed constraint ids unknown to this build were skipped", "ids", skipped)
	}
	return pr
}

// Stage: call the model behind the Generator interface.
func (s *Service) callModel(ctx context.Context, pr prompt.Prompt) (json.RawMessage, Usage, error) {
	body, usage, err := s.Generator.GenerateRecipe(ctx, pr)
	if err != nil {
		return nil, usage, fmt.Errorf("%w: %v", ErrModelUnavailable, err)
	}
	return body, usage, nil
}

// Stage: post-process. Compose the Draft around the model's Body, then run the
// structural validator (ADR 0004). No Constraint check (ADR 0006). Generation
// Limits are logged when exceeded, not enforced: whether the service or the
// app reacts to an over-limit Draft is #19's call.
func (s *Service) postProcess(body json.RawMessage, req Request, log *slog.Logger) (*recipe.Draft, error) {
	var b recipe.Body
	if err := json.Unmarshal(body, &b); err != nil {
		log.Warn("model output does not decode", "error", err.Error())
		return nil, fmt.Errorf("%w: %v", ErrModelOutput, err)
	}
	id, err := s.newID()
	if err != nil {
		return nil, fmt.Errorf("mint draft id: %w", err)
	}
	b.Cover.Kind = recipe.CoverKindEmoji
	b.Cover.PhotoPath = nil
	b.Macros.Source = recipe.MacrosSourceModelEstimate
	if b.Cookware == nil {
		b.Cookware = []recipe.Cookware{}
	}
	if b.MealTypes == nil {
		b.MealTypes = []string{}
	}
	draft := &recipe.Draft{
		ID:            id,
		SchemaVersion: recipe.SchemaVersion,
		Source:        recipe.Source{Kind: recipe.SourceKindGenerated},
		CreatedAt:     s.now().UTC().Truncate(time.Second),
		Body:          b,
	}
	encoded, err := json.Marshal(draft)
	if err != nil {
		return nil, fmt.Errorf("encode draft: %w", err)
	}
	if err := recipe.ValidateDraft(encoded); err != nil {
		log.Warn("model output rejected by validator", "error", err.Error())
		return nil, fmt.Errorf("%w: %v", ErrModelOutput, err)
	}
	logLimitOverruns(req.Limits, &b, log)
	return draft, nil
}

func logLimitOverruns(l Limits, b *recipe.Body, log *slog.Logger) {
	if l.MaxTotalMinutes != nil && b.ActiveMinutes+b.PassiveMinutes > *l.MaxTotalMinutes {
		log.Info("draft exceeds time limit", "limit", *l.MaxTotalMinutes, "actual", b.ActiveMinutes+b.PassiveMinutes)
	}
	if l.MaxIngredients != nil && len(b.Ingredients) > *l.MaxIngredients {
		log.Info("draft exceeds ingredient limit", "limit", *l.MaxIngredients, "actual", len(b.Ingredients))
	}
	if l.MaxCookware != nil && len(b.Cookware) > *l.MaxCookware {
		log.Info("draft exceeds cookware limit", "limit", *l.MaxCookware, "actual", len(b.Cookware))
	}
}

// The seams default to their scaffold implementations when unset, so a
// Service{Profiles, Generator} is complete.

func (s *Service) logger() *slog.Logger {
	if s.Log != nil {
		return s.Log
	}
	return slog.Default()
}

func (s *Service) quota() QuotaChecker {
	if s.Quota != nil {
		return s.Quota
	}
	return AlwaysAllow{}
}

func (s *Service) store() DraftStore {
	if s.Store != nil {
		return s.Store
	}
	return NopDraftStore{}
}

func (s *Service) now() time.Time {
	if s.Now != nil {
		return s.Now()
	}
	return time.Now()
}

func (s *Service) newID() (string, error) {
	if s.NewID != nil {
		return s.NewID()
	}
	id, err := uuid.NewV7()
	if err != nil {
		return "", err
	}
	return id.String(), nil
}
