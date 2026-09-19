package gemini

import (
	"google.golang.org/genai"

	"github.com/CommRogue/recipe-app/backend/internal/recipe"
)

// BodySchema is the response schema for a recipe Body, hand-written as a
// flat genai.Schema rather than derived from schema/recipe.schema.json:
// Vertex AI rejects schemas it finds too complex (#10), and the JSON Schema
// uses $ref, oneOf and const that the OpenAPI subset does not carry. The JSON
// Schema stays the validator (recipe.ValidateDraft); a test keeps the two in
// step on property names and enums.
//
// Fields the service owns (id, schemaVersion, source, createdAt) are not
// asked of the model. minItems and maxItems are left out on purpose: Vertex
// AI answers a bare 400 INVALID_ARGUMENT when the schema carries them
// (verified against gemini-3.8-flash on 2026-09-19); the validator enforces
// the list bounds instead.
func BodySchema() *genai.Schema {
	nullable := genai.Ptr(true)
	return &genai.Schema{
		Type: genai.TypeObject,
		Properties: map[string]*genai.Schema{
			"title":       {Type: genai.TypeString, Description: "At most 80 characters."},
			"description": {Type: genai.TypeString, Description: "One or two sentences, at most 240 characters. Names any swap made to honour a hard rule."},
			"servings":    {Type: genai.TypeNumber, Description: "Number of servings the quantities make."},
			"activeMinutes": {
				Type: genai.TypeInteger, Description: "Hands-on minutes.",
			},
			"passiveMinutes": {
				Type: genai.TypeInteger, Description: "Unattended minutes: baking, resting, marinating.",
			},
			"ingredients": {
				Type: genai.TypeArray,
				Items: &genai.Schema{
					Type: genai.TypeObject,
					Properties: map[string]*genai.Schema{
						"id":       {Type: genai.TypeString, Description: "i1, i2, i3 ... in list order."},
						"name":     {Type: genai.TypeString, Description: "The ingredient alone, no quantity or preparation."},
						"quantity": {Type: genai.TypeNumber, Nullable: nullable, Description: "Null together with unit when there is no amount."},
						"unit": {
							Type: genai.TypeString, Format: "enum", Enum: recipe.Units, Nullable: nullable,
						},
						"preparation": {Type: genai.TypeString, Nullable: nullable, Description: "How it is prepared or used; 'to taste' or 'for greasing' when quantity is null."},
						"group":       {Type: genai.TypeString, Nullable: nullable, Description: "Heading the ingredient is listed under, such as 'For the sauce', or null."},
						"optional":    {Type: genai.TypeBoolean},
					},
					Required:         []string{"id", "name", "quantity", "unit", "preparation", "group", "optional"},
					PropertyOrdering: []string{"id", "name", "quantity", "unit", "preparation", "group", "optional"},
				},
			},
			"steps": {
				Type: genai.TypeArray,
				Items: &genai.Schema{
					Type: genai.TypeObject,
					Properties: map[string]*genai.Schema{
						"text":          {Type: genai.TypeString, Description: "The instruction, without quantities or temperatures."},
						"ingredientIds": {Type: genai.TypeArray, Items: &genai.Schema{Type: genai.TypeString}, Description: "Ids of the ingredients first used in this step."},
						"timerSeconds":  {Type: genai.TypeInteger, Nullable: nullable, Description: "Only for a real wait; null otherwise."},
						"temperatureC":  {Type: genai.TypeNumber, Nullable: nullable, Description: "Oven, oil or pan temperature in Celsius; null when none."},
					},
					Required:         []string{"text", "ingredientIds", "timerSeconds", "temperatureC"},
					PropertyOrdering: []string{"text", "ingredientIds", "timerSeconds", "temperatureC"},
				},
			},
			"cookware": {
				Type: genai.TypeArray,
				Items: &genai.Schema{
					Type:       genai.TypeObject,
					Properties: map[string]*genai.Schema{"name": {Type: genai.TypeString}},
					Required:   []string{"name"},
				},
			},
			"macros": {
				Type:        genai.TypeObject,
				Description: "Per serving, your best estimate.",
				Properties: map[string]*genai.Schema{
					"source":   {Type: genai.TypeString, Format: "enum", Enum: []string{recipe.MacrosSourceModelEstimate}},
					"calories": {Type: genai.TypeNumber, Description: "kcal"},
					"proteinG": {Type: genai.TypeNumber},
					"carbsG":   {Type: genai.TypeNumber},
					"fatG":     {Type: genai.TypeNumber},
					"fibreG":   {Type: genai.TypeNumber},
				},
				Required:         []string{"source", "calories", "proteinG", "carbsG", "fatG", "fibreG"},
				PropertyOrdering: []string{"source", "calories", "proteinG", "carbsG", "fatG", "fibreG"},
			},
			"cuisine":   {Type: genai.TypeString, Description: "One culinary tradition, such as 'Thai'."},
			"mealTypes": {Type: genai.TypeArray, Items: &genai.Schema{Type: genai.TypeString, Format: "enum", Enum: recipe.MealTypes}},
			"cover": {
				Type: genai.TypeObject,
				Properties: map[string]*genai.Schema{
					"kind":  {Type: genai.TypeString, Format: "enum", Enum: []string{recipe.CoverKindEmoji}},
					"emoji": {Type: genai.TypeString, Description: "One emoji that represents the dish."},
				},
				Required: []string{"kind", "emoji"},
			},
		},
		Required: []string{
			"title", "description", "servings", "activeMinutes", "passiveMinutes",
			"ingredients", "steps", "cookware", "macros", "cuisine", "mealTypes", "cover",
		},
		PropertyOrdering: []string{
			"title", "description", "cuisine", "mealTypes", "servings", "activeMinutes", "passiveMinutes",
			"cookware", "ingredients", "steps", "macros", "cover",
		},
	}
}
