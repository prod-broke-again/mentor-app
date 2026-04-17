import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/dashboard_repository.dart';
import '../../domain/dashboard_models.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._repository) : super(const HomeState.initial()) {
    on<HomeLoadRequested>(_onLoad);
    on<HomeAiTextSent>(_onAiText);
    on<HomeMicPressed>(_onMicPressed);
    on<HomeMicReleased>(_onMicReleased);
    on<HomeMentorActionApplied>(_onMentorActionApplied);
  }

  final DashboardRepository _repository;
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordingPath;

  Future<void> _onLoad(HomeLoadRequested event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading, clearError: true));
    try {
      final data = await _repository.loadDashboard();
      emit(state.copyWith(status: HomeStatus.ready, dashboard: data));
    } on ApiException catch (e) {
      emit(state.copyWith(status: HomeStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onAiText(HomeAiTextSent event, Emitter<HomeState> emit) async {
    if (event.text.trim().isEmpty) return;
    emit(state.copyWith(isSendingAi: true, clearError: true));
    try {
      await _repository.sendMentorText(event.text);
      final data = await _repository.loadDashboard();
      emit(state.copyWith(isSendingAi: false, dashboard: data, status: HomeStatus.ready));
    } on ApiException catch (e) {
      emit(state.copyWith(isSendingAi: false, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(isSendingAi: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onMicPressed(HomeMicPressed event, Emitter<HomeState> emit) async {
    if (state.isRecording) return;
    if (!await _recorder.hasPermission()) {
      emit(state.copyWith(errorMessage: 'Нет доступа к микрофону'));
      return;
    }
    final path =
        '${Directory.systemTemp.path}/mentor_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _recordingPath = path;
    try {
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      emit(state.copyWith(isRecording: true, clearError: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Не удалось начать запись: $e'));
    }
  }

  Future<void> _onMicReleased(HomeMicReleased event, Emitter<HomeState> emit) async {
    if (!state.isRecording) return;
    emit(state.copyWith(isRecording: false, isSendingAi: true));
    try {
      final path = await _recorder.stop();
      final effectivePath = path ?? _recordingPath;
      _recordingPath = null;
      if (effectivePath == null || effectivePath.isEmpty) {
        emit(state.copyWith(isSendingAi: false, errorMessage: 'Пустая запись'));
        return;
      }
      await _repository.sendMentorAudio(effectivePath);
      try {
        await File(effectivePath).delete();
      } catch (_) {}
      final data = await _repository.loadDashboard();
      emit(state.copyWith(isSendingAi: false, dashboard: data, status: HomeStatus.ready));
    } on ApiException catch (e) {
      emit(state.copyWith(isSendingAi: false, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(isSendingAi: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onMentorActionApplied(
    HomeMentorActionApplied event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isSendingAi: true, clearError: true));
    try {
      await _repository.applyMentorAction(event.messageId);
      final data = await _repository.loadDashboard();
      emit(state.copyWith(isSendingAi: false, dashboard: data, status: HomeStatus.ready));
    } on ApiException catch (e) {
      emit(state.copyWith(isSendingAi: false, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(isSendingAi: false, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _recorder.dispose();
    return super.close();
  }
}
