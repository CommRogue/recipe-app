import 'user_repository.dart';

/// Records the uids it was asked to ensure.
class FakeUserRepository implements UserRepository {
  final List<String> ensuredUids = [];

  @override
  Future<void> ensureUserDocument(String uid) async {
    ensuredUids.add(uid);
  }
}
