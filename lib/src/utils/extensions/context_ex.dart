import 'package:flutter/material.dart';

/// Convenience extensions on [BuildContext].
///
/// Theme colours, media query shorthands, and text styles
/// without the ceremony of `Theme.of(context).colorScheme...`.
extension ContextEx on BuildContext {
  // ─── MediaQuery ───────────────────────────────────────────────────────────

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewPadding => mediaQuery.viewPadding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  // ─── Theme ────────────────────────────────────────────────────────────────

  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  bool get isDark => theme.brightness == Brightness.dark;

  // ─── Colours ──────────────────────────────────────────────────────────────

  Color get primaryColor => theme.primaryColor;
  Color get secondaryColor => colorScheme.secondary;
  Color get scaffoldBgColor => theme.scaffoldBackgroundColor;
  Color get surfaceColor => colorScheme.surface;
  Color get errorColor => colorScheme.error;
  Color get primaryTextColor => colorScheme.onSurface;
  Color get onPrimaryColor => colorScheme.onPrimary;

  // ─── Text styles ──────────────────────────────────────────────────────────

  TextTheme get textTheme => theme.textTheme;
  TextStyle? get displayLarge => textTheme.displayLarge;
  TextStyle? get displayMedium => textTheme.displayMedium;
  TextStyle? get titleLarge => textTheme.titleLarge;
  TextStyle? get titleMedium => textTheme.titleMedium;
  TextStyle? get bodyLarge => textTheme.bodyLarge;
  TextStyle? get bodyMedium => textTheme.bodyMedium;
  TextStyle? get bodySmall => textTheme.bodySmall;
  TextStyle? get labelLarge => textTheme.labelLarge;
  TextStyle? get labelMedium => textTheme.labelMedium;
  TextStyle? get labelSmall => textTheme.labelSmall;

  // ─── Spacing ──────────────────────────────────────────────────────────────

  EdgeInsetsGeometry get screenPadding =>
      const EdgeInsets.symmetric(horizontal: 16);
}
