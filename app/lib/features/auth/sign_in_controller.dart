import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/users/user_providers.dart';

part 'sign_in_controller.g.dart';

/// Runs a sign-in and, on success, makes sure `users/{uid}` exists. The state
/// is loading while a sheet is open, an error when the provider failed, and
/// data (null) otherwise; a cancelled sheet is not an error.
@riverpod
class SignInController extends _$SignInController {
  @override
  Future<void> build() async {}

  Future<void> signInWithGoogle() =>
      _run((auth) => auth.signInWithGoogle());

  Future<void> signInWithApple() => _run((auth) => auth.signInWithApple());

  Future<void> _run(Future<AuthUser> Function(AuthRepository) signIn) async {
    state = const AsyncLoading();
    try {
      final user = await signIn(ref.read(authRepositoryProvider));
      await ref.read(userRepositoryProvider).ensureUserDocument(user.uid);
      state = const AsyncData(null);
    } on SignInCancelled {
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
