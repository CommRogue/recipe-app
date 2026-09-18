---
status: accepted
---

# Everything a user owns sits under `users/{uid}`, with backend-only subtrees, and a Recipe carries its owner-private data

ADR 0001 made the client write its own data under security rules and left the layout open. The full model is `docs/firestore-data-model.md`; four choices in it are hard to change once users have data.

**One prefix per user.** Profile, Recipes, Collections, Cooking Sessions, Plan, Quota and Draft Chains are all subcollections of `users/{uid}`, and Cover photos sit under the same prefix in Cloud Storage. Rules check ownership through one function (H12), a Recipe still stores `ownerUid` so a collection-group query stays possible, and account deletion is a recursive delete of one prefix. Recipe ids stay globally unique (ADR 0004), so moving to a top-level collection later is a copy, not a re-keying.

**Backend-only subtrees instead of backend-only fields.** `users/{uid}/server/*` (Plan, Quota) and `users/{uid}/draftChains/**` are written only by the Go service; the owner reads them, and may delete a Draft Chain to discard it. No document mixes client-writable and backend-only fields, so the rule is `allow write: if false` rather than a list of protected keys that has to be kept complete. This moves the Plan fields that #12 placed on `users/{uid}` into `users/{uid}/server/plan`; a missing document means Free. It also widens ADR 0002: the service is the writer of Plan, Quota, Draft Chains, Reports and webhook dedupe records, not only the caller of the model.

**Drafts are stored, for seven days.** The service writes every Draft it delivers into its Draft Chain, beside the effective set of ADR 0005 and the Refinement count, with a Firestore TTL of seven days. The client reads them, so a Draft survives a crash, a phone call or a dropped response after its Quota charge was taken. Saving is still a client-direct copy into `recipes/{draftId}`.

**Rating and Collection membership live on the Recipe document**, in a `private` map with `cookCount` and `lastCookedAt`. One read renders a library row with its stars, "Recipes in a Collection" is one `array-contains` query, sorting by Rating or last cooked is a query, and all of it works offline from cache. H5 asked for the price to be recorded: **sharing will work by copy or projection that drops `private`, never by granting read on the owner's document.**

The saved-Recipe cap (#5) is enforced in rules by a `recipeCount` on `users/{uid}` that must move by exactly one in the same batch as a Recipe create or delete (`getAfter`), with the Plan read from `server/plan`. Batches, unlike transactions, queue offline.

## Considered options

- Top-level `recipes/{id}` with an `ownerUid` filter: natural for sharing by granting read, rejected because v1 has no sharing, every query needs the owner filter and an index, and account deletion becomes a query per collection.
- Plan fields on `users/{uid}` guarded by `affectedKeys()`: one document fewer to read, rejected because every new client-writable field risks the guard, and the forged-Paid write is the rule that most needs to be obviously right.
- Drafts only in client memory, the chain record private to the service: smallest client surface, rejected because a Draft lost with app state is a charged generation the user never got.
- A 24-hour TTL: less stored data, rejected in favour of coming back to a Draft later in the week.
- Ratings as `ratings/{recipeId}` documents and Collections holding `recipeIds`: keeps the Recipe document shareable as it is, rejected because library rows need a join per Recipe, a Collection needs N reads, and sorting by Rating moves into the app.
- Rating on the Recipe, membership as an ordered list on the Collection: manual ordering for free, rejected because deleting a Recipe then touches every Collection.
- Profile free-text entries as a list of `{id, text}`: reads naturally, rejected because rules cannot loop over a list of objects, and two devices editing at once overwrite each other's list. They are a map from entry id to text.
- Saves through the Go service to enforce the cap: exact and simple, rejected because it breaks offline saving and ADR 0001.
- Rules that require a matching Draft before a Recipe can be created: stops hand-made Recipes, rejected because imports will save Recipes that never were Drafts (H16) and the data is the user's own.

## Consequences

- Rules carry the cap, immutability of the Recipe body in v1, the Profile caps as totals, and the two backend-only subtrees; the test plan in `docs/firestore-data-model.md` is part of the rules' definition of done. The exact 80-character cap per Profile entry is enforced only by the Go service and the app, because rules cannot iterate.
- The repo gains a Node toolchain under `firebase/` for the emulator tests; there is no other supported way to test rules.
- A save that syncs after the user went over the cap, or after a lapse, is rejected late. The Draft is still in its chain, and #19 designs the state.
- Two TTL policies (`draftChains`, `drafts`) and one composite index are part of project provisioning, for dev and again for prod (#24).
- When recipe editing arrives, the immutability rule loosens and old bodies go to a `revisions` subcollection (H8); `private` is not versioned.
