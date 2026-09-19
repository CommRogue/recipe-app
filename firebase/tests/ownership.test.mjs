// The "Ownership" and "Backend-only subtrees" blocks of the rules test plan in
// docs/firestore-data-model.md. Runs against the Firestore emulator:
//   npm run test:emulator
import { after, before, beforeEach, describe, it } from "node:test";
import {
  collectionGroup,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
  updateDoc,
} from "firebase/firestore";
import {
  OTHER,
  OWNER,
  assertFails,
  assertSucceeds,
  clients,
  seed,
  setupEnv,
} from "./helpers.mjs";

let env;
before(async () => {
  env = await setupEnv();
});
after(async () => {
  await env.cleanup();
});
beforeEach(async () => {
  await env.clearFirestore();
});

// Every client-owned path under users/{uid}, with a document that passes the
// baseline rules.
const OWNED = {
  [`users/${OWNER}/profile/default`]: { listed: ["diet.vegan"] },
  [`users/${OWNER}/recipes/r1`]: { title: "Miso noodles", ownerUid: OWNER },
  [`users/${OWNER}/collections/c1`]: { name: "Weeknight" },
  [`users/${OWNER}/cookingSessions/s1`]: { currentEntry: 0 },
};

const USER_DOC = {
  createdAt: new Date("2026-09-01T00:00:00Z"),
  unitSystem: null,
  consent: null,
  recipeCount: 0,
  countedRecipeId: null,
};

const BACKEND_ONLY = {
  [`users/${OWNER}/server/plan`]: { plan: "paid" },
  [`users/${OWNER}/server/quota`]: { window: {} },
  [`users/${OWNER}/draftChains/ch1`]: { refinementCount: 1 },
  [`users/${OWNER}/draftChains/ch1/drafts/d1`]: { draft: { title: "x" } },
};

describe("ownership of everything under users/{uid}", () => {
  beforeEach(async () => {
    await seed(env, { [`users/${OWNER}`]: USER_DOC, ...OWNED, ...BACKEND_ONLY });
  });

  for (const path of [`users/${OWNER}`, ...Object.keys(OWNED), ...Object.keys(BACKEND_ONLY)]) {
    it(`owner can read ${path}`, async () => {
      const { owner } = clients(env);
      await assertSucceeds(getDoc(doc(owner, path)));
    });

    it(`other cannot read ${path}`, async () => {
      const { other } = clients(env);
      await assertFails(getDoc(doc(other, path)));
    });

    it(`signed-out cannot read ${path}`, async () => {
      const { anon } = clients(env);
      await assertFails(getDoc(doc(anon, path)));
    });

    it(`other cannot update or delete ${path}`, async () => {
      const { other } = clients(env);
      await assertFails(updateDoc(doc(other, path), { hacked: true }));
      await assertFails(deleteDoc(doc(other, path)));
    });
  }

  it("other cannot create under the owner's prefix", async () => {
    const { other } = clients(env);
    await assertFails(setDoc(doc(other, `users/${OWNER}/recipes/r2`), { title: "planted" }));
    await assertFails(setDoc(doc(other, `users/${OWNER}/collections/c2`), { name: "planted" }));
  });

  it("owner can write their own client-owned documents", async () => {
    const { owner } = clients(env);
    await assertSucceeds(setDoc(doc(owner, `users/${OWNER}/recipes/r2`), { title: "new" }));
    await assertSucceeds(updateDoc(doc(owner, `users/${OWNER}/collections/c1`), { name: "Renamed" }));
    await assertSucceeds(deleteDoc(doc(owner, `users/${OWNER}/cookingSessions/s1`)));
    await assertSucceeds(setDoc(doc(owner, `users/${OWNER}/profile/default`), { listed: [] }));
  });

  it("a collection-group query over recipes by a client is denied", async () => {
    const { owner } = clients(env);
    await assertFails(getDocs(collectionGroup(owner, "recipes")));
  });
});

