import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panwise/core/auth/auth_providers.dart';
import 'package:panwise/core/auth/auth_repository.dart';
import 'package:panwise/core/auth/fake_auth_repository.dart';
import 'package:panwise/core/users/fake_user_repository.dart';
import 'package:panwise/core/users/user_providers.dart';
import 'package:panwise/features/auth/sign_in_controller.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeUserRepository users;
  late ProviderContainer container;

  setUp(() {
    auth = FakeAuthRepository();
    users = FakeUserRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWith((ref) => auth),
        userRepositoryProvider.overrideWith((ref) => users),
      ],
    );
    addTearDown(container.dispose);
  });

  test('a successful sign-in ensures users/{uid} exists', () async {
    await container.read(signInControllerProvider.notifier).signInWithGoogle();

    expect(auth.currentUser, FakeAuthRepository.defaultUser);
    expect(users.ensuredUids, ['fake-uid']);
    expect(
      container.read(signInControllerProvider),
      const AsyncData<void>(null),
    );
  });

  test('apple sign-in goes through the same path', () async {
    await container.read(signInControllerProvider.notifier).signInWithApple();
    expect(users.ensuredUids, ['fake-uid']);
  });

  test('a cancelled sheet is not an error and creates nothing', () async {
    auth.nextError = const SignInCancelled();

    await container.read(signInControllerProvider.notifier).signInWithGoogle();

    expect(container.read(signInControllerProvider).hasError, isFalse);
    expect(users.ensuredUids, isEmpty);
    expect(auth.currentUser, isNull);
  });

  test('a provider failure surfaces as an error state', () async {
    auth.nextError = StateError('network');

    await container.read(signInControllerProvider.notifier).signInWithGoogle();

    expect(container.read(signInControllerProvider).hasError, isTrue);
    expect(users.ensuredUids, isEmpty);
  });
}
