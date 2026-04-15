import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/dashboard_models.dart';

/// Glassmorphism-баббл для сообщений от ментора.
///
/// Техника: [ClipRRect] + [BackdropFilter] (blur σ=10) + полупрозрачный фон.
/// Текст сообщения поддерживает Markdown через пакет flutter_markdown.
class MentorMessageBubble extends StatelessWidget {
  const MentorMessageBubble({super.key, required this.message});

  final MentorMessageItem message;

  @override
  Widget build(BuildContext context) {
    final cyber = Theme.of(context).extension<CyberColors>() ?? CyberColors.defaults;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            // Полупрозрачный серый фон (Glassmorphism)
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            // Градиентная рамка: от прозрачного → neon cyan
            border: Border.all(
              color: cyber.neonCyan.withValues(alpha: 0.30),
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Заголовок: бейдж + время ──────────────────────────────
              Row(
                children: [
                  _MentorBadge(cyber: cyber),
                  const SizedBox(width: 8),
                  if (message.createdAt != null)
                    Text(
                      _formatTime(message.createdAt!),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: cyber.neonCyan.withValues(alpha: 0.45),
                        letterSpacing: 0.5,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Тело: Markdown ────────────────────────────────────────
              MarkdownBody(
                data: message.body,
                shrinkWrap: true,
                selectable: false,
                styleSheet: _buildMarkdownStyle(context, cyber),
              ),

              // ── Action-бейдж (если есть) ──────────────────────────────
              if (_hasAction) ...[
                const SizedBox(height: 8),
                _ActionBadge(message: message, cyber: cyber),
              ],
            ],
          ),
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

  static MarkdownStyleSheet _buildMarkdownStyle(
    BuildContext context,
    CyberColors cyber,
  ) {
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    const bodyStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      height: 1.55,
    );
    return base.copyWith(
      p: bodyStyle,
      pPadding: EdgeInsets.zero,
      strong: TextStyle(
        color: cyber.neonCyan,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      em: TextStyle(
        color: cyber.neonGreen,
        fontStyle: FontStyle.italic,
        fontSize: 14,
      ),
      code: TextStyle(
        fontFamily: 'monospace',
        color: cyber.neonGreen,
        backgroundColor: Colors.white.withValues(alpha: 0.07),
        fontSize: 13,
      ),
      codeblockDecoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cyber.neonCyan.withValues(alpha: 0.2)),
      ),
      blockquote: const TextStyle(color: Colors.white60, fontSize: 14),
      blockquoteDecoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border(
          left: BorderSide(color: cyber.neonCyan.withValues(alpha: 0.5), width: 3),
        ),
      ),
      h1: TextStyle(
        color: cyber.neonCyan,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      h2: TextStyle(
        color: cyber.neonCyan,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      h3: TextStyle(color: cyber.neonCyan, fontSize: 14),
      listBullet: const TextStyle(color: Colors.white60, fontSize: 14),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: cyber.neonCyan.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MentorBadge extends StatelessWidget {
  const _MentorBadge({required this.cyber});

  final CyberColors cyber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: cyber.neonCyan.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: cyber.neonCyan.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: cyber.neonCyan.withValues(alpha: 0.15),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        'MENTOR',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 9,
          color: cyber.neonCyan,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ActionBadge extends StatelessWidget {
  const _ActionBadge({required this.message, required this.cyber});

  final MentorMessageItem message;
  final CyberColors cyber;

  @override
  Widget build(BuildContext context) {
    final parts = [
      if (message.actionType != null) message.actionType!.toUpperCase(),
      if (message.actionAmount != null)
        '${message.actionAmount!.toStringAsFixed(0)} ₽',
      if (message.actionCategory != null) message.actionCategory!,
    ].where((e) => e.isNotEmpty).toList();

    if (parts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cyber.neonGreen.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cyber.neonGreen.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: cyber.neonGreen.withValues(alpha: 0.12),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        parts.join(' · '),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          color: cyber.neonGreen,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
