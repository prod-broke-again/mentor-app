import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_service.dart';
import '../../../../core/theme/soft_ui_colors.dart';
import '../../data/dashboard_repository.dart';
import '../bloc/home_bloc.dart';
import '../widgets/ambient_background.dart';
import '../widgets/home/home_input_row.dart';
import '../widgets/home/home_progress_header.dart';
import '../widgets/home/home_top_bar.dart';
import '../widgets/mentor_message_bubble.dart';
import '../widgets/soft_mic_button.dart';

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
    final soft = Theme.of(context).extension<SoftUiColors>() ?? SoftUiColors.light;
    final scheme = Theme.of(context).colorScheme;
    final money = NumberFormat.decimalPattern('ru_RU');

    return Scaffold(
      backgroundColor: soft.background,
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
          }
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
          final progress = (target <= 0 ? 0.0 : (current / target)).clamp(0.0, 1.0);
          final messages = d?.mentorMessages ?? const [];

          return AmbientBackground(
            child: SafeArea(
              child: Column(
                children: [
                  HomeTopBar(
                    onRefresh: () =>
                        context.read<HomeBloc>().add(const HomeLoadRequested()),
                    onLogout: () async {
                      try {
                        await widget.api.logout();
                      } catch (_) {}
                      if (context.mounted) widget.onLogout();
                    },
                  ),
                  Expanded(
                    child: CustomScrollView(
                      controller: _scrollCtrl,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: HomeProgressHeaderDelegate(
                            progress: progress,
                            current: current,
                            target: target,
                            money: money,
                          ),
                        ),
                        if (state.status == HomeStatus.loading && d == null)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (messages.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  'Пока нет сообщений.\nНапишите текст или удерживайте микрофон.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                        height: 1.6,
                                      ),
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                            sliver: SliverList.separated(
                              itemCount: messages.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (_, i) =>
                                  MentorMessageBubble(message: messages[i]),
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: state.isSendingAi
                        ? LinearProgressIndicator(
                            key: const ValueKey('ai'),
                            minHeight: 2,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(soft.accent),
                          )
                        : const SizedBox(key: ValueKey('idle'), height: 2),
                  ),
                  HomeInputRow(
                    controller: _textCtrl,
                    isSending: state.isSendingAi,
                    onSend: () => _sendText(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 16),
                    child: Column(
                      children: [
                        SoftMicButton(
                          isRecording: state.isRecording,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            context.read<HomeBloc>().add(const HomeMicPressed());
                          },
                          onReleased: () =>
                              context.read<HomeBloc>().add(const HomeMicReleased()),
                        ),
                        const SizedBox(height: 6),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                color: state.isRecording
                                    ? scheme.error.withValues(alpha: 0.9)
                                    : scheme.onSurfaceVariant,
                              ),
                          child: Text(
                            state.isRecording
                                ? 'Отпустите — отправить'
                                : 'Удерживайте — говорить',
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
