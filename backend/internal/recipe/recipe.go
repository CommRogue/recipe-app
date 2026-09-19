// Package recipe holds the Go side of the Go-to-Dart recipe contract
// (schema/recipe.schema.json, ADR 0002, ADR 0004): the Draft type the service
// returns and the structural validator the post-process stage runs on every
// Draft the model produces.
//
// A Draft holds nothing about the Generation Request that produced it (H16).
package recipe

import (
	_ "embed"
	"time"
)

// SchemaJSON is a byte-identical copy of schema/recipe.schema.json, embedded so
// the binary carries its own contract. A test asserts it has not drifted.
//
//go:embed recipe.schema.json
var SchemaJSON []byte

// SchemaVersion is the value of Draft.schemaVersion this service writes.
const SchemaVersion = 1

// Units is the closed, metric-canonical unit set (ADR 0004).
var Units = []string{"g", "ml", "tsp", "tbsp", "piece", "clove", "slice", "sprig", "bunch", "pinch"}

// MealTypes is the closed Meal Type set.
var MealTypes = []string{"breakfast", "lunch", "dinner", "snack", "dessert", "drink"}

// Draft is what the Go service returns: a Body plus identity and provenance.
type Draft struct {
	ID            string    `json:"id"`
	SchemaVersion int       `json:"schemaVersion"`
	Source        Source    `json:"source"`
	CreatedAt     time.Time `json:"createdAt"`
	Body
}

// Body is the recipe content shared by a Draft and a Recipe. It is what the
// model is asked to produce.
type Body struct {
	Title          string       `json:"title"`
	Description    string       `json:"description"`
	Servings       float64      `json:"servings"`
	ActiveMinutes  int          `json:"activeMinutes"`
	PassiveMinutes int          `json:"passiveMinutes"`
	Ingredients    []Ingredient `json:"ingredients"`
	Steps          []Step       `json:"steps"`
	Cookware       []Cookware   `json:"cookware"`
	Macros         Macros       `json:"macros"`
	Cuisine        *string      `json:"cuisine"`
	MealTypes      []string     `json:"mealTypes"`
	Cover          Cover        `json:"cover"`
}

// Ingredient is one line of a recipe: the name alone, a quantity in a closed
// unit set, how it is prepared, and the group it is listed under.
type Ingredient struct {
	ID          string   `json:"id"`
	Name        string   `json:"name"`
	Quantity    *float64 `json:"quantity"`
	Unit        *string  `json:"unit"`
	Preparation *string  `json:"preparation,omitempty"`
	Group       *string  `json:"group,omitempty"`
	Optional    bool     `json:"optional,omitempty"`
}

// Step names the Ingredients it first uses by id and carries no quantities or
// temperatures in its text (ADR 0004).
type Step struct {
	Text          string   `json:"text"`
	IngredientIDs []string `json:"ingredientIds"`
	TimerSeconds  *int     `json:"timerSeconds,omitempty"`
	TemperatureC  *float64 `json:"temperatureC,omitempty"`
}

// Cookware is one piece of cookware.
type Cookware struct {
	Name string `json:"name"`
}

// Macros are the Estimated Macros per serving. Source drives the "estimate"
// label in the app (H3).
type Macros struct {
	Source   string  `json:"source"`
	Calories float64 `json:"calories"`
	ProteinG float64 `json:"proteinG"`
	CarbsG   float64 `json:"carbsG"`
	FatG     float64 `json:"fatG"`
	FibreG   float64 `json:"fibreG"`
}

// MacrosSourceModelEstimate is the only macros source v1 writes.
const MacrosSourceModelEstimate = "model_estimate"

// Cover is the tagged visual of a recipe. A Draft always has kind "emoji".
type Cover struct {
	Kind      string  `json:"kind"`
	Emoji     string  `json:"emoji"`
	PhotoPath *string `json:"photoPath,omitempty"`
}

// CoverKindEmoji is the Cover kind every Draft carries.
const CoverKindEmoji = "emoji"

// Source is the provenance of a Draft or Recipe (H4). v1 writes only
// kind "generated".
type Source struct {
	Kind        string       `json:"kind"`
	URL         *string      `json:"url,omitempty"`
	Attribution *string      `json:"attribution,omitempty"`
	DerivedFrom *DerivedFrom `json:"derivedFrom,omitempty"`
}

// SourceKindGenerated is the only Source kind v1 writes.
const SourceKindGenerated = "generated"

// DerivedFrom points at the Recipe a Recipe was copied from. Never set in v1.
type DerivedFrom struct {
	RecipeID string `json:"recipeId"`
	Revision int    `json:"revision"`
}
