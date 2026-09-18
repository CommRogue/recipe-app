---
status: accepted
---

# Constraints are honoured by the prompt alone; a Draft is not checked after generation

A Draft that breaks a Constraint is invalid, and the question was what stands behind that. In v1 the answer is the prompt and nothing else: the hard-rules block built from the effective Constraint set (ADR 0005) is the only guard. The Go service runs no deterministic ingredient check, no second model pass, and no repair loop, and a Draft is returned as the model produced it once the structural post-process has passed (ADR 0004). The developer chose this over a recommended lexicon-plus-checker mix, trusting the generated recipe. What that mix would have cost is under the considered options.

**No claim is made.** Because nothing is checked, nothing in the app says or implies that a Draft or Recipe was checked, verified or is safe for a Constraint: no badge, no "matches your Profile" line. This is the same stance as ADR 0004's refusal of model-emitted dietary flags. The consent screen before the first Generation Request (#13) carries the allergy disclaimer and tells the user to read the Ingredients.

**The Report action is the feedback path.** A Draft that breaks a Constraint is reported through the Report action (#13), which offers "breaks one of my Constraints" as a reason. The Draft is addressable by id (ADR 0004) and the effective set is on the Draft chain record, so a report can be judged after the fact.

**Quota.** A generation is charged only when a Draft is delivered. A Generation Request that ends with no Draft (model error, a Draft rejected by the structural post-process) charges nothing, and a Refinement that yields no Draft does not use up one of the three Refinements of its chain.

**No snapshot.** A saved Recipe keeps nothing about the Constraints it was generated under. With no validation there is no verdict to record, and the recipe body stays free of the Generation Request (H5, H16).

## Considered options

- A deterministic term lexicon per Listed Constraint plus a cheap model checker over the whole effective set, repairing once and refusing on a second failure: the recommended option, not taken for v1. It would add a model call and one to two seconds to every Draft, a worst case of two generations, and a lexicon to maintain that can never be complete (pesto, surimi, Worcestershire sauce) and whose false positives (eggplant, coconut milk, nutmeg) turn into refusals.
- Model checker only: no lexicon to maintain, rejected with the above; it also doubles the model calls per Draft.
- Lexicon for Listed Constraints only: cheapest check, rejected because it makes the allergen check the weakest one and cannot express kosher or halal.
- Showing a failing Draft with a warning: never a dead end, moot without a check.
- An owner-private snapshot of the effective set on the saved Recipe, so the app could later say "made before you added your sesame Constraint": rejected with validation; it cannot be backfilled, which is accepted.

## Consequences

- Constraint adherence is now wholly a prompt-quality matter. The golden set in the prompt-design work (map, not yet specified) must measure it per catalogue id and for Custom Constraints, including colliding asks ("peanut noodles" with a peanut Constraint) and hidden sources (tahini, fish sauce, Worcestershire sauce), and a prompt version does not ship if adherence regresses. Kosher and halal need the most cases.
- Where ADR 0005 says a Refinement is "generated and validated against" the effective set, read "generated against". The effective set still lives on the Draft chain record, because Refinement prompts are built from it.
- The post-process stage stays a place in the pipeline (H14) and does structural checks only. A Constraint check can be added there later without changing the Draft contract or the client: the endpoint already may answer with no Draft.
- `schema/constraint-catalogue.json` carries labels and ids only; no ingredient terms are added per id.
- The generate endpoint needs no "refused for a Constraint" outcome, and #19 needs no warning or refusal state for one. It still needs the generic "no Draft came back" state.
- Reports with the Constraint reason are the only production signal of adherence; the observability work (map, not yet specified) should count them per prompt version.
