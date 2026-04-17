import 'package:flutter/material.dart';

import '../../../../../core/theme/soft_ui_colors.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.onRefresh,
    required this.onLogout,
  });

  final VoidCallback onRefresh;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final soft = Theme.of(context).extension<SoftUiColors>() ?? SoftUiColors.light;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            'Mentor',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                  letterSpacing: -0.5,
                ),
          ),
          const Spacer(),
          _SoftIconButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Обновить',
            onTap: onRefresh,
            soft: soft,
          ),
          const SizedBox(width: 8),
          _SoftIconButton(
            icon: Icons.logout_rounded,
            tooltip: 'Выйти',
            onTap: onLogout,
            soft: soft,
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _SoftIconButton extends StatelessWidget {
  const _SoftIconButton({
    required this.icon,
    required this.onTap,
    required this.soft,
    this.tooltip,
    this.emphasize = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final SoftUiColors soft;
  final String? tooltip;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = emphasize ? scheme.error : soft.accent;

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: soft.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: soft.outline.withValues(alpha: 0.9)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}
