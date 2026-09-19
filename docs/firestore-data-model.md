# Firestore data model and security rules

Decided in #22. The choices that are expensive to undo are in [ADR 0007](adr/0007-firestore-layout-under-users-with-backend-only-subtrees.md); this document is the working reference for the Go service (#18), the Flutter app (#17) and the rules tests. Terms are from `CONTEXT.md`. The Recipe shape is `schema/recipe.schema.json`.

## Principles

- **Everything a user owns is under `users/{uid}`**, in Firestore and in Cloud Storage. One ownership function in the rules (`isOwner(uid)`, H12), one prefix to delete when an account is deleted.
- **The client writes its own data directly** (ADR 0001): user settings, Profile, Recipes, Collections, Cooking Sessions.
- **Two subtrees are written only by the Go service** and are read-only to their owner: `users/{uid}/server/*` (Plan, Quota) and `users/{uid}/draftChains/**` (Draft Chains and Drafts). The Admin SDK bypasses rules, so "backend-only" means `allow write: if false`.
- **Client writes are plain writes or batches, never transactions**, so every one of them queues while offline. A rule that needs two documents to change together uses `getAfter()` on a batch.
- **Timestamps** are Firestore Timestamps in stored documents and RFC 3339 strings on the wire between Go and Dart. Client-set times that rules care about (`createdAt`, `savedAt`, `updatedAt`) must equal `request.time`, which is what `FieldValue.serverTimestamp()` produces.
- **Rules check ownership, caps, immutability and a few types. They do not re-implement the Recipe schema.** The data is the owner's own; the Dart types are the real validator, and readers tolerate unknown fields and values (H19).

## Layout

```
users/{uid}                                   client     settings, consent, recipeCount
users/{uid}/profile/default                   client     the Profile
users/{uid}/recipes/{recipeId}                client     Recipe body + ownership + private map
users/{uid}/collections/{collectionId}        client     Collection
users/{uid}/cookingSessions/{sessionId}       client     Cooking Session
users/{uid}/server/plan                       backend    Plan fields (#12)
users/{uid}/server/quota                      backend    Quota window and charges (H15)
users/{uid}/draftChains/{chainId}             backend    Draft Chain record     (owner may read and delete)
users/{uid}/draftChains/{chainId}/drafts/{draftId}
                                              backend    one Draft              (owner may read and delete)
reports/{reportId}                            backend    Report on a Draft (#13), no client access
revenuecatEvents/{eventId}                    backend    webhook dedupe (#12), no client access

Cloud Storage
users/{uid}/recipes/{recipeId}/cover.jpg      client     Cover photo (H13)
```

## Documents

### `users/{uid}`

Created by the client on first sign-in.

| Field | Type | Notes |
| --- | --- | --- |
| `createdAt` | timestamp | `request.time` on create, immutable |
| `unitSystem` | `"metric"` \| `"imperial"` \| null | null means "follow the locale" |
| `consent` | `{version: int, acceptedAt: timestamp}` \| null | The consent screen from #13. The Go service refuses a Generation Request while it is null or older than the current consent version |
| `recipeCount` | int | Number of documents in `recipes`. Starts at 0. See "The saved-Recipe cap" |
| `countedRecipeId` | string \| null | The Recipe whose save or delete the latest `recipeCount` change accounts for |

### `users/{uid}/profile/default`

The Profile (ADR 0005). Absent means empty, which is valid. The Go service loads it itself for every Generation Request (H14).

| Field | Type | Cap |
| --- | --- | --- |
| `listed` | list of catalogue ids | 40 entries. Rules do not check ids against the catalogue, so an unknown id written by a newer app survives (H19) |
| `customConstraints` | map entryId → text | 20 |
| `liked` | map entryId → text | 30 |
| `disliked` | map entryId → text | 30 |
| `qualities` | map entryId → text | 20 |
| `updatedAt` | timestamp | |

