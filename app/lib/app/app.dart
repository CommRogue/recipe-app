import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'flavor.dart';
import 'router.dart';
import 'theme.dart';

/// The root widget. Everything it needs comes from providers, so tests pump it
/// inside a [ProviderScope] with fakes and the flavor overridden.
class PanwiseApp extends ConsumerWidget {
  const PanwiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(flavorConfigProvider);
    return MaterialApp.router(
      title: config.displayName,
      theme: buildTheme(),
      routerConfig: ref.watch(goRouterProvider),
    );
  }
}
