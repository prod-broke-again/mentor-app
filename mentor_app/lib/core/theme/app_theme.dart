import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'soft_ui_colors.dart';

abstract final class AppTheme {
  static ThemeData lightSoft() => _build(brightness: Brightness.light, soft: SoftUiColors.light);

  static ThemeData darkSoft() => _build(brightness: Brightness.dark, soft: SoftUiColors.dark);

  static ThemeData _build({required Brightness brightness, required SoftUiColors soft}) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
    );

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: soft.accent,
      onPrimary: soft.accentForeground,
      secondary: soft.accentSoft,
      onSecondary: soft.accentForeground,
      error: const Color(0xFFE87990),
      onError: soft.accentForeground,
      surface: soft.surface,
      onSurface: soft.textPrimary,
      onSurfaceVariant: soft.textDim,
      outline: soft.outline,
      outlineVariant: soft.outlineStrong,
      shadow: Colors.black.withValues(alpha: brightness == Brightness.dark ? 0.35 : 0.1),
      scrim: Colors.black54,
      inverseSurface: soft.textPrimary,
      onInverseSurface: soft.background,
      inversePrimary: soft.accentSoft,
      surfaceTint: soft.accent,
      tertiary: soft.success,
      onTertiary: soft.accentForeground,
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: soft.textPrimary,
      displayColor: soft.textPrimary,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: soft.background,
      textTheme: textTheme,
      extensions: [soft],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: soft.background,
        foregroundColor: soft.textPrimary,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: soft.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: soft.outline),
        ),
        shadowColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shadowColor: Colors.transparent,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: soft.surfaceBubble,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: soft.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: soft.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: soft.accentLine, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: textTheme.bodyMedium?.copyWith(color: soft.textDim),
        hintStyle: textTheme.bodyMedium?.copyWith(color: soft.textMute),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: soft.surfaceBubble,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: soft.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: soft.outline),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: soft.accent),
      dividerTheme: DividerThemeData(color: soft.outline, thickness: 1),
    );
  }
}
