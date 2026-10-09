class ReferralNodeModel {
  final String userId;
  final String fullName;
  final String referralCode;
  final String status;
  final int level;
  final DateTime joinedAt;
  final double totalCommissionsGenerated;

  ReferralNodeModel({
    required this.userId,
    required this.fullName,
    required this.referralCode,
    required this.status,
    required this.level,
    required this.joinedAt,
    required this.totalCommissionsGenerated,
  });

  factory ReferralNodeModel.fromJson(Map<String, dynamic> json) {
    return ReferralNodeModel(
      userId: json['userId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'Membre',
      referralCode: json['referralCode']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      level: (json['level'] as num?)?.toInt() ?? 1,
      joinedAt: json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : DateTime.now(),
      totalCommissionsGenerated: (json['totalCommissionsGenerated'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ReferralTreeModel {
  final String myReferralCode;
  final String shareUrl;
  final int level1Count;
  final int level2Count;
  final int level3Count;
  final List<ReferralNodeModel> directReferrals;

  ReferralTreeModel({
    required this.myReferralCode,
    required this.shareUrl,
    required this.level1Count,
    required this.level2Count,
    required this.level3Count,
    required this.directReferrals,
  });

  int get totalTeamCount => level1Count + level2Count + level3Count;

  factory ReferralTreeModel.fromJson(Map<String, dynamic> json) {
    var rawList = json['directReferrals'] as List<dynamic>? ?? [];
    return ReferralTreeModel(
      myReferralCode: json['myReferralCode']?.toString() ?? '',
      shareUrl: json['shareUrl']?.toString() ?? '',
      level1Count: (json['level1Count'] as num?)?.toInt() ?? 0,
      level2Count: (json['level2Count'] as num?)?.toInt() ?? 0,
      level3Count: (json['level3Count'] as num?)?.toInt() ?? 0,
      directReferrals: rawList.map((e) => ReferralNodeModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class LevelQuestTaskModel {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final int currentProgress;
  final int targetProgress;

  LevelQuestTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.currentProgress,
    required this.targetProgress,
  });

  factory LevelQuestTaskModel.fromJson(Map<String, dynamic> json) {
    return LevelQuestTaskModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isCompleted: json['isCompleted'] == true,
      currentProgress: (json['currentProgress'] as num?)?.toInt() ?? 0,
      targetProgress: (json['targetProgress'] as num?)?.toInt() ?? 1,
    );
  }
}

class LevelTierModel {
  final int level;
  final String title;
  final String honorificTitle;
  final double commissionAmount;
  final bool isUnlocked;
  final String assetPath;
  final double pendingLockedAmount;
  final List<LevelQuestTaskModel> tasks;

  LevelTierModel({
    required this.level,
    required this.title,
    required this.honorificTitle,
    required this.commissionAmount,
    required this.isUnlocked,
    required this.assetPath,
    required this.pendingLockedAmount,
    required this.tasks,
  });

  factory LevelTierModel.fromJson(Map<String, dynamic> json) {
    var rawTasks = json['tasks'] as List<dynamic>? ?? [];
    return LevelTierModel(
      level: (json['level'] as num?)?.toInt() ?? 1,
      title: json['title']?.toString() ?? '',
      honorificTitle: json['honorificTitle']?.toString() ?? '',
      commissionAmount: (json['commissionAmount'] as num?)?.toDouble() ?? 0.0,
      isUnlocked: json['isUnlocked'] == true,
      assetPath: json['assetPath']?.toString() ?? 'assets/images/pepite_or_n1.jpg',
      pendingLockedAmount: (json['pendingLockedAmount'] as num?)?.toDouble() ?? 0.0,
      tasks: rawTasks.map((t) => LevelQuestTaskModel.fromJson(t as Map<String, dynamic>)).toList(),
    );
  }
}

class LevelProgressionModel {
  final int currentUnlockedLevel;
  final int activeDirectReferrals;
  final int activeLevel2Referrals;
  final int activeTotalTeam;
  final double totalGoldEarned;
  final double totalGoldPending;
  final LevelTierModel level1;
  final LevelTierModel level2;
  final LevelTierModel level3;

  LevelProgressionModel({
    required this.currentUnlockedLevel,
    required this.activeDirectReferrals,
    required this.activeLevel2Referrals,
    required this.activeTotalTeam,
    required this.totalGoldEarned,
    required this.totalGoldPending,
    required this.level1,
    required this.level2,
    required this.level3,
  });

  factory LevelProgressionModel.fromJson(Map<String, dynamic> json) {
    return LevelProgressionModel(
      currentUnlockedLevel: (json['currentUnlockedLevel'] as num?)?.toInt() ?? 0,
      activeDirectReferrals: (json['activeDirectReferrals'] as num?)?.toInt() ?? 0,
      activeLevel2Referrals: (json['activeLevel2Referrals'] as num?)?.toInt() ?? 0,
      activeTotalTeam: (json['activeTotalTeam'] as num?)?.toInt() ?? 0,
      totalGoldEarned: (json['totalGoldEarned'] as num?)?.toDouble() ?? 0.0,
      totalGoldPending: (json['totalGoldPending'] as num?)?.toDouble() ?? 0.0,
      level1: LevelTierModel.fromJson(json['level1'] as Map<String, dynamic>? ?? {}),
      level2: LevelTierModel.fromJson(json['level2'] as Map<String, dynamic>? ?? {}),
      level3: LevelTierModel.fromJson(json['level3'] as Map<String, dynamic>? ?? {}),
    );
  }
}

