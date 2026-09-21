# Issue #16: proposed screen map

Status: **Index (variant A) selected on 21 September 2026** for [issue #16](https://github.com/CommRogue/recipe-app/issues/16). The [archived clickable artifact](https://github.com/CommRogue/recipe-app/blob/prototype/issue-16-index/docs/design/issue-16-prototype.html) includes the feedback iteration. This map is the navigation handoff, not a claim that the production flows have been implemented.

## Scope and evidence

Phone app for Android and iOS, built in Flutter. Typography leads; emoji Covers provide visual recognition without recipe photography. The map follows `CONTEXT.md`, ADRs 0004–0006, and the decisions recorded on issue #1. Production feature implementation belongs to later tickets.

The developer chose saved Recipes as the initial screen and clickable code as the artifact format. Proposed primary destinations are Recipes, Generate, and Profile; each stays one tap away from the other root destinations. Collections live within Recipes, not behind Profile or an account menu.

## Navigation

Depth counts screens pushed above a root destination. Sheets count as one additional level while open. Switching destinations does not add to the back stack. Route names are proposals, not changes to the existing router.

| Screen | Entry and depth | Main actions and exit |
| --- | --- | --- |
| Recipes `/recipes` | Root, 0 | Search inline; open a Recipe; switch to Collections; resume an active Cooking Session |
| Collections | Segment within Recipes, 0 | Open or create a Collection |
| Collection `/collections/:id` | Recipes → Collection, 1 | Open a Recipe; rename or delete grouping without deleting Recipes |
| Recipe `/recipes/:id` | Recipes → Recipe, 1; via Collection, 2 | Cook, Rate, organise into Collections; Ingredients and Steps in the same scroll |
| Cooking Session `/sessions/:id` | Recipe → Cook, 2; via Collection, 3 | Step progress, relevant Ingredient amounts, timer where present; previous/next; exit preserves progress |
| Generate `/generate` | Root, 0 | Free-text ask, inline Generation Limits, Profile summary, Generate |
| Overrides | Generate → sheet, 1 | Switch Profile entries off or add One-off Constraints; clearly scoped to this Draft Chain; confirm disabling an allergen |
| Recent Draft Chains | Inline list on Generate, 0 | Resume an unsaved Draft; show expiry, retained for seven days |
| Draft `/draft-chains/:chainId/drafts/:id` | Generate → Draft, 1 | Save, Refine, Report, discard; no checked/safe/matches-Profile claim |
| Refinement | Draft → sheet, 2 | Instruction and remaining Refinements; successful response replaces displayed Draft, with access to previous Drafts |
| Profile `/profile` | Root, 0 | Constraints and Preferences, with clear hard-rule versus soft-signal copy |
| Profile entry editor | Profile → sheet, 1 | Listed Constraint toggles or verbatim Custom Constraint/Preference text |
| Account `/account` | Profile → Account, 1 | Unit System, Plan and Quota, purchases/restore, sign out, privacy/terms, deletion and export entry points |
| Panwise Plus `/plan` | Account → Plan, 2; directly from a reached cap, 1 | Explain generation and saved-Recipe caps; store purchase/restore; dismiss to the interrupted task |
| Rating / Collection membership | Recipe → sheet, 2; via Collection, 3 | One to five stars with optional note / multiple Collection selection; save and return |
| Report | Draft → sheet, 2 | Include “breaks one of my Constraints”; submit and return to the same Draft |

Native back navigation returns to the actual origin, preserving list search, scroll, form input, and Draft Chain context. After saving a Draft, display the saved Recipe without creating another copy or an ever-growing stack. Cooking mode uses its own focused controls; leaving it exposes a one-tap Resume action at the roots. Route identifiers remain in paths rather than object-only navigation payloads.

## Tap budget

From Recipes, excluding scrolling, typing and first-use consent: open a visible Recipe in one tap; start cooking it in two; resume a Cooking Session in one; reach the Generation Request form or Profile in one. From Generate, submit an already entered request in one tap and save a delivered Draft in one more. Organising or rating a visible Recipe takes two taps to reach the editor, then the input and Save. Collection navigation adds one tap to Recipe and cooking paths.

Keep search on the Recipes screen, all three Generation Limits on the request form, and Ingredients alongside Steps. Avoid a dashboard between the user and these tasks. A Recipe detail page shows title, Cover, description, servings, Active Time, Passive Time, cookware, Cuisine, Meal Types, and Estimated Macros labelled as estimates per serving.

## First use and exceptional states

- Sign in → one skippable screen of diet/allergen toggles → chosen root. Before the first Generation Request is sent, show the consent screen described by issue #13. Declining leaves saved Recipes accessible. Exact onboarding choreography remains a follow-up decision.
- Empty Recipes: a direct Generate action; no fabricated recommendations. Empty Profile remains valid.
- Generation in progress: preserve the ask and Overrides, show progress without an invented percentage, and prevent duplicate submission. Failure with no delivered Draft charges no Quota; retain the request for retry.
- Unsaved Draft: make its status and expiry visible. Saving failure keeps the Draft and offers retry. A Refinement failure preserves the previous Draft and does not consume a Refinement.
- Reached generation Quota: show the actual next reset time and Plan route. Three-Refinement cap: preserve Save and reading, explain that a new Generation Request is needed to continue refining.
- Saved-Recipe cap: keep the Draft available; offer management of saved Recipes and the Plan route. A Paid Plan lapse must not block reading or cooking existing Recipes.
- Offline: cached Recipes and an existing Cooking Session remain usable where supported; generation explains that a connection is needed. Never present pending writes as confirmed server success.
- Destructive actions name their target and consequences. Account deletion and export behavior require the separate account-flow specification; this map reserves their entry points without inventing policy.

## Open review questions

1. Resolved: Index (variant A), selected by the developer. No elements from Shelf or Tempo were requested.
2. Iteration: dedicate the default preview to Index; preserve library position on return; resume the same Recipe's Cooking Session rather than restart it. Search and the three root destinations remain directly accessible.
3. Issue #16 says no recipe photography in v1, while the existing domain allows user-supplied photo Covers. The artifact will use emoji only; removing the photo capability from v1 requires an explicit scope decision, not an accidental visual-design change.

The scope question about user-supplied photo Covers is separate from the chosen visual direction. The prototype and accepted default use emoji; implementation must not silently remove the existing photo capability decision.
