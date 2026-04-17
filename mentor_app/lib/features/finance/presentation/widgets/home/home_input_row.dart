import 'package:flutter/material.dart';

import '../../../../../core/theme/soft_ui_colors.dart';

class HomeInputRow extends StatelessWidget {
  const HomeInputRow({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final soft = Theme.of(context).extension<SoftUiColors>() ?? SoftUiColors.light;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Напишите ментору…',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.65),
                    ),
                filled: true,
                fillColor: soft.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: soft.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: soft.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: soft.accent, width: 2),
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: isSending ? soft.outline.withValues(alpha: 0.35) : soft.accent,
            elevation: 0,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: isSending ? null : onSend,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Icon(
                  Icons.send_rounded,
                  size: 22,
                  color: isSending
                      ? scheme.onSurfaceVariant
                      : soft.accentForeground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
