/// DTO дашборда с API.
final class DashboardGoal {
  const DashboardGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.locationSlug,
  });

  final int id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String locationSlug;

  factory DashboardGoal.fromJson(Map<String, dynamic> json) {
    return DashboardGoal(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      targetAmount: double.tryParse(json['target_amount']?.toString() ?? '') ?? 0,
      currentAmount: double.tryParse(json['current_amount']?.toString() ?? '') ?? 0,
      locationSlug: json['location_slug'] as String? ?? 'vietnam',
    );
  }
}

final class MentorMessageItem {
  const MentorMessageItem({
    required this.id,
    required this.body,
    required this.actionType,
    required this.actionAmount,
    required this.actionCategory,
    required this.createdAt,
  });

  final int id;
  final String body;
  final String? actionType;
  final double? actionAmount;
  final String? actionCategory;
  final String? createdAt;

  factory MentorMessageItem.fromJson(Map<String, dynamic> json) {
    final action = json['action'] as Map<String, dynamic>? ?? {};
    final amount = action['amount'];
    return MentorMessageItem(
      id: (json['id'] as num).toInt(),
      body: json['body'] as String? ?? '',
      actionType: action['type'] as String?,
      actionAmount: amount is num ? amount.toDouble() : null,
      actionCategory: action['category'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}

final class DashboardData {
  const DashboardData({
    required this.targetAmountRub,
    required this.goal,
    required this.progressCurrentRub,
    required this.mentorMessages,
  });

  final double targetAmountRub;
  final DashboardGoal? goal;
  final double progressCurrentRub;
  final List<MentorMessageItem> mentorMessages;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final rawGoal = json['goal'] as Map<String, dynamic>?;
    final msgs = (json['mentor_messages'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(MentorMessageItem.fromJson)
        .toList();
    return DashboardData(
      targetAmountRub: (json['target_amount_rub'] as num?)?.toDouble() ?? 180_000,
      goal: rawGoal != null ? DashboardGoal.fromJson(rawGoal) : null,
      progressCurrentRub: (json['progress_current_rub'] as num?)?.toDouble() ?? 0,
      mentorMessages: msgs,
    );
  }

  double get effectiveTarget => goal?.targetAmount ?? targetAmountRub;

  double get effectiveCurrent => goal?.currentAmount ?? progressCurrentRub;
}
