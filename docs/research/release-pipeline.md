# Store release pipeline: Shorebird, GitHub Actions, fastlane, iOS without a local Mac

**Research date:** 2026-09-16  
**Audit:** first pass completed by a smaller model after a rate-limit interruption; audited and corrected on 2026-09-17 against the Shorebird, fastlane and GitHub pages cited below (see Audit notes at the end)  
**Question:** How do we build and ship Android and iOS releases from GitHub Actions when the developer's machine is Windows/WSL with no macOS?

---

## Answer: iOS is fully possible without a local Mac, using GitHub Actions macOS runners

**Short answer:** iOS releases and patches can be produced entirely on GitHub's macOS runners; no local Mac is required. The developer's Windows machine is used only for Git, code edits, and triggering workflows. All signing, building, and uploading happens in CI.

---

## Concrete pipeline design

### Workflow structure

Two workflows run on different triggers:

1. **Release workflow** (`release.yml`)
   - Trigger: manual (`workflow_dispatch` with optional inputs for `release-version`, `build-name`)
   - Runs on: `ubuntu-latest` (Android) and `macos-latest` (iOS in separate jobs)
   - Builds an app bundle or IPA using Shorebird, uploads to Shorebird servers
   - Then uploads the artifact to Play Store (Android) / TestFlight (iOS)

2. **Patch workflow** (`patch.yml`)
   - Trigger: manual or tag push matching `v*-hotfix*`
   - Runs on: `ubuntu-latest` (Android) and `macos-latest` (iOS in separate jobs)
   - Builds patches using Shorebird, uploads to Shorebird servers
   - Optionally routes to staging track for testing

### Android job (ubuntu-latest)

```yaml
jobs:
  release_android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'
      - name: Decode and set up Android keystore
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > /tmp/upload.jks
          echo "storePassword=${{ secrets.ANDROID_KEYSTORE_PASSWORD }}" > android/key.properties
          echo "keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}" >> android/key.properties
          echo "storeFile=/tmp/upload.jks" >> android/key.properties
      - uses: shorebirdtech/setup-shorebird@v1
        with:
          cache: true
      - uses: shorebirdtech/shorebird-release@v1
        with:
          platform: android
        env:
          SHOREBIRD_TOKEN: ${{ secrets.SHOREBIRD_TOKEN }}
      - name: Upload to Play internal testing
        run: |
          echo '${{ secrets.PLAY_CONSOLE_SERVICE_ACCOUNT_JSON }}' > /tmp/play.json
          bundle exec fastlane run upload_to_play_store \
            json_key:/tmp/play.json \
            package_name:"$PACKAGE_NAME" \
            aab:build/app/outputs/bundle/release/app-release.aab \
            track:internal
```

`fastlane run <action> key:value` is the CLI form for a single action. In practice put this in an `android/fastlane/Fastfile` lane instead, mirroring iOS. The first build of a new app must be uploaded to Play Console by hand before the API accepts uploads: "you'll need to set up your app manually first by uploading at least one build to Google Play Store" (fastlane `upload_to_play_store` docs).

### iOS job (macos-latest)

Shorebird's fastlane guide recommends a Fastfile lane in which the plugin's `shorebird_release` action replaces `build_app`; "this change from build_app to release_shorebird is the only change needed". Install the plugin with `bundle exec fastlane add_plugin shorebird`.

`ios/fastlane/Fastfile`:

```ruby
lane :release_shorebird do
  setup_ci                                  # temporary keychain on the runner
  api_key = app_store_connect_api_key(
    key_id: ENV["ASC_KEY_ID"],
    issuer_id: ENV["ASC_ISSUER_ID"],
    key_content: ENV["ASC_KEY_P8_BASE64"],
    is_key_content_base64: true
  )
  match(type: "appstore", readonly: true, api_key: api_key)
  shorebird_release(platform: "ios")
  upload_to_testflight(api_key: api_key)
end
```

Workflow job:

