import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase client configuration of the prod project `recipe-app-prod-508817`
/// (#24). Same values as android/app/src/prod/google-services.json and
/// ios/Runner/Firebase/Prod/GoogleService-Info.plist, in the shape the
/// FlutterFire CLI would generate.
///
/// These are public client identifiers, restricted to the registered app ids
/// and protected by Firestore security rules, so they are committed.
abstract final class ProdFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web is not a v1 platform (docs/later-versions.md).',
      );
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      _ => throw UnsupportedError(
        'No Firebase app is registered for $defaultTargetPlatform.',
      ),
    };
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC1u4WV7H93CCokYlXDEyVqTxWhWh0j_Bg',
    appId: '1:889209061329:android:713a3f33fda2f8b75d2af0',
    messagingSenderId: '889209061329',
    projectId: 'recipe-app-prod-508817',
    storageBucket: 'recipe-app-prod-508817.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_S7Uplv6HbmsvFGq-__p9D3ABqU5GS8A',
    appId: '1:889209061329:ios:4fe0afa2a166145d5d2af0',
    messagingSenderId: '889209061329',
    projectId: 'recipe-app-prod-508817',
    storageBucket: 'recipe-app-prod-508817.firebasestorage.app',
    iosBundleId: 'app.panwise',
  );

  /// The web OAuth client Firebase creates when the Google provider is
  /// enabled in the Firebase console. Passed to `google_sign_in` as `serverClientId`.
  static const String googleServerClientId = '';
}
