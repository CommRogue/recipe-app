package profile

import (
	"fmt"
	"reflect"
	"strings"
	"testing"
)

func entries(n int, prefix string) map[string]string {
	m := make(map[string]string, n)
	for i := range n {
		m[fmt.Sprintf("%s%03d", prefix, i)] = fmt.Sprintf("%s entry %d", prefix, i)
	}
	return m
}

func TestNormalizedDropsEntriesOver80Characters(t *testing.T) {
	long := strings.Repeat("é", 81) // 81 runes, more bytes
	ok := strings.Repeat("é", 80)
	p := Profile{Liked: map[string]string{"a": long, "b": ok}}
	got := p.Normalized()
	if _, has := got.Liked["a"]; has {
		t.Fatal("81-rune entry should be dropped")
	}
	if got.Liked["b"] != ok {
		t.Fatal("80-rune entry should survive untouched")
	}
}

func TestNormalizedKeepsOnlyTheFirstEntriesInKeyOrder(t *testing.T) {
	p := Profile{
		CustomConstraints: entries(25, "c"),
		Liked:             entries(31, "l"),
		Disliked:          entries(30, "d"),
		Qualities:         entries(21, "q"),
	}
	got := p.Normalized()
	if len(got.CustomConstraints) != CapCustomConstraints || len(got.Liked) != CapLiked || len(got.Disliked) != 30 || len(got.Qualities) != CapQualities {
		t.Fatalf("caps not applied: %d %d %d %d", len(got.CustomConstraints), len(got.Liked), len(got.Disliked), len(got.Qualities))
	}
	if _, has := got.Liked["l030"]; has {
		t.Fatal("the entry beyond the cap in key order should be the one dropped")
	}
	if _, has := got.Liked["l000"]; !has {
		t.Fatal("the first entry in key order should survive")
	}
}

func TestNormalizedCapsListedAndDedupes(t *testing.T) {
	var listed []string
	for i := range 45 {
		listed = append(listed, fmt.Sprintf("allergen.x%d", i))
	}
	listed = append([]string{"diet.vegan", "diet.vegan"}, listed...)
	got := Profile{Listed: listed}.Normalized()
	if len(got.Listed) != CapListed {
		t.Fatalf("listed should be capped at %d, got %d", CapListed, len(got.Listed))
	}
	if got.Listed[0] != "diet.vegan" || got.Listed[1] == "diet.vegan" {
		t.Fatalf("listed should be deduped in order: %v", got.Listed[:3])
	}
}

func TestApplySwitchesOffListedAndEntriesAndAddsOneOffs(t *testing.T) {
	p := Profile{
		Listed:            []string{"diet.vegan", "allergen.peanuts"},
		CustomConstraints: map[string]string{"c1": "no seed oils", "c2": "no cilantro"},
		Liked:             map[string]string{"l1": "garlic"},
		Disliked:          map[string]string{"d1": "olives"},
		Qualities:         map[string]string{"q1": "high protein", "q2": "crispy"},
	}
	o := Overrides{
		Off:       []string{"diet.vegan", "c2", "q1", "does-not-exist"},
		AddListed: []string{"allergen.tree-nuts", "allergen.peanuts"},
		AddCustom: []string{"no mushrooms"},
	}
	got := Apply(p, o)
	want := EffectiveSet{
		Listed:            []string{"allergen.peanuts", "allergen.tree-nuts"},
		CustomConstraints: []string{"no seed oils", "no mushrooms"},
		Liked:             []string{"garlic"},
		Disliked:          []string{"olives"},
		Qualities:         []string{"crispy"},
	}
	if !reflect.DeepEqual(got, want) {
		t.Fatalf("got %+v\nwant %+v", got, want)
	}
}

func TestApplyOnEmptyProfileIsEmpty(t *testing.T) {
	got := Apply(Profile{}, Overrides{})
	if !got.IsEmpty() {
		t.Fatalf("expected empty effective set, got %+v", got)
	}
}

func TestApplyCapsTheEffectiveSetToo(t *testing.T) {
	p := Profile{CustomConstraints: entries(20, "c")}
	got := Apply(p, Overrides{AddCustom: []string{"one more", "and another"}})
	if len(got.CustomConstraints) != CapCustomConstraints {
		t.Fatalf("one-off Custom Constraints must respect the cap: %d", len(got.CustomConstraints))
	}
}

func TestApplyOrdersFreeTextByEntryID(t *testing.T) {
	p := Profile{Liked: map[string]string{"zz": "later", "aa": "earlier"}}
	got := Apply(p, Overrides{})
	if !reflect.DeepEqual(got.Liked, []string{"earlier", "later"}) {
		t.Fatalf("entries should be in key order: %v", got.Liked)
	}
}
