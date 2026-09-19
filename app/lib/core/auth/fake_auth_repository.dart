import 'dart:async';

import 'auth_repository.dart';

/// In-memory [AuthRepository] for widget and unit tests. Signing in with
/// either provider yields [nextUser]; set [nextError] to make it throw.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AuthUser? signedInAs}) : _current = signedInAs;

  static const defaultUser = AuthUser(
    uid: 'fake-uid',
    email: 'cook@example.com',
    displayName: 'Fake Cook',
  );

  AuthUser nextUser = defaultUser;
  Object? nextError;
  int signInCalls = 0;

  AuthUser? _current;
  final _controller = StreamController<AuthUser?>.broadcast();

  @override
  AuthUser? get currentUser => _current;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<AuthUser> signInWithGoogle() => _signIn();

  @override
  Future<AuthUser> signInWithApple() => _signIn();

  Future<AuthUser> _signIn() async {
    signInCalls++;
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
    _set(nextUser);
    return nextUser;
  }

  @override
  Future<void> signOut() async => _set(null);

  void _set(AuthUser? user) {
    _current = user;
    _controller.add(user);
  }
}
