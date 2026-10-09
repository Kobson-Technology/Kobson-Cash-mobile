class QuestModel {
  final String code;
  final String title;
  final String description;
  final double rewardAmount;
  final int type;
  final int currentProgress;
  final int targetThreshold;
  final int status; // 1: InProgress, 2: Completed, 3: Claimed
  final DateTime? claimedAt;

  QuestModel({
    required this.code,
    required this.title,
    required this.description,
    required this.rewardAmount,
    required this.type,
    required this.currentProgress,
    required this.targetThreshold,
    required this.status,
    this.claimedAt,
  });

  bool get isCompleted => status == 2;
  bool get isClaimed => status == 3;
  bool get isInProgress => status == 1;

  double get progressPercentage =>
      targetThreshold > 0 ? (currentProgress / targetThreshold).clamp(0.0, 1.0) : 0.0;

  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      rewardAmount: (json['rewardAmount'] as num?)?.toDouble() ?? 0.0,
      type: (json['type'] as num?)?.toInt() ?? 1,
      currentProgress: (json['currentProgress'] as num?)?.toInt() ?? 0,
      targetThreshold: (json['targetThreshold'] as num?)?.toInt() ?? 1,
      status: (json['status'] as num?)?.toInt() ?? 1,
      claimedAt: json['claimedAt'] != null ? DateTime.tryParse(json['claimedAt'].toString()) : null,
    );
  }
}

class ClaimQuestResultModel {
  final bool success;
  final double rewardAmount;
  final double newWalletBalance;
  final String message;

  ClaimQuestResultModel({
    required this.success,
    required this.rewardAmount,
    required this.newWalletBalance,
    required this.message,
  });

  factory ClaimQuestResultModel.fromJson(Map<String, dynamic> json) {
    return ClaimQuestResultModel(
      success: json['success'] == true,
      rewardAmount: (json['rewardAmount'] as num?)?.toDouble() ?? 0.0,
      newWalletBalance: (json['newWalletBalance'] as num?)?.toDouble() ?? 0.0,
      message: json['message']?.toString() ?? '',
    );
  }
}
