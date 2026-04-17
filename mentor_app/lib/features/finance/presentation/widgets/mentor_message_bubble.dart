import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/theme/soft_ui_colors.dart';
import '../../domain/dashboard_models.dart';

/// Message card: soft surface, light border, readable markdown.
class MentorMessageBubble extends StatelessWidget {
  const MentorMessageBubble({super.key, required this.message});

  final MentorMessageItem message;

  @override
  Widget build(BuildContext context) {
    final soft = Theme.of(context).extension<SoftUiColors>() ?? SoftUiColors.light;
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        color: soft.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: soft.outline.withValues(alpha: 0.85)),
        boxShadow: SoftUiColors.shadowRaised(brightness),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _MentorBadge(soft: soft),
              const SizedBox(width: 8),
              if (message.createdAt != null)
                Text(
                  _formatTime(message.createdAt!),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          MarkdownBody(
            data: message.body,
            shrinkWrap: true,
            selectable: false,
            styleSheet: _markdownStyle(context, soft, scheme),
          ),
          if (_hasAction) ...[
            const SizedBox(height: 10),
            _ActionBadge(message: message, soft: soft),
          ],
        ],
      ),
    );
  }

  bool get _hasAction =>
      message.actionType != null ||
      message.actionAmount != null ||
      message.actionCategory != null;

  static String _formatTime(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }

  static MarkdownStyleSheet _markdownStyle(
    BuildContext context,
    SoftUiColors soft,
    ColorScheme scheme,
  ) {
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    final body = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
          height: 1.55,
        );
    return base.copyWith(
      p: body,
      pPadding: EdgeInsets.zero,
      strong: body?.copyWith(
        color: soft.accent,
        fontWeight: FontWeight.w700,
      ),
      em: body?.copyWith(
        color: soft.success,
        fontStyle: FontStyle.italic,
      ),
      code: TextStyle(
        color: scheme.onSurface,
        backgroundColor: soft.outline.withValues(alpha: 0.25),
        fontSize: 13,
        fontFamily: 'monospace',
      ),
      codeblockDecoration: BoxDecoration(
        color: soft.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: soft.outline),
      ),
      blockquote: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14, height: 1.5),
      blockquoteDecoration: BoxDecoration(
        color: soft.accent.withValues(alpha: 0.06),
        border: Border(
          left: BorderSide(color: soft.accent.withValues(alpha: 0.65), width: 3),
        ),
      ),
      h1: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
      h2: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
      h3: Theme.of(context).textTheme.titleSmall?.copyWith(color: scheme.onSurface),
      listBullet: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: soft.outline, width: 1),
        ),
      ),
    );
  }
}

class _MentorBadge extends StatelessWidget {
  const _MentorBadge({required this.soft});

  final SoftUiColors soft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: soft.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: soft.accent.withValues(alpha: 0.35)),
      ),
      child: Text(
        'Ментор',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: soft.accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  const _ActionBadge({
    required this.message,
    required this.soft,
  });

  final MentorMessageItem message;
  final SoftUiColors soft;

  @override
  Widget build(BuildContext context) {
    final parts = [
      if (message.actionType != null) message.actionType!.toUpperCase(),
      if (message.actionAmount != null) '${message.actionAmount!.toStringAsFixed(0)} ₽',
      if (message.actionCategory != null) message.actionCategory!,
    ].where((e) => e.isNotEmpty).toList();

    if (parts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: soft.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: soft.success.withValues(alpha: 0.35)),
      ),
      child: Text(
        parts.join(' · '),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: soft.success,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
