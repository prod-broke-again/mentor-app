import 'package:flutter/material.dart';

/// Semantic colors aligned with `resources/css/app.css` (Soft UI palette).
@immutable
class SoftUiColors extends ThemeExtension<SoftUiColors> {
  const SoftUiColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.outline,
    required this.outlineStrong,
    required this.accent,
    required this.accentForeground,
    required this.accentMuted,
    required this.success,
    required this.gridLine,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color outline;
  final Color outlineStrong;
  final Color accent;
  final Color accentForeground;
  final Color accentMuted;
  final Color success;
  final Color gridLine;

  /// Light theme tokens (calm teal accent, warm neutrals).
  static const SoftUiColors light = SoftUiColors(
    background: Color(0xFFF8F9FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFFFFFF),
    outline: Color(0xFFE2E8F0),
    outlineStrong: Color(0xFFCBD5E1),
    accent: Color(0xFF2D8A7A),
    accentForeground: Color(0xFFFFFFFF),
    accentMuted: Color(0xFF4AA899),
    success: Color(0xFF3D8B6E),
    gridLine: Color(0xFF94A3B8),
  );

  /// Dark theme (deep blue-gray, not pure black).
  static const SoftUiColors dark = SoftUiColors(
    background: Color(0xFF1A1F2E),
    surface: Color(0xFF242B3D),
    surfaceElevated: Color(0xFF2D3548),
    outline: Color(0xFF3D4759),
    outlineStrong: Color(0xFF4A5568),
    accent: Color(0xFF5CBFB0),
    accentForeground: Color(0xFF0F1419),
    accentMuted: Color(0xFF3D9A8C),
    success: Color(0xFF6BC49A),
    gridLine: Color(0xFF64748B),
  );

  /// Soft outer shadow for elevated cards / buttons.
  static List<BoxShadow> shadowRaised(Brightness brightness) {
    final a = brightness == Brightness.dark ? 0.45 : 0.07;
    return [
      BoxShadow(
        color: Color.fromRGBO(15, 23, 42, a),
        blurRadius: 24,
        offset: const Offset(0, 10),
        spreadRadius: -4,
      ),
      BoxShadow(
        color: Color.fromRGBO(15, 23, 42, brightness == Brightness.dark ? 0.2 : 0.03),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ];
  }

  @override
  SoftUiColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? outline,
    Color? outlineStrong,
    Color? accent,
    Color? accentForeground,
    Color? accentMuted,
    Color? success,
    Color? gridLine,
  }) =>
      SoftUiColors(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceElevated: surfaceElevated ?? this.surfaceElevated,
        outline: outline ?? this.outline,
        outlineStrong: outlineStrong ?? this.outlineStrong,
        accent: accent ?? this.accent,
        accentForeground: accentForeground ?? this.accentForeground,
        accentMuted: accentMuted ?? this.accentMuted,
        success: success ?? this.success,
        gridLine: gridLine ?? this.gridLine,
      );

  @override
  SoftUiColors lerp(SoftUiColors? other, double t) {
    if (other == null) return this;
    return SoftUiColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineStrong: Color.lerp(outlineStrong, other.outlineStrong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentForeground: Color.lerp(accentForeground, other.accentForeground, t)!,
      accentMuted: Color.lerp(accentMuted, other.accentMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      gridLine: Color.lerp(gridLine, other.gridLine, t)!,
    );
  }
}
