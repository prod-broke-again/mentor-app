import '../domain/dashboard_models.dart';
import '../../../core/network/api_service.dart';

final class DashboardRepository {
  DashboardRepository(this._api);

  final ApiService _api;

  Future<DashboardData> loadDashboard() async {
    final json = await _api.fetchDashboard();
    return DashboardData.fromJson(json);
  }

  Future<void> sendMentorText(String text) async {
    await _api.processAiText(text.trim());
  }

  Future<void> sendMentorAudio(String filePath) async {
    await _api.processAiAudioFile(filePath);
  }

  Future<void> applyMentorAction(int mentorMessageId) async {
    await _api.applyMentorAction(mentorMessageId);
  }
}
