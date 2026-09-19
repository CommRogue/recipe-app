#!/usr/bin/env bash
#
# End-to-end check of the deployed service (#18's definition of done): mint a
# Firebase ID token for a test user without a client app, then call
# POST /v1/generate and print the Draft.
#
# How the token is minted: the IAM Credentials API signs a Firebase custom
# token as a service account (the caller needs roles/iam.serviceAccountTokenCreator
# on it), and Identity Toolkit exchanges that for an ID token, exactly as a
# client would after signInWithCustomToken. Nothing is written to disk.
#
#   backend/scripts/e2e-generate.sh
#   ASK="quick breakfast" MAX_MINUTES=15 backend/scripts/e2e-generate.sh
#   SERVICE_URL=http://localhost:8080 backend/scripts/e2e-generate.sh   # local server
#
# Requires: gcloud (logged in as a project Owner or as someone with Token
# Creator on the minter SA), curl, jq, python3.

set -euo pipefail

PROJECT="${PROJECT:-recipe-app-508817}"
REGION="${REGION:-me-west1}"
SERVICE="${SERVICE:-recipe-api}"
MINTER_SA="${MINTER_SA:-recipe-api-runtime@$PROJECT.iam.gserviceaccount.com}"
TEST_UID="${TEST_UID:-e2e-test-user}"
ASK="${ASK:-something Asian for tonight}"
MAX_MINUTES="${MAX_MINUTES:-30}"

for tool in gcloud curl jq python3; do
  command -v "$tool" >/dev/null || { echo "$tool is required" >&2; exit 1; }
done

ACCESS_TOKEN=$(gcloud auth print-access-token)
QP=(-H "Authorization: Bearer $ACCESS_TOKEN" -H "x-goog-user-project: $PROJECT")

if [[ -z "${SERVICE_URL:-}" ]]; then
  SERVICE_URL=$(gcloud run services describe "$SERVICE" --region "$REGION" --project "$PROJECT" --format='value(status.url)')
fi
echo "service: $SERVICE_URL" >&2

# The Firebase Web API key of the project, from the Identity Toolkit config.
API_KEY=$(curl -sS "${QP[@]}" "https://identitytoolkit.googleapis.com/admin/v2/projects/$PROJECT/config" | jq -r '.client.apiKey')
[[ -n "$API_KEY" && "$API_KEY" != null ]] || { echo "could not read the Firebase API key" >&2; exit 1; }

# 1. Custom token: a JWT with iss/sub = the minter SA, aud = Identity Toolkit,
#    uid = the test user, signed by IAM Credentials signJwt.
NOW=$(date +%s)
CLAIMS=$(python3 - "$MINTER_SA" "$TEST_UID" "$NOW" <<'PY'
import json, sys
sa, uid, now = sys.argv[1], sys.argv[2], int(sys.argv[3])
print(json.dumps({
    "iss": sa, "sub": sa,
    "aud": "https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit",
    "iat": now, "exp": now + 3600, "uid": uid,
}))
PY
)
CUSTOM_TOKEN=$(curl -sS --fail "${QP[@]}" -H "Content-Type: application/json" \
  "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/$MINTER_SA:signJwt" \
  -d "$(jq -cn --arg p "$CLAIMS" '{payload: $p}')" | jq -r '.signedJwt')
[[ -n "$CUSTOM_TOKEN" && "$CUSTOM_TOKEN" != null ]] || { echo "signJwt failed; do you have roles/iam.serviceAccountTokenCreator on $MINTER_SA?" >&2; exit 1; }

# 2. Exchange it for a Firebase ID token, as a client does after signInWithCustomToken.
ID_TOKEN=$(curl -sS --fail -H "Content-Type: application/json" \
  "https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=$API_KEY" \
  -d "$(jq -cn --arg t "$CUSTOM_TOKEN" '{token: $t, returnSecureToken: true}')" | jq -r '.idToken')
[[ -n "$ID_TOKEN" && "$ID_TOKEN" != null ]] || { echo "signInWithCustomToken failed" >&2; exit 1; }
echo "signed in as uid $TEST_UID" >&2

# 3. Health, then generate.
curl -sS --fail "$SERVICE_URL/healthz" >/dev/null && echo "healthz ok" >&2

BODY=$(jq -cn --arg ask "$ASK" --argjson m "$MAX_MINUTES" '{ask: $ask, limits: {maxTotalMinutes: $m}}')
echo "POST /v1/generate $BODY" >&2
START=$(date +%s)
HTTP=$(curl -sS -o /tmp/e2e-draft.json -w '%{http_code}' \
  -H "Authorization: Bearer $ID_TOKEN" -H "Content-Type: application/json" \
  "$SERVICE_URL/v1/generate" -d "$BODY")
echo "HTTP $HTTP in $(( $(date +%s) - START ))s" >&2
jq . /tmp/e2e-draft.json
[[ "$HTTP" == 200 ]]
