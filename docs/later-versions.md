# Later versions

Features from `plan.md` that are deferred past v1, recorded so v1 does not foreclose them. v1 builds none of this. Each section has three parts: the idea as the developer described it, what v1 must keep open, and the questions to grill before building.

Terms are from `CONTEXT.md`. Where `plan.md` uses a word the glossary avoids, the glossary term is used here and the original wording is kept only inside quotes. Hooks are labelled H1 to H20 and consolidated in the [summary](#summary-of-v1-hooks) for the Recipe model (#4) and Firestore data model (#22) tickets.

For reference, v1 is: the profile of Constraints and Preferences, generation with Generation Limits and one Refinement loop, Draft until saved, saving and rating Recipes, Collections, a single-Recipe Cooking Session, model-estimated macros labelled as estimates, Free and Paid Plans, an emoji Cover replaceable by a photo, Android and iOS, English only.

## 1. Import from websites and video

### The idea

`plan.md` gives this one line: "Importing recipes from recipe websites or videos (like TikTok or Instagram reels or posts)." It treats websites and video as one feature and says nothing more: not how the user hands over the link, not whether the imported recipe is adapted to the user's Constraints and Preferences, not whether the original is credited. The two sources are kept in one section here, but they differ enough in mechanism and risk that the hooks and questions below call them out separately.

### What v1 must keep open

- **H4, provenance on the Recipe.** A `source` object with a `kind`. v1 only ever writes `kind: "generated"`. Later kinds (website, video) add a URL and an attribution string. Without this field, imported and generated Recipes are indistinguishable after the fact and nothing can be credited or re-fetched.
- **H16, a Draft does not assume a Generation Request produced it.** The Draft shape returned by the Go service carries the same `source` object, and the client's review, Refinement and save flow works from the Draft alone. An import can then land as a Draft and reuse that flow. Whether it should is an open question below.
- **H1 and H6, structured ingredients and steps.** An import is only useful later (shopping lists, nutrition lookups, Cooking Sessions) if it is normalised into the same ingredient and step shapes as a generated recipe. The recipe JSON schema shared between Go and Dart (ADR 0002) is the target of extraction, so it must not contain fields that only make sense for generation. Anything generation-specific goes in the Generation Request or in `source`, not in the recipe body.
- **H14 and H15, backend seams.** ADR 0002 already names imports as an extension of the Go service, so there is no tension for websites: the Gemini research (#10) found a URL context tool that reads HTML and combines with structured output. v1 needs only that auth, Quota checking and the model call are separate stages that a second endpoint can reuse, and that a Quota charge records what kind of operation it was, because an import will not cost the same as a generation.
- **Tension, video.** The same research found that Gemini accepts video from Cloud Storage or a public YouTube URL, not from TikTok or Instagram links. Importing those means the service fetching and storing video bytes, which is more than "model calls and nothing else", may outlive a Cloud Run request, and would need a new ADR. v1 should do nothing about this beyond not assuming every endpoint is a short synchronous call that returns a Draft.
- **H18, routes carry ids in the path.** A later share-sheet entry point ("share to the app" from a browser or TikTok) needs to open the app on an import screen with a URL. Nothing to build in v1 except routes that can be entered from outside.

### Open questions

- Is an imported recipe kept as written, or rewritten to respect the user's Constraints and steer towards their Preferences? If kept as written and it breaks a Constraint, is it rejected, flagged, or saved anyway? The glossary says only that a *generated* recipe breaking a Constraint is invalid.
- Does an import land as a Draft (reviewable, open to Refinement) or straight as a Recipe? If a Draft, the glossary definition of Draft ("a recipe the model has produced") needs widening.
- Does an import count against Quota, and at what weight? Does it count against the Plan's cap on saved Recipes? Is import a Paid feature?
- Websites: do the terms of recipe sites permit automated fetching and storing of their content? Is a recipe's ingredient list and method copyrightable in the jurisdictions the app ships to, and what about the prose and photos around it? Is attribution with a link back required, sufficient, or neither?
- Websites: parse schema.org `Recipe` markup when present and use the model only as a fallback, or always use the model? What happens on paywalled pages, which the URL context tool cannot read?
- Video: do TikTok's and Instagram's terms of service allow downloading or server-side processing of a video from a share link at all? Is there an official API that permits it, and would the app qualify? What is the exposure if the app does it anyway?
- Video: does App Store or Play review take a position on apps that extract content from those platforms?
- Video: is the recipe taken from the caption, the speech, on-screen text, or the frames? What does a typical 60-second reel cost in tokens, and who pays for a 20-minute video?
- Video: are fetched video bytes stored, for how long, and in which region? Is the work synchronous or a background job the client polls?
- What does the Cover of an imported recipe default to: a model-chosen emoji as usual, or the source's photo (a second copyright question)?
- Can the user also type a recipe in by hand? `plan.md` does not mention it, but it is the same "Recipe without a Generation Request" case.

## 2. Recipe version control

### The idea

From the recipe management line of `plan.md`: "making changes (including recipe version control, like making edits the second time the recipe is cooked and noting how it affected the recipe or changed the rating)". So: a saved Recipe changes over time, each change is remembered, each change can carry a note on what it did, and the Rating is tied to the version it was given to.

The glossary has no term for a change to a saved Recipe. "Edit" is listed as an avoided alias for Refinement, which applies only to Drafts. This feature needs its own terms (for the change and for the version) before it is built.

### What v1 must keep open

- **H8, one document per Recipe body.** Everything that defines the dish (ingredients, steps, time, cookware, servings, macros) lives in a single Firestore document, so a version later is a copy of one document into a `revisions` subcollection. If v1 spreads the body across several documents, a version becomes a multi-document snapshot.
- **H7, a `revision` integer and `updatedAt` on the Recipe.** Starts at 1. If v1 allows any change to a saved Recipe, the change increments it. The old body is lost in v1, which is accepted, but every other record can point at a revision number from day one.
- **H9, the Rating records what it rated and when.** A Rating is an object (`stars`, `note`, `ratedAt`, `recipeRevision`), not a bare integer on the Recipe. That is enough to show later that a Rating changed between versions. Whether Ratings become a history is an open question; v1 must only avoid a shape where a new Rating silently erases the fact that there was an old one for an older revision.
- **H10, cooking leaves a trace.** "The second time the recipe is cooked" requires knowing the Recipe was cooked a first time. Finishing a Cooking Session in v1 should at least bump `cookCount` and `lastCookedAt` on the Recipe, or keep the finished session with a `completedAt`, rather than deleting it without record. Cost: one extra write per finished session.
- **H11, a Cooking Session notes the `recipeRevision` it is walking.** Costs nothing in v1 and avoids step indexes pointing at the wrong step once Recipes can change under a session.
- **H4, `source.derivedFrom`.** Room for a pointer to the Recipe a Recipe was derived from, unused in v1. Whether a changed Recipe is a new version or a new Recipe is an open question, and this keeps both answers possible.
- **Tension with ADR 0001.** The ADR records that Postgres was the better relational fit for versioning and that Firestore was chosen anyway. The consequence is that versions are client-written snapshots under security rules, with immutability enforced by rules on the subcollection (create allowed, update and delete denied), and those rules need tests. No cost in v1.

### Open questions

- Can a saved Recipe be changed by hand in v1 at all, or only by generating again? If it can, is losing the previous body acceptable until versions ship?
- Is a change made by hand, by an instruction to the model (a Refinement-like loop on a saved Recipe), or both? If the model is involved, does it cost Quota?
- Full snapshots per version, or diffs? Is there a cap on versions per Recipe, and does it differ by Plan?
- Is there one Rating per Recipe that moves, one per version, or one per time the Recipe is cooked? What does the Recipe list sort by?
- Is the note about "how it affected the recipe" part of the version, part of the Rating, or a separate cook log entry?
- Can the user go back to an old version, and is that a new version or a pointer move?
- Do versions count against the Plan's cap on saved Recipes?
- What does a Collection point at: the Recipe, always showing the latest version?
- What are the glossary terms for the change and the version?

## 3. Sharing

### The idea

`plan.md` mentions sharing once, in the opening paragraph: the app "will also let the user save and manage recipes, share them, and organize them." It does not appear in the feature list and nothing else is said. Whether sharing means sending a link, exporting text, sharing between accounts, or publishing publicly is not stated.

### What v1 must keep open

- **H12, an `ownerUid` field on every Recipe, and one ownership function in the rules.** Even if the path already contains the uid (`users/{uid}/recipes/{id}`), store the owner in the document and write the security rules so the ownership check is a single function called everywhere. Adding a second way to be allowed to read is then one change, and collection-group queries remain possible.
- **H5, the Recipe renders from its own document.** Displaying a Recipe needs nothing from the owner's profile. Units are converted at display time from the viewer's metric or imperial setting, not baked into the stored text.
- **H5, owner-private data is separable from the recipe body.** Rating, Collection membership and any snapshot of the Generation Request are not interleaved with ingredients and steps. The Generation Request matters most: it contains the user's Constraints, which can include allergies. v1 stores no such snapshot on a Recipe (#21, ADR 0006); if a later version does, it must sit in a clearly separate field or document so a shared copy can leave it out.
- **Cost of H5.** Firestore rules cannot hide individual fields. Keeping Rating and Collection ids on the Recipe document is the cheapest shape for v1 queries (sort by stars, `array-contains` on a Collection id), and it is acceptable, but it means sharing later works by copying or projecting the body, not by granting read on the owner's document. #22 should choose knowingly.
- **H13, Cover photos are stored by path, not by tokenised download URL.** The Recipe holds a Cloud Storage path under the owner's prefix. A long-lived download URL baked into the document would be an unrevocable public link the moment a Recipe is shared.
- **H4, `source.derivedFrom` and `source.kind`.** A Recipe received from someone else needs to say so.
- **H18, routes carry ids in the path.** A shared link has to open a specific Recipe.
- **Tension with ADR 0001 and ADR 0002.** ADR 0001 covers the user's *own* data. A Recipe read by someone else is not that. Sharing will need either rules that admit other readers (more authorisation logic in rules) or a backend endpoint that serves shared Recipes (the Go service growing beyond model calls and Quota). Either is a new ADR. v1 should not pre-decide it.

### Open questions

- What does "share" mean here: a text or image export through the system share sheet, a link anyone can open, a copy sent to another account, a live shared Recipe, or a public profile?
- If a link: what does someone without the app see? That depends on the web platform (section 9) or a server-rendered page.
- Is a received Recipe a copy the recipient owns, or a reference to the sender's? If a copy, does it count against the recipient's saved-Recipe cap?
- Does the sender's Rating or note travel with it? Does the Cover photo?
- Should a received Recipe be checked against the recipient's Constraints, and what happens when it breaks one?
- Can a share be revoked? What happens to shares when the owner deletes the Recipe or their account?
- If anything is publicly visible: moderation, reporting, and the store rules on user-generated content. Is that a line this product wants to cross?
- Can Collections be shared, or only single Recipes?
- Is sharing free or Paid?

## 4. Shopping lists

### The idea

`plan.md`: "Ingredient shopping lists - selecting certain recipes and getting a shopping list for ingredients that they use." The user picks several Recipes and gets one list. Nothing is said about merging duplicates, ticking items off, or what the user already has at home.

### What v1 must keep open

- **H1, structured ingredients.** Each ingredient is an object: `name` (the ingredient alone, "onion", not "1 large onion, finely diced"), `quantity` (a number, nullable for "to taste"), `unit` (from a closed set, including a unitless count), and a separate `preparation` text. Free-text ingredient lines make a merged list impossible without another model call per list.
- **H1, one canonical unit system in storage.** v1 already has a metric or imperial toggle. Store one system and convert at display. A list that adds grams from one Recipe to ounces from another should not depend on which setting was active when each was saved.
- **H2, `servings` is a number.** Scaling a Recipe before adding it to a list needs arithmetic on servings and quantities.
- **Cost of H1.** A stricter schema is more for the model to get right, and the Gemini research (#10) notes Vertex AI rejects schemas it finds too complex. The ingredient shape should stay flat, and the quality check for generation should cover it (for example that `name` really is free of quantities and preparation).
- **No backend seam is required.** If aggregation is pure arithmetic it can run on the client against the user's own Recipes, consistent with ADR 0001. If it turns out to need the model, H14 and H15 apply.

### Open questions

- How are near-duplicates merged: "2 cloves garlic" and "1 tbsp minced garlic", or "spring onion" and "scallion"? Arithmetic only, a canonical ingredient vocabulary, or the model? If the model, does building a list cost Quota?
- Can mass and volume of the same ingredient be added, and where would densities come from?
- Is a shopping list a saved, tickable thing that syncs, or a throwaway view? If saved, it is a new glossary term and a new collection in Firestore.
- Can the user scale Recipes per list? Add items by hand?
- Is there a notion of staples the user always has, and is that part of the profile?
- Grouping by shop section; export or share of a list to another person or app.
- Does the list use shopping units ("1 tin", "1 bunch") or recipe units ("240 g")?
- Free or Paid?

## 5. Multi-recipe Cooking Sessions

### The idea

`plan.md`: "Interactive, step-by-step 'cooking' mode. The user should also be able to cook multiple recipes at once, and the app will keep the progress between the multiple recipes and let the user switch between them." The glossary already reflects this: a Cooking Session is "designed to hold several Recipes at once in a later version". As described, the feature is parallel progress and switching. `plan.md` does not ask for the app to interleave or schedule steps across Recipes.

### What v1 must keep open

- **H11, a Cooking Session is its own document holding a list of entries.** Each entry is `{recipeId, recipeRevision, currentStep, ...}`. v1 always writes a list of length one. What v1 must not do is put progress on the Recipe (`recipe.currentStep`) or give the session a single top-level `recipeId`, because both turn the later change into a migration.
- **H11, more than one session document can exist.** Do not model the session as a singleton at a fixed path whose shape assumes one Recipe. Whether the user may have several sessions open is an open question; the path should not decide it.
- **H6, steps are objects, not strings.** An ordered list of `{text, ...}` lets later fields (whatever multi-recipe cooking turns out to need per step) be added without changing the type of the list.
- **Client seam.** The Cooking Session state in the Flutter app (the prototype in #20) is keyed by entry, with "the current entry" as separate state, even though v1 has one entry. The screen for one Recipe then becomes one page of a switcher rather than being rewritten.
- ADR 0001 already lists Cooking Sessions as client-direct data with offline persistence. No tension and no backend seam.

### Open questions

- Is it only switching between independent walks, or should the app merge the Recipes into one timeline ("while the rice simmers, start the sauce")? The second is a model call and a different feature.
- Are there timers, and do they keep running and notify while another Recipe is on screen? `plan.md` does not mention timers at all.
- One Cooking Session containing several Recipes, or several sessions at once? What does "finish" mean when one Recipe is done and another is not?
- Is there a limit on Recipes per session, and is it a Plan matter?
- What happens to a session when its Recipe is changed or deleted mid-way?
- Does a session sync across the user's devices in real time, and does that matter?

## 6. Suggestions and ideas

### The idea

`plan.md`: "Recipe suggestions and ideas. For example, the user may want to eat asian food at the moment, while only having 30 minutes to cook, so suggest food ideas like easy to cook noodles, or fried rice." The output is a handful of short ideas to choose from, not a full recipe. v1 partly covers the example already: a Generation Request has a free-text ask ("something Asian for tonight") and a time Generation Limit, but it answers with one Draft, not a set of options.

Glossary note: "suggestion" is an avoided alias for Draft. The thing this feature returns is not a Draft, and it needs its own term before it is built. This document uses "idea" in lower case as a placeholder.

### What v1 must keep open

- **H14, the generation pipeline is staged.** Verifying the user, loading Constraints and Preferences, checking Quota, building the prompt, calling the model and post-processing are separate functions in the Go service, with the model call behind an interface. An ideas endpoint reuses everything except the prompt and the response schema.
- **H15, a Quota charge has a kind.** A list of five one-line ideas is cheaper than a full recipe. If Quota is a bare counter that every model call decrements by one, ideas either cost too much or bypass Quota.
- **The free-text ask is the hand-off.** Choosing an idea becomes a Generation Request whose free-text ask is the idea, with the same Generation Limits. v1 needs nothing new for this as long as the free-text ask stays a first-class field of the Generation Request rather than being folded into a fixed prompt.
- **H20, a versioned API path.** New endpoints arrive alongside old app versions still in the field.

### Open questions

- What is an idea: a title, a title and one line, an emoji, rough time and ingredient count? Is it kept anywhere or gone when the screen closes?
- Do ideas draw only on the model, or also on the user's saved Recipes ("you rated this five stars and it takes 25 minutes")? The second needs the backend to read Recipes, which today it has no reason to do.
- Are ideas requested by the user, or offered unprompted on the home screen or by notification? Unprompted ideas cost model calls nobody asked for.
- Do ideas cost Quota, at what weight, and is the feature Free or Paid?
- Must every idea already respect all Constraints, and how is that checked for a one-line idea?
- Does this become the default entry to generation (ideas first, then a Draft), changing the v1 flow?
- What is the glossary term?

## 7. Nutrition-database macros

### The idea

`plan.md` says only: "Display macro-nutrient information for recipes." It does not say where the numbers come from. v1 answers with macros estimated by the model and labelled as estimates. The deferred feature is replacing or backing those estimates with figures computed from a nutrition database. That distinction comes from charting the v1 map, not from `plan.md`.

### What v1 must keep open

- **H3, macros carry their origin.** The `macros` object has a `source` field, `"model_estimate"` in v1, and states its basis (per serving). The "estimate" label in the UI is driven by that field, not hard-coded, so a Recipe with computed macros can drop the label without an app change.
- **H1 and H2, structured ingredients and numeric servings.** A lookup needs an ingredient name free of quantities and preparation, a numeric quantity and a known unit. Later, an ingredient can gain an optional reference to a database entry; v1 only needs the ingredient to be an object so that field has somewhere to go.
- **H14, a post-processing stage in the Go service.** ADR 0002 names nutrition lookups as an extension of the service. The natural slot is after the model returns and before the Draft goes to the client, which is also where a Constraint check would go if one is ever added (v1 has none, ADR 0006). v1 needs that stage to exist as a place, even if it does little.
- **Cost.** A lookup in that stage adds latency to a streamed Draft, and a database hosted outside GCP adds an outbound dependency to a service that today talks only to Vertex AI and Firestore. Neither is a v1 cost.

### Open questions

- Which database: USDA FoodData Central, Open Food Facts, a commercial API such as Edamam or Nutritionix, or a national database? What are the licence terms for a paid commercial app, the attribution requirements, the rate limits and the price?
- How well does it cover ingredients common where the users are (the Middle East), and in English?
- How is a free-text ingredient name matched to a database entry: string matching, embeddings, the model choosing from candidates? What is shown when there is no confident match?
- How are volumes and counts ("1 cup", "2 eggs", "1 medium onion") turned into mass?
- Raw or cooked values, and what about oil absorbed, liquid discarded, or yield?
- Is the database queried live, cached, or loaded into the service's own store?
- Are existing Recipes backfilled, and who triggers that given the backend does not normally read Recipes?
- Only macros, or fibre, sugar, salt and micronutrients as well? Several Preferences in `plan.md` ("a lot of fiber", "low in fats") would become checkable.
- Should computed macros be used to check a Draft against macro Preferences and trigger a retry?
- Does stating computed nutrition figures carry regulatory or store-policy obligations that an "estimate" label avoids?
- Free or Paid?

## 8. AI-generated Covers

### The idea

`plan.md` says nothing about this. It does not mention recipe images or Covers at all. The Cover as a model-chosen emoji replaceable by a user photo was decided while charting v1, and a Cover generated by an image model was listed there as deferred. There is no developer description to be faithful to beyond the item's name.

### What v1 must keep open

- **H13, the Cover is a tagged value.** `{kind: "emoji", emoji}` or `{kind: "photo", storagePath}` in v1, with room for a generated kind later. The Dart and Go types treat an unknown `kind` as "fall back to the emoji" rather than failing to parse (H19).
- **H13, the emoji is always kept.** When a photo replaces the emoji as the Cover, the emoji stays on the Recipe. It is the fallback for an unknown kind, a missing file, a slow network, and the placeholder while a generated Cover is being made.
- **H13, a fixed storage layout.** Cover files live under a per-owner, per-Recipe prefix in Cloud Storage, and the Recipe stores the path. A backend-written generated Cover then uses the same prefix, and deleting a Recipe has one place to clean.
- **H14 and H15, backend seams.** Generating a Cover is a model call, so it belongs in the Go service under ADR 0002 with no tension. It is priced very differently from text, so the Quota charge needs a kind.
- The Cover photo storage design is still listed as unspecified on the v1 map. It should be settled with this section in view.

### Open questions

- Which model (Imagen or a Gemini image model on Vertex AI), at what cost per Cover, and from which endpoint given that nothing generative is served from `me-west1`?
- When is it generated: for every Draft, on save, or only when the user asks? Every Draft multiplies cost by the number of Drafts discarded.
- Is it Paid only? Does it draw on the same Quota as generation or a separate one?
- Synchronous or background? Drafts stream today; a Cover would arrive later.
- A photorealistic Cover shows a dish that was never cooked and may not match the recipe. Is that acceptable, should the style be deliberately illustrative, and must it be labelled as generated (store policy, or law in the target markets)?
- What resolution and how many sizes are stored, what does storage and egress cost per user, and are files deleted with the Recipe and with the account?
- What happens when the image model refuses or returns something unusable?
- If the user later adds a photo, is the generated Cover kept?

## 9. Web platform

### The idea

`plan.md` does not mention a web version. It says "Use Flutter for the UI" and names no platforms. The v1 map settled on a public store release for Android and iOS with web deferred. So the idea here is no more than: the same Flutter app, also built for the web, at some later point.

### What v1 must keep open

- **H17, no platform assumptions in feature code.** No `dart:io` imports and no `Platform.isAndroid` checks inside features. Anything platform-specific (file access, photo picking, purchases, share sheet) sits behind an interface in one place. When a plugin is added, note whether it supports web; a plugin without web support is fine in v1 but must be behind such an interface.
- **H18, routes carry ids in the path.** go_router routes are addressable by URL and screens load what they need from the id, rather than receiving objects through `extra`. On the web, a reload or a pasted link has only the URL. This also serves sharing and the import entry point.
- **The Plan is read from Firestore, never from the store SDK alone.** This is already the outcome of the Subscriptions research (#12): the Go service is the only writer of the Plan fields. Because of it, a web client needs no store SDK to know the user's Plan. v1 must not add a client path that unlocks Paid features from the purchase SDK's local state only.
- **H20, the Go service authenticates with a Firebase ID token in the `Authorization` header.** Nothing about calling the service should be possible only from a mobile app. If App Check is enforced in v1, it is configured so a web provider can be added. CORS is not needed in v1 and is a small later change.
- **Not a v1 hook: responsive layout.** The v1 design brief is a phone app. Making every screen adapt to wide windows has a real cost and is not asked of v1. Accept that a web version would need layout work.
- **Tension with ADR 0001.** The ADR chose Firestore largely for offline use in a kitchen. Firestore's offline persistence on the web behaves differently from mobile (browser storage, multiple tabs). The ADR still holds, but its main benefit is weaker on this platform.

### Open questions

- What is the web version for: the full app, a read-only view of Recipes on a larger screen, or a landing page for shared links (section 3)?
- How does a web user buy the Paid Plan? Store Subscriptions do not exist there. Does RevenueCat's web billing fit, what do Apple's and Google's rules say about a cheaper web price or linking to it, and does a Subscription bought on one platform apply everywhere (it should, given the Plan lives in Firestore, but refunds and restores need checking)?
- Do all the plugins in use by then support web, including the purchases SDK and photo picking?
- Where is it hosted (Firebase Hosting is the obvious candidate), on what domain, and does the Go service need a custom domain, given Cloud Run domain mapping is not offered in `me-west1`?
- Which Flutter web renderer, what initial load size is acceptable, and does it matter for a page opened from a shared link?
- Does a Cooking Session on the web need the screen kept awake and offline support, or is web never the cooking device?
- Shorebird does not apply to web builds. How are web releases shipped and rolled back?
- Does web change the abuse picture for generation (easier scripted sign-ups against the Free Plan's Quota)?

## Summary of v1 hooks

Each hook is cheap: a field, a shape, or a boundary. None of them builds a deferred feature. "Needed by" uses the section numbers above.

### Recipe model (#4)

| Hook | What v1 does | Needed by |
| --- | --- | --- |
| H1 | Ingredients are objects: `name` (ingredient only), `quantity` (number, nullable), `unit` (closed set, including count), `preparation` (text). Stored in one canonical unit system; converted at display. Keep the shape flat for the model's sake. | 1, 4, 7 |
| H2 | `servings` is a number. Macros are stated per serving. | 4, 7 |
| H3 | `macros` has a `source` field (`"model_estimate"` in v1); the UI's "estimate" label is driven by it. | 7 |
| H4 | `source` provenance object with `kind` (`"generated"` only in v1) and room for `url`, `attribution`, `derivedFrom`. Present on Drafts and Recipes. | 1, 2, 3 |
| H5 | The Recipe renders from its own document. Owner-private data (Rating, Collection membership, any Generation Request or Constraints snapshot) is separable from the recipe body and never required to display it. | 3, 2 |
| H6 | Steps are an ordered list of objects (`{text, ...}`), not strings. | 1, 2, 5 |
| H7 | `revision` integer starting at 1, and `updatedAt`. | 2, 5 |
| H9 | Rating is an object: `stars`, `note`, `ratedAt`, `recipeRevision`. | 2 |
| H13 | Cover is a tagged value (`kind: "emoji"` or `"photo"`); the emoji is always kept; a photo is referenced by Cloud Storage path under a per-owner, per-Recipe prefix, never by tokenised download URL. | 8, 3 |
| H19 | The schema generated into Go and Dart is forward-compatible: unknown fields ignored, unknown enum values (`source.kind`, `cover.kind`, `macros.source`, `unit`) map to a safe fallback. A `schemaVersion` field on the Recipe. | all |

### Firestore data model and security rules (#22)

| Hook | What v1 does | Needed by |
| --- | --- | --- |
| H8 | The whole recipe body is one document, so a later version is a copy of one document into a `revisions` subcollection. | 2 |
| H10 | Finishing a Cooking Session leaves a trace: `cookCount` and `lastCookedAt` on the Recipe, or the finished session kept with `completedAt`. | 2 |
| H11 | A Cooking Session is its own document with a list of entries `{recipeId, recipeRevision, currentStep}`; length one in v1. No progress fields on the Recipe, no single top-level `recipeId`, no singleton path. | 5, 2 |
| H12 | `ownerUid` stored on every Recipe. Rules check ownership through one function, used everywhere. Storage rules follow the same pattern. | 3 |
| H5 | If Rating and Collection ids stay on the Recipe document for query convenience, record that sharing will then work by copy or projection, not by granting read. | 3 |

### Go service (#18) and Plans (#5)

| Hook | What v1 does | Needed by |
| --- | --- | --- |
| H14 | The generation pipeline is separate stages (verify token, load profile, check Quota, build prompt, call model behind an interface, post-process, return Draft). The post-process stage exists as a place. Not every endpoint is assumed to be a short synchronous call returning a Draft. | 1, 6, 7, 8 |
| H15 | A Quota charge records the kind of operation (generation and Refinement in v1) and can carry a weight, rather than being a bare counter. | 1, 6, 8 |
| H16 | The Draft shape and the client's review, Refinement and save flow do not assume a Generation Request produced the Draft. Generation-specific data stays out of the recipe body. | 1 |
| H20 | Versioned API paths. Auth is a Firebase ID token in the `Authorization` header; nothing is mobile-only. App Check, if enforced, leaves room for a web provider. | 9, 6, 1 |

### Flutter app (#17) and Cooking Session prototype (#20)

| Hook | What v1 does | Needed by |
| --- | --- | --- |
| H17 | No `dart:io` or platform checks in feature code; platform-specific plugins sit behind an interface; web support noted when a plugin is added. | 9 |
| H18 | go_router routes carry ids in the path and screens load from the id, not from objects passed in `extra`. | 9, 3, 1 |
| H11 | Cooking Session state is keyed by entry, with the current entry as separate state. | 5 |
| (from #12) | Paid features are unlocked from the Plan fields in Firestore, never from the purchase SDK's local state alone. | 9 |

### Tensions with the ADRs

- **Sharing** falls outside ADR 0001 (which covers only the user's own data) and would stretch either the rules or ADR 0002's "model calls and nothing else". New ADR when built.
- **Video import** needs the service to fetch and hold media and possibly run longer than a request. New ADR when built. Website import is already anticipated by ADR 0002.
- **Version control** is the case ADR 0001 names as the better fit for Postgres. On Firestore it becomes client-written, rule-protected snapshots.
- **Nutrition lookups** are anticipated by ADR 0002 but add an outbound dependency and latency to Draft generation.
- **Web** weakens ADR 0001's offline rationale without contradicting it.
- The Subscriptions research (#12) already recommends amending ADR 0002, because the service also owns the RevenueCat webhook and the Plan fields. H15 (Quota kinds) should be decided alongside that.

### Glossary gaps to close before building

- A change to a saved Recipe, and a version of a Recipe ("edit" is an avoided alias for Refinement).
- The short idea returned by suggestions ("suggestion" is an avoided alias for Draft).
- A shopping list, if it becomes a saved thing.
- Draft, if imports land as Drafts: its definition currently says "a recipe the model has produced".
