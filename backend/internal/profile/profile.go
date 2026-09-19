// Package profile holds the Profile (ADR 0005, docs/firestore-data-model.md):
// the Constraints and Preferences a user has stored, the Overrides a
// Generation Request applies to it, and the effective set the prompt is built
// from.
//
// Free-text entries are maps from entry id to the verbatim text. Entry ids
// sort in creation order, so key order is display order. Rules bound these
// maps as totals only; this package is the exact enforcer of the per-entry
// 80-character cap and the per-member counts.
package profile

import (
	"slices"
	"unicode/utf8"
)

// Caps from ADR 0005 and docs/firestore-data-model.md.
const (
	CapListed            = 40
	CapCustomConstraints = 20
	CapLiked             = 30
	CapDisliked          = 30
	CapQualities         = 20
	MaxEntryChars        = 80
)

// Profile is users/{uid}/profile/default. A zero Profile is the empty
// Profile, which is valid.
type Profile struct {
	// Listed holds catalogue ids (schema/constraint-catalogue.json). Unknown
	// ids are kept here (H19); the prompt stage skips what it cannot render.
	Listed            []string
	CustomConstraints map[string]string
	Liked             map[string]string
	Disliked          map[string]string
	Qualities         map[string]string
}

// Overrides are the deltas a Generation Request applies to the Profile for
// one Draft Chain (ADR 0005). Nothing here is written back.
type Overrides struct {
	// Off names catalogue ids in Listed or entry ids in any free-text map.
	Off []string
	// AddListed adds One-off Listed Constraints by catalogue id.
	AddListed []string
	// AddCustom adds One-off Custom Constraints in the user's words.
	AddCustom []string
}

// EffectiveSet is the Profile after Overrides, flattened to what the prompt
// needs: ordered texts, no entry ids.
type EffectiveSet struct {
	Listed            []string
	CustomConstraints []string
	Liked             []string
	Disliked          []string
	Qualities         []string
}

// IsEmpty reports whether nothing constrains or steers generation.
func (e EffectiveSet) IsEmpty() bool {
	return len(e.Listed)+len(e.CustomConstraints)+len(e.Liked)+len(e.Disliked)+len(e.Qualities) == 0
}

// Normalized returns the Profile with the exact caps applied: an entry over
// MaxEntryChars runes is dropped, then entries beyond each cap are dropped in
// key order, and Listed is deduped and capped in stored order.
func (p Profile) Normalized() Profile {
	return Profile{
		Listed:            capListed(p.Listed),
		CustomConstraints: capEntries(p.CustomConstraints, CapCustomConstraints),
		Liked:             capEntries(p.Liked, CapLiked),
		Disliked:          capEntries(p.Disliked, CapDisliked),
		Qualities:         capEntries(p.Qualities, CapQualities),
	}
}

// Apply builds the effective set: Normalized Profile, minus everything named
// in Overrides.Off, plus the One-off Constraints, with the caps applied again.
func Apply(p Profile, o Overrides) EffectiveSet {
	p = p.Normalized()
	off := make(map[string]bool, len(o.Off))
	for _, id := range o.Off {
		off[id] = true
	}

	listed := make([]string, 0, len(p.Listed)+len(o.AddListed))
	for _, id := range p.Listed {
		if !off[id] {
			listed = append(listed, id)
		}
	}
	listed = capListed(append(listed, o.AddListed...))

	custom := textsInKeyOrder(p.CustomConstraints, off)
	for _, text := range o.AddCustom {
		if utf8.RuneCountInString(text) <= MaxEntryChars && text != "" {
			custom = append(custom, text)
		}
	}
	if len(custom) > CapCustomConstraints {
		custom = custom[:CapCustomConstraints]
	}

	return EffectiveSet{
		Listed:            listed,
		CustomConstraints: custom,
		Liked:             textsInKeyOrder(p.Liked, off),
		Disliked:          textsInKeyOrder(p.Disliked, off),
		Qualities:         textsInKeyOrder(p.Qualities, off),
	}
}

func capListed(ids []string) []string {
	out := make([]string, 0, min(len(ids), CapListed))
	seen := make(map[string]bool, len(ids))
	for _, id := range ids {
		if id == "" || seen[id] {
			continue
		}
		seen[id] = true
		out = append(out, id)
		if len(out) == CapListed {
			break
		}
	}
	return out
}

func sortedKeys(m map[string]string) []string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	slices.Sort(keys)
	return keys
}

// capEntries drops entries whose text is empty or over MaxEntryChars runes,
// then keeps the first limit entries in key order.
func capEntries(m map[string]string, limit int) map[string]string {
	if len(m) == 0 {
		return nil
	}
	out := make(map[string]string, min(len(m), limit))
	for _, k := range sortedKeys(m) {
		text := m[k]
		if text == "" || utf8.RuneCountInString(text) > MaxEntryChars {
			continue
		}
		out[k] = text
		if len(out) == limit {
			break
		}
	}
	return out
}

func textsInKeyOrder(m map[string]string, off map[string]bool) []string {
	out := make([]string, 0, len(m))
	for _, k := range sortedKeys(m) {
		if !off[k] {
			out = append(out, m[k])
		}
	}
	return out
}
