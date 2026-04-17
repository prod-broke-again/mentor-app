import 'package:flutter/material.dart';

import '../../../../../core/theme/soft_ui_colors.dart';

typedef QuickChipCallback = void Function(String prompt);

/// Horizontal quick prompts (reference `.quickbar` / `.qchip`).
class HomeQuickBar extends StatelessWidget {
  const HomeQuickBar({super.key, required this.onChip});

  final QuickChipCallback onChip;

  static const _chips = <(String label, String prompt)>[
    ('+ Отложить', 'Хочу отложить деньги сегодня, подскажи как лучше.'),
    ('Трата', 'Записать трату за сегодня.'),
    ('Итог дня', 'Дай краткий итог дня по накоплениям.'),
    ('План недели', 'Краткий финансовый план на неделю.'),
  ];

  @override
  Widget build(BuildContext context) {
    final soft = Theme.of(context).extension<SoftUiColors>() ?? SoftUiColors.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final (label, prompt) in _chips)
            Material(
              color: soft.surface,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: () => onChip(prompt),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: soft.outline),
                  ),
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: soft.textDim,
                          fontSize: 12,
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
