import 'package:firebase_core/firebase_core.dart';

import 'app/flavor.dart';
import 'bootstrap.dart';
import 'firebase_options_prod.dart';

/// Entry point of the prod flavor:
/// `flutter run --flavor prod -t lib/main_prod.dart`
///
/// Starts, then fails in [bootstrap] until #24 provides the prod project.
Future<void> main() => bootstrap(
  const FlavorConfig(
    flavor: Flavor.prod,
    displayName: 'Panwise',
    firebaseOptions: _prodOptions,
    googleServerClientId: ProdFirebaseOptions.googleServerClientId,
  ),
);

FirebaseOptions _prodOptions() => ProdFirebaseOptions.currentPlatform;
