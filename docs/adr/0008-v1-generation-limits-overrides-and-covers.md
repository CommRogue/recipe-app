---
status: accepted
---

# Generation Limits are soft caps, Overrides support Additional Preferences, and photo Covers remain in scope

Resolves scope and contract differences between the v1 prototypes (#16, #19, #20) and foundational decisions (#1, #4, #5, #6, #18, #21), formalising six design choices for v1 implementation.

## 1. Additional Preferences in Overrides

The generation prototype (#19) validated an in-memory list of "Additional preferences" on the Generate screen under "Just this time" (Overrides). This feature is preserved as a soft Preference, not a One-off Constraint.

- **Wire contract**: `overrides.addPreferences []string` in `POST /v1/generate` (and Refinements).
- **Bounds**: At most 20 entries (`CapAdditionalPreferences = 20`), each at most 80 characters (`MaxEntryChars = 80`), non-empty and non-blank.
- **Effective set**: Added to `profile.EffectiveSet.AdditionalPreferences` and rendered verbatim in the prompt's `PREFERENCES` steer block ("Additional preferences for this recipe, in the user's words: ..."). It steers generation without forbidding anything; the ask outranks it.
- **Persistence across Refinements**: Persisted on the server-owned Draft Chain record (`users/{uid}/draftChains/{chainId}`) as part of the chain's effective set (ADR 0005). When refining, the Go service reloads the chain's effective set so the client does not need to resend it. It is never saved to the user's Profile document.

## 2. Generation Limit Overruns

Generation Limits cap the shape of a recipe: time to make (`activeMinutes + passiveMinutes`), number of ingredients (`len(ingredients)`), and pieces of cookware (`len(cookware)`).

- **No automatic retries**: The service does not automatically retry when a generated Draft exceeds a limit. A retry would double latency (from ~18s to ~36s+) and token cost, with no guarantee that a tight limit will be satisfied.
- **Service delivery**: The Go service logs overruns (`logLimitOverruns`) but does not reject structurally valid Drafts.
- **Quota charging**: Charged 1 Quota upon delivery of a complete, structurally valid Draft. Quota is only uncharged when generation fails to return a valid Draft (e.g. 502 no_draft or model unavailability).
- **UI outcome**: The Draft is presented to the user with an explicit limit overrun notice / badge in the recipe metadata (e.g. "35 min (limit was 30 min)"). The user may save it as-is, refine it (e.g. "Cut time to under 30 minutes" using free Refinement), or discard it.

## 3. Slider Ranges, Defaults, and No-Limit Affordance

The accepted demo defaults from #19 are distinguished from the production API contract.

- **Production API contract**: Retains broad validation limits on the wire (`maxTotalMinutes` 1–1440, `maxIngredients` 1–40, `maxCookware` 1–15; `null` = no limit).
- **Native UI slider contract**:
  - **Time**: 15–120 minutes in discrete steps of 5 minutes. Default: 30 minutes.
  - **Ingredients**: 3–20 in discrete steps of 1. Default: 8 ingredients.
  - **Cookware**: 1–6 in discrete steps of 1. Default: 2 pieces.
  - **No-limit affordance**: Each slider provides an explicit "No limit" chip / toggle. When toggled off, the slider is disabled and sends `null` on the wire.
  - **Screen defaults**: On a fresh session, sliders default to active preset values (30 min / 8 ingredients / 2 cookware) with one-tap "No limit" controls immediately accessible.

## 4. Waiting State Transport

Complete-response waiting over standard HTTP POST is chosen over chunked streaming for v1.

- **Structured JSON integrity**: A Draft is a strictly structured JSON document validated against `recipe.schema.json`. Ingredients, linked steps with `ingredientIds`, cookware, macros, and cover form an atomic whole. Incomplete JSON cannot be safely displayed to a cook.
- **Model behavior**: Gemini Vertex AI with thinking tokens outputs thought tokens before JSON payload tokens. Streaming raw tokens provides no usable intermediate recipe presentation.
- **Client experience**: The client awaits `POST /v1/generate` returning complete `{"draft": <Draft>, "chainId": "<id>"}`. The UI displays an honest, calm waiting indicator with cooking copy and elapsed indicator, without simulated progress percentages. Duplicate submission is prevented while in flight. If the call fails with no delivered Draft, no Quota is charged and input is preserved for retry.

## 5. Cover Conflict Resolution: User Photos in Scope

Resolves the wording conflict between issue #16 ("no recipe photography in v1") and the foundational Recipe model (#1, #4, #5, #46, ADR 0004, CONTEXT.md).

- **Resolution**: Issue #16's note was an aesthetic constraint for the visual prototype (typography leads; emoji Covers are the visual anchor; no stock food photography). It did not exclude the user-facing feature of attaching personal photos of cooked dishes to saved Recipes.
- **Contract**:
  - Generated Drafts always receive a model-chosen emoji Cover (`kind: "emoji"`).
  - Saved Recipes allow the user to replace the emoji with their own photo via the device image picker (Issue #46).
  - Photos are owner-private in Cloud Storage under `users/{uid}/recipes/{recipeId}/cover.jpg`, strictly under 2 MiB, referenced by `photoPath` (never a public URL, H13).
  - The model-chosen `emoji` is always retained on the Recipe as a permanent fallback.
  - AI-generated food photography and stock photography remain deferred.

## 6. Cooking Session Timers: Foreground Alert and Background Notification

Clarifies timer behavior in Cooking Sessions (#20, #45).

- **Foreground**: The cooking screen holds a foreground wake lock (`keep-screen-awake`). When a Step timer reaches zero in the foreground, an in-app audio chime, haptic feedback, and visual banner trigger.
- **Background**: If the user backgrounds the app or locks the device while a timer runs, a local system notification with standard alarm sound is scheduled at the target wall-clock expiry time (`runningSince + remainingSeconds`). Pausing, resetting, or completing the timer cancels the scheduled notification.
- **Wall-clock derivation**: Timers derive remaining time from the system clock upon resume (`now - runningSince`); no background service or polling tick is required.
- **Permission**: Notification permission is requested contextually on the first timer start (not during onboarding). If permission is denied, the app degrades gracefully without errors, relying on wall-clock derivation upon resume.

## Consequences

- **Issue #37 (Draft Chains)**: Must persist `addPreferences` in the chain's effective set, accept nullable limits, and handle chain persistence without rejecting over-limit Drafts.
- **Issue #42 (Generation Flow)**: Connects sliders with no-limit toggles, sends `addPreferences`, implements complete-response waiting without fake progress bars, and renders limit overrun notices on delivered Drafts.
- **Issue #44 (Prompt & Golden Set)**: Adds `addPreferences` golden-set coverage under `PREFERENCES` and tests limit adherence as quality metrics without treating limits as runtime rejection gates.
- **Issue #45 (Cooking Sessions)**: Implements foreground audio chime with wake lock and contextual local notification scheduling for Step timers.
- **Issue #46 (Photo Covers)**: Confirmed in scope as `ready-for-agent` for owner-private photo upload on saved Recipes.
