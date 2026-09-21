#!/usr/bin/env bash
#
# Provisions what the Go service needs on a GCP project (#18, #14):
# Workload Identity Federation for GitHub Actions, the deployer and runtime
# service accounts and their roles. Idempotent: rerun after changes. Run as a
# project Owner with gcloud logged in.
#
#   backend/scripts/provision-gcp.sh                 # dev project
#   PROJECT=<prod-id> backend/scripts/provision-gcp.sh   # prod (#24)
#
# Prints the two values the GitHub Actions workflow needs as variables.

set -euo pipefail

PROJECT="${PROJECT:-recipe-app-508817}"
REGION="${REGION:-me-west1}"
GITHUB_OWNER_ID="${GITHUB_OWNER_ID:-55894360}"        # CommRogue
GITHUB_REPO_ID="${GITHUB_REPO_ID:-1373086201}"        # CommRogue/recipe-app
POOL="github"
PROVIDER="github-provider"
DEPLOYER="github-actions-deployer"
RUNTIME="recipe-api-runtime"

NUMBER=$(gcloud projects describe "$PROJECT" --format='value(projectNumber)')
DEPLOYER_SA="$DEPLOYER@$PROJECT.iam.gserviceaccount.com"
RUNTIME_SA="$RUNTIME@$PROJECT.iam.gserviceaccount.com"
COMPUTE_SA="$NUMBER-compute@developer.gserviceaccount.com"

log() { printf '\n== %s\n' "$*"; }

log "APIs"
gcloud services enable \
  iam.googleapis.com iamcredentials.googleapis.com sts.googleapis.com \
  cloudresourcemanager.googleapis.com run.googleapis.com cloudbuild.googleapis.com \
  artifactregistry.googleapis.com aiplatform.googleapis.com firestore.googleapis.com \
  --project "$PROJECT"

log "Workload Identity Federation pool and GitHub OIDC provider"
if ! gcloud iam workload-identity-pools describe "$POOL" --location=global --project "$PROJECT" >/dev/null 2>&1; then
  gcloud iam workload-identity-pools create "$POOL" --location=global --project "$PROJECT" \
    --display-name="GitHub Actions" \
    --description="Identities of GitHub Actions runs in this owner's repositories"
fi
# A freshly created pool can take a few seconds to become readable.
POOL_NAME=""
for _ in 1 2 3 4 5 6; do
  POOL_NAME=$(gcloud iam workload-identity-pools describe "$POOL" --location=global \
    --project "$PROJECT" --format='value(name)' 2>/dev/null || true)
  [[ -n "$POOL_NAME" ]] && break
  sleep 5
done
[[ -n "$POOL_NAME" ]] || { echo "pool $POOL not readable after creation" >&2; exit 1; }

if ! gcloud iam workload-identity-pools providers describe "$PROVIDER" --location=global \
     --workload-identity-pool="$POOL" --project "$PROJECT" >/dev/null 2>&1; then
  gcloud iam workload-identity-pools providers create-oidc "$PROVIDER" \
    --location=global --workload-identity-pool="$POOL" --project "$PROJECT" \
    --display-name="GitHub" \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_id=assertion.repository_id,attribute.repository_owner=assertion.repository_owner,attribute.repository_owner_id=assertion.repository_owner_id" \
    --attribute-condition="assertion.repository_owner_id == '$GITHUB_OWNER_ID'"
fi
# A freshly created provider can take a few seconds to become readable.
PROVIDER_NAME=""
for _ in 1 2 3 4 5 6; do
  PROVIDER_NAME=$(gcloud iam workload-identity-pools providers describe "$PROVIDER" --location=global \
    --workload-identity-pool="$POOL" --project "$PROJECT" --format='value(name)' 2>/dev/null || true)
  [[ -n "$PROVIDER_NAME" ]] && break
  sleep 5
done
[[ -n "$PROVIDER_NAME" ]] || { echo "provider $PROVIDER not readable after creation" >&2; exit 1; }

log "Service accounts"
for sa in "$DEPLOYER:Deploys the Go service from GitHub Actions" "$RUNTIME:Identity the recipe-api Cloud Run service runs as"; do
  id="${sa%%:*}"; desc="${sa#*:}"
  if ! gcloud iam service-accounts describe "$id@$PROJECT.iam.gserviceaccount.com" --project "$PROJECT" >/dev/null 2>&1; then
    gcloud iam service-accounts create "$id" --project "$PROJECT" --display-name="$id" --description="$desc"
  fi
done

log "GitHub Actions runs of repository $GITHUB_REPO_ID may impersonate the deployer"
gcloud iam service-accounts add-iam-policy-binding "$DEPLOYER_SA" --project "$PROJECT" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/$POOL_NAME/attribute.repository_id/$GITHUB_REPO_ID" >/dev/null

log "Deployer roles"
# run.admin: create/update the service and set its IAM policy (the service is
# publicly invokable and verifies Firebase ID tokens itself, #14 audit).
# run.sourceDeveloper: deploy from source (Cloud Build + Artifact Registry).
for role in roles/run.admin roles/run.sourceDeveloper roles/serviceusage.serviceUsageConsumer; do
  gcloud projects add-iam-policy-binding "$PROJECT" --member="serviceAccount:$DEPLOYER_SA" --role="$role" --condition=None >/dev/null
done
# actAs on the two identities a source deploy uses: the runtime SA and the
# build SA (Compute Engine default). Bound on the SAs, not the project.
for sa in "$RUNTIME_SA" "$COMPUTE_SA"; do
  gcloud iam service-accounts add-iam-policy-binding "$sa" --project "$PROJECT" \
    --member="serviceAccount:$DEPLOYER_SA" --role="roles/iam.serviceAccountUser" >/dev/null
done

log "Build identity may build from source"
gcloud projects add-iam-policy-binding "$PROJECT" --member="serviceAccount:$COMPUTE_SA" --role="roles/run.builder" --condition=None >/dev/null

log "Runtime roles"
# aiplatform.user: call Gemini on Vertex AI. datastore.user: read the Profile
# and, later, write the backend-only subtrees. logWriter: structured logs.
# Verifying Firebase ID tokens needs no role (public keys).
for role in roles/aiplatform.user roles/datastore.user roles/logging.logWriter; do
  gcloud projects add-iam-policy-binding "$PROJECT" --member="serviceAccount:$RUNTIME_SA" --role="$role" --condition=None >/dev/null
done

log "Done. GitHub Actions variables for the '$([[ $PROJECT == recipe-app-508817 ]] && echo dev || echo prod)' environment:"
echo "GCP_PROJECT_ID=$PROJECT"
echo "GCP_REGION=$REGION"
echo "GCP_WORKLOAD_IDENTITY_PROVIDER=$PROVIDER_NAME"
echo "GCP_DEPLOYER_SERVICE_ACCOUNT=$DEPLOYER_SA"
echo "GCP_RUNTIME_SERVICE_ACCOUNT=$RUNTIME_SA"
echo
echo "IAM changes can take up to 5 minutes to propagate."