```yaml
jobs:
  release_ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shorebirdtech/setup-shorebird@v1
        with:
          cache: true
      - uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
          working-directory: ios
      - name: Release to Shorebird and TestFlight
        working-directory: ios
        run: bundle exec fastlane release_shorebird
        env:
          SHOREBIRD_TOKEN: ${{ secrets.SHOREBIRD_TOKEN }}
          ASC_KEY_ID: ${{ secrets.APP_STORE_CONNECT_KEY_ID }}
          ASC_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          ASC_KEY_P8_BASE64: ${{ secrets.APP_STORE_CONNECT_API_KEY_BASE64 }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          MATCH_GIT_BASIC_AUTHORIZATION: ${{ secrets.MATCH_GIT_BASIC_AUTHORIZATION }}
```

Note that fastlane's `api_key_path` option expects fastlane's own API-key JSON file, not the raw `.p8`, which is why the lane builds the key with `app_store_connect_api_key` instead. The very first run needs one lane execution with `readonly: false` so match can create the distribution certificate and profile through the API key and store them in the private match repo. That also runs on the macOS runner, so no Mac is needed for bootstrap. The demo repo `shorebirdtech/fastlane_demo` is the working reference.

### Patch workflow: staging → production

Patches are created similarly, but with `--track=staging` by default:

```bash
shorebird patch ios --track=staging
# Dev previews on a device, validates, then
shorebird patches set-track --release-version 1.0.0+1 --patch-number 1 --track stable
```

---

## Secrets and their sources

| Secret | Source | How to obtain | Notes |
|--------|--------|---------------|-------|
| `SHOREBIRD_TOKEN` | Shorebird Console | Account → API Keys → Create API Key (copy immediately, shown once) | Deprecated `shorebird login:ci` works until Sept 2026; use console API keys for new tokens |
| `ANDROID_KEYSTORE_BASE64` | Android Studio or keytool | `keytool -genkey -v -keystore upload-keystore.jks ...` then `base64 -w0 upload-keystore.jks` | Generated once, stored securely; if lost, must revoke in Play Console and create new key |
| `ANDROID_KEYSTORE_PASSWORD` | Developer-defined | Password set during keytool generation | Keep same as key password for simplicity |
| `ANDROID_KEY_ALIAS` | Developer-defined | Alias set during keytool generation (default: `upload`) | |
| `ANDROID_KEY_PASSWORD` | Developer-defined | Password set during keytool generation | Same as keystore password recommended |
| `APP_STORE_CONNECT_KEY_ID` | App Store Connect | Users and Access → Integrations → Team Keys → Generate → note the "Key ID" | Not secret |
| `APP_STORE_CONNECT_API_KEY_BASE64` | App Store Connect | Users and Access → Integrations → Team Keys → Generate → Download `.p8` file → `base64 -w0 AuthKey_*.p8` | Downloaded once; if lost, revoke and regenerate. Must use Account Holder or Admin role. |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect | Users and Access → Integrations → API Keys → "Issuer ID" field at top | Not secret; used by fastlane |
| `MATCH_PASSWORD` | Developer-defined | Passphrase for encrypting match certificates in private Git repo | Must match local setup if running match locally; 20+ chars recommended |
| `MATCH_GIT_BASIC_AUTHORIZATION` | GitHub | Personal access token (Settings → Developer settings → Personal access tokens) → `echo -n "username:token" \| base64` | If using SSH keys for match repo, leave empty; if using HTTPS, provide this |
| `PLAY_CONSOLE_SERVICE_ACCOUNT_JSON` | Google Cloud Console | Google Cloud → IAM & Admin → Service Accounts → Select account → Keys → Add Key → JSON (store the raw JSON) | Service account must be invited in Play Console (Users & Permissions) with "Release to testing tracks" permission |

**Total minimum secrets: 7** (if using SSH for match and skipping some optional fields)

---

## Code signing recommendation: fastlane match with App Store Connect API key

For a solo developer (no team):

1. **Use fastlane `match`** with a **private GitHub repo** for certificates and provisioning profiles
   - Eliminates need to store cert `.p12` files in CI secrets (48 KB limit)
   - `match` encrypts and version-controls certificates via Git
   - On CI: `match` syncs them from repo and installs to temporary keychain (via `setup_ci`)
   - On local Mac (if used later): same `match` workflow decrypts from repo

2. **Use App Store Connect API key** (not Apple ID) for fastlane authentication
   - No 2FA needed
   - Better performance
   - Recommended by Apple and fastlane docs for CI