- Free-text entries are a **map from entry id to the verbatim text**, not a list of objects. An Override names an entry by its id; two devices editing different entries merge field by field instead of overwriting one list; and rules can bound a map of strings (below) where they cannot loop over a list of objects.
- An entry id is minted by the client: milliseconds since epoch in base 36, zero-padded, plus a short random suffix. Entries are shown in key order, which is creation order. Moving an entry between `disliked` and `customConstraints` keeps its id.
- Rules cannot iterate, so per entry they cannot check 80 characters. They check `m.size() <= cap` and `m.values().join('').size() <= cap * 80`. The same total storage bound, not the same per-entry bound. **The Go service is the exact enforcer**: it drops an entry over 80 characters and entries beyond the cap when it loads the Profile, and the app never lets one be typed.

### `users/{uid}/recipes/{recipeId}`

The Recipe of `schema/recipe.schema.json`: the Draft body unchanged, plus `ownerUid`, `revision`, `savedAt`, `updatedAt`, plus the `private` map. `recipeId` is the Draft's id (ADR 0004), so saving twice writes the same document.

| `private` member | Type | Notes |
| --- | --- | --- |
| `rating` | Rating \| null | `stars` 1 to 5, `note` up to 1000 characters, `ratedAt`, `recipeRevision` (H9) |
| `collectionIds` | list of string | Up to 50. "Recipes in Collection X" is `where private.collectionIds array-contains X` |
| `cookCount` | int | Finished Cooking Sessions (H10) |
| `lastCookedAt` | timestamp \| null | |

- Rules do not require a matching Draft to exist. The save flow must not assume a Generation Request produced the Draft (H16), and imports will later save Recipes that never were Drafts.
- **Immutable after create**: every key except `cover`, `updatedAt` and `private`. v1 cannot change content, so `revision` stays 1; when editing arrives, the rule loosens and the old body is copied to a `revisions` subcollection (H8).
- Sharing later works by **copy or projection without `private`**, never by granting read on this document (ADR 0007, H5).
- Deleting a Recipe: one batch that deletes the document and decrements `recipeCount`; the client then deletes the Cover file. Cooking Sessions that point at it are tolerated as dangling.

### `users/{uid}/collections/{collectionId}`

`name` (1 to 60 characters), `createdAt`, `updatedAt`. Flat, no nesting, no membership list: membership is `private.collectionIds` on each Recipe. Deleting a Collection is a client batch that deletes the document and `arrayRemove`s its id from member Recipes; readers ignore an id with no Collection, so a half-finished clean-up is harmless. The number of Collections is capped by the app only (100).

### `users/{uid}/cookingSessions/{sessionId}`

| Field | Type | Notes |
| --- | --- | --- |
| `entries` | list of `{recipeId, recipeRevision, currentStep}` | Length 1 in v1; rules allow 1 to 10 (H11) |
| `currentEntry` | int | Index into `entries` |
| `startedAt`, `updatedAt` | timestamp | |
| `completedAt` | timestamp \| null | null while in progress |

No singleton path and no progress on the Recipe (H11). "The session in progress" is a query for `completedAt == null`. Finishing sets `completedAt` and, in the same batch, increments `private.cookCount` and sets `private.lastCookedAt` on the Recipe; the finished session is kept (H10). An abandoned session is deleted by the client. #20 may add fields (running timers); rules check only ownership, the `entries` bound and the timestamps.

### `users/{uid}/server/plan` and `users/{uid}/server/quota`

