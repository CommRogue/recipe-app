---
status: accepted
---

# A single Go service on Cloud Run owns model calls and nothing else

Prompts are product logic that will change far more often than the app ships, and model credentials and Quota enforcement cannot live on a phone. We chose one Go service on Cloud Run that turns a Generation Request into Gemini calls on Vertex AI, enforces Quota, and returns Drafts. All other data access is client-direct to Firestore (ADR 0001).

## Considered options

- Firebase AI Logic from the client, no backend: simplest, but prompts ship inside the app and per-user Quota cannot be enforced server-side.
- Dart on Cloud Run: shares types with Flutter, but server-side Gemini SDK support is thin.
- TypeScript or Python: first-party Gen AI SDKs, rejected on developer preference for Go.

## Consequences

- The recipe JSON schema is the contract between Go and Dart and is generated into both, not hand-written twice.
- Future server-side features (importing from websites and video, nutrition lookups) extend this service rather than adding Cloud Functions.
