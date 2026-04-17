import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/soft_ui_colors.dart';

/// Compact top bar: brand dot + goal chip + horizontal progress + amounts + actions.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.progress,
    required this.current,
    required this.target,
    required this.goalLabel,
    required this.onRefresh,
    required this.onLogout,
  });

  final double progress;
  final double current;
  final double target;
  final String goalLabel;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final soft = Theme.of(context).extension<SoftUiColors>() ?? SoftUiColors.dark;
    final money = NumberFormat.decimalPattern('ru_RU');
    final p = progress.clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF101014),
            soft.background,
          ],
        ),
        border: Border(bottom: BorderSide(color: soft.outline)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: soft.accent,
                  boxShadow: [
                    BoxShadow(
                      color: soft.accentLine.withValues(alpha: 0.85),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Mentor',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: soft.textPrimary,
                      letterSpacing: 0.2,
                    ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: soft.surfaceBubble,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: soft.outline),
                  ),
                  child: Text(
                    goalLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: soft.textDim,
                          fontSize: 11,
                        ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        value: p,
                        backgroundColor: soft.surfaceBubble,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.lerp(soft.accentSoft, soft.accent, 0.5)!,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${money.format(current)} / ${money.format(target)} ₽',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: soft.textDim,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _IconBtn(
            icon: Icons.refresh_rounded,
            tooltip: 'Обновить',
            onTap: onRefresh,
            soft: soft,
            danger: false,
          ),
          const SizedBox(width: 8),
          _IconBtn(
            icon: Icons.logout_rounded,
            tooltip: 'Выйти',
            onTap: onLogout,
            soft: soft,
            danger: true,
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    required this.soft,
    required this.danger,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final SoftUiColors soft;
  final bool danger;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: soft.surfaceBubble,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: soft.outline),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(
              icon,
              size: 18,
              color: danger ? soft.accent : soft.textDim,
            ),
          ),
        ),
      ),
    );
  }
}
