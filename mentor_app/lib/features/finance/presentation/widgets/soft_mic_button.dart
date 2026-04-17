import 'package:flutter/material.dart';

import '../../../../core/theme/soft_ui_colors.dart';

/// Push-to-talk control: soft raised surface, minimal glow.
class SoftMicButton extends StatefulWidget {
  const SoftMicButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
    required this.onReleased,
    this.size = 72,
  });

  final bool isRecording;
  final VoidCallback onPressed;
  final VoidCallback onReleased;
  final double size;

  @override
  State<SoftMicButton> createState() => _SoftMicButtonState();
}

class _SoftMicButtonState extends State<SoftMicButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final soft = Theme.of(context).extension<SoftUiColors>() ?? SoftUiColors.light;
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isRec = widget.isRecording;
    final accent = isRec ? scheme.error : soft.accent;
    final s = widget.size;

    return Listener(
      onPointerDown: (_) => widget.onPressed(),
      onPointerUp: (_) => widget.onReleased(),
      onPointerCancel: (_) => widget.onReleased(),
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          final scale = isRec ? 1.0 + (_pulse.value * 0.04) : 1.0;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: s,
              height: s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRec ? scheme.error.withValues(alpha: 0.12) : soft.surfaceElevated,
                border: Border.all(
                  color: accent.withValues(alpha: isRec ? 0.55 : 0.35),
                  width: 1.5,
                ),
                boxShadow: SoftUiColors.shadowRaised(brightness),
              ),
              child: Icon(
                isRec ? Icons.stop_rounded : Icons.mic_rounded,
                size: s * 0.38,
                color: accent,
              ),
            ),
          );
        },
      ),
    );
  }
}
