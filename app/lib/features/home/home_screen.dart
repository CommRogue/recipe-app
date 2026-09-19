import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';

/// Placeholder home. The library, the Generation Request entry point and the
/// Profile arrive with #16 and #19; this proves the signed-in state.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const signOutButtonKey = Key('sign-out');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) {
      // Auth is still loading; the router redirects once it settles.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panwise'),
        actions: [
          IconButton(
            key: signOutButtonKey,
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: Center(child: Text('Signed in as ${user.email ?? user.uid}')),
    );
  }
}
