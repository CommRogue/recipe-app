# In-app subscriptions in Flutter with server-side entitlement

Research for [issue #12](https://github.com/CommRogue/recipe-app/issues/12), part of the [v1 map](https://github.com/CommRogue/recipe-app/issues/1). Vocabulary from `CONTEXT.md`: **Plan** (Free or Paid), **Subscription** (the store purchase that grants the Paid Plan while active), **Quota** (generations a Plan allows per period).

Settled context this builds on: Flutter on Android and iOS, Firebase Auth, Firestore client-direct (ADR 0001), one Go service on Cloud Run that owns model calls and Quota and must be able to trust the user's Plan (ADR 0002), solo developer on Windows/WSL with no local macOS.

## Question

How should the Paid Plan be sold and enforced? Compare RevenueCat against the first-party `in_app_purchase` plugin plus our own server: store setup, purchase validation, turning store notifications into a Plan field in Firestore that only the backend writes and the Go backend trusts, sandbox testing, restore purchases, grace periods and billing retry, and cost.

## Recommendation

**Use RevenueCat (`purchases_flutter`) with the Firebase UID as the RevenueCat App User ID, and point a RevenueCat webhook at a new endpoint on the existing Go service, which is the only writer of the Plan field on the user's Firestore document.** Skip the RevenueCat Firebase Extension and skip `in_app_purchase` with a self-built server.

Reasoning:

1. **The self-built path is two store integrations, not one.** Apple's App Store Server Notifications V2 arrive as a JWS `signedPayload` you must decode and validate ([Apple, Receiving notifications](https://developer.apple.com/documentation/appstoreservernotifications/receiving-app-store-server-notifications)); calling the App Store Server API needs an ES256-signed JWT per request ([Apple, Generating JWTs](https://developer.apple.com/documentation/appstoreserverapi/generating-json-web-tokens-for-api-requests)); Apple's helper library exists in "four languages": Swift, Java, Python and Node, not Go ([Apple, App Store Server Library](https://developer.apple.com/documentation/appstoreserverapi/simplifying-your-implementation-by-using-the-app-store-server-library)). Google's notifications "tell you only that the purchase state changed", so every one needs a follow-up `purchases.subscriptionsv2.get` call ([Google, RTDN reference](https://developer.android.com/google/play/billing/rtdn-reference)), plus acknowledgement "within three days so that the purchase isn't automatically refunded" ([Google, Integrate](https://developer.android.com/google/play/billing/integrate)). The two lifecycles differ (Apple has 5 subscription statuses, Google has 9 states) and both must be mapped to one Plan. That is a lot of correctness-critical code for a solo developer whose product is recipes.
2. **RevenueCat collapses both into one webhook and one entitlement.** Transactions "will be automatically completed (finished on iOS, acknowledged and consumed in Android)" ([RevenueCat, Making purchases](https://www.revenuecat.com/docs/getting-started/making-purchases)); the webhook has a fixed event vocabulary with `app_user_id`, `entitlement_ids`, `expiration_at_ms`, `grace_period_expiration_at_ms` and `environment` ([RevenueCat, Event types and fields](https://www.revenuecat.com/docs/integrations/webhooks/event-types-and-fields)); the SDK's `restorePurchases`, offline entitlements and caching come for free ([RevenueCat, Customer info](https://www.revenuecat.com/docs/customers/customer-info)).
3. **Cost is negligible until the app earns real money.** "Pay nothing for up to $2,500 in monthly tracked revenue", then "1% of what you track" ([RevenueCat pricing](https://www.revenuecat.com/pricing)). At $2,500 MTR the fee is $25/month, against the store's 15 to 30 percent.
4. **The webhook into Go, not the Firebase Extension, fits the ADRs.** ADR 0002 says future server features "extend this service rather than adding Cloud Functions"; the extension is a Cloud Function and requires the Blaze plan ([RevenueCat, Firebase integration](https://www.revenuecat.com/docs/integrations/third-party-integrations/firebase-integration)). It also writes RevenueCat's own customer document shape rather than our `Plan` field. The webhook handler is roughly 100 lines of Go and keeps the "only the backend writes the Plan" rule literal.
5. **Server-side trust is preserved.** The client never writes the Plan; it reads it from its own Firestore document (client-direct per ADR 0001) and the Go service reads the same document when enforcing Quota, with the RevenueCat REST API as a tie-breaker.

Consequence for the ADRs: ADR 0002 says the Go service owns "model calls and nothing else"; add an ADR (or amend 0002) recording that it also owns the Subscription webhook and the Plan field, which is Quota-adjacent and the only place a trusted write can happen.

## Comparison

| Concern | RevenueCat (`purchases_flutter`) | `in_app_purchase` + own Go server |
|---|---|---|
| Client SDK | `purchases_flutter` 10.12.0, verified publisher revenuecat.com, iOS 13+, Android SDK 21+ ([pub.dev](https://pub.dev/packages/purchases_flutter)); requires Flutter 3.22+ and `FlutterFragmentActivity` on Android ([RevenueCat, Flutter install](https://www.revenuecat.com/docs/getting-started/installation/flutter)) | `in_app_purchase` 3.3.0, verified publisher flutter.dev, Android SDK 24+, iOS 13+, StoreKit 2 by default ([pub.dev](https://pub.dev/packages/in_app_purchase)) |
| Purchase validation | RevenueCat validates with the stores and finishes/acknowledges transactions ([Making purchases](https://www.revenuecat.com/docs/getting-started/making-purchases)) | Plugin only points you at each store's guide: "validate restored purchases following the best practices for each underlying store" ([README](https://github.com/flutter/packages/blob/main/packages/in_app_purchase/in_app_purchase/README.md)). You verify JWS (Apple) or call `subscriptionsv2.get` (Google), then must call `completePurchase` or Android refunds after 3 days and iOS keeps redelivering the transaction ([README](https://github.com/flutter/packages/blob/main/packages/in_app_purchase/in_app_purchase/README.md)) |
| Tying a purchase to the Firebase user | `Purchases.configure(PurchasesConfiguration(key)..appUserID = uid)`; IDs must be unique, not guessable, under 100 chars ([Identifying customers](https://www.revenuecat.com/docs/customers/identifying-customers)) | `PurchaseParam.applicationUserName` becomes StoreKit 2 `appAccountToken` (must be a UUID) and Play `obfuscatedAccountId` ([storekit platform source](https://github.com/flutter/packages/blob/main/packages/in_app_purchase/in_app_purchase_storekit/lib/src/in_app_purchase_storekit_platform.dart), [android platform source](https://github.com/flutter/packages/blob/main/packages/in_app_purchase/in_app_purchase_android/lib/src/in_app_purchase_android_platform.dart)); you keep the mapping table yourself |
| Store notifications | Apple: paste RevenueCat's URL as both Production and Sandbox Server URL; RevenueCat can forward to your server too ([Apple server notifications](https://www.revenuecat.com/docs/platform-resources/server-notifications/apple-server-notifications)). Google: RevenueCat creates the Pub/Sub topic; you grant `google-play-developer-notifications@system.gserviceaccount.com` Pub/Sub Publisher and paste the topic in Play Console ([Google server notifications](https://www.revenuecat.com/docs/platform-resources/server-notifications/google-server-notifications)) | Apple: your HTTPS endpoint, TLS 1.2+, 200-206 to ack, 5 retries over 72 h in production only ([Enabling](https://developer.apple.com/documentation/appstoreservernotifications/enabling-app-store-server-notifications), [Responding](https://developer.apple.com/documentation/appstoreservernotifications/responding-to-app-store-server-notifications)). Google: your Pub/Sub topic, push subscription to Cloud Run with a service account holding `roles/run.invoker` ([Cloud Run Pub/Sub](https://docs.cloud.google.com/run/docs/tutorials/pubsub)), then a Developer API call per message ([Getting ready](https://developer.android.com/google/play/billing/getting-ready)) |
| One webhook to your server | Yes: at-least-once, 200 within 60 s, 5 retries at 5/10/20/40/80 min, optional HMAC-SHA256 `X-RevenueCat-Webhook-Signature` ([Webhooks](https://www.revenuecat.com/docs/integrations/webhooks)) | You are the webhook: two inbound formats, two auth schemes |
| Server-side status lookup | REST v2 `GET /projects/{project_id}/customers/{customer_id}` returns `active_entitlements`, 480 req/min, secret `sk_` key ([API v2](https://www.revenuecat.com/docs/api-v2), [API keys](https://www.revenuecat.com/docs/projects/authentication)) | Apple `GET /inApps/v1/subscriptions/{anyTransactionId}` at 50 req/s per app, JWT auth ([Get All Subscription Statuses](https://developer.apple.com/documentation/appstoreserverapi/get-all-subscription-statuses), [Rate limits](https://developer.apple.com/documentation/appstoreserverapi/identifying-rate-limits)). Google `PurchasesSubscriptionsv2Service.Get(packageName, token)` in `google.golang.org/api/androidpublisher/v3`, 3000 queries/min default ([Go package](https://pkg.go.dev/google.golang.org/api/androidpublisher/v3), [Quotas](https://developers.google.com/android-publisher/quotas)) |
| Go support | Plain HTTP JSON webhook and REST | No official Apple library for Go; JWS chain validation and JWT signing are hand-rolled |
| Restore | `Purchases.restorePurchases()` from a user tap; default restore behaviour transfers purchases to the new App User ID and emits `TRANSFER` ([Restoring](https://www.revenuecat.com/docs/getting-started/restoring-purchases), [Restore behaviour](https://www.revenuecat.com/docs/projects/restore-behavior)) | `InAppPurchase.instance.restorePurchases()` re-emits purchases on `purchaseStream`; you decide what a restore on a different Firebase account means |
| Grace period and billing retry | `BILLING_ISSUE` with `grace_period_expiration_at_ms`; entitlement stays active during grace; then `RENEWAL` or `EXPIRATION` ([Event flows](https://www.revenuecat.com/docs/integrations/webhooks/event-flows)) | Apple: `DID_FAIL_TO_RENEW` (subtype `GRACE_PERIOD`), `GRACE_PERIOD_EXPIRED`, `DID_RENEW` (subtype `BILLING_RECOVERY`), `EXPIRED` ([notificationType](https://developer.apple.com/documentation/appstoreservernotifications/notificationtype)). Google: `SUBSCRIPTION_IN_GRACE_PERIOD` (keep access), `SUBSCRIPTION_ON_HOLD` (revoke), `SUBSCRIPTION_RECOVERED`, `SUBSCRIPTION_EXPIRED` ([RTDN reference](https://developer.android.com/google/play/billing/rtdn-reference), [Subscriptions](https://developer.android.com/google/play/billing/subscriptions)) |
| Sandbox detection | Automatic; webhook `environment` is `SANDBOX` or `PRODUCTION`; separate webhook per environment allowed ([Sandbox](https://www.revenuecat.com/docs/test-and-launch/sandbox), [Webhooks](https://www.revenuecat.com/docs/integrations/webhooks)) | Apple sandbox uses `api.storekit-sandbox.apple.com` and one delivery attempt with no retries ([Server API](https://developer.apple.com/documentation/appstoreserverapi), [Responding](https://developer.apple.com/documentation/appstoreservernotifications/responding-to-app-store-server-notifications)); Google marks `testPurchase` on the resource ([subscriptionsv2](https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptionsv2)) |
| Dashboard, charts, paywalls | Included, "No plans, no gates" ([Pricing](https://www.revenuecat.com/pricing)) | Build or go without |
| Vendor cost | Free to $2,500 MTR, then 1% of MTR ([Pricing](https://www.revenuecat.com/pricing)) | None beyond Cloud Run |
| Lock-in | Moderate: purchases are still store purchases; RevenueCat stores the mapping to App User IDs | None |

## Store setup (both paths need this)

**App Store Connect.** The Account Holder must sign the Paid Applications Agreement and link a bank account with status "Clear" before purchases can be tested ([RevenueCat, iOS products](https://www.revenuecat.com/docs/getting-started/entitlements/ios-products); [Apple, Sandbox testing](https://developer.apple.com/documentation/storekit/testing-in-app-purchases-with-sandbox)). Create a Subscription Group, then a subscription with reference name, Product ID, duration, price, availability and review information; "Your first auto-renewable subscription must be submitted with a new app version" ([Apple, Offer auto-renewable subscriptions](https://developer.apple.com/help/app-store-connect/manage-subscriptions/offer-auto-renewable-subscriptions/)). Enable Billing Grace Period explicitly (3, 16 or 28 days; weekly plans cap at 6) ([Apple, Billing Grace Period](https://developer.apple.com/help/app-store-connect/manage-subscriptions/enable-billing-grace-period-for-auto-renewable-subscriptions)). RevenueCat needs an In-App Purchase Key (.p8) and the Issuer ID ([RevenueCat, In-app purchase key](https://www.revenuecat.com/docs/service-credentials/itunesconnect-app-specific-shared-secret/in-app-purchase-key-configuration)).

**Google Play Console.** Set up a payments profile; upload a build before products can be created; a subscription needs at least one activated base plan, and product IDs can never be reused across your apps ([Google, Create and manage subscriptions](https://support.google.com/googleplay/android-developer/answer/140504); [RevenueCat, Android products](https://www.revenuecat.com/docs/getting-started/entitlements/android-products)). RevenueCat identifies Play products as `<subscription_id>:<base-plan_id>` ([RevenueCat, Android products](https://www.revenuecat.com/docs/getting-started/entitlements/android-products)). Grace period and account hold are per base plan; "By default, all auto-renewing base plans have account hold enabled and the lengths are automatically calculated. The calculation will be 60 days minus any grace period duration", and the two must total at least 30 days ([Google, Understanding subscriptions](https://support.google.com/googleplay/android-developer/answer/12154973); [Google, Recovery period changes](https://support.google.com/googleplay/android-developer/answer/16631229)). RevenueCat needs a service account JSON with Play permissions (view financial data, manage orders and subscriptions) and Pub/Sub Editor, and "It can take up to 36 hours for new Play service credentials to work" ([RevenueCat, Play credentials](https://www.revenuecat.com/docs/service-credentials/creating-play-service-credentials)).

**RevenueCat project.** One entitlement, suggested id `paid`, attached to the App Store and Play products; one offering with monthly and annual packages. Use the platform-specific public API keys in the app, never the Test Store key in production ([RevenueCat, Sandbox](https://www.revenuecat.com/docs/test-and-launch/sandbox)).

## Entitlement data flow

```
Firebase sign-in ──► Purchases.configure(appUserID = uid) ──► Purchases.purchase(package)
                                                                      │
                     App Store / Google Play  ◄───────────────────────┘
                              │ ASSN v2 / RTDN (renewal, billing issue, expiry, refund, transfer)
                              ▼
                        RevenueCat  ──── webhook (POST, Authorization or HMAC) ────►  Go on Cloud Run
                              ▲                                                            │
                              │ REST v2 GET customer (tie-breaker)                          │ Admin SDK write
                              └────────────────────────────────────────────────────────────┤
                                                                                           ▼
                                                        Firestore users/{uid}: plan, planExpiresAt, ...
                                                             ▲                       ▲
                                              client reads (rules)         Go reads at generate time
```

### 1. Client identity

Configure once at launch with the Firebase UID: `Purchases.configure(PurchasesConfiguration(key)..appUserID = uid)`; for apps with their own auth, "Only configure the SDK with a custom App User ID, and never call `.logout()`", and call `Purchases.logIn(newUid)` on account switch ([RevenueCat, Identifying customers](https://www.revenuecat.com/docs/customers/identifying-customers)). Firebase UIDs satisfy the "unique, not guessable, under 100 characters" rule. This is also what the Firebase integration requires: "the `app_user_id` of the user to match the user's Firebase Authentication UID" ([RevenueCat, Firebase integration](https://www.revenuecat.com/docs/integrations/third-party-integrations/firebase-integration)).

### 2. Purchase

`final result = await Purchases.purchase(PurchaseParams.package(package));` then check `result.customerInfo.entitlements.all["paid"]?.isActive` ([RevenueCat, Making purchases](https://www.revenuecat.com/docs/getting-started/making-purchases)). The client may unlock the Paid UI immediately from `CustomerInfo`, but this is cosmetic; Quota is enforced from Firestore by Go.

### 3. Store event to RevenueCat

Apple: enter RevenueCat's URL as both Production and Sandbox Server URL in App Store Connect and choose V2 ([RevenueCat, Apple server notifications](https://www.revenuecat.com/docs/platform-resources/server-notifications/apple-server-notifications)); Apple allows one URL per environment ([Apple, Enabling](https://developer.apple.com/documentation/appstoreservernotifications/enabling-app-store-server-notifications)). Google: let RevenueCat create the Pub/Sub topic, grant Google's notifications service account Pub/Sub Publisher, paste the topic in Play Console Monetization setup and select subscriptions ([RevenueCat, Google server notifications](https://www.revenuecat.com/docs/platform-resources/server-notifications/google-server-notifications)).

### 4. RevenueCat webhook to Go

Register one webhook per environment: sandbox events to the dev Cloud Run service, production events to prod ("You can set up multiple webhook integrations per project – for example, if you use a different backend for production and sandbox/testing") ([RevenueCat, Webhooks](https://www.revenuecat.com/docs/integrations/webhooks)). The Go handler `POST /webhooks/revenuecat`:

1. Verify the `Authorization` header value or the HMAC over the raw body (`X-RevenueCat-Webhook-Signature: t=<ts>,v1=<hex>`), and reject `environment` values that do not match the deployment ([Webhooks](https://www.revenuecat.com/docs/integrations/webhooks)).
2. Respond 200 within 60 s; do the write synchronously (a Firestore write is milliseconds) so retries stay simple.
3. Dedupe on event `id` (delivery is at-least-once) and drop events older than the stored `planEventTimestampMs` (ordering is not guaranteed; the Firebase extension keeps the same watermark, `rc_last_event_timestamp_ms`, for this reason) ([Webhooks](https://www.revenuecat.com/docs/integrations/webhooks); [extension POSTINSTALL](https://github.com/RevenueCat/firestore-revenuecat-purchases/blob/main/POSTINSTALL.md)).
4. Treat the event as a trigger, not as the truth: call REST v2 `GET /projects/{project_id}/customers/{app_user_id}` with the secret key and read `active_entitlements` ([API v2](https://www.revenuecat.com/docs/api-v2)). This sidesteps hand-mapping 21 event types and makes `TRANSFER` (fetch both `app_user_id` and the origin user) and out-of-order deliveries harmless. 480 requests/minute is far above any plausible event rate.
5. Write with the Admin SDK to `users/{uid}`: `plan: "paid" | "free"`, `planExpiresAt` (entitlement `expires_at`, null for free), `planStore`, `planEventTimestampMs`, `planUpdatedAt`.

If the REST call is undesirable, the direct mapping is: `INITIAL_PURCHASE`, `RENEWAL`, `UNCANCELLATION`, `PRODUCT_CHANGE`, `SUBSCRIPTION_EXTENDED` set paid with `expiration_at_ms`; `CANCELLATION` leaves the Plan alone (access lasts to the period end); `BILLING_ISSUE` sets `planExpiresAt = grace_period_expiration_at_ms` while keeping paid; `EXPIRATION` sets free; `TRANSFER` sets the origin user free and the target paid; `TEST` is a 200 no-op ([Event types](https://www.revenuecat.com/docs/integrations/webhooks/event-types-and-fields); [Event flows](https://www.revenuecat.com/docs/integrations/webhooks/event-flows)).

### 5. Firestore rules: the client never writes the Plan

Users already read and update their own `users/{uid}` document (ADR 0001). Restrict updates so the Plan keys are untouchable from the client, using the field-level pattern from the Firestore docs ([Firebase, Control access to specific fields](https://firebase.google.com/docs/firestore/security/rules-fields)):

```
match /users/{uid} {
  allow read: if request.auth != null && request.auth.uid == uid;
  allow create: if request.auth != null && request.auth.uid == uid
    && !request.resource.data.keys().hasAny(['plan', 'planExpiresAt', 'planStore', 'planEventTimestampMs', 'planUpdatedAt']);
  allow update: if request.auth != null && request.auth.uid == uid
    && !request.resource.data.diff(resource.data).affectedKeys()
        .hasAny(['plan', 'planExpiresAt', 'planStore', 'planEventTimestampMs', 'planUpdatedAt']);
}
```

The Admin SDK used by Go bypasses rules, so the backend remains the sole writer. Custom claims were considered and rejected: they propagate only when the ID token refreshes, are capped at 1000 bytes, and Firebase says they "are only used to provide access control. They are not designed to store additional data" ([Firebase, Custom claims](https://firebase.google.com/docs/auth/admin/custom-claims)); a document field the client already listens to is simpler and instant.

### 6. Go backend check at generate time

`client.VerifyIDToken(ctx, idToken)` yields the `uid` ([Firebase, Verify ID tokens](https://firebase.google.com/docs/auth/admin/verify-id-tokens)). Read `users/{uid}`; effective Plan is Paid when `plan == "paid"` and (`planExpiresAt` is null or in the future by server clock), otherwise Free. If `plan == "paid"` but `planExpiresAt` has passed (a missed `EXPIRATION`), call the REST v2 customer endpoint, rewrite the document, and use the fresh answer. Quota is then chosen from the Plan; the accounting itself is the "Quota accounting and Plan enforcement" item on the map.

### 7. Restore purchases

Apple requires a restore affordance: "Include some mechanism in your app, such as a Restore Purchases button" and "Don't automatically restore purchases, especially when your app launches" ([Apple, Restoring purchased products](https://developer.apple.com/documentation/storekit/restoring-purchased-products)); the subscription sign-up screen must offer "A way for current subscribers to sign in or restore purchases" ([Apple, Subscriptions](https://developer.apple.com/app-store/subscriptions/)). Call `Purchases.restorePurchases()` from a button only ([RevenueCat, Restoring](https://www.revenuecat.com/docs/getting-started/restoring-purchases)). Keep the default restore behaviour, "Transfer to new App User ID" ([RevenueCat, Restore behaviour](https://www.revenuecat.com/docs/projects/restore-behavior)): a user who reinstalls and signs in with a different Firebase account still gets their Subscription, and the resulting `TRANSFER` webhook lets Go set the old UID to Free and the new one to Paid.

## Testing plan

**Constraint.** The development machine is Windows/WSL with no macOS, so Xcode StoreKit Configuration files ("StoreKit testing only works if you are running your app directly through Xcode", [RevenueCat, Apple sandbox](https://www.revenuecat.com/docs/test-and-launch/sandbox/apple-app-store)) are not an option. iOS testing runs on a physical iPhone using TestFlight builds produced by the fastlane pipeline; "Apps that you download from TestFlight always run in the sandbox environment" ([Apple, Sandbox testing](https://developer.apple.com/documentation/storekit/testing-in-app-purchases-with-sandbox)).

**iOS.**
1. Create Sandbox Apple Accounts in App Store Connect under Users and Access > Sandbox with emails not already registered as Apple Accounts ([Apple, Create a Sandbox Apple Account](https://developer.apple.com/help/app-store-connect/test-in-app-purchases/create-a-sandbox-apple-account)).
2. On the device: sign out of Media & Purchases, then Settings > Developer > Sandbox Apple Account > Sign In ([Apple, Sandbox testing](https://developer.apple.com/documentation/storekit/testing-in-app-purchases-with-sandbox)).
3. Sandbox renewals are accelerated ("1 month = 5 minutes", up to 12 renewals per day; TestFlight renews once every 24 hours) ([RevenueCat, Apple sandbox](https://www.revenuecat.com/docs/test-and-launch/sandbox/apple-app-store)). Use the iOS sandbox Account Settings to change the renewal rate, enable interrupted purchases, and clear purchase history; Apple provides dedicated scenarios for "failed subscription renewals that are in the billing retry or billing grace period states" ([Apple, Sandbox testing](https://developer.apple.com/documentation/storekit/testing-in-app-purchases-with-sandbox)).
4. Enable Billing Grace Period for "Only Sandbox Environment" first ([Apple, Billing Grace Period](https://developer.apple.com/help/app-store-connect/manage-subscriptions/enable-billing-grace-period-for-auto-renewable-subscriptions)).

**Android.**
1. Add the test Google account under Play Console > Settings > License testing; upload a signed build to a closed or internal track and open the opt-in URL, or "products will not load" ([RevenueCat, Play sandbox](https://www.revenuecat.com/docs/test-and-launch/sandbox/google-play-store)).
2. License testers pay with "Test instrument, always approves" or "always declines" and slow test cards; test renewals run at 5 minutes for a month and 30 minutes for a year; grace period is 5 minutes and account hold 10 minutes ([Google, Test](https://developer.android.com/google/play/billing/test)).
3. Use Play Console > Monetization setup > Send Test Message to confirm RTDN reaches RevenueCat's topic ([Google, Getting ready](https://developer.android.com/google/play/billing/getting-ready)).

**RevenueCat and backend.**
1. Point a sandbox-only webhook at the dev Cloud Run service; send a `TEST` event from the dashboard ([RevenueCat, Webhooks](https://www.revenuecat.com/docs/integrations/webhooks)).
2. Record real sandbox payloads for `INITIAL_PURCHASE`, `RENEWAL`, `CANCELLATION`, `BILLING_ISSUE`, `EXPIRATION`, `TRANSFER` and use them as fixtures for Go handler tests: idempotency on duplicate `id`, stale-event rejection, environment mismatch rejection, HMAC failure.
3. Firestore rules tests: a client update that touches `plan` is denied; one that does not is allowed.
4. Verify the dashboard sandbox toggle shows the purchases ([RevenueCat, Sandbox](https://www.revenuecat.com/docs/test-and-launch/sandbox)).
5. Test at least once with a non-license-tester account on Android to avoid relying on test-only renewal durations ([Google, Test](https://developer.android.com/google/play/billing/test)).

## Costs

| Item | Cost | Source |
|---|---|---|
| RevenueCat | $0 up to $2,500 monthly tracked revenue, then 1% of MTR; all features on every tier | [RevenueCat pricing](https://www.revenuecat.com/pricing) |
| Apple commission | 70% to developer in a subscriber's first year, 85% after one year of paid service; 85% from day one in the Small Business Program (proceeds up to $1M in the prior calendar year, enrolment required) | [Apple, Subscriptions](https://developer.apple.com/app-store/subscriptions/), [Small Business Program](https://developer.apple.com/app-store/small-business-program/) |
| Google service fee | 15% for auto-renewing subscriptions; regional changes for EEA, UK and US from June 30, 2026 | [Google, Service fees](https://support.google.com/googleplay/android-developer/answer/112622) |
| Cloud Run | One extra route on the existing service; no new resource | ADR 0002 |
| Firebase Extension (not chosen) | Requires Blaze; bills Cloud Functions, Firestore and Secret Manager | [Extension PREINSTALL](https://github.com/RevenueCat/firestore-revenuecat-purchases/blob/main/PREINSTALL.md) |
| API quotas (self-built path) | App Store Server API 50 req/s per app, sandbox 10% of that; Play Developer API 3000 queries/min | [Apple rate limits](https://developer.apple.com/documentation/appstoreserverapi/identifying-rate-limits), [Google quotas](https://developers.google.com/android-publisher/quotas) |

Enrol in the Small Business Program before launch: it moves Apple's first-year cut from 30% to 15%.

## Notes on the Firebase Extension (considered, not chosen)

`revenuecat/firestore-revenuecat-purchases` 0.1.19 is an HTTPS Cloud Function that RevenueCat calls with a shared secret; it can write a customers collection, an events collection, and a custom claim `revenueCatEntitlements` on the Firebase user ([extension.yaml](https://github.com/RevenueCat/firestore-revenuecat-purchases/blob/main/extension.yaml), [functions/src/index.ts](https://github.com/RevenueCat/firestore-revenuecat-purchases/blob/main/functions/src/index.ts); the POSTINSTALL text says `activeEntitlements`, which is stale). It is a fine zero-code alternative if the Go webhook turns out to be unwanted, at the cost of Cloud Functions in a project that ADR 0002 keeps to one Go service, and a document shape (`subscriptions[].expires_date`, aliases) that the app would then have to interpret instead of a single `plan` field.

## Open items for the build tickets

- Add an ADR: the Go service owns the RevenueCat webhook and is the only writer of `plan*` fields on `users/{uid}`.
- Decide the exact product catalogue (monthly, annual, trial or not); price is a product decision, not a research one.
- The Quota accounting ticket should read `plan` and `planExpiresAt` as described in section 6.
- Provisioning checklist (a `wizard` candidate): Paid Apps agreement and banking, Sandbox Apple Accounts, In-App Purchase Key, Play payments profile, Play service account and the 36-hour wait, Pub/Sub topic permission, App Store Connect notification URL, RevenueCat webhook secrets in Secret Manager for dev and prod.
