package recipe

import (
	"bytes"
	"encoding/json"
	"fmt"
	"regexp"
	"strings"
	"sync"

	"github.com/santhosh-tekuri/jsonschema/v6"
	"golang.org/x/text/language"
	"golang.org/x/text/message"
)

var englishPrinter = message.NewPrinter(language.English)

// ValidationError reports why a Draft failed the structural post-process
// check. The message is meant for logs, not for users.
type ValidationError struct {
	Problems []string
}

func (e *ValidationError) Error() string {
	return "draft failed validation: " + strings.Join(e.Problems, "; ")
}

var ingredientIDPattern = regexp.MustCompile(`^i[0-9]+$`)

var (
	compileOnce sync.Once
	draftSchema *jsonschema.Schema
	compileErr  error
)

func compiledDraftSchema() (*jsonschema.Schema, error) {
	compileOnce.Do(func() {
		doc, err := jsonschema.UnmarshalJSON(bytes.NewReader(SchemaJSON))
		if err != nil {
			compileErr = fmt.Errorf("parse embedded schema: %w", err)
			return
		}
		c := jsonschema.NewCompiler()
		c.AssertFormat()
		const url = "https://panwise.app/schema/recipe.schema.json"
		if err := c.AddResource(url, doc); err != nil {
			compileErr = fmt.Errorf("add embedded schema: %w", err)
			return
		}
		draftSchema, compileErr = c.Compile(url + "#/$defs/Draft")
	})
	return draftSchema, compileErr
}

// ValidateDraft is the structural check of the post-process stage (ADR 0004,
// ADR 0006): the JSON must satisfy the Draft definition of the contract, every
// Step.ingredientIds entry must name an existing Ingredient, and Ingredient
// ids must be unique. It checks nothing about Constraints (ADR 0006).
func ValidateDraft(draftJSON []byte) error {
	sch, err := compiledDraftSchema()
	if err != nil {
		return err
	}
	inst, err := jsonschema.UnmarshalJSON(bytes.NewReader(draftJSON))
	if err != nil {
		return &ValidationError{Problems: []string{"not valid JSON: " + err.Error()}}
	}
	var problems []string
	if err := sch.Validate(inst); err != nil {
		problems = append(problems, schemaProblems(err)...)
	}

	var d Draft
	if err := json.Unmarshal(draftJSON, &d); err != nil {
		problems = append(problems, "does not decode into Draft: "+err.Error())
		return &ValidationError{Problems: problems}
	}
	problems = append(problems, referenceProblems(&d.Body)...)
	if len(problems) > 0 {
		return &ValidationError{Problems: problems}
	}
	return nil
}

// referenceProblems checks what the JSON Schema cannot express: unique
// Ingredient ids and resolvable Step references.
func referenceProblems(b *Body) []string {
	var problems []string
	ids := make(map[string]bool, len(b.Ingredients))
	for _, ing := range b.Ingredients {
		if !ingredientIDPattern.MatchString(ing.ID) {
			problems = append(problems, fmt.Sprintf("ingredient id %q does not match ^i[0-9]+$", ing.ID))
			continue
		}
		if ids[ing.ID] {
			problems = append(problems, fmt.Sprintf("duplicate ingredient id %q", ing.ID))
		}
		ids[ing.ID] = true
	}
	for i, st := range b.Steps {
		for _, ref := range st.IngredientIDs {
			if !ids[ref] {
				problems = append(problems, fmt.Sprintf("step %d references unknown ingredient %q", i+1, ref))
			}
		}
	}
	return problems
}

func schemaProblems(err error) []string {
	verr, ok := err.(*jsonschema.ValidationError)
	if !ok {
		return []string{err.Error()}
	}
	var out []string
	var walk func(v *jsonschema.ValidationError)
	walk = func(v *jsonschema.ValidationError) {
		if len(v.Causes) == 0 {
			loc := "/" + strings.Join(v.InstanceLocation, "/")
			out = append(out, fmt.Sprintf("%s: %s", loc, v.ErrorKind.LocalizedString(englishPrinter)))
			return
		}
		for _, c := range v.Causes {
			walk(c)
		}
	}
	walk(verr)
	return out
}
