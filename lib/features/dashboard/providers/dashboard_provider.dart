import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/dashboard_models.dart';

final dashboardProvider = FutureProvider.autoDispose<DashboardSummaryModel>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final res = await apiClient.get('/api/v1/members/dashboard');
  return DashboardSummaryModel.fromJson(res);
});