3. **Android**: Use Play App Signing (managed by Google); upload key stored as GitHub secret

---

## Shorebird plan recommendation

**Stay on Free until the public launch, then move to Pro ($20/month, or $240/year).**

Shorebird bills **patch installs**, not patches: "A patch install is" one successful download and application of a patch on one device, and a user who skips several patches is billed once.

| Plan | Price | Monthly patch installs | Overage | Adds |
|---|---|---|---|---|
| Free | $0 | 5,000 | none | unlimited apps and releases |
| Pro | $20/month | 50,000 | $1 per 2,500 installs | patch rollbacks, signed patches, staging, usage notifications |
| Business | $400/month | 1,000,000 | $1 per 2,500 installs | analytics, private support |

During TestFlight and Play internal testing the install count is a handful of devices, so Free is enough. Pro matters at launch for rollbacks and the staging track, and 50,000 installs covers roughly 50,000 active devices each taking one patch a month.

---

## GitHub Actions cost

**$0 for this repository as it stands.** `CommRogue/recipe-app` is public, and "GitHub Actions usage is free for self-hosted runners and for public repositories that use standard GitHub-hosted runners". `ubuntu-latest` and `macos-latest` are standard runners. Larger runners are not free for public repositories.

If the repository is made private, the per-minute rates apply after the plan's included minutes (GitHub Free: 2,000 per month): Linux 2-core $0.006 per minute, standard macOS $0.062 per minute. The per-minute price already reflects the macOS premium; do not multiply it again.

| Job (private repo scenario) | Runner | Minutes | Rate | Cost |
|---|---|---|---|---|
| Android release | ubuntu-latest | 5 | $0.006 | $0.03 |
| iOS release | macos-latest | 10 | $0.062 | $0.62 |
| 2 Android patches | ubuntu-latest | 10 | $0.006 | $0.06 |
| 2 iOS patches | macos-latest | 20 | $0.062 | $1.24 |
| **Total per month** | | | | **about $2**, before included minutes |

Build durations are estimates, not measurements. Flutter iOS builds on hosted macOS runners commonly take longer than 10 minutes; measure once the scaffold exists.

---

## Gotchas and critical notes

1. **iOS requires macOS runner, period.** The Shorebird docs state explicitly: "To release for iOS or macOS, you must run this command on macOS hardware." This is a Flutter/Xcode limitation, not Shorebird's. Use `runs-on: macos-latest` (currently macOS 26 arm64 M1/M3) or `macos-15`.

2. **Android must have signing configured before Shorebird step.** Without the `key.properties` file, Gradle falls back to the debug key, causing Play Console rejection (`INSTALL_PARSE_FAILED_NO_CERTIFICATES`).

3. **Patch Flutter version pinning:** A patch must use the same Flutter version as its release. `shorebird patch --flutter-version` flag does not exist; patches inherit the release's version. Upgrades require new releases.

4. **No native or asset changes in patches.** Patches support Dart code only. Changes to Kotlin, Swift, assets, or build configs require a new release. Shorebird flags these and refuses upload unless you add `--allow-native-diffs` or `--allow-asset-diffs`.

5. **App Store Connect API key: one-time download.** The `.p8` file can only be downloaded once from App Store Connect. Store securely; if lost, revoke the key in App Store Connect and generate a new one.

6. **TestFlight availability.** Builds are available for up to 90 days. After that, testers can no longer install them.

7. **Play Store: new accounts need closed testing first.** Accounts created after Nov 13, 2023 must run a closed test (≥12 testers, ≥14 days) before accessing production release. Shorebird + fastlane target internal testing track to avoid this initially.

8. **Staging track is Shorebird's feature, not Play/TestFlight's.** The staging track lets you validate patches on real devices before promoting to stable; it does not gate the app in the Play Store or TestFlight. Both still expose released versions to users; only Shorebird patches can be routed via tracks.

9. **Rollback requires the Pro plan or above.** Patch rollbacks, signed patches and the staging track are not on the Free plan (Shorebird pricing comparison).

10. **Export Options plist for iOS signing.** If using fastlane, the `shorebird_release` action auto-generates `ExportOptions.plist` with the correct settings (app-store method, manual signing, provisioning profiles from match). If you pass your own plist, ensure `manageAppVersionAndBuildNumber` is **false**, or Xcode will overwrite the build number after Shorebird creates the IPA.

