import 'package:flutter/material.dart';

import '../../../../../core/theme/soft_ui_colors.dart';

/// Composer: rounded row + mic + gradient send (reference `.composer` / `.inputrow`).
class HomeInputRow extends StatefulWidget {
  const HomeInputRow({
    super.key,
    required this.controller,
    required this.isSending,
    required this.isRecording,
    required this.onSend,
    required this.onMicDown,
    required this.onMicUp,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool isRecording;
  final VoidCallback onSend;
  final VoidCallback onMicDown;
  final VoidCallback onMicUp;

  @override
  State<HomeInputRow> createState() => _HomeInputRowState();
}

class _HomeInputRowState extends State<HomeInputRow> {
  late final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final soft = Theme.of(context).extension<SoftUiColors>() ?? SoftUiColors.dark;
    final focused = _focus.hasFocus;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            soft.background,
            const Color(0xFF0A0A0C),
          ],
        ),
        border: Border(top: BorderSide(color: soft.outline)),
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
            decoration: BoxDecoration(
              color: soft.surfaceBubble,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: focused ? soft.accentLine : soft.outline,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focus,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: soft.textPrimary,
                          fontSize: 14.5,
                        ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Напишите ментору…',
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: soft.textMute,
                            fontSize: 14.5,
                          ),
                    ),
                    onSubmitted: (_) => widget.onSend(),
                  ),
                ),
                Listener(
                  onPointerDown: (_) => widget.onMicDown(),
                  onPointerUp: (_) => widget.onMicUp(),
                  onPointerCancel: (_) => widget.onMicUp(),
                  child: _SquareBtn(
                    size: 34,
                    borderRadius: 10,
                    color: soft.surfaceRaised,
                    borderColor: soft.outline,
                    child: Icon(
                      Icons.mic_rounded,
                      size: 16,
                      color: widget.isRecording ? soft.accent : soft.textDim,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _GradientSendBtn(
                  soft: soft,
                  enabled: !widget.isSending,
                  onTap: widget.onSend,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.isRecording
                ? 'Отпустите — отправить голос'
                : 'Удерживайте микрофон — говорить',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: soft.textMute,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}

class _SquareBtn extends StatelessWidget {
  const _SquareBtn({
    required this.child,
    required this.color,
    required this.borderColor,
    this.size = 34,
    this.borderRadius = 10,
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class _GradientSendBtn extends StatelessWidget {
  const _GradientSendBtn({
    required this.soft,
    required this.enabled,
    required this.onTap,
  });

  final SoftUiColors soft;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: enabled
                  ? [soft.accent, soft.accentSoft]
                  : [
                      soft.outline,
                      soft.outlineStrong,
                    ],
            ),
          ),
          child: Icon(
            Icons.send_rounded,
            size: 16,
            color: enabled ? soft.accentForeground : soft.textMute,
          ),
        ),
      ),
    );
  }
}
