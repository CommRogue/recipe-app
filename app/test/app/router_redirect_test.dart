import 'package:flutter_test/flutter_test.dart';
import 'package:panwise/app/router.dart';

void main() {
  group('redirectFor', () {
    test('sends a signed-out user anywhere to the sign-in screen', () {
      expect(
        redirectFor(signedIn: false, location: Routes.home),
        Routes.signIn,
      );
      expect(
        redirectFor(signedIn: false, location: '/recipes/abc'),
        Routes.signIn,
      );
    });

    test('lets a signed-out user stay on the sign-in screen', () {
      expect(redirectFor(signedIn: false, location: Routes.signIn), isNull);
    });

    test('moves a signed-in user off the sign-in screen to home', () {
      expect(redirectFor(signedIn: true, location: Routes.signIn), Routes.home);
    });

    test('lets a signed-in user through everywhere else', () {
      expect(redirectFor(signedIn: true, location: Routes.home), isNull);
      expect(redirectFor(signedIn: true, location: '/recipes/abc'), isNull);
    });
  });
}
