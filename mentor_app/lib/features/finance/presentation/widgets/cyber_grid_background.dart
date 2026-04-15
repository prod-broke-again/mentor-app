import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Фоновый виджет: тёмное полотно + слабые линии сетки в стиле Cyberpunk.
///
/// Использует [RepaintBoundary] для изоляции перерисовки сетки.
/// [child] рендерится поверх сетки.
class CyberGridBackground extends StatelessWidget {
  const CyberGridBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final cyber = Theme.of(context).extension<CyberColors>() ?? CyberColors.defaults;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Чёрный фон
        ColoredBox(color: cyber.surfaceDeep),

        // Сетка (isolate repaints)
        RepaintBoundary(
          child: CustomPaint(
            painter: _GridPainter(gridColor: cyber.gridLine),
            child: const SizedBox.expand(),
          ),
        ),

        // Виньетирование: радиальный градиент по углам для ощущения глубины
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.35,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
            child: const SizedBox.expand(),
          ),
        ),

        if (child != null) child!,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.gridColor});

  final Color gridColor;

  // Размер ячейки в логических пикселях
  static const double _cell = 32.0;
  static const int _accentEvery = 4; // каждая 4-я линия — чуть ярче

  @override
  void paint(Canvas canvas, Size size) {
    final faint = Paint()
      ..color = gridColor.withValues(alpha: 0.04)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final accent = Paint()
      ..color = gridColor.withValues(alpha: 0.09)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Вертикальные линии
    for (double x = 0; x <= size.width; x += _cell) {
      final isAccent = (x / _cell).round() % _accentEvery == 0;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), isAccent ? accent : faint);
    }

    // Горизонтальные линии
    for (double y = 0; y <= size.height; y += _cell) {
      final isAccent = (y / _cell).round() % _accentEvery == 0;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), isAccent ? accent : faint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.gridColor != gridColor;
}
