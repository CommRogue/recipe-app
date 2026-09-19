import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/flavor.dart';
import 'auth_repository.dart';
import 'firebase_auth_repository.dart';

part 'auth_providers.g.dart';

/// The production [AuthRepository]. Tests override this with a
/// `FakeAuthRepository`.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final config = ref.watch(flavorConfigProvider);
  return FirebaseAuthRepository(
    auth: FirebaseAuth.instance,
    googleSignIn: GoogleSignIn.instance,
    googleServerClientId: config.googleServerClientId,
  );
}

/// The signed-in user, null when signed out, loading until the first event.
@Riverpod(keepAlive: true)
Stream<AuthUser?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}
