import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase client configuration of the dev project `recipe-app-508817`
/// (#15, #17). Same values as android/app/src/dev/google-services.json and
/// ios/Runner/Firebase/Dev/GoogleService-Info.plist, in the shape the
/// FlutterFire CLI would generate.
///
/// These are public client identifiers, restricted to the registered app ids
/// and protected by Firestore security rules, so they are committed.
abstract final class DevFirebaseOptions {
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
    apiKey: 'AIzaSyCbBTexrg83mKYEtntVCdYVCluFMFW0pIA',
    appId: '1:674819344439:android:92853830f06585d0ae17b2',
    messagingSenderId: '674819344439',
    projectId: 'recipe-app-508817',
    storageBucket: 'recipe-app-508817.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAuAy-zkSrfWTRetTuIyEFCxxyAuOEqy6k',
    appId: '1:674819344439:ios:e6ac3702c793ec33ae17b2',
    messagingSenderId: '674819344439',
    projectId: 'recipe-app-508817',
    storageBucket: 'recipe-app-508817.firebasestorage.app',
    androidClientId: '674819344439-couk1p6ph1hcp6h9b6jdmttrkbarrkb8.apps.googleusercontent.com',
    iosClientId: '674819344439-fntsj8uk9s6qgm3hk171vhrt9g0ho4j7.apps.googleusercontent.com',
    iosBundleId: 'app.panwise.dev',
  );

  /// The web OAuth client Firebase created when the Google provider was
  /// enabled. Passed to `google_sign_in` as `serverClientId`.
  static const String googleServerClientId =
      '674819344439-1n73ut10evmmo7o39f0bdt8tdurtfh0n.apps.googleusercontent.com';
}
