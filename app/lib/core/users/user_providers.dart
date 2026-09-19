import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../firestore/firestore_providers.dart';
import 'firestore_user_repository.dart';
import 'user_repository.dart';

part 'user_providers.g.dart';

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  return FirestoreUserRepository(ref.watch(firestoreProvider));
}
