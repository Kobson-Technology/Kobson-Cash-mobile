import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/referral_models.dart';

final referralTreeProvider = FutureProvider.autoDispose<ReferralTreeModel>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final res = await apiClient.get('/api/v1/referrals/tree');
  return ReferralTreeModel.fromJson(res);
});

final levelProgressionProvider = FutureProvider.autoDispose<LevelProgressionModel>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final res = await apiClient.get('/api/v1/referrals/levels');
  return LevelProgressionModel.fromJson(res);
});

