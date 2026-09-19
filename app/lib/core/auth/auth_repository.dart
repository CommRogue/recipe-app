/// The signed-in user as the rest of the app sees it. Deliberately not the
/// Firebase `User`, so features never import Firebase Auth.
class AuthUser {
  const AuthUser({required this.uid, this.email, this.displayName});

  final String uid;
  final String? email;
  final String? displayName;

  @override
  bool operator ==(Object other) =>
      other is AuthUser &&
      other.uid == uid &&
      other.email == email &&
      other.displayName == displayName;

  @override
  int get hashCode => Object.hash(uid, email, displayName);

  @override
  String toString() => 'AuthUser($uid, $email)';
}

/// The user backed out of the provider's sign-in sheet. Not an error.
class SignInCancelled implements Exception {
  const SignInCancelled();
}

/// Sign-in and the signed-in user, behind an interface so features and tests
/// never touch Firebase Auth directly.
abstract interface class AuthRepository {
  /// Emits the current user on listen, then on every change. Null when
  /// signed out.
  Stream<AuthUser?> authStateChanges();

  AuthUser? get currentUser;

  /// Throws [SignInCancelled] when the user dismisses the sheet.
  Future<AuthUser> signInWithGoogle();

  /// iOS only in v1 (see PlatformInfo). Throws [SignInCancelled] on dismiss.
  Future<AuthUser> signInWithApple();

  Future<void> signOut();
}
