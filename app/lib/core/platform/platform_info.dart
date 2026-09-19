import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'platform_info.g.dart';

/// The one place that knows which platform the app runs on (H17). Features
/// ask this interface instead of checking `Platform` or `defaultTargetPlatform`
/// themselves, so a web build later changes one implementation.
abstract interface class PlatformInfo {
  /// Sign in with Apple is offered on Apple platforms only in v1. Apple 4.8
  /// requires it beside Google sign-in on iOS (#13); Android has no such rule.
  bool get supportsAppleSignIn;
}

class DefaultPlatformInfo implements PlatformInfo {
  const DefaultPlatformInfo();

  @override
  bool get supportsAppleSignIn =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);
}

/// Fixed answers for tests.
class FakePlatformInfo implements PlatformInfo {
  const FakePlatformInfo({this.supportsAppleSignIn = false});

  @override
  final bool supportsAppleSignIn;
}

@Riverpod(keepAlive: true)
PlatformInfo platformInfo(Ref ref) => const DefaultPlatformInfo();