11. **Play's first upload is manual.** The Play Developer API rejects uploads for an app that has never had a build uploaded through the Console. Build the first `.aab` in CI, download the artifact, and upload it by hand once.

12. **Local machine needs ONLY Git and editor.** Shorebird CLI, Flutter, Xcode, Android SDK, and fastlane all run on GitHub Actions. The Windows dev machine does not need them (though optional local testing via `shorebird preview` on macOS is useful).

13. **Deprecation notice:** `shorebird login:ci` command is deprecated; existing tokens work until September 2026. Switch to console API keys now.

---

## Citations

- **Shorebird GitHub CI setup:** https://docs.shorebird.dev/code-push/ci/github/
- **Shorebird release command:** https://docs.shorebird.dev/code-push/release/
- **Shorebird patch command:** https://docs.shorebird.dev/code-push/patch/
- **Shorebird API keys & authentication:** https://docs.shorebird.dev/account/api-keys/
- **Shorebird billing & pricing:** https://docs.shorebird.dev/account/billing/ and https://shorebird.dev/pricing/
- **Shorebird fastlane integration:** https://docs.shorebird.dev/code-push/ci/fastlane/
- **Shorebird tracks (staging/production):** https://docs.shorebird.dev/code-push/tracks/
- **fastlane match (code signing):** https://docs.fastlane.tools/actions/match/
- **fastlane setup_ci (CI integration):** https://docs.fastlane.tools/actions/setup_ci/
- **fastlane upload_to_testflight (TestFlight):** https://docs.fastlane.tools/actions/upload_to_testflight/
- **fastlane upload_to_play_store (Play Console):** https://docs.fastlane.tools/actions/upload_to_play_store/
- **App Store Connect API keys:** https://developer.apple.com/help/app-store-connect/get-started/app-store-connect-api
- **Google Play service account setup:** https://developers.google.com/android-publisher/getting_started
- **GitHub Actions macOS runners:** https://github.com/actions/runner-images
- **GitHub Actions billing (free for public repos on standard runners):** https://docs.github.com/en/billing/concepts/product-billing/github-actions
- **GitHub Actions runner per-minute pricing:** https://docs.github.com/en/billing/reference/actions-runner-pricing
- **fastlane App Store Connect API key formats:** https://docs.fastlane.tools/app-store-connect-api/
- **Flutter iOS build & signing:** https://docs.flutter.dev/deployment/ios
- **Flutter Android build & signing:** https://docs.flutter.dev/deployment/android
- **Android App Signing (Play App Signing):** https://developer.android.com/studio/publish/app-signing
- **Shorebird fastlane_demo repo:** https://github.com/shorebirdtech/fastlane_demo
- **Fastlane plugin for Shorebird:** https://github.com/shorebirdtech/fastlane-plugin-shorebird
- **Shorebird patch-signing:** https://docs.shorebird.dev/code-push/guides/patch-signing/
- **Shorebird staging patches guide:** https://docs.shorebird.dev/code-push/guides/staging-patches/
- **Shorebird FAQ:** https://docs.shorebird.dev/code-push/faq/

---

## Audit notes (2026-09-17)

Verified as written: iOS releases and patches need macOS hardware and can run entirely on GitHub macOS runners; `setup-shorebird` and `SHOREBIRD_TOKEN` from a console API key; `login:ci` deprecation with tokens valid until September 2026; Android keystore handling and the debug-key failure mode; Shorebird plan prices and install allowances.

Corrected: the GitHub Actions cost estimate (it multiplied the macOS per-minute price by ten a second time, and missed that this public repository pays nothing on standard runners); "patches per month" to "patch installs per month"; the fastlane command lines, which were not valid CLI syntax and passed the `.p8` where fastlane expects its JSON key format; the plan recommendation, now Free until launch. Added the manual first Play upload and the match bootstrap run.

Not re-verified: the Play closed-testing rule for new personal accounts (12 testers for 14 days), TestFlight's 90-day build expiry, and the `ExportOptions.plist` behaviour of `shorebird_release`. Check these when the App CI ticket is worked.
