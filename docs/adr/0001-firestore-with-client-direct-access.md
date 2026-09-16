---
status: accepted
---

# Firestore is the database, and the Flutter client talks to it directly

The app needs to work in a kitchen with a phone that may be offline, and the team is one developer. We chose Firestore over Cloud SQL for its built-in offline persistence, realtime sync and Firebase Auth security rules. The Flutter client reads and writes the user's own data (profile, Recipes, Collections, Ratings, Cooking Sessions) directly under security rules; the backend never sits between the client and its own data.

## Considered options

- Cloud SQL Postgres behind the backend: relational fit for recipe versioning, but every read goes through a server, and offline support has to be built by hand.
- Firestore with all writes through the backend: keeps the schema server-owned, at the cost of a round trip on every save and a much larger backend surface.

## Consequences

- Firestore's location is chosen once and cannot be changed; a research ticket picks it.
- Security rules carry real authorisation logic and need tests.
- Anything the client must not be trusted with (Quota accounting, Plan changes, model calls) lives in the backend, not in rules.
