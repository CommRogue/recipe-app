import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panwise/core/users/firestore_user_repository.dart';

void main() {
  late FakeFirebaseFirestore db;
  late FirestoreUserRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = FirestoreUserRepository(db);
  });

  test(
    'creates users/{uid} with the data-model fields on first sign-in',
    () async {
      await repo.ensureUserDocument('u1');

      final data = (await db.doc('users/u1').get()).data()!;
      expect(
        data.keys,
        unorderedEquals([
          'createdAt',
          'unitSystem',
          'consent',
          'recipeCount',
          'countedRecipeId',
        ]),
      );
      expect(data['createdAt'], isNotNull, reason: 'server timestamp resolved');
      expect(data['unitSystem'], isNull);
      expect(data['consent'], isNull);
      expect(data['recipeCount'], 0);
      expect(data['countedRecipeId'], isNull);
    },
  );

  test('leaves an existing document untouched', () async {
    await db.doc('users/u1').set({
      'createdAt': DateTime.utc(2026, 1, 1),
      'unitSystem': 'imperial',
      'consent': {'version': 1},
      'recipeCount': 7,
      'countedRecipeId': 'r7',
    });

    await repo.ensureUserDocument('u1');

    final data = (await db.doc('users/u1').get()).data()!;
    expect(data['recipeCount'], 7);
    expect(data['unitSystem'], 'imperial');
    expect(data['countedRecipeId'], 'r7');
  });
}
