import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'auth_repository.dart';

/// Firebase Auth with the Google and Apple providers enabled on the project
/// (#15).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required String googleServerClientId,
  }) : this._(auth, googleSignIn, googleServerClientId);

  FirebaseAuthRepository._(
    this._auth,
    this._googleSignIn,
    this._googleServerClientId,
  );

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final String _googleServerClientId;
  Future<void>? _googleInitialised;

  @override
  Stream<AuthUser?> authStateChanges() =>
      _auth.authStateChanges().map(_toAuthUser);

  @override
  AuthUser? get currentUser => _toAuthUser(_auth.currentUser);

  @override
  Future<AuthUser> signInWithGoogle() async {
    // google_sign_in 7 must be initialised once before authenticate().
    _googleInitialised ??= _googleSignIn.initialize(
      serverClientId: _googleServerClientId,
    );
    await _googleInitialised;

    final GoogleSignInAccount account;
    try {
      account = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const SignInCancelled();
      }
      rethrow;
    }
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw StateError('Google returned no ID token; is serverClientId set?');
    }
    final credential = await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
    return _toAuthUser(credential.user)!;
  }

  @override
  Future<AuthUser> signInWithApple() async {
    // Apple signs the SHA-256 of the nonce into the identity token; Firebase
    // checks it against the raw nonce, which ties the token to this request.
    final rawNonce = _randomNonce();
    final AuthorizationCredentialAppleID apple;
    try {
      apple = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const SignInCancelled();
      }
      rethrow;
    }
    final credential = await _auth.signInWithCredential(
      OAuthProvider('apple.com').credential(
        idToken: apple.identityToken,
        rawNonce: rawNonce,
      ),
    );
    return _toAuthUser(credential.user)!;
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  static AuthUser? _toAuthUser(User? user) => user == null
      ? null
      : AuthUser(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
        );

  static String _randomNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}
