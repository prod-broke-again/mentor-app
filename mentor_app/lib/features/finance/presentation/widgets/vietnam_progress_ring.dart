import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/soft_ui_colors.dart';

/// Soft ring progress — no neon blur; calm gradient accent.
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
    final soft = Theme.of(context).extension<SoftUiColors>() ?? SoftUiColors.light;
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter = size ?? (constraints.maxWidth * 0.55).clamp(120.0, 280.0);
        final p = progress.clamp(0.0, 1.0);

        return SizedBox.square(
          dimension: diameter,
          child: CustomPaint(
            painter: _SoftRingPainter(
              progress: p,
              track: soft.outline.withValues(alpha: 0.45),
              start: soft.accentSoft,
              end: soft.accent,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(p * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                          height: 1.0,
                          fontSize: diameter * 0.16,
                        ),
                  ),
                  SizedBox(height: diameter * 0.03),
                  Text(
                    'Цель: Вьетнам',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          letterSpacing: 0.6,
                          fontSize: (diameter * 0.065).clamp(10.0, 13.0),
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

class _SoftRingPainter extends CustomPainter {
  const _SoftRingPainter({
    required this.progress,
    required this.track,
    required this.start,
    required this.end,
  });

  final double progress;
  final Color track;
  final Color start;
  final Color end;

  static const double _stroke = 7;
  static const double _radiusFactor = 0.84;
  static const double _startAngle = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) * _radiusFactor;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke,
    );

    if (progress <= 0) return;

    final sweep = 2 * math.pi * progress;
    final gradient = SweepGradient(
      startAngle: _startAngle,
      endAngle: _startAngle + sweep,
      colors: [start, end],
      tileMode: TileMode.clamp,
      transform: const GradientRotation(_startAngle),
    ).createShader(rect);

    canvas.drawArc(
      rect,
      _startAngle,
      sweep,
      false,
      Paint()
        ..shader = gradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round,
    );

    final endAngle = _startAngle + sweep;
    final dot = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );
    canvas.drawCircle(
      dot,
      _stroke / 2 + 1,
      Paint()..color = end.withValues(alpha: 0.35),
    );
    canvas.drawCircle(dot, _stroke / 2, Paint()..color = end);
  }

  @override
  bool shouldRepaint(_SoftRingPainter old) =>
      old.progress != progress ||
      old.track != track ||
      old.start != start ||
      old.end != end;
}
