# Panwise app

The Flutter client (#17). Terms are from `../CONTEXT.md`; the Firestore layout it writes to is `../docs/firestore-data-model.md`; the Go-to-Dart contract is `../schema/recipe.schema.json`.

## Flavors

| Flavor | Bundle id         | Firebase project           | Entry point          |
| ------ | ----------------- | -------------------------- | -------------------- |
| dev    | `app.panwise.dev` | `recipe-app-508817`        | `lib/main_dev.dart`  |
| prod   | `app.panwise`     | none yet, created in #24   | `lib/main_prod.dart` |

Every build needs a flavor, on both platforms:

```sh
flutter run --flavor dev -t lib/main_dev.dart
flutter build apk --debug --flavor dev -t lib/main_dev.dart
```

The prod flavor builds, then throws on start until #24 fills in `lib/firebase_options_prod.dart` and `ios/Flutter/Prod.xcconfig`.

Android flavors are Gradle product flavors in `android/app/build.gradle.kts`. iOS flavors are the `dev` and `prod` schemes with `Debug-dev`, `Release-dev`, `Profile-dev` and the `-prod` build configurations, each reading `ios/Flutter/<Config>-<flavor>.xcconfig`, which includes `Dev.xcconfig` or `Prod.xcconfig` for the bundle id, display name and Google client ids. The iOS side was written without Xcode and is unverified until a macOS runner builds it (#23).

## Firebase configuration

Firebase is initialised from Dart (`lib/firebase_options_dev.dart`), so no google-services Gradle plugin or plist build phase is needed and a flavor with no config file still builds. `android/app/src/dev/google-services.json` and `ios/Runner/Firebase/Dev/GoogleService-Info.plist` are the raw configs the values were taken from. They hold public client identifiers restricted to the registered app ids, which is why they are committed.

Google sign-in on Android needs the debug keystore's SHA-1 registered on the Firebase Android app. The WSL machine's is registered; another machine's debug key has to be added in the Firebase console (Project settings → Your apps → Add fingerprint) before Google sign-in works on it.

## Layout

```
lib/
  main_dev.dart, main_prod.dart   one FlavorConfig each, then bootstrap()
  bootstrap.dart                  Firebase init, ProviderScope, runApp
  firebase_options_<flavor>.dart
  app/                            flavor, router, theme, root widget
  core/
    auth/                         AuthRepository (interface, Firebase impl, fake)
    users/                        UserRepository: users/{uid} on first sign-in
    firestore/                    RFC 3339 <-> Timestamp, entry ids
    platform/                     PlatformInfo (H17: the only place that asks which platform this is)
  features/
    auth/                         sign-in screen and controller
    home/                         placeholder home
    recipes/domain/               Draft and Recipe models from the schema
```

Rules of the road, from `../docs/later-versions.md`: no `dart:io` or `Platform.is*` in `features/` (H17); routes carry ids in the path, never objects in `extra` (H18); readers ignore unknown fields and map unknown enum values to the schema's named fallback (H19).

## Everyday commands

```sh
dart run build_runner build -d     # regenerate *.g.dart and *.freezed.dart
flutter analyze
flutter test                       # unit and widget tests, all fakes, no Firebase
flutter test test/features/recipes # one directory
```

Riverpod providers use `riverpod_annotation`; models use `freezed` and `json_serializable`. Generated files are committed so a fresh clone builds without running the generator.

## Security rules

Rules, indexes and their emulator tests live in `../firebase/`:

```sh
cd ../firebase
npm install
JAVA_HOME=~/.local/jdk/21 PATH=$JAVA_HOME/bin:$PATH npm run test:emulator   # emulator needs JDK 21+
npm run deploy:dev                                                          # needs `npx firebase login` once
```
