---
status: accepted
---

# A Recipe is stored metric with Steps linked to Ingredients, and keeps the id its Draft was given

The Recipe shape is the contract between Go and Dart (ADR 0002), is written by the client straight into Firestore (ADR 0001), and every saved Recipe carries it forever, so three choices in it are expensive to change later. The shape is `schema/recipe.schema.json`.

**Units.** An Ingredient's unit comes from a closed set: `g`, `ml`, `tsp`, `tbsp` and a few counts (`piece`, `clove`, `slice`, `sprig`, `bunch`, `pinch`), or null with a null quantity for "to taste". The model always emits these. The Unit System toggle converts `g` and `ml` when a Recipe is shown and leaves spoons and counts alone. There is no volume-to-weight conversion and no density table.

**Steps.** Step text cannot be converted, so it carries no ingredient quantities and no cooking temperatures. Ingredients have short ids (`i1`, `i2`), a Step lists the `ingredientIds` it first uses and an optional `temperatureC` and `timerSeconds`, and the app renders the amounts and temperature beside the Step in the viewer's Unit System. The Go post-process stage rejects a Draft whose references do not resolve. An ingredient used in two portions is two Ingredients, usually under different groups. Lengths have no structured home and are written in both systems in the text.

**Identity.** The Go service mints a UUIDv7 for every Draft. Saving writes the Recipe under that same id, so a repeated save cannot create a duplicate and a Draft can be referred to (the Report action from #13) before it is saved. A Refinement yields a Draft with a new id. A Recipe is identified by id plus `revision`; a later shared or imported copy gets a fresh id and points back through `source.derivedFrom`.

## Considered options

- The model emits both metric and imperial quantities: friendlier imperial numbers for flour and the like, rejected because the two can disagree and later shopping-list and scaling maths would have two sources of truth.
- Store whatever Unit System was active at generation: simplest prompt, rejected because the library becomes inconsistent and sharing inherits it.
- Plain Step text with both units written inline: simplest schema, rejected because it ignores the toggle, is noisy, and makes scaling servings impossible later.
- Every Step has a duration and totals are summed: one source of truth, rejected because models estimate trivial steps badly and parallel steps make the sum wrong. The Recipe carries `activeMinutes` and `passiveMinutes` and a Step has a timer only for a real wait; the two are not reconciled.
- Firestore auto-id minted by the client at save: less for the service to do, rejected because saves are not idempotent and Drafts are unaddressable.
- Model-emitted dietary flags (vegan, nut-free): useful filters, rejected because shown to a user they are an allergen claim the app cannot back. Whether a Draft honours the user's Constraints is decided in #21 and stays out of the recipe body.
- Open-vocabulary tags: rejected for v1 because the vocabulary drifts; Cuisine and a closed Meal Type set are the only classification, and users organise with Collections.

## Consequences

- An imperial viewer sees "8.8 oz flour", not "2 cups". Accepted; weight is the better instruction anyway.
- The prompt must teach the conventions (no quantities or temperatures in Step text, split portions into separate Ingredients, water as an Ingredient when measured), and the golden set must check them. This goes to the prompt-design work under "Not yet specified" on the map.
- The Cooking Session (#20) can show "for this Step" amounts, and servings scaling becomes a display-time multiplication if it is ever wanted.
- Draft and Recipe share one body. Nothing about the Generation Request is in it (H16); ownership, `revision`, `savedAt` and `updatedAt` are added on save. Rating and Collection membership are owner-private and placed by #22.
- `revision` goes up only when content a cook would notice changes. Replacing the Cover touches `updatedAt` only. v1 cannot change content, so `revision` is always 1.
- Readers ignore unknown fields and every enum names its fallback for unknown values (H19), so an older app survives a newer Recipe. `schemaVersion` is 1.
- Drafts are addressable by id; where they live until saved or discarded is for #19 and #22.
