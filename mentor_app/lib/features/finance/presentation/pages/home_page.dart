import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/dashboard_repository.dart';
import '../bloc/home_bloc.dart';
import '../widgets/cyber_grid_background.dart';
import '../widgets/vietnam_progress_ring.dart';
import '../widgets/mentor_message_bubble.dart';
import '../widgets/cyber_mic_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Точка входа — создаёт BLoC
// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.api, required this.onLogout});

  final ApiService api;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HomeBloc(DashboardRepository(api))..add(const HomeLoadRequested()),
      child: _HomeView(api: api, onLogout: onLogout),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Основной экран (StatefulWidget — нужен для TextEditingController + ScrollController)
// ─────────────────────────────────────────────────────────────────────────────

class _HomeView extends StatefulWidget {
  const _HomeView({required this.api, required this.onLogout});

  final ApiService api;
  final VoidCallback onLogout;

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cyber = Theme.of(context).extension<CyberColors>() ?? CyberColors.defaults;
    final money = NumberFormat.decimalPattern('ru_RU');

    return Scaffold(
      backgroundColor: cyber.surfaceDeep,
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage!,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  backgroundColor: const Color(0xFF1A0020),
                ),
              );
          }
          // Прокрутка к последнему сообщению после обновления
          if (state.dashboard?.mentorMessages.isNotEmpty == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollCtrl.hasClients) {
                _scrollCtrl.animateTo(
                  _scrollCtrl.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        },
        builder: (context, state) {
          final d = state.dashboard;
          final target = d?.effectiveTarget ?? 180_000;
          final current = d?.effectiveCurrent ?? 0;
          final progress =
              (target <= 0 ? 0.0 : (current / target)).clamp(0.0, 1.0);
          final messages = d?.mentorMessages ?? const [];

          return CyberGridBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // ── Верхняя панель ─────────────────────────────────────
                  _TopBar(
                    onRefresh: () =>
                        context.read<HomeBloc>().add(const HomeLoadRequested()),
                    onLogout: () async {
                      try {
                        await widget.api.logout();
                      } catch (_) {}
                      if (context.mounted) widget.onLogout();
                    },
                    cyber: cyber,
                  ),

                  // ── Сообщения + прогресс (скролл) ─────────────────────
                  Expanded(
                    child: CustomScrollView(
                      controller: _scrollCtrl,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Sticky-заголовок с кольцевым прогрессом
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _ProgressHeaderDelegate(
                            progress: progress,
                            current: current,
                            target: target,
                            money: money,
                            cyber: cyber,
                          ),
                        ),

                        // Содержимое: загрузка / пусто / сообщения
                        if (state.status == HomeStatus.loading && d == null)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (messages.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                '> Пока нет данных.\n> Напиши или зажми микрофон.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.white24,
                                  fontSize: 13,
                                  height: 1.7,
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 10, 16, 16),
                            sliver: SliverList.separated(
                              itemCount: messages.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (_, i) =>
                                  MentorMessageBubble(message: messages[i]),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── Индикатор AI-запроса ───────────────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: state.isSendingAi
                        ? LinearProgressIndicator(
                            key: const ValueKey('ai'),
                            minHeight: 1.5,
                            backgroundColor: Colors.transparent,
                            valueColor:
                                AlwaysStoppedAnimation(cyber.neonCyan),
                          )
                        : SizedBox(
                            key: const ValueKey('idle'),
                            height: 1.5,
                          ),
                  ),

                  // ── Строка ввода ───────────────────────────────────────
                  _InputRow(
                    controller: _textCtrl,
                    isSending: state.isSendingAi,
                    onSend: () => _sendText(context),
                    cyber: cyber,
                  ),

                  // ── Mic-кнопка ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 14),
                    child: Column(
                      children: [
                        CyberMicButton(
                          isRecording: state.isRecording,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            context
                                .read<HomeBloc>()
                                .add(const HomeMicPressed());
                          },
                          onReleased: () => context
                              .read<HomeBloc>()
                              .add(const HomeMicReleased()),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: state.isRecording
                                ? cyber.neonMagenta.withValues(alpha: 0.85)
                                : Colors.white24,
                          ),
                          child: Text(
                            state.isRecording
                                ? '[ ОТПУСТИ — ОТПРАВИТЬ ]'
                                : '[ УДЕРЖИВАЙ — ГОВОРИТЬ ]',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _sendText(BuildContext context) {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    context.read<HomeBloc>().add(HomeAiTextSent(text));
    _textCtrl.clear();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onRefresh,
    required this.onLogout,
    required this.cyber,
  });

  final VoidCallback onRefresh;
  final VoidCallback onLogout;
  final CyberColors cyber;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '// MENTOR',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cyber.neonCyan,
              letterSpacing: 2.5,
              shadows: [
                Shadow(
                  color: cyber.neonCyan.withValues(alpha: 0.65),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const Spacer(),
          _CyberIconButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Обновить',
            onTap: onRefresh,
            cyber: cyber,
          ),
          const SizedBox(width: 8),
          _CyberIconButton(
            icon: Icons.logout_rounded,
            tooltip: 'Выйти',
            onTap: onLogout,
            cyber: cyber,
            color: cyber.neonMagenta,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CyberIconButton extends StatelessWidget {
  const _CyberIconButton({
    required this.icon,
    required this.onTap,
    required this.cyber,
    this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final CyberColors cyber;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? cyber.neonCyan;
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: c.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(7),
            color: c.withValues(alpha: 0.07),
          ),
          child: Icon(icon, size: 18, color: c),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SliverPersistentHeaderDelegate для прогресс-кольца
// Разворачивается до 240 px и схлопывается до 88 px при скролле.
// При схлопывании — Glassmorphism-blur + горизонтальный compact-режим.
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _ProgressHeaderDelegate({
    required this.progress,
    required this.current,
    required this.target,
    required this.money,
    required this.cyber,
  });

  final double progress;
  final double current;
  final double target;
  final NumberFormat money;
  final CyberColors cyber;

  static const double _minH = 88.0;
  static const double _maxH = 240.0;

  @override
  double get minExtent => _minH;

  @override
  double get maxExtent => _maxH;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // t: 0 = раскрыт, 1 = схлопнут
    final t = (shrinkOffset / (_maxH - _minH)).clamp(0.0, 1.0);
    final blurSigma = t * 12.0;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25 + t * 0.45),
            border: Border(
              bottom: BorderSide(
                color: cyber.neonCyan.withValues(alpha: 0.18 + t * 0.15),
                width: 0.5,
              ),
            ),
          ),
          child: t < 0.55
              // ── Expanded: кольцо + строка сумм ──────────────────────
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    VietnamProgressRing(
                      progress: progress,
                      size: (_maxH - 70) * (1 - t * 0.6),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${money.format(current)} ₽  /  ${money.format(target)} ₽',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Colors.white38,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                )
              // ── Collapsed: маленькое кольцо + текст рядом ───────────
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      VietnamProgressRing(progress: progress, size: 60),
                      const SizedBox(width: 14),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${(progress * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: cyber.neonCyan,
                              shadows: [
                                Shadow(
                                  color:
                                      cyber.neonCyan.withValues(alpha: 0.7),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${money.format(current)} ₽',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Colors.white38,
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
  bool shouldRebuild(_ProgressHeaderDelegate old) =>
      old.progress != progress ||
      old.current != current ||
      old.target != target;
}

// ─────────────────────────────────────────────────────────────────────────────
// Input row
// ─────────────────────────────────────────────────────────────────────────────

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.cyber,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final CyberColors cyber;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.white,
                fontSize: 13,
              ),
              cursorColor: cyber.neonCyan,
              decoration: InputDecoration(
                hintText: '> напиши ментору...',
                hintStyle: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.white.withValues(alpha: 0.18),
                  fontSize: 13,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: cyber.neonCyan.withValues(alpha: 0.25),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: cyber.neonCyan, width: 1.5),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.04),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isSending ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSending
                    ? Colors.white.withValues(alpha: 0.04)
                    : cyber.neonCyan.withValues(alpha: 0.14),
                border: Border.all(
                  color: isSending
                      ? Colors.white12
                      : cyber.neonCyan.withValues(alpha: 0.55),
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSending
                    ? null
                    : [
                        BoxShadow(
                          color: cyber.neonCyan.withValues(alpha: 0.18),
                          blurRadius: 8,
                        ),
                      ],
              ),
              child: Icon(
                Icons.send_rounded,
                size: 20,
                color: isSending
                    ? Colors.white.withValues(alpha: 0.18)
                    : cyber.neonCyan,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
