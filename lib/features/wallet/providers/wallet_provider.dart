import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/wallet_models.dart';

final walletProvider = FutureProvider.autoDispose<WalletModel>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final res = await apiClient.get('/api/v1/wallet');
  return WalletModel.fromJson(res);
});

final walletTransactionsProvider = FutureProvider.autoDispose<List<WalletTransactionModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final res = await apiClient.get('/api/v1/wallet/transactions?pageNumber=1&pageSize=50');
  final items = (res['items'] as List<dynamic>? ?? []);
  return items.map((e) => WalletTransactionModel.fromJson(e as Map<String, dynamic>)).toList();
});
