import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';

class PublicConfig {
  final double membershipAmount;
  final double cashInFeePercent;
  final double totalMembershipPayment;
  final double commissionLevel1;
  final double commissionLevel2;
  final double commissionLevel3;
  final double minimumWithdrawal;
  final double maximumWithdrawal;
  final double withdrawalFeePercent;
  final double withdrawalFeeFixed;
  final double withdrawalFee;
  final String currency;

  PublicConfig({
    required this.membershipAmount,
    required this.cashInFeePercent,
    required this.totalMembershipPayment,
    required this.commissionLevel1,
    required this.commissionLevel2,
    required this.commissionLevel3,
    required this.minimumWithdrawal,
    required this.maximumWithdrawal,
    required this.withdrawalFeePercent,
    required this.withdrawalFeeFixed,
    required this.withdrawalFee,
    required this.currency,
  });

  /// Calculates the dynamic withdrawal fee for a given gross amount
  double calculateWithdrawalFee(double amount) {
    if (amount <= 0) return 0.0;
    final percentFee = (amount * (withdrawalFeePercent / 100.0)).roundToDouble();
    final fee = percentFee > withdrawalFeeFixed ? percentFee : withdrawalFeeFixed;
    return (fee == 0.0 && withdrawalFee > 0.0) ? withdrawalFee : fee;
  }

  /// Calculates the dynamic net amount received after deduction of fees
  double calculateNetWithdrawal(double amount) {
    final fee = calculateWithdrawalFee(amount);
    return (amount > fee) ? (amount - fee) : 0.0;
  }

  /// Calculates the cash-in fee for membership
  double get cashInFee => (membershipAmount * (cashInFeePercent / 100.0)).roundToDouble();

  factory PublicConfig.fromJson(Map<String, dynamic> json) {
    final memAmount = (json['membershipAmount'] as num?)?.toDouble() ?? 4500.0;
    final inFeePercent = (json['cashInFeePercent'] as num?)?.toDouble() ?? 3.0;
    final inFee = (memAmount * (inFeePercent / 100.0)).roundToDouble();
    final totalPay = (json['totalMembershipPayment'] as num?)?.toDouble() ?? (memAmount + inFee);

    return PublicConfig(
      membershipAmount: memAmount,
      cashInFeePercent: inFeePercent,
      totalMembershipPayment: totalPay,
      commissionLevel1: (json['commissionLevel1'] as num?)?.toDouble() ?? 2200.0,
      commissionLevel2: (json['commissionLevel2'] as num?)?.toDouble() ?? 900.0,
      commissionLevel3: (json['commissionLevel3'] as num?)?.toDouble() ?? 500.0,
      minimumWithdrawal: (json['minimumWithdrawal'] as num?)?.toDouble() ?? 1000.0,
      maximumWithdrawal: (json['maximumWithdrawal'] as num?)?.toDouble() ?? 500000.0,
      withdrawalFeePercent: (json['withdrawalFeePercent'] as num?)?.toDouble() ?? 2.0,
      withdrawalFeeFixed: (json['withdrawalFeeFixed'] as num?)?.toDouble() ?? 0.0,
      withdrawalFee: (json['withdrawalFee'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'FCFA',
    );
  }
}

final configProvider = FutureProvider<PublicConfig>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final res = await apiClient.get('/api/v1/config', requiresAuth: false);
    return PublicConfig.fromJson(res);
  } catch (_) {
    // Fallback default business structure
    return PublicConfig(
      membershipAmount: 4500.0,
      cashInFeePercent: 3.0,
      totalMembershipPayment: 4635.0,
      commissionLevel1: 2200.0,
      commissionLevel2: 900.0,
      commissionLevel3: 500.0,
      minimumWithdrawal: 1000.0,
      maximumWithdrawal: 500000.0,
      withdrawalFeePercent: 2.0,
      withdrawalFeeFixed: 0.0,
      withdrawalFee: 0.0,
      currency: 'FCFA',
    );
  }
});
