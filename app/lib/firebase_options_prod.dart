import 'package:firebase_core/firebase_core.dart';

/// PLACEHOLDER. The prod Firebase project does not exist yet; #24 creates it
/// and replaces this file with the real options (and Prod.xcconfig on iOS).
abstract final class ProdFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnimplementedError('prod Firebase project is created in #24');
  }

  static const String googleServerClientId = '';
}
