import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Кольцевой прогресс-бар «до Вьетнама» в стиле Cyberpunk.
///
/// Использует [CustomPainter] с [MaskFilter.blur] для неонового свечения.
/// В центре — крупный Monospace-процент + подпись "Destination: Vietnam".
///
/// [progress] — значение от 0.0 до 1.0.
/// [size]     — диаметр кольца; если null, займёт 55% ширины родителя.
class VietnamProgressRing extends StatelessWidget {
  const VietnamProgressRing({
    super.key,
    required this.progress,
    this.size,
  });

  final double progress;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final cyber = Theme.of(context).extension<CyberColors>() ?? CyberColors.defaults;

    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter = size ?? (constraints.maxWidth * 0.55).clamp(120.0, 280.0);

        return SizedBox.square(
          dimension: diameter,
          child: CustomPaint(
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              neonCyan: cyber.neonCyan,
              neonGreen: cyber.neonGreen,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Процент — крупный Monospace
                  Text(
                    '${(progress.clamp(0.0, 1.0) * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: diameter * 0.18,
                      fontWeight: FontWeight.bold,
                      color: cyber.neonCyan,
                      height: 1.0,
                      shadows: [
                        Shadow(
                          color: cyber.neonCyan.withValues(alpha: 0.85),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: diameter * 0.03),
                  // Подпись
                  Text(
                    'Destination: Vietnam',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: (diameter * 0.072).clamp(9.0, 14.0),
                      color: cyber.neonGreen.withValues(alpha: 0.8),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.neonCyan,
    required this.neonGreen,
  });

  final double progress;
  final Color neonCyan;
  final Color neonGreen;

  static const double _strokeWidth = 8.0;
  static const double _radiusFactor = 0.84;
  static const double _startAngle = -math.pi / 2; // 12 часов

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) * _radiusFactor;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // ── 1. Трек (фоновое кольцо) ──────────────────────────────────────────
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = neonCyan.withValues(alpha: 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth,
    );

    if (progress <= 0) return;

    final sweepAngle = 2 * math.pi * progress;
    final gradient = SweepGradient(
      startAngle: _startAngle,
      endAngle: _startAngle + sweepAngle,
      colors: [neonGreen, neonCyan],
      tileMode: TileMode.clamp,
      transform: const GradientRotation(_startAngle),
    ).createShader(rect);

    // ── 2. Слой свечения (blur) ───────────────────────────────────────────
    canvas.drawArc(
      rect,
      _startAngle,
      sweepAngle,
      false,
      Paint()
        ..shader = gradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth + 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // ── 3. Основная дуга ──────────────────────────────────────────────────
    canvas.drawArc(
      rect,
      _startAngle,
      sweepAngle,
      false,
      Paint()
        ..shader = gradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // ── 4. Точка в конце дуги ─────────────────────────────────────────────
    final endAngle = _startAngle + sweepAngle;
    final dotCenter = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );
    // Свечение точки
    canvas.drawCircle(
      dotCenter,
      _strokeWidth / 2 + 3,
      Paint()
        ..color = neonCyan
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    // Яркое ядро точки
    canvas.drawCircle(
      dotCenter,
      _strokeWidth / 2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.neonCyan != neonCyan ||
      old.neonGreen != neonGreen;
}
