# GitHub Actions to GCP: Workload Identity Federation and Deploys

**Research Date:** 2026-09-17  
**Ticket:** Issue #14  
**Map:** Issue #1

## Question

How do GitHub Actions deploy to this GCP setup without service account keys? What are the exact `gcloud` commands to configure Workload Identity Federation, the least-privilege IAM roles, and how does a workflow deploy the Go service to Cloud Run and Firestore security rules to two projects (dev and prod)?

## Architecture Context

- **Dev project:** `recipe-app-508817` (project number 674819344439)
- **Prod project:** Created near end of map, details TBD
- **Service:** Single Go service on Cloud Run for model calls and Quota enforcement (ADR 0002)
- **Database:** Firestore with client-direct access and security rules (ADR 0001)
- **CI/CD:** GitHub Actions via CommRogue/recipe-app repository
- **Users region:** Middle East (me-west1 preferred, me-central1/me-central2 available)

---

## Workload Identity Federation Setup

Workload Identity Federation (WIF) replaces long-lived service account keys with short-lived OIDC tokens from GitHub Actions, signed by `https://token.actions.githubusercontent.com`.

### 1. Create Workload Identity Pool

```bash
gcloud iam workload-identity-pools create "github" \
  --project="PROJECT_ID" \
  --location="global" \
  --display-name="GitHub Actions Pool" \
  --description="Workload identity pool for GitHub Actions deployments"
```

**Required role on project:** `roles/iam.workloadIdentityPoolAdmin`

**APIs to enable beforehand:**
- `iam.googleapis.com`
- `cloudresourcemanager.googleapis.com`
- `iamcredentials.googleapis.com`
- `sts.googleapis.com`

