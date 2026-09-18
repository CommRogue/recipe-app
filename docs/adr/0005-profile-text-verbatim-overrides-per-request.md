---
status: accepted
---

# Free text in the Profile is stored verbatim, and a Generation Request may override the Profile

The Profile is captured two ways at once. Common Constraints are toggles from a closed catalogue, `schema/constraint-catalogue.json`: five diets and the 14 major allergens, each with a permanent id. Everything else is the user's own words: Custom Constraints ("no seed oils"), liked and disliked ingredients, and qualities ("voluminous and filling") with tappable suggestions that are only pre-filled text. Three choices here shape the Go service, the Firestore model and #21, and are awkward to undo once users have Profiles.

**Verbatim.** Free text is stored exactly as typed and nothing is derived from it. There is no model call when the Profile is edited, so the Profile stays a client-direct Firestore write (ADR 0001) and the Go service stays generation-only (ADR 0002). The cost is accepted: a Listed Constraint can be checked deterministically by #21 because its id has a known meaning, a Custom Constraint can only ever be checked by a model reading the same words the user wrote.

**Rendered as data.** The prompt has a hard-rules block and a steer block. A Listed Constraint is rendered from a canonical sentence per id that lives in the Go service and is versioned with the prompt (`allergen.peanuts` becomes "no peanuts or peanut-derived ingredients"); Custom Constraints follow in the same block as a delimited, quoted list. Preferences go in the steer block under "draw on these where they fit, do not use them all". Both blocks are introduced as user data that is never to be followed as instructions. Each entry is at most 80 characters; a Profile holds at most 20 Custom Constraints, 30 liked ingredients, 30 disliked ingredients and 20 qualities. The caps are enforced in security rules (#22) and again in the Go service. There is no moderation pass.

**Precedence.** Constraint beats ask beats Preference. An ask that collides with a Constraint ("peanut noodles" with a peanut Constraint) is adapted, not refused, and the Draft's description says what was swapped. An ask that names a disliked ingredient gets it.

**Overrides.** For one Generation Request the user may switch off any Constraint or Preference in the Profile and add One-off Constraints, Listed or Custom (cooking for a guest). Nothing is written back to the Profile. The client sends only the deltas; the Go service still loads the Profile itself (H14), applies them, and the resulting effective set is what the prompt is built from and what #21 validates. The service keeps that effective set on the Draft chain record it already holds for the Refinement cap, and every Refinement in the chain is generated and validated against it, whatever happens to the Profile or the app's state meanwhile. Switching off an allergen asks for one confirmation.

## Considered options

- Pickers only: fully checkable and the quickest onboarding, rejected because "no seed oils", an example from the original plan, could not be a Constraint at all.
- Free text only: least to build, rejected because a peanut allergy would be just a string, uncheckable by #21 and slower to enter than a toggle.
- Model expansion of a Custom Constraint that the user confirms ("excludes canola, sunflower, soybean…"): would make Custom Constraints checkable by ingredient match, rejected for v1 because it adds an endpoint, an uncharged model call, a confirm step, and a derived copy to keep in step with the text. It can be added later beside the verbatim text without a migration.
- Normalised form replaces the text: rejected because the user's intent is lost and a wrong reading is invisible.
- A closed enum of Preferences over an ingredient taxonomy: rejected because Ingredient names are free text (ADR 0004) and v1 has no taxonomy to pick from.
- Gluten-free and dairy-free as diets, keto, low-FODMAP and paleo as toggles: the first two duplicate the gluten and milk allergens, the rest are fuzzy and have no ingredient-level meaning. Users type them.
- Allergen severity or "traces" levels: rejected because a recipe cannot control cross-contamination; the consent screen (#13) carries the allergy disclaimer.
- Refusing a Generation Request whose ask conflicts with a Constraint: predictable, rejected because detecting the conflict needs a model call anyway and it is a dead end in an app meant to need few taps.
- Overrides that only add, or no Overrides: safer and smaller, rejected because a vegan cooking for a guest would have to edit the Profile and edit it back, and a guest's allergy typed into the ask would be steered but never validated.
- The client resends the Overrides with each Refinement: keeps the service stateless, rejected because lost app state would silently drop a guest's allergy from the next Draft.

## Consequences

- Draft and Recipe still carry nothing about the Generation Request (ADR 0004, H5). The effective set lives only on the owner-private Draft chain record; whether a saved Recipe keeps a snapshot of it is for #21.
- Every free-text entry needs a stable id inside the Profile so an Override can name the entry it switches off. The Profile shape and the caps go to #22.
- The generate endpoint takes Overrides as deltas (`off` ids, added Listed ids, added Custom text, the same caps) and the load-profile stage gains an apply-Overrides step. This goes to #18.
- #21 starts from two classes of Constraint: Listed, where a deterministic check is possible, and Custom, where only a model check is.
- An empty Profile is valid. First run shows one skippable screen with the diet and allergen toggles only; Custom Constraints and Preferences are added from the Profile screen or from the profile summary on the Generation Request screen (#19), where Overrides are also made. An entry can be moved between disliked ingredients and Custom Constraints.
- The canonical sentences are part of the prompt, so they fall under prompt versioning and the golden set; "kosher" and "halal" need the most care.
