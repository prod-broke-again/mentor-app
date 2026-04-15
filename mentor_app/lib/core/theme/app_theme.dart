import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CyberColors — ThemeExtension для доступа через Theme.of(context).extension
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class CyberColors extends ThemeExtension<CyberColors> {
  const CyberColors({
    required this.neonCyan,
    required this.neonGreen,
    required this.neonMagenta,
    required this.surfaceDeep,
    required this.gridLine,
  });

  final Color neonCyan;
  final Color neonGreen;
  final Color neonMagenta;
  final Color surfaceDeep;
  final Color gridLine;

  /// Значения по умолчанию из дизайн-системы (Cyberpunk Digital Assistant).
  static const CyberColors defaults = CyberColors(
    neonCyan: Color(0xFF00FFFF),
    neonGreen: Color(0xFF39FF14),
    neonMagenta: Color(0xFFFF00E5),
    surfaceDeep: Color(0xFF000000),
    gridLine: Color(0xFF00FFFF),
  );

  @override
  CyberColors copyWith({
    Color? neonCyan,
    Color? neonGreen,
    Color? neonMagenta,
    Color? surfaceDeep,
    Color? gridLine,
  }) =>
      CyberColors(
        neonCyan: neonCyan ?? this.neonCyan,
        neonGreen: neonGreen ?? this.neonGreen,
        neonMagenta: neonMagenta ?? this.neonMagenta,
        surfaceDeep: surfaceDeep ?? this.surfaceDeep,
        gridLine: gridLine ?? this.gridLine,
      );

  @override
  CyberColors lerp(CyberColors? other, double t) {
    if (other == null) return this;
    return CyberColors(
      neonCyan: Color.lerp(neonCyan, other.neonCyan, t)!,
      neonGreen: Color.lerp(neonGreen, other.neonGreen, t)!,
      neonMagenta: Color.lerp(neonMagenta, other.neonMagenta, t)!,
      surfaceDeep: Color.lerp(surfaceDeep, other.surfaceDeep, t)!,
      gridLine: Color.lerp(gridLine, other.gridLine, t)!,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme — фабрика ThemeData
// ─────────────────────────────────────────────────────────────────────────────

abstract final class AppTheme {
  // Backward-compat static shortcuts
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonMagenta = Color(0xFFFF00E5);
  static const Color surfaceDeep = Color(0xFF000000);

  static ThemeData darkCyberpunk() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: surfaceDeep,
      colorScheme: base.colorScheme.copyWith(
        primary: neonCyan,
        secondary: neonMagenta,
        surface: const Color(0xFF0D0D12),
        onPrimary: Colors.black,
        onSecondary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDeep,
        foregroundColor: neonCyan,
        elevation: 0,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: neonCyan,
      ),
      extensions: const [CyberColors.defaults],
    );
  }
}