[Source: Google Cloud — Workload Identity Federation with deployment pipelines](https://docs.cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines)

### 2. Create GitHub OIDC Provider

```bash
# Get pool ID (output is full resource name)
POOL_ID=$(gcloud iam workload-identity-pools describe "github" \
  --project="PROJECT_ID" \
  --location="global" \
  --format="value(name)")

# Create OIDC provider with attribute condition restricting to this repo
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project="PROJECT_ID" \
  --location="global" \
  --workload-identity-pool="github" \
  --display-name="CommRogue/recipe-app Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_id=assertion.repository_id,attribute.repository_owner=assertion.repository_owner,attribute.repository_owner_id=assertion.repository_owner_id" \
  --attribute-condition="assertion.repository_owner_id == '55894360'" \
  --issuer-uri="https://token.actions.githubusercontent.com"

# Extract provider resource name (use in workflow)
PROVIDER=$(gcloud iam workload-identity-pools providers describe "github-provider" \
  --project="PROJECT_ID" \
  --location="global" \
  --workload-identity-pool="github" \
  --format="value(name)")
```

**Key details:**

- **Issuer URI:** Always `https://token.actions.githubusercontent.com` for GitHub
- **Attribute condition:** Restricts tokens to your GitHub organization/user. Use `repository_owner_id` (numeric) instead of `repository_owner` (name) to prevent spoofing attacks ([GitHub to GCP security note](https://docs.cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines))
- **Audience default:** If not specified via `--allowed-audiences`, the audience in the GitHub token must equal the full provider resource name
- **Attribute mapping:** Maps GitHub token claims (`assertion.*`) to Google Cloud attributes. Required: `google.subject=assertion.sub` (maps the OIDC subject)
- **GitHub token claims available:** `repository_id`, `repository_owner_id`, `repository`, `repository_owner`, `ref`, `ref_type`, `environment`, `event_name`, `actor`, `job_workflow_ref`, `workflow`, `run_id`

[Sources: Google Cloud — Workload Identity Federation](https://docs.cloud.google.com/iam/docs/workload-identity-federation), [google-github-actions/auth README](https://github.com/google-github-actions/auth)]

### 3. Configuration Propagation

Changes to pools, providers, and IAM bindings can take **up to 5 minutes** to propagate. Test after waiting.

[Source: google-github-actions/auth README](https://github.com/google-github-actions/auth)

---

## IAM Roles and Service Accounts

### Deployer Service Account

Create a dedicated service account that GitHub Actions will impersonate:

```bash
gcloud iam service-accounts create "github-actions-deployer" \
  --project="PROJECT_ID" \
  --display-name="GitHub Actions Deployer" \
  --description="Deploys Go service to Cloud Run and Firestore rules from GitHub Actions"

DEPLOYER_SA="github-actions-deployer@PROJECT_ID.iam.gserviceaccount.com"
```

### Grant Pool Permission to Impersonate Deployer

```bash
gcloud iam service-accounts add-iam-policy-binding "$DEPLOYER_SA" \
  --project="PROJECT_ID" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/$POOL_ID/attribute.repository_id/1373086201"
```

**Breakdown:**
- **principalSet:** Matches all identities with a specific attribute value (here, any GitHub Actions run from repo ID 1373086201)
- **Binding format:** `principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/attribute.ATTRIBUTE_NAME/ATTRIBUTE_VALUE`
- **Repo ID:** Find via `gh api repos/CommRogue/recipe-app --jq '.id'` (value: 1373086201)

[Source: Google Cloud — Workload Identity Federation with deployment pipelines](https://docs.cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines)

### Required Roles on Deployer Service Account

Grant these roles **at the project level** in both dev and prod projects:

```bash
# Cloud Run deployment (from source or image)
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:$DEPLOYER_SA" \
  --role="roles/run.admin"

# Deployment from source requires Cloud Run Builder role on Compute Engine default SA
gcloud iam service-accounts add-iam-policy-binding \
  "PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
  --project="PROJECT_ID" \
  --role="roles/run.builder" \
  --member="serviceAccount:$DEPLOYER_SA"

# Service Account User (allows running service as the Cloud Run service identity)
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:$DEPLOYER_SA" \
  --role="roles/iam.serviceAccountUser"

# Artifact Registry access (if pushing images)
gcloud artifacts repositories add-iam-policy-binding "cloud-run-source-deploy" \
  --location="REGION" \
  --member="serviceAccount:$DEPLOYER_SA" \
  --role="roles/artifactregistry.writer"

# Firebase Rules deployment
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:$DEPLOYER_SA" \
  --role="roles/firebaserules.admin"

# Firestore indexes (for non-rules deployments)
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:$DEPLOYER_SA" \
  --role="roles/datastore.indexAdmin"

# Firebase CLI / general project access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:$DEPLOYER_SA" \
  --role="roles/firebase.viewer"

# Service Usage (to check API enablement)
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:$DEPLOYER_SA" \
  --role="roles/serviceusage.serviceUsageConsumer"
```

**Role breakdown:**

| Role | Purpose | Permissions |
|------|---------|-------------|
| `roles/run.admin` | Full Cloud Run management | Create, update, delete services; manage IAM and networking |
| `roles/run.builder` | Cloud Build access for source deploys | `cloudbuild.builds.*`, artifact registry uploads, logging |
| `roles/iam.serviceAccountUser` | Impersonate runtime service account | `iam.serviceAccounts.actAs` (allows running service as SA) |
| `roles/artifactregistry.writer` | Push/pull container images | Read, write, and delete artifacts |
| `roles/firebaserules.admin` | Full Firestore Rules management | Create/update/delete rulesets and releases |
| `roles/datastore.indexAdmin` | Manage Firestore indexes | Create, update, list, delete indexes; manage schemas |
| `roles/firebase.viewer` | Read Firebase project state | Needed by Firebase CLI for `firebase.projects.get`, `cloudconfig.configs.get` |
| `roles/serviceusage.serviceUsageConsumer` | Check API enablement | Inspect service states, quotas, billing |

[Sources: Cloud Run IAM roles](https://docs.cloud.google.com/run/docs/reference/iam/roles), [Artifact Registry access control](https://docs.cloud.google.com/artifact-registry/docs/access-control), [Firebase Rules Admin role](https://cloud.google.com/iam/docs/understanding-custom-roles#firebaserules-roles), [Cloud Datastore Index Admin](https://cloud.google.com/firestore/docs/security/iam)]

---

## GitHub Actions Workflow Skeleton

### Prerequisites in Workflow

All jobs deploying to GCP require:

```yaml
permissions:
  contents: read
  id-token: write  # Required to generate OIDC token
```

Always run `actions/checkout` **before** `google-github-actions/auth`:

```yaml
- uses: actions/checkout@v4
```

[Source: google-github-actions/auth README](https://github.com/google-github-actions/auth)

### Authenticate to GCP via google-github-actions/auth

```yaml
- id: auth
  uses: google-github-actions/auth@v3
  with:
    workload_identity_provider: ${{ vars.GCP_WORKLOAD_IDENTITY_PROVIDER }}
    service_account: ${{ vars.GCP_SERVICE_ACCOUNT_EMAIL }}
    token_format: "access_token"
    access_token_lifetime: "900s"  # 15 minutes
```

**Inputs:**

- `workload_identity_provider`: Full resource name from step 2 above (e.g., `projects/674819344439/locations/global/workloadIdentityPools/github/providers/github-provider`)
- `service_account`: Email of deployer SA created above
- `token_format`: "access_token" for use with gcloud, Firebase CLI, and docker
- `access_token_lifetime`: Maximum 3600s (1 hour); shorter is more secure

**Outputs:**

- `access_token`: Short-lived access token (use with `GOOGLE_CLOUD_CHANNEL=default` for gcloud)
- `project_id`: Resolved GCP project ID

**Environment setup:**

The action automatically exports environment variables:
- `GOOGLE_APPLICATION_CREDENTIALS`: Path to a credentials file (if `create_credentials_file: true`, default)
- `CLOUDSDK_PROJECT`: Sets `gcloud` default project
- `GOOGLE_CLOUD_PROJECT`: For application libraries

[Source: google-github-actions/auth README](https://github.com/google-github-actions/auth)

### Deploy Go Service to Cloud Run (from source)

```yaml
- id: deploy
  uses: google-github-actions/deploy-cloudrun@v3
  with:
    service: "recipe-api"
    source: "."
    region: "me-west1"
    project_id: ${{ steps.auth.outputs.project_id }}
    allow_unauthenticated: false
    flags: "--update-env-vars ENVIRONMENT=${{ github.ref_name }}"
```

**Key details:**

- `source: "."`: Deploys from source code; Cloud Build automatically builds using Go buildpack (detects `go.mod`)
- `region`: Choose based on user geography (dev: `me-west1` or `us-central1`, prod: likely `me-west1` for Middle East users)
- `allow_unauthenticated: false`: Cloud Run service requires authentication by default (good for backend)
- `flags`: Pass additional `gcloud run deploy` flags (e.g., `--service-account`, `--min-instances`, `--max-instances`, `--cpu`, `--memory`)
- The action automatically includes GitHub Actions metadata as labels

**Required roles on deployer:** `roles/run.admin`, `roles/iam.serviceAccountUser`, plus source deploy roles (see above)

**Under the hood:**

The action calls `gcloud run deploy --source` which:
1. Uploads source code to Cloud Build
2. Detects Go buildpack (requires `go.mod`)
3. Builds container image in Artifact Registry (`cloud-run-source-deploy` repo, auto-created)
4. Deploys to Cloud Run in specified region

[Source: google-github-actions/deploy-cloudrun README](https://github.com/google-github-actions/deploy-cloudrun)]

### Deploy Firestore Rules and Indexes

```yaml
- name: Deploy Firestore
  env:
    FIREBASE_TOKEN: ${{ steps.auth.outputs.access_token }}
  run: |
    npm install -g firebase-tools
    
    # Set project (using .firebaserc alias or --project flag)
    firebase deploy \
      --project "${{ env.GCP_PROJECT_ID }}" \
      --only firestore:rules,firestore:indexes \
      --non-interactive \
      --force
```

**Alternative: Using credentials file (preferred for CI)**

```yaml
- name: Deploy Firestore
  env:
    GOOGLE_APPLICATION_CREDENTIALS: ${{ steps.auth.outputs.credentials_file_path }}
  run: |
    npm install -g firebase-tools
    firebase deploy \
      --project "${{ env.GCP_PROJECT_ID }}" \
      --only firestore:rules,firestore:indexes \
      --non-interactive
```

**Key details:**

- **`--only firestore:rules,firestore:indexes`:** Deploys both. Use `firestore:rules` or `firestore:indexes` alone to deploy only one
- **`--project`:** Can be a project ID or a `.firebaserc` alias (see below)
- **`--non-interactive`:** Skips prompts (required in CI)
- **`--force`:** Bypasses confirmation prompts for index/ruleset deletions
- **Authentication:** Firebase CLI checks credentials in order: `--token` (deprecated), `FIREBASE_TOKEN` env var (deprecated), `GOOGLE_APPLICATION_CREDENTIALS` env var (recommended), Application Default Credentials via `gcloud auth application-default login`
- **firebase.json:** Must contain:
  ```json
  {
    "firestore": {
      "rules": "firestore/firestore.rules",
      "indexes": "firestore/firestore.indexes.json"
    }
  }
  ```

**Required roles on deployer:** `roles/firebaserules.admin`, `roles/datastore.indexAdmin`

**Gotchas:**

- Rules compilation errors (syntax, unused fields) are caught during `firebase deploy` (no separate test step needed)
- Deploying indexes takes time to complete; the API returns immediately, but index creation is asynchronous
- If local `firestore.indexes.json` doesn't list an existing index, `firebase deploy` **will not** delete it unless `--force` is used (in non-interactive mode, you must use `--force`)
- Rules rulesets have a project limit of **2500 total deployed rulesets**; old versions are auto-deleted when near the limit
- Rules and index changes take **several minutes to fully propagate** to all Firestore nodes

[Sources: Firebase CLI documentation](https://firebase.google.com/docs/cli), [Firebase Rules deployment](https://firebase.google.com/docs/rules/manage-deploy), [Firestore indexes via Firebase CLI](https://firebase.google.com/docs/firestore/query-data/indexing)]

---

## Multi-Environment Workflow (Dev and Prod)

Use GitHub **environments** to separate dev and prod deployments:

```yaml
name: Deploy
on:
  push:
    branches:
      - main

jobs:
  deploy-dev:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write
    environment:
      name: dev
      url: https://recipe-api-dev.run.app
    steps:
      - uses: actions/checkout@v4
      - id: auth
        uses: google-github-actions/auth@v3
        with:
          workload_identity_provider: ${{ secrets.GCP_DEV_WORKLOAD_IDENTITY_PROVIDER }}
          service_account: ${{ secrets.GCP_DEV_SERVICE_ACCOUNT_EMAIL }}
          token_format: "access_token"
      
      - id: deploy
        uses: google-github-actions/deploy-cloudrun@v3
        with:
          service: "recipe-api"
          source: "."
          region: "me-west1"
          project_id: ${{ secrets.GCP_DEV_PROJECT_ID }}
          allow_unauthenticated: false
      
      - name: Deploy Firestore
        env:
          GOOGLE_APPLICATION_CREDENTIALS: ${{ steps.auth.outputs.credentials_file_path }}
        run: |
          npm install -g firebase-tools
          firebase deploy --project "${{ secrets.GCP_DEV_PROJECT_ID }}" --only firestore --non-interactive

  deploy-prod:
    needs: deploy-dev
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write
    environment:
      name: prod
      url: https://recipe-api.run.app
    steps:
      - uses: actions/checkout@v4
      - id: auth
        uses: google-github-actions/auth@v3
        with:
          workload_identity_provider: ${{ secrets.GCP_PROD_WORKLOAD_IDENTITY_PROVIDER }}
          service_account: ${{ secrets.GCP_PROD_SERVICE_ACCOUNT_EMAIL }}
          token_format: "access_token"
      
      - id: deploy
        uses: google-github-actions/deploy-cloudrun@v3
        with:
          service: "recipe-api"
          source: "."
          region: "me-west1"
          project_id: ${{ secrets.GCP_PROD_PROJECT_ID }}
          allow_unauthenticated: false
      
      - name: Deploy Firestore
        env:
          GOOGLE_APPLICATION_CREDENTIALS: ${{ steps.auth.outputs.credentials_file_path }}
        run: |
          npm install -g firebase-tools
          firebase deploy --project "${{ secrets.GCP_PROD_PROJECT_ID }}" --only firestore --non-interactive
```

**Multi-environment strategy:**

- **GitHub environments:** Set protection rules (required reviewers, wait timers) on prod environment
- **Separate WIF pools and SAs per project:** Each dev/prod project gets its own pool, provider, and deployer SA (simplifies rotation and audit trails)
- **Store secrets as repository/environment secrets:** `GCP_DEV_WORKLOAD_IDENTITY_PROVIDER`, `GCP_PROD_WORKLOAD_IDENTITY_PROVIDER`, etc. (WIF provider resource names are public; SA emails are semi-public)
- **Conditional deployment:** Use `needs: deploy-dev` to ensure dev succeeds before prod; add environment protection rules for manual approval on prod

[Source: GitHub Actions — Environments and deployment protection rules](https://docs.github.com/en/actions/managing-workflow-runs-and-deployments/managing-deployments/managing-environments-for-deployment)]

---

## GitHub OIDC Token Subject Claims

The GitHub token's `sub` claim determines which identities can assume the deployer role. For newer repositories (created after 2026-07-15), the format is immutable and includes IDs:

**Format:** `repo:OWNER@OWNER_ID/REPO@REPO_ID:ref:refs/heads/BRANCH`

**Examples:**
- Branch: `repo:CommRogue@55894360/recipe-app@1373086201:ref:refs/heads/main`
- Tag: `repo:CommRogue@55894360/recipe-app@1373086201:ref:refs/tags/v1.0.0`
- Environment: `repo:CommRogue@55894360/recipe-app@1373086201:environment:prod`

The attribute mapping in the provider maps the `sub` to `google.subject`, which becomes the principal identifier for RBAC checks.

[Source: GitHub Actions — OIDC token claims](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/about-security-hardening-with-openid-connect)]

---

## Gotchas and Troubleshooting

### 1. Firebase CLI Incompatibility with Direct WIF

**Problem:** Firebase Admin SDK does not support direct Workload Identity Federation (principalSet on resources).

**Solution:** Use service account impersonation (described above): GitHub token → WIF → impersonate deployer SA → Firebase CLI uses SA.

[Source: google-github-actions/auth README](https://github.com/google-github-actions/auth)

### 2. Attribute Mapping References Non-Existent Claims

**Problem:** If a GitHub token doesn't have a claim you reference (e.g., `environment` when triggered by non-environment event), the mapping fails.

**Solution:** Only map claims you know exist. Optional claims can be handled with CEL logic (not shown in skeleton), but the simple approach is to map only required claims: `sub`, `repository_id`, `repository_owner_id`, `ref`.

[Source: Google Cloud — Workload Identity Federation troubleshooting](https://docs.cloud.google.com/iam/docs/troubleshooting-workload-identity-federation)]

### 3. Token Lifetime and Credential Caching

**Problem:** GitHub OIDC tokens expire in 5 minutes; the WIF-exchanged access token lasts up to 1 hour. If a deployment takes longer than 5 minutes, the original token is stale but the access token is still valid (no re-exchange needed).

**Solution:** None required; the auth action handles this. Just ensure your deploy script completes within the `access_token_lifetime` (default 3600s).

[Source: google-github-actions/auth README](https://github.com/google-github-actions/auth)

### 4. Audience Mismatch

**Problem:** `Error: credential_request_failed: invalid_grant` — the GitHub token's `aud` claim doesn't match what Google expects.

**Root cause:** By default, `aud` equals the WIF provider's full resource name. If you set `--allowed-audiences` on the provider, the token's `aud` must match one of those values.

**Solution:** Leave `--allowed-audiences` empty (or match your default). The google-github-actions/auth action defaults `aud` to the provider resource name.

[Source: Google Cloud — Workload Identity Federation troubleshooting](https://docs.cloud.google.com/iam/docs/troubleshooting-workload-identity-federation)]

### 5. Propagation Delays

**Problem:** IAM policy changes, pool creation, or provider updates don't take effect immediately.

**Timeline:** Up to 5 minutes for propagation. If a deployment fails immediately after setup, wait and retry.

[Source: google-github-actions/auth README](https://github.com/google-github-actions/auth)

### 6. Service Account Permissions Not Inherited

**Problem:** Even if the deployer SA has `roles/iam.serviceAccountUser`, it cannot run as a Cloud Run service with a runtime SA without explicit binding.

**Solution:** Grant `roles/iam.serviceAccountUser` on the **runtime service account** (the SA that Cloud Run services run as), not just the project.

[Source: Cloud Run — Service Identity](https://docs.cloud.google.com/run/docs/securing/service-identity)]

### 7. Cloud Build Service Account Permissions for Source Deploys

**Problem:** `gcloud run deploy --source` fails with permission denied on Cloud Build operations.

**Root cause:** The Compute Engine default service account needs `roles/run.builder` to run builds. If the deployer SA is not also an admin of the project, it cannot grant this role to the Compute Engine SA.

**Solution:** Ensure the deployer SA has `roles/iam.serviceAccountUser` on the Compute Engine default service account (PROJECT_NUMBER-compute@developer.gserviceaccount.com), and that the Compute Engine SA has `roles/run.builder`.

[Source: Cloud Run — Deploying from source code](https://docs.cloud.google.com/run/docs/deploying-source-code)]

---

## Summary: Exact Commands Checklist

For **dev project** (`recipe-app-508817`):

```bash
# 1. Enable APIs
gcloud services enable iam.googleapis.com cloudresourcemanager.googleapis.com \
  iamcredentials.googleapis.com sts.googleapis.com \
  --project=recipe-app-508817

# 2. Create pool
gcloud iam workload-identity-pools create "github" \
  --project=recipe-app-508817 \
  --location=global \
  --display-name="GitHub Actions Pool"

# 3. Get pool ID
POOL_ID=$(gcloud iam workload-identity-pools describe "github" \
  --project=recipe-app-508817 \
  --location=global \
  --format="value(name)")

# 4. Create OIDC provider
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project=recipe-app-508817 \
  --location=global \
  --workload-identity-pool="github" \
  --display-name="CommRogue/recipe-app Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository_id=assertion.repository_id,attribute.repository_owner_id=assertion.repository_owner_id" \
  --attribute-condition="assertion.repository_owner_id == '55894360'" \
  --issuer-uri="https://token.actions.githubusercontent.com"

# 5. Get provider resource name
PROVIDER=$(gcloud iam workload-identity-pools providers describe "github-provider" \
  --project=recipe-app-508817 \
  --location=global \
  --workload-identity-pool="github" \
  --format="value(name)")

# 6. Create deployer service account
gcloud iam service-accounts create "github-actions-deployer" \
  --project=recipe-app-508817 \
  --display-name="GitHub Actions Deployer"

DEPLOYER_SA="github-actions-deployer@recipe-app-508817.iam.gserviceaccount.com"

# 7. Grant WIF pool permission to impersonate deployer
gcloud iam service-accounts add-iam-policy-binding "$DEPLOYER_SA" \
  --project=recipe-app-508817 \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/$POOL_ID/attribute.repository_id/1373086201"

# 8. Grant deployer roles on project
gcloud projects add-iam-policy-binding recipe-app-508817 \
  --member="serviceAccount:$DEPLOYER_SA" \
  --role="roles/run.admin"

gcloud iam service-accounts add-iam-policy-binding \
  "674819344439-compute@developer.gserviceaccount.com" \
  --project=recipe-app-508817 \
  --role="roles/run.builder" \
  --member="serviceAccount:$DEPLOYER_SA"

gcloud projects add-iam-policy-binding recipe-app-508817 \
  --member="serviceAccount:$DEPLOYER_SA" \
  --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding recipe-app-508817 \
  --member="serviceAccount:$DEPLOYER_SA" \
  --role="roles/firebaserules.admin"

gcloud projects add-iam-policy-binding recipe-app-508817 \
  --member="serviceAccount:$DEPLOYER_SA" \
  --role="roles/datastore.indexAdmin"

gcloud projects add-iam-policy-binding recipe-app-508817 \
  --member="serviceAccount:$DEPLOYER_SA" \
  --role="roles/firebase.viewer"

gcloud projects add-iam-policy-binding recipe-app-508817 \
  --member="serviceAccount:$DEPLOYER_SA" \
  --role="roles/serviceusage.serviceUsageConsumer"

# 9. Store secrets in GitHub repo:
#    GCP_DEV_WORKLOAD_IDENTITY_PROVIDER = $PROVIDER
#    GCP_DEV_SERVICE_ACCOUNT_EMAIL = $DEPLOYER_SA
#    GCP_DEV_PROJECT_ID = recipe-app-508817
```

Repeat for **prod project** with appropriate project IDs and repository secret names.

---

## References

All claims in this document are backed by official Google Cloud and GitHub documentation:

- [Google Cloud — Workload Identity Federation](https://docs.cloud.google.com/iam/docs/workload-identity-federation)
- [Google Cloud — WIF with deployment pipelines](https://docs.cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines)
- [Google Cloud — Cloud Run IAM roles](https://docs.cloud.google.com/run/docs/reference/iam/roles)
- [Google Cloud — Cloud Run deploying from source](https://docs.cloud.google.com/run/docs/deploying-source-code)
- [Google Cloud — Cloud Run service identity](https://docs.cloud.google.com/run/docs/securing/service-identity)
- [Google Cloud — Artifact Registry access control](https://docs.cloud.google.com/artifact-registry/docs/access-control)
- [Google Cloud — Firestore IAM and security](https://docs.cloud.google.com/firestore/native/docs/security/iam)
- [Google Cloud — Troubleshooting WIF](https://docs.cloud.google.com/iam/docs/troubleshooting-workload-identity-federation)
- [GitHub — google-github-actions/auth](https://github.com/google-github-actions/auth)
- [GitHub — google-github-actions/deploy-cloudrun](https://github.com/google-github-actions/deploy-cloudrun)
- [Firebase — CLI documentation](https://firebase.google.com/docs/cli)
- [Firebase — Deploying Firestore rules and indexes](https://firebase.google.com/docs/rules/manage-deploy)
- [GitHub Actions — OIDC token claims](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [GitHub Actions — Environments and deployments](https://docs.github.com/en/actions/managing-workflow-runs-and-deployments/managing-deployments/managing-environments-for-deployment)
