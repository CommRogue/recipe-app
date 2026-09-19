import 'package:flutter/material.dart';

/// Placeholder theme. The design direction is decided in #16; nothing here is
/// a design decision, it only keeps Material 3 defaults readable.
ThemeData buildTheme() {
  return ThemeData(
    colorSchemeSeed: const Color(0xFF6D4C41),
    useMaterial3: true,
  );
}
