import 'package:firebase_core/firebase_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flavor.g.dart';

/// The two builds of the app, one per GCP project (dev is `recipe-app-508817`,
/// prod is created in #24). Bundle ids follow ADR 0003: `app.panwise.dev` and
/// `app.panwise`.
enum Flavor { dev, prod }

/// Everything that differs between the dev and prod builds. One instance is
/// created by each `main_<flavor>.dart` and handed to [bootstrap].
class FlavorConfig {
  const FlavorConfig({
    required this.flavor,
    required this.displayName,
    required this.firebaseOptions,
    required this.googleServerClientId,
  });

  final Flavor flavor;

  /// Shown as the app title. The launcher label is set natively per flavor.
  final String displayName;

  /// Resolves the Firebase project for the platform the app is running on.
  /// A function rather than a value so the prod placeholder can throw only
  /// when it is actually used.
  final FirebaseOptions Function() firebaseOptions;

  /// The web OAuth client of the Firebase project. `google_sign_in` needs it
  /// on Android to return an ID token that Firebase Auth accepts.
  final String googleServerClientId;
}

/// Overridden in [bootstrap] with the running flavor. Reading it without an
/// override is a programming error, so it throws rather than defaulting to dev.
@Riverpod(keepAlive: true)
FlavorConfig flavorConfig(Ref ref) {
  throw UnimplementedError('flavorConfigProvider is overridden in bootstrap()');
}
