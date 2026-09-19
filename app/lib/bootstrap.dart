import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/flavor.dart';

/// Shared start-up for every flavor: initialise Firebase for the flavor's
/// project, then run the app with the flavor available to providers.
Future<void> bootstrap(FlavorConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: config.firebaseOptions());
  runApp(
    ProviderScope(
      overrides: [flavorConfigProvider.overrideWith((ref) => config)],
      child: const PanwiseApp(),
    ),
  );
}
