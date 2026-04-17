import 'package:flutter/material.dart';

/// Design tokens: zinc neutrals + muted rose accent (see HTML reference).
@immutable
class SoftUiColors extends ThemeExtension<SoftUiColors> {
  const SoftUiColors({
    required this.background,
    required this.surface,
    required this.surfaceBubble,
    required this.surfaceRaised,
    required this.outline,
    required this.outlineStrong,
    required this.accent,
    required this.accentSoft,
    required this.accentForeground,
    required this.accentGhost,
    required this.accentLine,
    required this.textPrimary,
    required this.textDim,
    required this.textMute,
    required this.success,
    required this.warn,
    required this.gridLine,
  });

  final Color background;
  final Color surface;
  /// Incoming message bubbles, composer well.
  final Color surfaceBubble;
  final Color surfaceRaised;
  final Color outline;
  final Color outlineStrong;
  final Color accent;
  final Color accentSoft;
  final Color accentForeground;
  final Color accentGhost;
  final Color accentLine;
  final Color textPrimary;
  final Color textDim;
  final Color textMute;
  final Color success;
  final Color warn;
  final Color gridLine;

  /// Dark: zinc-950-ish + muted rose.
  static final SoftUiColors dark = SoftUiColors(
    background: const Color(0xFF0B0B0D),
    surface: const Color(0xFF131316),
    surfaceBubble: const Color(0xFF1B1B1F),
    surfaceRaised: const Color(0xFF232328),
    outline: const Color(0xFF2A2A30),
    outlineStrong: const Color(0xFF3A3A42),
    accent: const Color(0xFFE4678A),
    accentSoft: const Color(0xFFC25170),
    accentForeground: const Color(0xFF1A0E12),
    accentGhost: const Color(0x1FE4678A),
    accentLine: const Color(0x47E4678A),
    textPrimary: const Color(0xFFE7E7EA),
    textDim: const Color(0xFFA1A1AA),
    textMute: const Color(0xFF71717A),
    success: const Color(0xFF86C5A5),
    warn: const Color(0xFFE0B06A),
    gridLine: const Color(0xFF2A2A30),
  );

  /// Light: zinc-50/100 surfaces, same rose accent.
  static final SoftUiColors light = SoftUiColors(
    background: const Color(0xFFF4F4F5),
    surface: const Color(0xFFFFFFFF),
    surfaceBubble: const Color(0xFFF4F4F5),
    surfaceRaised: const Color(0xFFE4E4E7),
    outline: const Color(0xFFE4E4E7),
    outlineStrong: const Color(0xFFD4D4D8),
    accent: const Color(0xFFC25170),
    accentSoft: const Color(0xFFA84363),
    accentForeground: const Color(0xFF1A0E12),
    accentGhost: const Color(0x14C25170),
    accentLine: const Color(0x47C25170),
    textPrimary: const Color(0xFF18181B),
    textDim: const Color(0xFF52525B),
    textMute: const Color(0xFF71717A),
    success: const Color(0xFF4D8B6E),
    warn: const Color(0xFFB8860B),
    gridLine: const Color(0xFFD4D4D8),
  );

  /// Reference CSS: inset highlight + soft drop shadow.
  static List<BoxShadow> insetTopGlow() => [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.03),
          offset: const Offset(0, 1),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> shadowDropped({double opacity = 0.25}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: opacity),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  @override
  SoftUiColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceBubble,
    Color? surfaceRaised,
    Color? outline,
    Color? outlineStrong,
    Color? accent,
    Color? accentSoft,
    Color? accentForeground,
    Color? accentGhost,
    Color? accentLine,
    Color? textPrimary,
    Color? textDim,
    Color? textMute,
    Color? success,
    Color? warn,
    Color? gridLine,
  }) =>
      SoftUiColors(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceBubble: surfaceBubble ?? this.surfaceBubble,
        surfaceRaised: surfaceRaised ?? this.surfaceRaised,
        outline: outline ?? this.outline,
        outlineStrong: outlineStrong ?? this.outlineStrong,
        accent: accent ?? this.accent,
        accentSoft: accentSoft ?? this.accentSoft,
        accentForeground: accentForeground ?? this.accentForeground,
        accentGhost: accentGhost ?? this.accentGhost,
        accentLine: accentLine ?? this.accentLine,
        textPrimary: textPrimary ?? this.textPrimary,
        textDim: textDim ?? this.textDim,
        textMute: textMute ?? this.textMute,
        success: success ?? this.success,
        warn: warn ?? this.warn,
        gridLine: gridLine ?? this.gridLine,
      );

  @override
  SoftUiColors lerp(SoftUiColors? other, double t) {
    if (other == null) return this;
    return SoftUiColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceBubble: Color.lerp(surfaceBubble, other.surfaceBubble, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineStrong: Color.lerp(outlineStrong, other.outlineStrong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentForeground: Color.lerp(accentForeground, other.accentForeground, t)!,
      accentGhost: Color.lerp(accentGhost, other.accentGhost, t)!,
      accentLine: Color.lerp(accentLine, other.accentLine, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
      textMute: Color.lerp(textMute, other.textMute, t)!,
      success: Color.lerp(success, other.success, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      gridLine: Color.lerp(gridLine, other.gridLine, t)!,
    );
  }
}
