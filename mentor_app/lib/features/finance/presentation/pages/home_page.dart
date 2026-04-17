import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_service.dart';
import '../../../../core/theme/soft_ui_colors.dart';
import '../../data/dashboard_repository.dart';
import '../../domain/dashboard_models.dart';
import '../bloc/home_bloc.dart';
import '../widgets/ambient_background.dart';
import '../widgets/home/home_input_row.dart';
import '../widgets/home/home_quick_bar.dart';
import '../widgets/home/home_sub_bar.dart';
import '../widgets/home/home_top_bar.dart';
import '../widgets/mentor_message_bubble.dart';

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

  bool _groupWithPrevious(List<MentorMessageItem> list, int i) {
    if (i <= 0) return false;
    final a = list[i - 1].createdAt;
    final b = list[i].createdAt;
    if (a == null || b == null) return false;
    try {
      final da = DateTime.parse(a);
      final db = DateTime.parse(b);
      return da.difference(db).inMinutes.abs() <= 3;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final soft = Theme.of(context).extension<SoftUiColors>() ?? SoftUiColors.dark;
    final scheme = Theme.of(context).colorScheme;

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
          final goalLabel = d?.goal?.title.isNotEmpty == true
              ? d!.goal!.title
              : 'Вьетнам';

          return AmbientBackground(
            child: SafeArea(
              child: Column(
                children: [
                  HomeTopBar(
                    progress: progress,
                    current: current,
                    target: target,
                    goalLabel: goalLabel,
                    onRefresh: () =>
                        context.read<HomeBloc>().add(const HomeLoadRequested()),
                    onLogout: () async {
                      try {
                        await widget.api.logout();
                      } catch (_) {}
                      if (context.mounted) widget.onLogout();
                    },
                  ),
                  HomeSubBar(current: current, target: target),
                  HomeQuickBar(
                    onChip: (prompt) =>
                        context.read<HomeBloc>().add(HomeAiTextSent(prompt)),
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
                  Expanded(
                    child: state.status == HomeStatus.loading && d == null
                        ? const Center(child: CircularProgressIndicator())
                        : messages.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Text(
                                    'Пока нет сообщений.\nНапишите ниже или используйте быстрые подсказки.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                          height: 1.6,
                                        ),
                                  ),
                                ),
                              )
                            : ListView(
                                controller: _scrollCtrl,
                                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                                children: [
                                  const _DayDivider(),
                                  for (var i = 0; i < messages.length; i++) ...[
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: i == messages.length - 1
                                            ? 0
                                            : (_groupWithPrevious(messages, i + 1) ? 2 : 6),
                                      ),
                                      child: MentorMessageBubble(
                                        message: messages[i],
                                        groupWithPrevious:
                                            _groupWithPrevious(messages, i),
                                        isApplyingAction: state.isSendingAi,
                                        onApplyAction: () => context
                                            .read<HomeBloc>()
                                            .add(HomeMentorActionApplied(messages[i].id)),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                  ),
                  HomeInputRow(
                    controller: _textCtrl,
                    isSending: state.isSendingAi,
                    isRecording: state.isRecording,
                    onSend: () => _sendText(context),
                    onMicDown: () {
                      HapticFeedback.mediumImpact();
                      context.read<HomeBloc>().add(const HomeMicPressed());
                    },
                    onMicUp: () =>
                        context.read<HomeBloc>().add(const HomeMicReleased()),
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

class _DayDivider extends StatelessWidget {
  const _DayDivider();

  @override
  Widget build(BuildContext context) {
    final soft = Theme.of(context).extension<SoftUiColors>() ?? SoftUiColors.dark;
    final now = DateTime.now();
    final label = DateFormat('d MMM', 'ru_RU').format(now);

    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: soft.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: soft.outline),
        ),
        child: Text(
          'Сегодня · $label',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: soft.textMute,
                fontSize: 11,
              ),
        ),
      ),
    );
  }
}
