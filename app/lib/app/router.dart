import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/auth/auth_providers.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/home/home_screen.dart';

part 'router.g.dart';

/// Route paths. Routes carry ids in the path, never objects in `extra` (H18),
/// so every screen can be reached from a URL.
abstract final class Routes {
  static const home = '/';
  static const signIn = '/sign-in';
}

/// Where a navigation should go instead, given whether the user is signed in.
/// Returns null to let it through. Kept free of GoRouter so it is testable.
String? redirectFor({required bool signedIn, required String location}) {
  if (!signedIn) {
    return location == Routes.signIn ? null : Routes.signIn;
  }
  return location == Routes.signIn ? Routes.home : null;
}

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  // GoRouter re-evaluates redirects when this notifier fires.
  final refresh = ValueNotifier(0);
  ref.onDispose(refresh.dispose);
  ref.listen(authStateProvider, (_, _) => refresh.value++);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      // Until the first auth event, stay put; HomeScreen shows progress.
      if (auth.isLoading) return null;
      return redirectFor(
        signedIn: auth.value != null,
        location: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(
        path: Routes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.signIn,
        name: 'sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
    ],
  );
}
