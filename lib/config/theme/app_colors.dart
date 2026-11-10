import 'package:flutter/material.dart';

class AppColors {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color card(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color inset(BuildContext context) => isDark(context)
      ? const Color(0xFF1E1E1E)
      : const Color(0xFFF5F7FA);

  static Color tint(BuildContext context) => isDark(context)
      ? const Color(0xFF1B3A2A)
      : const Color(0xFFE8F5E9);

  static Color onSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
}
