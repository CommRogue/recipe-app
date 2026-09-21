import 'package:firebase_core/firebase_core.dart';

import 'app/flavor.dart';
import 'bootstrap.dart';
import 'firebase_options_prod.dart';

/// Entry point of the prod flavor:
/// `flutter run --flavor prod -t lib/main_prod.dart`
Future<void> main() => bootstrap(
  const FlavorConfig(
    flavor: Flavor.prod,
    displayName: 'Panwise',
    firebaseOptions: _prodOptions,
    googleServerClientId: ProdFirebaseOptions.googleServerClientId,
  ),
);

FirebaseOptions _prodOptions() => ProdFirebaseOptions.currentPlatform;
