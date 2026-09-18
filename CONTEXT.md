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
A per-request cap on the shape of a recipe: time to make, number of ingredients, number of pieces of cookware. Part of a Generation Request, not stored on the profile.
_Avoid_: Constraint (reserved for hard food rules), filter, quota

**Draft**:
A recipe the model has produced that the user has not yet saved. A Draft is refined or discarded; only saving turns it into a Recipe.
_Avoid_: Generated recipe, result, suggestion

**Refinement**:
An instruction applied to a Draft ("make it spicier", "swap the tofu for chicken") that yields a new Draft.
_Avoid_: Edit, regenerate, tweak

### Recipes

**Recipe**:
A saved dish owned by a user: ingredients with quantities, ordered steps, time, cookware, servings, estimated macros and a Cover.
_Avoid_: Dish, meal, card

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
What a user is entitled to: Free or Paid. The Plan sets the Quota and the cap on saved Recipes.
_Avoid_: Tier, level, subscription (see below)

**Subscription**:
The store purchase that grants the Paid Plan while it is active.
_Avoid_: Plan, membership, premium

**Quota**:
The number of generations a Plan allows within a period.
_Avoid_: Generation limit (reserved for per-request caps), allowance, credits
