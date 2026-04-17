import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/theme/soft_ui_colors.dart';
import '../../domain/dashboard_models.dart';

/// Chat bubble variant A: dense mentor message, optional grouping, action chips.
class MentorMessageBubble extends StatelessWidget {
  const MentorMessageBubble({
    super.key,
    required this.message,
    this.groupWithPrevious = false,
    required this.onApplyAction,
    this.isApplyingAction = false,
  });

  final MentorMessageItem message;
  final bool groupWithPrevious;
  final VoidCallback onApplyAction;
  final bool isApplyingAction;

  @override
  Widget build(BuildContext context) {
    final soft = Theme.of(context).extension<SoftUiColors>() ?? SoftUiColors.dark;
    final showMeta = !groupWithPrevious;
    final radiusTopLeft = groupWithPrevious ? 14.0 : 6.0;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.86,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: soft.surfaceBubble,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radiusTopLeft),
                  topRight: const Radius.circular(14),
                  bottomLeft: const Radius.circular(14),
                  bottomRight: const Radius.circular(14),
                ),
                border: Border.all(color: soft.outline),
              ),
              child: MarkdownBody(
                data: message.body,
                shrinkWrap: true,
                selectable: false,
                styleSheet: _markdownStyle(context, soft),
              ),
            ),
            if (showMeta) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: Row(
                  children: [
                    Text(
                      'Ментор',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: soft.textMute,
                            fontSize: 10.5,
                          ),
                    ),
                    if (message.createdAt != null) ...[
                      Text(
                        ' · ',
                        style: TextStyle(color: soft.textMute, fontSize: 10.5),
                      ),
                      Text(
                        _formatTime(message.createdAt!),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: soft.textMute,
                              fontSize: 10.5,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (_hasAction) ...[
              const SizedBox(height: 6),
              _ActionChips(
                message: message,
                soft: soft,
                isApplying: isApplyingAction,
                onApplyAction: onApplyAction,
              ),
            ],
          ],
        ),
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

  static MarkdownStyleSheet _markdownStyle(BuildContext context, SoftUiColors soft) {
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    final body = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: soft.textPrimary,
          fontSize: 14.5,
          height: 1.4,
        );
    return base.copyWith(
      p: body,
      pPadding: EdgeInsets.zero,
      strong: body?.copyWith(
        color: soft.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      em: body?.copyWith(
        color: soft.success,
        fontStyle: FontStyle.italic,
      ),
      code: TextStyle(
        color: soft.textPrimary,
        backgroundColor: soft.surfaceRaised,
        fontSize: 13,
        fontFamily: 'monospace',
      ),
      codeblockDecoration: BoxDecoration(
        color: soft.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: soft.outline),
      ),
      blockquote: TextStyle(color: soft.textDim, fontSize: 14, height: 1.45),
      blockquoteDecoration: BoxDecoration(
        color: soft.accentGhost,
        border: Border(
          left: BorderSide(color: soft.accentLine, width: 3),
        ),
      ),
      h1: body?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
      h2: body?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
      h3: body?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      listBullet: TextStyle(color: soft.textDim, fontSize: 14),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: soft.outline, width: 0.5)),
      ),
    );
  }
}

class _ActionChips extends StatelessWidget {
  const _ActionChips({
    required this.message,
    required this.soft,
    required this.onApplyAction,
    required this.isApplying,
  });

  final MentorMessageItem message;
  final SoftUiColors soft;
  final VoidCallback onApplyAction;
  final bool isApplying;

  @override
  Widget build(BuildContext context) {
    final parts = [
      if (message.actionType != null) message.actionType!.toUpperCase(),
      if (message.actionAmount != null) '${message.actionAmount!.toStringAsFixed(0)} ₽',
      if (message.actionCategory != null) message.actionCategory!,
    ].where((e) => e.isNotEmpty).toList();

    if (parts.isEmpty) return const SizedBox.shrink();

    final actionType = message.actionType?.toLowerCase();
    final canApply = (actionType == 'save' || actionType == 'spend') &&
        (message.actionAmount ?? 0) > 0 &&
        !isApplying;
    final applyLabel = actionType == 'spend' ? 'Списать' : 'Сохранить';

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canApply ? onApplyAction : null,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: canApply
                      ? [soft.accent, soft.accentSoft]
                      : [soft.outline, soft.outlineStrong],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.save_rounded, size: 14, color: soft.accentForeground),
                  const SizedBox(width: 4),
                  Text(
                    '$applyLabel · ${parts.join(' · ')}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: soft.accentForeground,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: soft.outline),
              ),
              child: Text(
                'Позже',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: soft.textDim,
                      fontSize: 12.5,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
