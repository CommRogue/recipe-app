import 'package:firebase_core/firebase_core.dart';

import 'app/flavor.dart';
import 'bootstrap.dart';
import 'firebase_options_dev.dart';

/// Entry point of the dev flavor:
/// `flutter run --flavor dev -t lib/main_dev.dart`
Future<void> main() => bootstrap(
  const FlavorConfig(
    flavor: Flavor.dev,
    displayName: 'Panwise Dev',
    firebaseOptions: _devOptions,
    googleServerClientId: DevFirebaseOptions.googleServerClientId,
  ),
);

// A top-level function so the config can be const.
FirebaseOptions _devOptions() => DevFirebaseOptions.currentPlatform;
