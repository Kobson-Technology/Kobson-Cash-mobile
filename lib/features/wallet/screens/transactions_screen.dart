import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_badge.dart';
import '../models/wallet_models.dart';
import '../providers/wallet_provider.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _selectedFilter = 'Toutes';

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(walletTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Historique des Transactions'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(walletTransactionsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Toutes'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Commissions'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Retraits'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Réservations'),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          Expanded(
            child: txAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Erreur: $err', style: const TextStyle(color: AppColors.errorRed)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(walletTransactionsProvider),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
              data: (transactions) {
                final filtered = transactions.where((tx) {
                  if (_selectedFilter == 'Commissions') {
                    return tx.type.toLowerCase().contains('commission');
                  } else if (_selectedFilter == 'Retraits') {
                    return tx.type.toLowerCase() == 'withdrawal';
                  } else if (_selectedFilter == 'Réservations') {
                    return tx.type.toLowerCase().contains('hold');
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textSecondary),
                          SizedBox(height: 16),
                          Text(
                            'Aucune transaction trouvée',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(walletTransactionsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildTransactionCard(item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      backgroundColor: const Color(0xFFF1F5F9),
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilter = label);
      },
    );
  }

  Widget _buildTransactionCard(WalletTransactionModel item) {
    final isCredit = item.type.toLowerCase().contains('commission') ||
        item.type.toLowerCase().contains('refund') ||
        item.type.toLowerCase().contains('adjustment');
    final isHold = item.type.toLowerCase().contains('hold');

    Color iconBg;
    Color iconColor;
    IconData icon;

    if (isHold) {
      iconBg = AppColors.accentGold.withValues(alpha: 0.12);
      iconColor = AppColors.accentGold;
      icon = Icons.lock_clock_outlined;
    } else if (isCredit) {
      iconBg = AppColors.successGreen.withValues(alpha: 0.12);
      iconColor = AppColors.successGreen;
      icon = Icons.arrow_downward_rounded;
    } else {
      iconBg = AppColors.errorRed.withValues(alpha: 0.12);
      iconColor = AppColors.errorRed;
      icon = Icons.arrow_upward_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.formatTransactionType(item.type),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.formatDateTime(item.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isCredit ? "+" : (isHold ? "" : "-")}${Formatters.formatCurrency(item.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isHold
                          ? AppColors.accentGold
                          : (isCredit ? AppColors.successGreen : AppColors.errorRed),
                    ),
                  ),
                  const SizedBox(height: 2),
                  StatusBadge(status: item.type),
                ],
              ),
            ],
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.description,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Réf: ${item.reference}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                'Solde après: ${Formatters.formatCurrency(item.balanceAfter)}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
