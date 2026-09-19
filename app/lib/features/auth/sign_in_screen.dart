import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/platform_info.dart';
import 'sign_in_controller.dart';

/// Placeholder sign-in screen. Layout and copy are decided in #16; this only
/// wires the two providers the store rules require (#13).
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  static const googleButtonKey = Key('sign-in-google');
  static const appleButtonKey = Key('sign-in-apple');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signInControllerProvider);
    final controller = ref.read(signInControllerProvider.notifier);
    final showApple = ref.watch(platformInfoProvider).supportsAppleSignIn;
    final busy = state.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Panwise',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),
              FilledButton(
                key: googleButtonKey,
                onPressed: busy ? null : controller.signInWithGoogle,
                child: const Text('Continue with Google'),
              ),
              if (showApple) ...[
                const SizedBox(height: 12),
                FilledButton.tonal(
                  key: appleButtonKey,
                  onPressed: busy ? null : controller.signInWithApple,
                  child: const Text('Continue with Apple'),
                ),
              ],
              const SizedBox(height: 16),
              if (busy) const Center(child: CircularProgressIndicator()),
              if (state.hasError)
                Text(
                  'Sign-in failed. Please try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
