import 'package:flutter/material.dart';
import 'package:rwin_core/src/theme/app_colors.dart';

/// Default text style scale for rwin_core apps.
/// Font family is set at the [ThemeData] level via [AppTheme.fontFamily].
class AppTypography {
  AppTypography._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    color: AppColors.primary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.primary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );
}
