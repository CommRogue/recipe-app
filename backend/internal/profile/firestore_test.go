package profile

import (
	"reflect"
	"testing"
)

func TestFromDocumentDataIgnoresNonStringEntries(t *testing.T) {
	data := map[string]any{
		"listed":            []any{"diet.vegan", 42, "allergen.soy"},
		"customConstraints": map[string]any{"c1": "no seed oils", "c2": 7, "c3": map[string]any{"x": 1}},
		"liked":             "not a map",
		"qualities":         nil,
	}
	got := FromDocumentData(data)
	want := Profile{
		Listed:            []string{"diet.vegan", "allergen.soy"},
		CustomConstraints: map[string]string{"c1": "no seed oils"},
	}
	if !reflect.DeepEqual(got, want) {
		t.Fatalf("got %+v\nwant %+v", got, want)
	}
}

func TestFromDocumentDataOnEmptyDocumentIsEmptyProfile(t *testing.T) {
	got := FromDocumentData(map[string]any{})
	if !Apply(got, Overrides{}).IsEmpty() {
		t.Fatalf("expected empty, got %+v", got)
	}
}
