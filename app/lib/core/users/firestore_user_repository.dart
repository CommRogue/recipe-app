import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository(this._db);

  final FirebaseFirestore _db;

  @override
  Future<void> ensureUserDocument(String uid) async {
    final doc = _db.collection('users').doc(uid);
    // A plain set() would overwrite recipeCount, so check first. If the check
    // is wrong (stale cache), the rules reject the write: createdAt may not
    // change and recipeCount may not move without a Recipe.
    final snapshot = await doc.get();
    if (snapshot.exists) return;
    await doc.set(newUserDocument(createdAt: FieldValue.serverTimestamp()));
  }
}
