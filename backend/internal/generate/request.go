package generate

import (
	"errors"
	"fmt"
	"strings"
	"unicode/utf8"

	"github.com/CommRogue/recipe-app/backend/internal/profile"
	"github.com/CommRogue/recipe-app/backend/internal/prompt"
)

// Request is the wire form of a Generation Request (CONTEXT.md, ADR 0005):
// the ask, the Generation Limits for this request, and the Overrides to the
// user's Profile. The Profile itself is never sent; the service loads it.
type Request struct {
	Ask       string    `json:"ask"`
	Limits    Limits    `json:"limits"`
	Overrides Overrides `json:"overrides"`
}

// Limits are the Generation Limits. A missing or null member means no limit.
type Limits struct {
	MaxTotalMinutes *int `json:"maxTotalMinutes,omitempty"`
	MaxIngredients  *int `json:"maxIngredients,omitempty"`
	MaxCookware     *int `json:"maxCookware,omitempty"`
}

// Overrides are the per-request deltas to the Profile (ADR 0005).
type Overrides struct {
	Off       []string `json:"off,omitempty"`
	AddListed []string `json:"addListed,omitempty"`
	AddCustom []string `json:"addCustom,omitempty"`
}

// Bounds on a request, checked before anything is loaded or called.
const (
	MaxAskChars       = 500
	MaxTotalMinutesHi = 24 * 60
	MaxOffEntries     = 200
)

// ErrInvalidRequest marks a request the client should fix; it maps to 400.
var ErrInvalidRequest = errors.New("invalid generation request")

func invalid(format string, args ...any) error {
	return fmt.Errorf("%w: %s", ErrInvalidRequest, fmt.Sprintf(format, args...))
}

// Validate checks bounds and vocabulary. It does not touch the Profile.
func (r Request) Validate() error {
	if utf8.RuneCountInString(r.Ask) > MaxAskChars {
		return invalid("ask is longer than %d characters", MaxAskChars)
	}
	if err := positiveWithin("limits.maxTotalMinutes", r.Limits.MaxTotalMinutes, MaxTotalMinutesHi); err != nil {
		return err
	}
	if err := positiveWithin("limits.maxIngredients", r.Limits.MaxIngredients, 40); err != nil {
		return err
	}
	if err := positiveWithin("limits.maxCookware", r.Limits.MaxCookware, 15); err != nil {
		return err
	}
	if len(r.Overrides.Off) > MaxOffEntries {
		return invalid("overrides.off has more than %d entries", MaxOffEntries)
	}
	if len(r.Overrides.AddListed) > profile.CapListed {
		return invalid("overrides.addListed has more than %d entries", profile.CapListed)
	}
	// An unknown id here is a 400, while the same id stored in the Profile is
	// kept and skipped (H19, docs/firestore-data-model.md). The asymmetry is
	// deliberate: a One-off Constraint is often a guest's allergy, and
	// dropping it silently is the failure ADR 0005 designed Overrides to
	// avoid, whereas refusing every generation over one stale Profile entry
	// would be worse than skipping it.
	for _, id := range r.Overrides.AddListed {
		if !prompt.IsCatalogueID(id) {
			return invalid("overrides.addListed contains %q, which is not a catalogue id", id)
		}
	}
	if len(r.Overrides.AddCustom) > profile.CapCustomConstraints {
		return invalid("overrides.addCustom has more than %d entries", profile.CapCustomConstraints)
	}
	for _, text := range r.Overrides.AddCustom {
		if strings.TrimSpace(text) == "" {
			return invalid("overrides.addCustom contains an empty entry")
		}
		if utf8.RuneCountInString(text) > profile.MaxEntryChars {
			return invalid("overrides.addCustom entry is longer than %d characters", profile.MaxEntryChars)
		}
	}
	return nil
}

func positiveWithin(name string, v *int, hi int) error {
	if v == nil {
		return nil
	}
	if *v < 1 || *v > hi {
		return invalid("%s must be between 1 and %d", name, hi)
	}
	return nil
}

func (r Request) profileOverrides() profile.Overrides {
	return profile.Overrides{Off: r.Overrides.Off, AddListed: r.Overrides.AddListed, AddCustom: r.Overrides.AddCustom}
}

func (r Request) promptLimits() prompt.Limits {
	return prompt.Limits{MaxTotalMinutes: r.Limits.MaxTotalMinutes, MaxIngredients: r.Limits.MaxIngredients, MaxCookware: r.Limits.MaxCookware}
}
