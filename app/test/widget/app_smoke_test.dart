import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panwise/app/app.dart';
import 'package:panwise/app/flavor.dart';
import 'package:panwise/core/auth/auth_providers.dart';
import 'package:panwise/core/auth/fake_auth_repository.dart';
import 'package:panwise/core/platform/platform_info.dart';
import 'package:panwise/core/users/fake_user_repository.dart';
import 'package:panwise/core/users/user_providers.dart';
import 'package:panwise/features/auth/sign_in_screen.dart';
import 'package:panwise/features/home/home_screen.dart';

FirebaseOptions _noFirebase() => throw StateError('tests never touch Firebase');

const _testConfig = FlavorConfig(
  flavor: Flavor.dev,
  displayName: 'Panwise Test',
  firebaseOptions: _noFirebase,
  googleServerClientId: '',
);

Widget app({
  required FakeAuthRepository auth,
  required FakeUserRepository users,
  bool apple = false,
}) => ProviderScope(
  overrides: [
    flavorConfigProvider.overrideWith((ref) => _testConfig),
    authRepositoryProvider.overrideWith((ref) => auth),
    userRepositoryProvider.overrideWith((ref) => users),
    platformInfoProvider.overrideWith((ref) => FakePlatformInfo(supportsAppleSignIn: apple)),
  ],
  child: const PanwiseApp(),
);

void main() {
  testWidgets('a signed-out start lands on the sign-in screen', (tester) async {
    await tester.pumpWidget(app(auth: FakeAuthRepository(), users: FakeUserRepository()));
    await tester.pumpAndSettle();

    expect(find.byType(SignInScreen), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.byKey(SignInScreen.appleButtonKey), findsNothing);
  });

  testWidgets('the Apple button appears only where the platform supports it', (tester) async {
    await tester.pumpWidget(app(auth: FakeAuthRepository(), users: FakeUserRepository(), apple: true));
    await tester.pumpAndSettle();

    expect(find.byKey(SignInScreen.appleButtonKey), findsOneWidget);
  });

  testWidgets('signing in creates the user document and shows home', (tester) async {
    final auth = FakeAuthRepository();
    final users = FakeUserRepository();
    await tester.pumpWidget(app(auth: auth, users: users));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SignInScreen.googleButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Signed in as cook@example.com'), findsOneWidget);
    expect(users.ensuredUids, ['fake-uid']);
  });

  testWidgets('a signed-in start goes straight home, and signing out returns to sign-in', (tester) async {
    final auth = FakeAuthRepository(signedInAs: FakeAuthRepository.defaultUser);
    await tester.pumpWidget(app(auth: auth, users: FakeUserRepository()));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.tap(find.byKey(HomeScreen.signOutButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(SignInScreen), findsOneWidget);
  });
}
