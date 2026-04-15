part of 'home_bloc.dart';

enum HomeStatus { initial, loading, ready, error }

final class HomeState extends Equatable {
  const HomeState({
    required this.status,
    required this.dashboard,
    required this.errorMessage,
    required this.isRecording,
    required this.isSendingAi,
  });

  const HomeState.initial()
      : status = HomeStatus.initial,
        dashboard = null,
        errorMessage = null,
        isRecording = false,
        isSendingAi = false;

  final HomeStatus status;
  final DashboardData? dashboard;
  final String? errorMessage;
  final bool isRecording;
  final bool isSendingAi;

  HomeState copyWith({
    HomeStatus? status,
    DashboardData? dashboard,
    String? errorMessage,
    bool? clearError,
    bool? isRecording,
    bool? isSendingAi,
  }) {
    return HomeState(
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      errorMessage: clearError == true ? null : (errorMessage ?? this.errorMessage),
      isRecording: isRecording ?? this.isRecording,
      isSendingAi: isSendingAi ?? this.isSendingAi,
    );
  }

  @override
  List<Object?> get props => [status, dashboard, errorMessage, isRecording, isSendingAi];
}
