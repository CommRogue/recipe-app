package recipe

import (
	"bytes"
	"encoding/json"
	"errors"
	"os"
	"strings"
	"testing"
)

func exampleDraft(t *testing.T) []byte {
	t.Helper()
	b, err := os.ReadFile("testdata/draft.json")
	if err != nil {
		t.Fatal(err)
	}
	return b
}

func TestEmbeddedSchemaMatchesRepoContract(t *testing.T) {
	repo, err := os.ReadFile("../../../schema/recipe.schema.json")
	if err != nil {
		t.Fatal(err)
	}
	if !bytes.Equal(repo, SchemaJSON) {
		t.Fatal("internal/recipe/recipe.schema.json differs from schema/recipe.schema.json; copy the repo file over the embedded one")
	}
}

func TestExampleDraftRoundTripsAndValidates(t *testing.T) {
	raw := exampleDraft(t)
	var d Draft
	if err := json.Unmarshal(raw, &d); err != nil {
		t.Fatal(err)
	}
	if d.ID != "01994f5e-7c3a-7b2e-9d41-5a6f0c2e8b17" || d.Title == "" || len(d.Ingredients) != 8 || len(d.Steps) != 4 {
		t.Fatalf("unexpected decode: %+v", d)
	}
	if d.Ingredients[7].Quantity != nil || d.Ingredients[7].Unit != nil || !d.Ingredients[7].Optional {
		t.Fatalf("nullable fields decoded wrongly: %+v", d.Ingredients[7])
	}
	out, err := json.Marshal(d)
	if err != nil {
		t.Fatal(err)
	}
	if err := ValidateDraft(out); err != nil {
		t.Fatalf("re-encoded example draft should validate: %v", err)
	}
}

func TestValidateDraftRejectsDanglingIngredientReference(t *testing.T) {
	d := decode(t, exampleDraft(t))
	d.Steps[0].IngredientIDs = []string{"i1", "i99"}
	err := ValidateDraft(encode(t, d))
	var verr *ValidationError
	if !errors.As(err, &verr) {
		t.Fatalf("want *ValidationError, got %v", err)
	}
	if !strings.Contains(err.Error(), "i99") {
		t.Fatalf("error should name the dangling id: %v", err)
	}
}

func TestValidateDraftRejectsUnknownUnit(t *testing.T) {
	d := decode(t, exampleDraft(t))
	cup := "cup"
	d.Ingredients[0].Unit = &cup
	if err := ValidateDraft(encode(t, d)); err == nil {
		t.Fatal("unit outside the closed set should be rejected")
	}
}

func TestValidateDraftRejectsBadIngredientID(t *testing.T) {
	d := decode(t, exampleDraft(t))
	d.Ingredients[0].ID = "onion"
	if err := ValidateDraft(encode(t, d)); err == nil {
		t.Fatal("ingredient id not matching ^i[0-9]+$ should be rejected")
	}
}

func TestValidateDraftRejectsDuplicateIngredientID(t *testing.T) {
	d := decode(t, exampleDraft(t))
	d.Ingredients[1].ID = "i1"
	err := ValidateDraft(encode(t, d))
	if err == nil || !strings.Contains(err.Error(), "duplicate") {
		t.Fatalf("duplicate ingredient id should be rejected, got %v", err)
	}
}

func TestValidateDraftRejectsMissingRequiredField(t *testing.T) {
	var m map[string]any
	if err := json.Unmarshal(exampleDraft(t), &m); err != nil {
		t.Fatal(err)
	}
	delete(m, "macros")
	b, _ := json.Marshal(m)
	if err := ValidateDraft(b); err == nil {
		t.Fatal("missing macros should be rejected")
	}
}

func TestValidateDraftRejectsNonJSON(t *testing.T) {
	if err := ValidateDraft([]byte("not json")); err == nil {
		t.Fatal("garbage should be rejected")
	}
}

func decode(t *testing.T, b []byte) Draft {
	t.Helper()
	var d Draft
	if err := json.Unmarshal(b, &d); err != nil {
		t.Fatal(err)
	}
	return d
}

func encode(t *testing.T, d Draft) []byte {
	t.Helper()
	b, err := json.Marshal(d)
	if err != nil {
		t.Fatal(err)
	}
	return b
}
