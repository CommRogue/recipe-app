/// The user document `users/{uid}` (docs/firestore-data-model.md).
abstract interface class UserRepository {
  /// Creates `users/{uid}` on first sign-in and leaves an existing document
  /// alone. Called after every successful sign-in.
  Future<void> ensureUserDocument(String uid);
}

/// The fields of a fresh `users/{uid}`. [createdAt] is whatever the store
/// uses for "now on the server" (`FieldValue.serverTimestamp()` in Firestore),
/// because the rules require `createdAt == request.time`.
Map<String, Object?> newUserDocument({required Object createdAt}) => {
  'createdAt': createdAt,
  'unitSystem': null,
  'consent': null,
  'recipeCount': 0,
  'countedRecipeId': null,
};
