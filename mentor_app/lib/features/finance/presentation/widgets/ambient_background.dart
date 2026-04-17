import 'package:flutter/material.dart';

import '../../../../core/theme/soft_ui_colors.dart';

/// Calm background: solid surface + optional very subtle grid (no neon).
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final soft = Theme.of(context).extension<SoftUiColors>() ?? SoftUiColors.light;
    final brightness = Theme.of(context).brightness;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: soft.background),
        RepaintBoundary(
          child: CustomPaint(
            painter: _SoftGridPainter(
              gridColor: soft.gridLine,
              brightness: brightness,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  soft.accent.withValues(alpha: brightness == Brightness.dark ? 0.04 : 0.03),
                  Colors.transparent,
                  soft.background.withValues(alpha: 0),
                ],
              ),
            ),
            child: const SizedBox.expand(),
          ),
        ),
        if (child case final Widget w) w,
      ],
    );
  }
}

class _SoftGridPainter extends CustomPainter {
  const _SoftGridPainter({
    required this.gridColor,
    required this.brightness,
  });

  final Color gridColor;
  final Brightness brightness;

  static const double _cell = 40;

  @override
  void paint(Canvas canvas, Size size) {
    final alpha = brightness == Brightness.dark ? 0.045 : 0.035;
    final paint = Paint()
      ..color = gridColor.withValues(alpha: alpha)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (double x = 0; x <= size.width; x += _cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += _cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_SoftGridPainter old) =>
      old.gridColor != gridColor || old.brightness != brightness;
}
