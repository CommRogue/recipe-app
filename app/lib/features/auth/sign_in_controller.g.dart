// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs a sign-in and, on success, makes sure `users/{uid}` exists. The state
/// is loading while a sheet is open, an error when the provider failed, and
/// data (null) otherwise; a cancelled sheet is not an error.

@ProviderFor(SignInController)
final signInControllerProvider = SignInControllerProvider._();

/// Runs a sign-in and, on success, makes sure `users/{uid}` exists. The state
/// is loading while a sheet is open, an error when the provider failed, and
/// data (null) otherwise; a cancelled sheet is not an error.
final class SignInControllerProvider
    extends $AsyncNotifierProvider<SignInController, void> {
  /// Runs a sign-in and, on success, makes sure `users/{uid}` exists. The state
  /// is loading while a sheet is open, an error when the provider failed, and
  /// data (null) otherwise; a cancelled sheet is not an error.
  SignInControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInControllerHash();

  @$internal
  @override
  SignInController create() => SignInController();
}

String _$signInControllerHash() => r'83962102a0170d4fbfb159cd123b5afee7b5b21a';

/// Runs a sign-in and, on success, makes sure `users/{uid}` exists. The state
/// is loading while a sheet is open, an error when the provider failed, and
/// data (null) otherwise; a cancelled sheet is not an error.

abstract class _$SignInController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
