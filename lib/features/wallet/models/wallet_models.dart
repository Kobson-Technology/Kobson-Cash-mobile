class WalletModel {
  final String id;
  final String currency;
  final double balance;
  final double heldBalance;
  final double availableBalance;
  final DateTime? updatedAt;

  WalletModel({
    required this.id,
    required this.currency,
    required this.balance,
    required this.heldBalance,
    required this.availableBalance,
    this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'FCFA',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      heldBalance: (json['heldBalance'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class WalletTransactionModel {
  final String id;
  final String type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String reference;
  final String description;
  final DateTime createdAt;

  WalletTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.reference,
    required this.description,
    required this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Transaction',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      balanceBefore: (json['balanceBefore'] as num?)?.toDouble() ?? 0.0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      reference: json['reference']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  String get typeLabel {
    const labels = {
      '1': 'Adhésion',
      '2': 'Commission parrainage',
      '3': 'Retrait',
      '4': 'Blocage retrait',
      '5': 'Libération retrait',
      '6': 'Frais de paiement',
      '7': 'Remboursement',
      '8': 'Ajustement',
      '9': 'Revenu plateforme',
      '10': 'Prime quête',
    };
    return labels[type] ?? 'Transaction';
  }
}
