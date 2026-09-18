# Panwise

Panwise (working name, bundle id `app.panwise`, see ADR 0003) is an AI-centred recipe app: a user's food profile steers generated recipes, which they then save, organise, rate and cook from.

## Language

### Food profile

**Constraint**:
A hard rule about food the user will never accept violated, such as an allergy, a diet like vegan or kosher, or an excluded ingredient class like seed oils. A generated recipe that breaks a Constraint is invalid.
_Avoid_: Restriction, dietary restriction, sensitivity, hard preference

**Preference**:
A soft signal that steers generation without forbidding anything: liked and disliked ingredients, textures, macro leanings like high protein or high fibre, qualities like filling or voluminous.
_Avoid_: Taste, like/dislike, soft constraint

### Generation

**Generation Request**:
Everything sent to the model to produce one recipe: the user's Constraints and Preferences, the Generation Limits for this request, and a free-text ask like "something Asian for tonight".
_Avoid_: Query, prompt (the prompt is the internal text built from a Generation Request)

**Generation Limit**:
A per-request cap on the shape of a recipe: time to make (Active Time plus Passive Time), number of ingredients, number of pieces of cookware. Part of a Generation Request, not stored on the profile.
_Avoid_: Constraint (reserved for hard food rules), filter, quota

**Draft**:
A recipe the model has produced that the user has not yet saved. A Draft is refined or discarded; only saving turns it into a Recipe, which keeps the Draft's id. A Draft has the same content as a Recipe and knows nothing about the Generation Request behind it.
_Avoid_: Generated recipe, result, suggestion

**Refinement**:
An instruction applied to a Draft ("make it spicier", "swap the tofu for chicken") that yields a new Draft with its own id.
_Avoid_: Edit, regenerate, tweak

### Recipes

**Recipe**:
A saved dish owned by a user: a title and short description, servings, Ingredients, ordered Steps, Active Time and Passive Time, cookware, Estimated Macros, a Cuisine, Meal Types and a Cover. It is identified by an id that is unique across all users plus a revision number, and it can be shown from its own content alone, without the owner's profile, Rating or Collections. The shape is `schema/recipe.schema.json` (ADR 0004).
_Avoid_: Dish, meal, card

**Ingredient**:
One line of a Recipe: the ingredient's name alone ("onion"), a quantity and unit, how it is prepared ("finely diced"), and optionally the group it is listed under ("For the sauce"). Quantities are stored in metric or kitchen measures (g, ml, tsp, tbsp, or a count such as clove) and converted when shown; "to taste" is an Ingredient with no quantity.
_Avoid_: Item, component, ingredient line

**Step**:
One instruction of a Recipe, in order. A Step names the Ingredients it uses instead of repeating their quantities, and may carry a timer and a cooking temperature, so the app can show amounts and temperatures in the viewer's Unit System.
_Avoid_: Instruction, direction, stage

**Active Time**:
Minutes of hands-on work in a Recipe.
_Avoid_: Prep time (it also covers hands-on cooking)

**Passive Time**:
Minutes a Recipe takes unattended: baking, resting, marinating. Active Time plus Passive Time is the time to make.
_Avoid_: Cook time, wait time

**Estimated Macros**:
Calories, protein, carbohydrate, fat and fibre per serving, guessed by the model and always labelled as an estimate.
_Avoid_: Nutrition, nutrition facts, macros (unqualified)

**Cuisine**:
The one culinary tradition the model assigns to a Recipe, as free text ("Thai").

**Meal Type**:
When a Recipe is eaten: breakfast, lunch, dinner, snack, dessert or drink. A Recipe can have several. Cuisine and Meal Type are the only classification a Recipe carries; it makes no dietary claims such as "vegan" or "nut-free".
_Avoid_: Course, tag, category

**Unit System**:
The viewer's choice of metric or imperial, defaulted from locale. It changes how a Recipe is shown, never how it is stored.
_Avoid_: Units setting, measurement system

**Cover**:
The visual that represents a Recipe. By default an emoji chosen by the model when the recipe was generated; the user may replace it with a photo.
_Avoid_: Image, thumbnail, icon, picture

**Collection**:
A flat, user-named grouping of Recipes. A Recipe can belong to many Collections.
_Avoid_: Folder, tag, playlist, category

**Rating**:
One to five stars a user gives a Recipe, with an optional note.
_Avoid_: Score, review, like

**Cooking Session**:
An in-progress, step-by-step walk through a Recipe that remembers where the user is. Designed to hold several Recipes at once in a later version.
_Avoid_: Cooking mode (that is the screen, not the state), cook

### Plans

**Plan**:
What a user is entitled to: Free or Paid. The Plan sets the Quota and the cap on saved Recipes, and gates nothing else. The Paid Plan is sold as "Panwise Plus"; the entitlements are recorded on #5.
_Avoid_: Tier, level, subscription (see below)

**Subscription**:
The store purchase that grants the Paid Plan while it is active.
_Avoid_: Plan, membership, premium

**Quota**:
The number of generations a Plan allows within a week, counted from the user's first generation of that week. A Refinement is not charged against Quota, but a Draft can be refined only a few times before the user has to generate again.
_Avoid_: Generation limit (reserved for per-request caps), allowance, credits
