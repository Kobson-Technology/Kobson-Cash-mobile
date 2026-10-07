enum WithdrawalOperator {
  wave(1, 'Wave', 'wave'),
  orangeMoney(2, 'Orange Money', 'orange'),
  mtn(3, 'MTN Mobile Money', 'mtn'),
  moov(4, 'Moov Money', 'moov'),
  djamo(5, 'Djamo', 'djamo');

  final int id;
  final String displayName;
  final String brandKey;
  const WithdrawalOperator(this.id, this.displayName, this.brandKey);
}

class WithdrawalModel {
  final String id;
  final String reference;
  final double amount;
  final double fee;
  final double netAmount;
  final int mode;
  final String phoneNumber;
  final String status;
  final DateTime createdAt;

  WithdrawalModel({
    required this.id,
    required this.reference,
    required this.amount,
    required this.fee,
    required this.netAmount,
    required this.mode,
    required this.phoneNumber,
    required this.status,
    required this.createdAt,
  });

  String get operatorName {
    switch (mode) {
      case 1:
        return 'Wave';
      case 2:
        return 'Orange Money';
      case 3:
        return 'MTN';
      case 4:
        return 'Moov';
      case 5:
        return 'Djamo';
      default:
        return 'Mobile Money';
    }
  }

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: json['id']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0.0,
      mode: (json['mode'] as num?)?.toInt() ?? 1,
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
