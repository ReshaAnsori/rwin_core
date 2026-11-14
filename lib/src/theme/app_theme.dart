import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rwin_core/src/theme/app_colors.dart';
import 'package:rwin_core/src/theme/app_typography.dart';

/// Builds light and dark [ThemeData] for rwin_core apps.
///
/// Quick start:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
/// );
/// ```
///
/// Custom font:
/// ```dart
/// // Set once before runApp — the builder uses it on the next call.
/// AppTheme.fontFamily = 'YourFont';
/// ```
class AppTheme {
  AppTheme._();

  /// Font family applied to [ThemeData.fontFamily].
  /// Defaults to `'Inter'`. Override before calling [lightTheme] / [darkTheme].
  static String fontFamily = 'Inter';

  static ThemeData get lightTheme => getTheme(isDarkMode: false);
  static ThemeData get darkTheme => getTheme(isDarkMode: true);

  static ThemeData getTheme({required bool isDarkMode}) {
    final primary = isDarkMode ? AppColors.primaryDark : AppColors.primary;
    final surface = isDarkMode ? AppColors.surfaceDark : AppColors.surface;
    final background =
        isDarkMode ? AppColors.bgDark : AppColors.pageBackground;
    final textPrimary =
        isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
      colorScheme: ColorScheme(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.black,
        surface: surface,
        onSurface: textPrimary,
        error: AppColors.danger,
        onError: Colors.white,
      ),
      textTheme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      )
          .textTheme
          .apply(
            fontFamily: fontFamily,
            bodyColor: textPrimary,
            displayColor: textPrimary,
          )
          .copyWith(
            displayLarge: AppTypography.displayLarge,
            displayMedium: AppTypography.displayMedium,
            titleLarge: AppTypography.titleLarge,
            titleMedium: AppTypography.titleMedium,
            bodyLarge: AppTypography.bodyLarge,
            bodyMedium: AppTypography.bodyMedium,
            bodySmall: AppTypography.bodySmall,
            labelLarge: AppTypography.labelLarge,
            labelMedium: AppTypography.labelMedium,
            labelSmall: AppTypography.labelSmall,
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: AppTypography.labelLarge,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? background : primary,
        foregroundColor: isDarkMode ? textPrimary : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      // Cupertino-style slide transition on both platforms
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        hintStyle: TextStyle(color: textSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white10 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(color: textSecondary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
