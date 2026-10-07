import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../models/withdrawal_models.dart';

final withdrawalHistoryProvider = FutureProvider.autoDispose<List<WithdrawalModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final res = await apiClient.get('/api/v1/withdrawals?pageNumber=1&pageSize=50');
  final items = (res['items'] as List<dynamic>? ?? []);
  return items.map((e) => WithdrawalModel.fromJson(e as Map<String, dynamic>)).toList();
});

class WithdrawalNotifier extends Notifier<AsyncValue<WithdrawalModel?>> {
  @override
  AsyncValue<WithdrawalModel?> build() {
    return const AsyncValue.data(null);
  }

  Future<WithdrawalModel?> submitWithdrawal({
    required double amount,
    required WithdrawalOperator operator,
    required String phoneNumber,
  }) async {
    state = const AsyncValue.loading();
    try {
      final apiClient = ref.read(apiClientProvider);
      final res = await apiClient.post(
        '/api/v1/withdrawals',
        body: {
          'amount': amount,
          'mode': operator.id,
          'phoneNumber': phoneNumber,
        },
      );
      final result = WithdrawalModel.fromJson(res);
      state = AsyncValue.data(result);

      // Invalidate relevant providers to refresh balances and transactions
      ref.invalidate(walletProvider);
      ref.invalidate(walletTransactionsProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(withdrawalHistoryProvider);

      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final withdrawalNotifierProvider = NotifierProvider<WithdrawalNotifier, AsyncValue<WithdrawalModel?>>(WithdrawalNotifier.new);
