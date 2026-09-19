// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The production [AuthRepository]. Tests override this with a
/// `FakeAuthRepository`.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// The production [AuthRepository]. Tests override this with a
/// `FakeAuthRepository`.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// The production [AuthRepository]. Tests override this with a
  /// `FakeAuthRepository`.
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'3ffb543e0d3054f73a6f373e72c299a287782cac';

/// The signed-in user, null when signed out, loading until the first event.

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// The signed-in user, null when signed out, loading until the first event.

final class AuthStateProvider
    extends
        $FunctionalProvider<AsyncValue<AuthUser?>, AuthUser?, Stream<AuthUser?>>
    with $FutureModifier<AuthUser?>, $StreamProvider<AuthUser?> {
  /// The signed-in user, null when signed out, loading until the first event.
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<AuthUser?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AuthUser?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'97ca81ed728c8d7ba5b0f50eb8590093d8d3c5a9';