Backend-only, owner-readable. `plan` holds `plan` (`"free"` \| `"paid"`), `planExpiresAt`, `planStore`, `planEventTimestampMs`, written only by the RevenueCat webhook handler (#12). **A missing document means Free.** This moves the Plan fields off `users/{uid}`, where #12 first put them, so that no document mixes client-writable and backend-only fields and the rule is a plain `allow write: if false`.

`quota` holds the current rolling window and its charges with kind and weight (H15, #5); the client reads it to show what is left. Its exact fields belong to the Quota accounting work on the map.

### `users/{uid}/draftChains/{chainId}` and `.../drafts/{draftId}`

Written by the Go service when it delivers a Draft. The owner may read them, so the app recovers an unsaved Draft after a crash or a dropped response, and may delete them (discard). Nothing else.

| Chain field | Notes |
| --- | --- |
| `createdAt`, `expireAt` | `expireAt` is 7 days after the latest Draft in the chain |
| `effectiveSet` | The Constraints and Preferences after Overrides (ADR 0005); every Refinement prompt is built from it |
| `refinementCount` | The cap of 3 is checked here (#5) |
| `latestDraftId`, `promptVersion` | |

| Draft document field | Notes |
| --- | --- |
| `draft` | The Draft body exactly as returned, nothing about the Generation Request inside it (H16) |
| `parentDraftId`, `instruction` | null on the first Draft; the Refinement instruction otherwise |
| `createdAt`, `expireAt` | |

- A **Firestore TTL policy on `expireAt`** for the collection groups `draftChains` and `drafts` deletes them. TTL deletion can lag by a day, so the client filters on `expireAt > now`.
- Saving copies `draft` into `recipes/{draftId}`; the chain is left to expire.
- A Report copies the Draft and the effective set into `reports/{reportId}`, so neither discarding nor expiry destroys what was reported.

### Cloud Storage

`users/{uid}/recipes/{recipeId}/cover.jpg`: owner read and write, `image/*`, under 2 MB (the app downsizes before upload). The Recipe stores the path, never a download URL (H13).

## The saved-Recipe cap

Free may hold 20 Recipes; Paid has no cap; on lapse nothing is locked and only new saves are blocked (#5).

- **Save** is one batch: create `recipes/{id}` and update `users/{uid}` with `recipeCount: FieldValue.increment(1)` and `countedRecipeId: id`. It must be `increment`, not an absolute number, so a batch queued offline is still right when it syncs.
- **Recipe create rule**: `getAfter(user).recipeCount == get(user).recipeCount + 1`, and `getAfter(user).recipeCount <= 20 || isPaid(uid)`, where `isPaid` reads `server/plan`. A missing Plan document fails `isPaid`, which is the Free outcome.
- **Recipe delete rule**: `getAfter(user).recipeCount == get(user).recipeCount - 1`.
- **User update rule**: `recipeCount` is unchanged, or goes up by 1 while `recipes/{countedRecipeId}` does not exist before and exists after, or goes down by 1 while it exists before and not after. So the counter cannot be lowered without deleting a Recipe.
- A re-save of an existing id is an update, not a create, and is rejected by the immutability rule unless only `cover`, `updatedAt` or `private` differ. The client checks for existence first and treats "already saved" as success.
- `plan == "paid"` is trusted as written; the webhook sets it back to `"free"` on expiry. Rules do not compare `planExpiresAt` with the clock, so a late webhook errs in the user's favour.
- **Offline**: the app pre-checks the cap from the cached `users/{uid}` and `server/plan`. A queued save that the server rejects surfaces as a failed write; the Draft is still in its Draft Chain for 7 days, so nothing is lost. #19 owns that state.

Worst case a save reads 5 documents in rules (`get` and `getAfter` of the user, the Plan, `exists` and `existsAfter` of the Recipe), within the limit of 20 for a batch.

## Indexes

Composite, all on `users/{uid}/recipes` (collection scope): `private.collectionIds` array-contains with `savedAt` desc; single-field orderings on `savedAt`, `private.rating.stars`, `private.lastCookedAt` and `title` come for free. Title search is done in the app over the cached library. `cookingSessions` on `completedAt` is single-field. TTL policies are configured beside the indexes.

## Rules test plan

Rules and tests live in `firebase/` (`firestore.rules`, `storage.rules`, `firestore.indexes.json`, `tests/`). Tests run against the Firebase Emulator Suite with `@firebase/rules-unit-testing` and a Node test runner, the only supported harness for rules, locally and in CI on every change under `firebase/`. Deploying rules goes through the same workflow as the service (#14). Each line below is at least one test; "other" is a signed-in user with a different uid.

**Ownership, every path under `users/{uid}`**
- Owner can read; other cannot; signed-out cannot.
- Other cannot create, update or delete anything.
- A collection-group query over `recipes` by a client is denied.
- `reports` and `revenuecatEvents`: every client read and write is denied.

**`users/{uid}`**
- Create with `recipeCount: 0` and `createdAt == request.time` passes; with `recipeCount: 5` fails.
- `createdAt` cannot change. `unitSystem` accepts the two values and null, rejects anything else.
- `consent` can be set; `version` must be an int.
- `recipeCount` changed alone, up or down, fails.

**Profile**
- Empty Profile passes. 20 Custom Constraints pass, 21 fail; likewise 30, 30, 20 and 40 for the other members.
- A map whose joined text exceeds cap × 80 fails.
- A non-string value: establish what `join` does with it and tighten the rule if it passes; the Go service ignores such an entry either way.
- An unknown catalogue id in `listed` passes (H19).
- Updating one entry by field path passes and leaves the others alone.

**Recipes and the cap**
- Free, count 0: batch of create plus increment passes.
- Create without the counter update fails. Counter update without the create fails. Increment by 2 fails.
- Free, count 20: save fails. Paid, count 20: save passes. No `server/plan` document, count 20: fails.
- Paid lapses to Free at count 35: read, Rating, Collection change, Cover change and delete all pass; save fails; after deleting down to 19, save passes.
- Delete plus decrement passes. Delete without decrement fails. Decrement without delete fails. Decrement naming a Recipe that still exists after the batch fails.
- `ownerUid` other than the path uid fails. `id` other than the document id fails. `revision` other than 1 fails. `savedAt` other than `request.time` fails.
- Update changing `title`, `ingredients`, `steps`, `ownerUid`, `revision` or `savedAt` fails. Update changing only `cover`, `updatedAt` or `private` passes.
- Rating: stars 0 and 6 fail; note of 1001 characters fails; null rating passes.
- `private.collectionIds` with 51 entries fails.
- A re-save of an existing id with an identical body does not raise `recipeCount`.

**Collections**
- Name of 1 to 60 characters passes; empty and 61 fail.
- Delete batch with `arrayRemove` on member Recipes passes.

**Cooking Sessions**
- Create with one entry passes; zero and 11 entries fail.
- Finish batch (set `completedAt`, increment `private.cookCount`, set `private.lastCookedAt`) passes.
- Owner can delete an abandoned session.

**Backend-only subtrees**
- Owner can read `server/plan` and `server/quota`; owner cannot create, update or delete either (the forged-Paid test: a client that writes `plan: "paid"` is denied).
- Owner can read and delete a Draft Chain and its Drafts; cannot create or update them (the forged-Refinement-count test).

**Storage**
- Owner uploads a 1 MB JPEG to their own Recipe prefix: passes. 3 MB fails. `application/pdf` fails. Other's prefix fails. Other cannot read.

## Handed on

- **#18** (scaffold, done): the service loads the Profile with the Admin SDK and enforces the exact caps on load. Left as named seams in `backend/internal/generate/` for the implementation issues from #25: writing `server/plan`, `server/quota`, `draftChains/**` (with `expireAt` on every chain and Draft write), `reports` and `revenuecatEvents`; treating a missing Plan document as Free; refusing a Generation Request while `consent` is null or stale (the consent screen does not exist yet).
- **#17** (scaffold, done): the `firebase/` directory with baseline ownership rules and the Ownership and Backend-only test blocks; Dart converters between Firestore Timestamps and the schema's date-time strings; the user document is created on first sign-in. Still to come with the save flow: repositories that use batches and `FieldValue.increment`, never transactions, and the remaining test blocks below.
- **#19**: recovering a Draft from its Draft Chain, the "recent Drafts" surface if #16 wants one, discard as a delete, and the rejected-save state.
- **#20**: the Cooking Session document, the finish batch, any timer fields.
- **#15** (done): TTL policies on `draftChains` and `drafts` and the composite index exist on dev; #24 recreates them on prod (`firebase/firestore.indexes.json` carries the index, the TTL policies are `gcloud` commands recorded on #15). Rules are deployed by hand for now; the CI deploy through #18's deployer needs `firebaserules.admin`, `datastore.indexAdmin` and `firebase.viewer` added, which is an implementation issue from #25.
- **Account deletion (map, not yet specified)**: a Go endpoint that recursively deletes `users/{uid}`, the Storage prefix `users/{uid}/`, the Auth user, revokes the Apple token (#13) and decides what happens to that user's `reports`.