describe("the user document", () => {
  it("is created by its owner with recipeCount 0 and a server createdAt", async () => {
    const { owner } = clients(env);
    await assertSucceeds(
      setDoc(doc(owner, `users/${OWNER}`), { ...USER_DOC, createdAt: serverTimestamp() }),
    );
  });

  it("cannot be created with a head start on recipeCount", async () => {
    const { owner } = clients(env);
    await assertFails(
      setDoc(doc(owner, `users/${OWNER}`), { ...USER_DOC, createdAt: serverTimestamp(), recipeCount: 5 }),
    );
  });

  it("cannot be created with a client-chosen createdAt", async () => {
    const { owner } = clients(env);
    await assertFails(setDoc(doc(owner, `users/${OWNER}`), USER_DOC));
  });

  it("cannot be created for someone else", async () => {
    const { other } = clients(env);
    await assertFails(
      setDoc(doc(other, `users/${OWNER}`), { ...USER_DOC, createdAt: serverTimestamp() }),
    );
  });

  it("keeps createdAt immutable and lets the owner change settings", async () => {
    await seed(env, { [`users/${OWNER}`]: USER_DOC });
    const { owner } = clients(env);
    await assertSucceeds(updateDoc(doc(owner, `users/${OWNER}`), { unitSystem: "imperial" }));
    await assertFails(updateDoc(doc(owner, `users/${OWNER}`), { createdAt: serverTimestamp() }));
  });

  it("cannot be deleted by its owner", async () => {
    await seed(env, { [`users/${OWNER}`]: USER_DOC });
    const { owner } = clients(env);
    await assertFails(deleteDoc(doc(owner, `users/${OWNER}`)));
  });
});

describe("backend-only subtrees", () => {
  beforeEach(async () => {
    await seed(env, { [`users/${OWNER}`]: USER_DOC, ...BACKEND_ONLY });
  });

  it("owner can read server/plan and server/quota", async () => {
    const { owner } = clients(env);
    await assertSucceeds(getDoc(doc(owner, `users/${OWNER}/server/plan`)));
    await assertSucceeds(getDoc(doc(owner, `users/${OWNER}/server/quota`)));
  });

  it("the forged-Paid write is denied: owner cannot create, update or delete server/*", async () => {
    const { owner } = clients(env);
    await assertFails(setDoc(doc(owner, `users/${OWNER}/server/newdoc`), { plan: "paid" }));
    await assertFails(updateDoc(doc(owner, `users/${OWNER}/server/plan`), { plan: "paid" }));
    await assertFails(setDoc(doc(owner, `users/${OWNER}/server/plan`), { plan: "paid" }));
    await assertFails(deleteDoc(doc(owner, `users/${OWNER}/server/plan`)));
  });

  it("owner can read and delete a Draft Chain and its Drafts", async () => {
    const { owner } = clients(env);
    await assertSucceeds(getDoc(doc(owner, `users/${OWNER}/draftChains/ch1`)));
    await assertSucceeds(getDoc(doc(owner, `users/${OWNER}/draftChains/ch1/drafts/d1`)));
    await assertSucceeds(deleteDoc(doc(owner, `users/${OWNER}/draftChains/ch1/drafts/d1`)));
    await assertSucceeds(deleteDoc(doc(owner, `users/${OWNER}/draftChains/ch1`)));
  });

  it("the forged-Refinement-count write is denied: owner cannot create or update chains or Drafts", async () => {
    const { owner } = clients(env);
    await assertFails(updateDoc(doc(owner, `users/${OWNER}/draftChains/ch1`), { refinementCount: 0 }));
    await assertFails(setDoc(doc(owner, `users/${OWNER}/draftChains/ch2`), { refinementCount: 0 }));
    await assertFails(setDoc(doc(owner, `users/${OWNER}/draftChains/ch1/drafts/d2`), { draft: {} }));
    await assertFails(updateDoc(doc(owner, `users/${OWNER}/draftChains/ch1/drafts/d1`), { draft: {} }));
  });
});

describe("reports and revenuecatEvents", () => {
  beforeEach(async () => {
    await seed(env, { "reports/rep1": { draftId: "d1" }, "revenuecatEvents/ev1": { id: "ev1" } });
  });

  for (const path of ["reports/rep1", "revenuecatEvents/ev1"]) {
    it(`no client can read or write ${path}`, async () => {
      const { owner, other, anon } = clients(env);
      for (const db of [owner, other, anon]) {
        await assertFails(getDoc(doc(db, path)));
        await assertFails(setDoc(doc(db, path), { hacked: true }));
        await assertFails(updateDoc(doc(db, path), { hacked: true }));
        await assertFails(deleteDoc(doc(db, path)));
      }
      await assertFails(setDoc(doc(owner, path.replace(/1$/, "9")), { planted: true }));
    });
  }
});
