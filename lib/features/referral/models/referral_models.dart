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
