import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/soft_ui_colors.dart';
import '../vietnam_progress_ring.dart';

/// Sticky header with ring progress; soft blur when collapsed.
class HomeProgressHeaderDelegate extends SliverPersistentHeaderDelegate {
  HomeProgressHeaderDelegate({
    required this.progress,
    required this.current,
    required this.target,
    required this.money,
  });

  final double progress;
  final double current;
  final double target;
  final NumberFormat money;

  static const double _minH = 88;
  static const double _maxH = 232;

  @override
  double get minExtent => _minH;

  @override
  double get maxExtent => _maxH;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final soft = Theme.of(context).extension<SoftUiColors>() ?? SoftUiColors.light;
    final scheme = Theme.of(context).colorScheme;
    final t = (shrinkOffset / (_maxH - _minH)).clamp(0.0, 1.0);
    final blurSigma = t * 10.0;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              soft.surface.withValues(alpha: 0.72 + t * 0.2),
              soft.background,
            ),
            border: Border(
              bottom: BorderSide(color: soft.outline.withValues(alpha: 0.65)),
            ),
          ),
          child: t < 0.55
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    VietnamProgressRing(
                      progress: progress,
                      size: (_maxH - 64) * (1 - t * 0.55),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${money.format(current)} ₽  /  ${money.format(target)} ₽',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      VietnamProgressRing(progress: progress, size: 58),
                      const SizedBox(width: 14),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${(progress * 100).toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                          ),
                          Text(
                            '${money.format(current)} ₽',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(HomeProgressHeaderDelegate old) =>
      old.progress != progress ||
      old.current != current ||
      old.target != target;
}
