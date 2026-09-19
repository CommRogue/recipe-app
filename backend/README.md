# Panwise Go service

The one backend of the app (ADR 0002): a Go service on Cloud Run that turns a Generation Request into a Draft by calling Gemini on Vertex AI. It verifies Firebase ID tokens, loads the user's Profile from Firestore, builds the prompt, calls the model and validates the result. Everything else the app does is client-direct Firestore (ADR 0001). Terms are from `CONTEXT.md`.

## Layout

```
cmd/server            wiring, config from env, graceful shutdown
internal/httpapi      routes, JSON, error codes; /health and /v1/*
internal/auth         Firebase ID token middleware (Verifier interface)
internal/generate     the staged pipeline (H14): Request, Service, seams
internal/profile      Profile, caps, Overrides, effective set, Firestore loader
internal/prompt       prompt v1: system text, catalogue sentences, blocks
internal/gemini       Generator on Vertex AI; hand-written response schema
internal/recipe       Draft types, embedded contract, structural validator
scripts/              provision-gcp.sh (GCP), e2e-generate.sh (deployed check)
```

Two files are byte-identical copies of the shared contract and are embedded into the binary: `internal/recipe/recipe.schema.json` (of `schema/recipe.schema.json`) and `internal/prompt/catalogue.json` (of `schema/constraint-catalogue.json`). A test fails when either drifts; fix it by copying the repo file over the embedded one.

## API

All routes except `/health` need `Authorization: Bearer <Firebase ID token>` (H20). Errors are `{"error": {"code", "message"}}`.

`POST /v1/generate`

```json
{
  "ask": "something Asian for tonight",
  "limits": { "maxTotalMinutes": 30, "maxIngredients": 8, "maxCookware": 2 },
  "overrides": {
    "off": ["allergen.peanuts", "0mfk3z9a1"],
    "addListed": ["allergen.sesame"],
    "addCustom": ["no mushrooms"]
  }
}
```

Every field is optional. `off` names catalogue ids from the Profile's `listed` or entry ids from its free-text maps; `addListed` takes catalogue ids; `addCustom` takes One-off Custom Constraints (at most 80 characters each). The Profile itself is never sent; the service loads it (H14).

Response `200`: `{"draft": <Draft per schema/recipe.schema.json>}`. The envelope leaves room for `chainId` once Draft Chains are stored. Codes: `400 invalid_argument`, `401 unauthenticated`, `403 consent_required` (reserved), `429 quota_exceeded` (reserved), `502 no_draft` (the model answered but not with a valid Draft; nothing is charged, ADR 0006), `503 model_unavailable`.

## Run locally

Needs Go 1.26 (the stock Ubuntu Go 1.22 cannot download a newer toolchain; install one under `~/.local/go`) and Application Default Credentials with Firestore read and Vertex AI access on the project.

```sh
cd backend
GOOGLE_CLOUD_PROJECT=recipe-app-508817 go run ./cmd/server
curl localhost:8080/health
SERVICE_URL=http://localhost:8080 scripts/e2e-generate.sh
```

| Variable | Default | Meaning |
| --- | --- | --- |
| `PORT` | `8080` | Cloud Run sets it |
| `GOOGLE_CLOUD_PROJECT` | metadata server on Cloud Run | Firebase project, Firestore, Vertex AI |
| `VERTEX_LOCATION` | `global` | No Middle East endpoint serves Gemini (#10) |
| `GEMINI_MODEL` | `gemini-3.8-flash` | Generation model |
| `GEMINI_THINKING_LEVEL` | model default (MEDIUM) | `LOW`, `MEDIUM` or `HIGH` |
| `LOG_LEVEL` | `info` | `debug`, `info`, `warn`, `error` |

## Tests

```sh
go vet ./... && gofmt -l . && go test ./...
go test ./internal/prompt -update        # after an intended prompt change: rewrite the golden file
RUN_VERTEX_TESTS=1 GOOGLE_CLOUD_PROJECT=recipe-app-508817 go test ./internal/gemini -run Vertex -v
```

The Vertex test calls the real model with ADC and is skipped otherwise. The usual way to exercise the model is the deployed service, below.

## Deploy

`.github/workflows/backend.yml` runs vet, fmt and tests on every push and pull request that touches `backend/`, and deploys to Cloud Run on pushes to `main` and on `workflow_dispatch`. It authenticates with Workload Identity Federation (no keys, #14) and deploys from source with the Dockerfile, so the image is the one the tests ran against. The service runs as `recipe-api-runtime`, is publicly invokable and verifies Firebase ID tokens itself, since Cloud Run IAM would reject them.

One-time provisioning of a project (pool, provider, service accounts, roles) is `scripts/provision-gcp.sh`; it prints the values to set as variables on the GitHub environment (`dev` today, `prod` with #24). Manual deploy for a hotfix:

```sh
gcloud run deploy recipe-api --source backend --region me-west1 --project recipe-app-508817 \
  --service-account recipe-api-runtime@recipe-app-508817.iam.gserviceaccount.com --allow-unauthenticated \
  --set-env-vars GOOGLE_CLOUD_PROJECT=recipe-app-508817,VERTEX_LOCATION=global,GEMINI_MODEL=gemini-3.8-flash
```

## End-to-end check

`scripts/e2e-generate.sh` mints a Firebase ID token for a test uid without a client app (IAM Credentials signs a custom token as `recipe-api-runtime`, Identity Toolkit exchanges it), calls `/v1/generate` on the deployed service and prints the Draft. The caller needs `roles/iam.serviceAccountTokenCreator` on that service account.

## Seams left for later

Each is a named type or stage in `internal/generate`, so the work drops in without touching the pipeline shape.

- **Quota** (`QuotaChecker`, `AlwaysAllow`): rolling weekly window, charges by kind and weight, 3 Refinements per chain (#5); lives in `users/{uid}/server/quota`. Charge only when a Draft is delivered (ADR 0006).
- **Draft Chains** (`DraftStore`, `NopDraftStore`): write `users/{uid}/draftChains/{chainId}` and `.../drafts/{draftId}` with the effective set, `promptVersion`, `refinementCount` and a 7-day `expireAt` (ADR 0007); return `chainId` in the response.
- **Consent** (`checkConsent`): refuse while `users/{uid}.consent` is null or older than the current version, once the consent screen (#13) exists.
- **Refinement**: `POST /v1/chains/{chainId}/refine` reusing every stage but the prompt, on `gemini-3.5-flash-lite`, generated against the chain's effective set.
- **Streaming**: `GenerateContentStream` is a drop-in for the non-streaming call once #19 decides what the waiting state shows; structured JSON is only usable complete.
- **RevenueCat webhook** (#12): `POST /v1/webhooks/revenuecat`, the only writer of `users/{uid}/server/plan`.
- **Generation Limits**: an over-limit Draft is logged, not rejected; #19 decides whether the app or the service reacts.
- **Reports**, **account deletion**, **App Check**: see the map (#1).
