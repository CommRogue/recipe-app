package gemini

import (
	"encoding/json"
	"reflect"
	"slices"
	"testing"

	"github.com/CommRogue/recipe-app/backend/internal/recipe"
)

// jsonKeys lists the JSON property names of a struct type, so the response
// schema cannot drift from the Go type the post-process stage decodes into.
func jsonKeys(t reflect.Type) []string {
	var keys []string
	for i := range t.NumField() {
		f := t.Field(i)
		if f.Anonymous {
			keys = append(keys, jsonKeys(f.Type)...)
			continue
		}
		tag := f.Tag.Get("json")
		if tag == "" || tag == "-" {
			continue
		}
		if c := indexComma(tag); c >= 0 {
			tag = tag[:c]
		}
		keys = append(keys, tag)
	}
	return keys
}

func indexComma(s string) int {
	for i := range s {
		if s[i] == ',' {
			return i
		}
	}
	return -1
}

func sortedKeys[V any](m map[string]V) []string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	slices.Sort(keys)
	return keys
}

func TestBodySchemaPropertiesMatchTheBodyType(t *testing.T) {
	s := BodySchema()
	want := jsonKeys(reflect.TypeFor[recipe.Body]())
	slices.Sort(want)
	if got := sortedKeys(s.Properties); !reflect.DeepEqual(got, want) {
		t.Fatalf("schema properties %v\nBody fields        %v", got, want)
	}
	if got := slices.Sorted(slices.Values(s.Required)); !reflect.DeepEqual(got, want) {
		t.Fatalf("every Body field must be required of the model: %v vs %v", got, want)
	}

	ing := jsonKeys(reflect.TypeFor[recipe.Ingredient]())
	slices.Sort(ing)
	if got := sortedKeys(s.Properties["ingredients"].Items.Properties); !reflect.DeepEqual(got, ing) {
		t.Fatalf("ingredient properties %v vs %v", got, ing)
	}
	step := jsonKeys(reflect.TypeFor[recipe.Step]())
	slices.Sort(step)
	if got := sortedKeys(s.Properties["steps"].Items.Properties); !reflect.DeepEqual(got, step) {
		t.Fatalf("step properties %v vs %v", got, step)
	}
	macros := jsonKeys(reflect.TypeFor[recipe.Macros]())
	slices.Sort(macros)
	if got := sortedKeys(s.Properties["macros"].Properties); !reflect.DeepEqual(got, macros) {
		t.Fatalf("macros properties %v vs %v", got, macros)
	}
}

func TestBodySchemaEnumsMatchTheContract(t *testing.T) {
	var contract struct {
		Defs struct {
			Unit     struct{ Enum []string } `json:"Unit"`
			MealType struct{ Enum []string } `json:"MealType"`
		} `json:"$defs"`
	}
	if err := json.Unmarshal(recipe.SchemaJSON, &contract); err != nil {
		t.Fatal(err)
	}
	s := BodySchema()
	if got := s.Properties["ingredients"].Items.Properties["unit"].Enum; !reflect.DeepEqual(got, contract.Defs.Unit.Enum) {
		t.Fatalf("unit enum %v vs contract %v", got, contract.Defs.Unit.Enum)
	}
	if got := s.Properties["mealTypes"].Items.Enum; !reflect.DeepEqual(got, contract.Defs.MealType.Enum) {
		t.Fatalf("mealTypes enum %v vs contract %v", got, contract.Defs.MealType.Enum)
	}
}

func TestBodySchemaSerialises(t *testing.T) {
	b, err := json.Marshal(BodySchema())
	if err != nil {
		t.Fatal(err)
	}
	if len(b) > 12_000 {
		t.Fatalf("schema is %d bytes; keep it small, it counts against input tokens on every call", len(b))
	}
}
