import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import { doc, setDoc } from "firebase/firestore";

const here = dirname(fileURLToPath(import.meta.url));

export const OWNER = "owner-uid";
export const OTHER = "other-uid";

/** Starts a test environment against the emulator (host and port from firebase.json). */
export async function setupEnv() {
  return initializeTestEnvironment({
    projectId: "recipe-app-508817",
    firestore: {
      rules: readFileSync(join(here, "..", "firestore.rules"), "utf8"),
    },
  });
}

/** Firestore handles for the owner, another signed-in user, and a signed-out client. */
export function clients(env) {
  return {
    owner: env.authenticatedContext(OWNER).firestore(),
    other: env.authenticatedContext(OTHER).firestore(),
    anon: env.unauthenticatedContext().firestore(),
  };
}

/** Writes documents with rules disabled, as the Go service would with the Admin SDK. */
export async function seed(env, docs) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    for (const [path, data] of Object.entries(docs)) {
      await setDoc(doc(db, path), data);
    }
  });
}

export { assertFails, assertSucceeds };
