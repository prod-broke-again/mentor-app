import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'soft_ui_colors.dart';

/// Minimalist Soft UI — light & dark Material 3 themes.
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
      secondary: soft.accentMuted,
      onSecondary: soft.accentForeground,
      error: brightness == Brightness.dark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
      onError: Colors.white,
      surface: soft.surface,
      onSurface: brightness == Brightness.dark ? const Color(0xFFE8EAED) : const Color(0xFF2D3436),
      onSurfaceVariant: brightness == Brightness.dark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
      outline: soft.outline,
      outlineVariant: soft.outlineStrong,
      shadow: Colors.black.withValues(alpha: brightness == Brightness.dark ? 0.4 : 0.08),
      scrim: Colors.black54,
      inverseSurface: brightness == Brightness.dark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
      onInverseSurface: brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
      inversePrimary: soft.accentMuted,
      surfaceTint: soft.accent,
      tertiary: soft.success,
      onTertiary: Colors.white,
    );

    final textTheme = GoogleFonts.instrumentSansTextTheme(base.textTheme).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
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
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: soft.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: soft.outline.withValues(alpha: 0.6)),
        ),
        shadowColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          shadowColor: Colors.transparent,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: soft.surface,
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
          borderSide: BorderSide(color: soft.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: soft.surfaceElevated,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
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
