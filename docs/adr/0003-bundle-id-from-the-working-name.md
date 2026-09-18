---
status: accepted
---

# The bundle id `app.panwise` is permanent even though Panwise is a working name

The bundle id is fixed the moment the apps are registered in Firebase and the stores, and the scaffold tickets need it before the name has been tested on real users. We chose to derive it from the product domain `panwise.app` now: `app.panwise` on both iOS and Android, with `app.panwise.dev` for the dev flavor so both builds install side by side and register as separate Firebase apps. If the display name changes later, the id stays; users never see it.

## Considered options

- A name-neutral id under a studio or personal domain: survives a rename cleanly, rejected because there is no studio brand, the seller name on an individual account is the developer's legal name anyway, and it means buying and keeping a second domain.
- Hold app registration until the name is final: stalls the Firebase, Flutter scaffold and CI tickets for a string nobody sees.
- `io.github.commrogue.*`: free, but ties a permanent id to a GitHub handle and still leaves the policy pages without a home.

## Consequences

- The id carries no "ai", "beta" or version words, lowercase only, no hyphens (Android) or underscores (iOS).
- `panwise.app` also hosts the privacy policy, Terms of Use and the public account-deletion URL the stores require. `panwise.com` is held by someone else since 2001 and is not part of the plan.
- The exact App Store title "Panwise" is held by an unrelated makeup tracker, so the store title carries a suffix ("Panwise: AI Recipes" or similar); the icon label is just "Panwise".
- A rename means a new display name and a second domain, never a new bundle id: a new id is a new app with no users, ratings or Subscriptions.
