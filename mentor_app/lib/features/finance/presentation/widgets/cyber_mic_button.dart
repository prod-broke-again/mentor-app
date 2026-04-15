import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Push-to-talk кнопка в форме шестиугольника с пульсирующим нео-ореолом.
///
/// При [isRecording] == true:
///   - Запускается анимация пульса ([AnimationController] + [BoxShadow]).
///   - Иконка меняется на [Icons.stop_rounded].
///   - Цветовая схема — neonMagenta.
///
/// При [isRecording] == false — статичное неоновое кольцо (neonCyan).
///
/// Взаимодействие через [onPressed] / [onReleased] (Pointer events).
class CyberMicButton extends StatefulWidget {
  const CyberMicButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
    required this.onReleased,
    this.size = 76.0,
  });

  final bool isRecording;
  final VoidCallback onPressed;
  final VoidCallback onReleased;

  /// Размер описанной окружности шестиугольника (логические пиксели).
  final double size;

  @override
  State<CyberMicButton> createState() => _CyberMicButtonState();
}

class _CyberMicButtonState extends State<CyberMicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);

    _pulseAnim = CurvedAnimation(parent: _pulse, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cyber = Theme.of(context).extension<CyberColors>() ?? CyberColors.defaults;

    return Listener(
      onPointerDown: (_) => widget.onPressed(),
      onPointerUp: (_) => widget.onReleased(),
      onPointerCancel: (_) => widget.onReleased(),
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, _) {
          final isRec = widget.isRecording;
          final glowColor = isRec ? cyber.neonMagenta : cyber.neonCyan;
          final s = widget.size;

          // Радиус пульсирующего ореола — только при записи
          final haloRadius = isRec ? _pulseAnim.value * s * 0.35 : 0.0;
          final haloOpacity = isRec ? (0.55 - _pulseAnim.value * 0.50) : 0.0;

          // Внешняя область (для ореола)
          final outerBox = s + haloRadius * 2 + 20;

          return SizedBox.square(
            dimension: outerBox,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Пульсирующий внешний ореол ──────────────────────────
                if (isRec) ...[
                  // Размытое свечение
                  Container(
                    width: s + haloRadius * 2,
                    height: s + haloRadius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withValues(alpha: haloOpacity),
                          blurRadius: 28,
                          spreadRadius: haloRadius * 0.5,
                        ),
                      ],
                    ),
                  ),
                  // Пульсирующая граница-кольцо
                  Container(
                    width: s + haloRadius * 1.4,
                    height: s + haloRadius * 1.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: glowColor.withValues(alpha: haloOpacity * 0.7),
                        width: 1.0,
                      ),
                    ),
                  ),
                ],

                // ── Шестиугольная кнопка ────────────────────────────────
                ClipPath(
                  clipper: const _HexClipper(),
                  child: Container(
                    width: s,
                    height: s,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isRec
                            ? [
                                cyber.neonMagenta.withValues(alpha: 0.35),
                                cyber.neonMagenta.withValues(alpha: 0.10),
                              ]
                            : [
                                cyber.neonCyan.withValues(alpha: 0.18),
                                cyber.neonCyan.withValues(alpha: 0.04),
                              ],
                      ),
                    ),
                    child: CustomPaint(
                      painter: _HexBorderPainter(
                        color: glowColor,
                        glowSigma: isRec ? 7.0 : 4.0,
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isRec ? Icons.stop_rounded : Icons.mic_rounded,
                            key: ValueKey(isRec),
                            size: s * 0.40,
                            color: glowColor,
                            shadows: [
                              Shadow(
                                color: glowColor.withValues(alpha: 0.90),
                                blurRadius: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Хелпер: путь правильного шестиугольника (pointy-top)
// ─────────────────────────────────────────────────────────────────────────────

Path _buildHexPath(Size size) {
  final cx = size.width / 2;
  final cy = size.height / 2;
  final r = math.min(cx, cy) * 0.90;
  final path = Path();
  for (int i = 0; i < 6; i++) {
    // 30° смещение → pointy-top
    final angle = math.pi / 6 + i * (math.pi / 3);
    final x = cx + r * math.cos(angle);
    final y = cy + r * math.sin(angle);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  return path;
}

// ─────────────────────────────────────────────────────────────────────────────

class _HexClipper extends CustomClipper<Path> {
  const _HexClipper();

  @override
  Path getClip(Size size) => _buildHexPath(size);

  @override
  bool shouldReclip(_HexClipper _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────

class _HexBorderPainter extends CustomPainter {
  const _HexBorderPainter({required this.color, this.glowSigma = 4.0});

  final Color color;
  final double glowSigma;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildHexPath(size);

    // Слой свечения
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSigma),
    );

    // Чёткая граница поверх
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_HexBorderPainter old) =>
      old.color != color || old.glowSigma != glowSigma;
}
