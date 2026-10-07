class TransactionItemModel {
  final String id;
  final String type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String reference;
  final String description;
  final DateTime createdAt;

  TransactionItemModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.reference,
    required this.description,
    required this.createdAt,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Unknown',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      balanceBefore: (json['balanceBefore'] as num?)?.toDouble() ?? 0.0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      reference: json['reference']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class DashboardSummaryModel {
  final double availableBalance;
  final double heldBalance;
  final double totalCommissions;
  final double totalWithdrawn;
  final int level1Count;
  final int level2Count;
  final int level3Count;
  final String referralCode;
  final String referralLink;
  final bool hasActiveMembership;
  final List<TransactionItemModel> recentTransactions;

  DashboardSummaryModel({
    required this.availableBalance,
    required this.heldBalance,
    required this.totalCommissions,
    required this.totalWithdrawn,
    required this.level1Count,
    required this.level2Count,
    required this.level3Count,
    required this.referralCode,
    required this.referralLink,
    required this.hasActiveMembership,
    required this.recentTransactions,
  });

  int get totalTeamCount => level1Count + level2Count + level3Count;

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    var rawTx = json['recentTransactions'] as List<dynamic>? ?? [];
    return DashboardSummaryModel(
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      heldBalance: (json['heldBalance'] as num?)?.toDouble() ?? 0.0,
      totalCommissions: (json['totalCommissions'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawn: (json['totalWithdrawn'] as num?)?.toDouble() ?? 0.0,
      level1Count: (json['level1Count'] as num?)?.toInt() ?? 0,
      level2Count: (json['level2Count'] as num?)?.toInt() ?? 0,
      level3Count: (json['level3Count'] as num?)?.toInt() ?? 0,
      referralCode: json['referralCode']?.toString() ?? '',
      referralLink: json['referralLink']?.toString() ?? '',
      hasActiveMembership: json['hasActiveMembership'] ?? false,
      recentTransactions: rawTx.map((e) => TransactionItemModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
