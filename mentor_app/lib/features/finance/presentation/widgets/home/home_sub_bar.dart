import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/soft_ui_colors.dart';

/// Secondary stats row under the top bar (reference `.subbar`).
class HomeSubBar extends StatelessWidget {
  const HomeSubBar({
    super.key,
    required this.current,
    required this.target,
  });

  final double current;
  final double target;

  @override
  Widget build(BuildContext context) {
    final soft = Theme.of(context).extension<SoftUiColors>() ?? SoftUiColors.dark;
    final money = NumberFormat.decimalPattern('ru_RU');
    final remaining = (target - current).clamp(0.0, double.infinity);
    final estDays = remaining <= 0 ? 0 : (remaining / 2000).ceil();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D10),
        border: Border(bottom: BorderSide(color: soft.outline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: soft.textMute,
                      fontSize: 11.5,
                    ),
                children: [
                  const TextSpan(text: 'До цели: '),
                  TextSpan(
                    text: '${money.format(remaining)} ₽',
                    style: TextStyle(
                      color: soft.textDim,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: soft.accentGhost,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: soft.accentLine),
            ),
            child: Text(
              estDays <= 0 ? 'Цель достигнута' : '$estDays дн. (оценка)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: soft.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
