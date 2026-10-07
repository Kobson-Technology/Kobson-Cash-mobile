import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';

class PublicConfig {
  final double membershipAmount;
  final double commissionLevel1;
  final double commissionLevel2;
  final double commissionLevel3;
  final double minimumWithdrawal;
  final double maximumWithdrawal;
  final double withdrawalFee;
  final String currency;

  PublicConfig({
    required this.membershipAmount,
    required this.commissionLevel1,
    required this.commissionLevel2,
    required this.commissionLevel3,
    required this.minimumWithdrawal,
    required this.maximumWithdrawal,
    required this.withdrawalFee,
    required this.currency,
  });

  factory PublicConfig.fromJson(Map<String, dynamic> json) {
    return PublicConfig(
      membershipAmount: (json['membershipAmount'] as num?)?.toDouble() ?? 4500.0,
      commissionLevel1: (json['commissionLevel1'] as num?)?.toDouble() ?? 2200.0,
      commissionLevel2: (json['commissionLevel2'] as num?)?.toDouble() ?? 900.0,
      commissionLevel3: (json['commissionLevel3'] as num?)?.toDouble() ?? 500.0,
      minimumWithdrawal: (json['minimumWithdrawal'] as num?)?.toDouble() ?? 1000.0,
      maximumWithdrawal: (json['maximumWithdrawal'] as num?)?.toDouble() ?? 500000.0,
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
      commissionLevel1: 2200.0,
      commissionLevel2: 900.0,
      commissionLevel3: 500.0,
      minimumWithdrawal: 1000.0,
      maximumWithdrawal: 500000.0,
      withdrawalFee: 0.0,
      currency: 'FCFA',
    );
  }
});
