import 'package:flutter/material.dart';

/// Default colour palette for rwin_core.
///
/// Override individual colours in your app by passing a custom [ColorScheme]
/// to [AppTheme.getTheme]. This class serves as a sensible starting point and
/// is used by [AppTheme] and [AppTypography] out of the box.
class AppColors {
  AppColors._();

  // ─── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1282A2);
  static const Color primaryDark = Color(0xFF0B4655);
  static const Color primaryMid = Color(0xFF107995);
  static const Color primaryLight = Color(0xFF187588);
  static const Color primary100 = Color(0xFFC5EFF5);
  static const Color primary50 = Color(0xFFDFF2F7);

  // ─── Surfaces ─────────────────────────────────────────────────────────────
  static const Color surface = Color(0xFFEFF4F6);
  static const Color pageBackground = Colors.white;
  static const Color bgLight = Color(0xFFF0F9FA);
  static const Color bgDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardLight = Colors.white;

  // ─── Accent ───────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFFF5C400);

  // ─── Status ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF1B6B63);
  static const Color successLight = Color(0xFF96DDD2);
  static const Color danger = Color(0xFFE52C48);
  static const Color dangerLight = Color(0xFFFFE6EA);
  static const Color info = Color(0xFF1888A4);
  static const Color infoLight = Color(0xFFC4EDF5);
  static const Color warning = Color(0xFFF5C400);

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF1A4D66);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient gradientHeader = LinearGradient(
    colors: [Color(0xFF0B4655), Color(0xFF187588)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient gradientBanner = LinearGradient(
    colors: [Color(0xFFF5C400), Color(0xFFF59E0B), Color(0xFFD97706)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
