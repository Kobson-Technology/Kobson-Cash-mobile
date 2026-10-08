import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/image_converter.dart';
import '../../../shared/widgets/balance_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../membership/screens/membership_payment_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../referral/screens/my_team_screen.dart';
import '../../referral/screens/referral_screen.dart';
import '../../wallet/screens/transactions_screen.dart';
import '../../withdrawals/screens/withdrawal_screen.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final dashboardAsync = ref.watch(dashboardProvider);

    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardProvider);
            await ref.read(authProvider.notifier).checkAuthStatus();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top App Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Builder(
                          builder: (context) {
                            final photoBytes = ImageConverter.decodeBase64Photo(user?.photo);
                            return CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
                              backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
                              child: photoBytes == null
                                  ? Text(
                                      user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'K',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlue,
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bonjour, ${user?.fullName.split(' ').first ?? 'Adhérent'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'Kobson Cash Côte d\'Ivoire',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 28, color: AppColors.navyBlue),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Dashboard Content
                dashboardAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, _) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Erreur: $err', style: const TextStyle(color: AppColors.errorRed)),
                  ),
                  data: (dash) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Membership status warning or active badge
                        if (!dash.hasActiveMembership) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: AppColors.accentGold, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Adhésion en attente',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF92400E),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Activez votre compte pour débloquer les commissions et retraits.',
                                        style: TextStyle(fontSize: 12, color: Color(0xFFB45309)),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentGold,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const MembershipPaymentScreen()),
                                    );
                                  },
                                  child: const Text('Activer', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Main Balance Card
                        BalanceCard(
                          availableBalance: dash.availableBalance,
                          heldBalance: dash.heldBalance,
                          onWithdrawPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const WithdrawalScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Quick Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildQuickAction(
                              context,
                              icon: Icons.account_balance_wallet,
                              label: 'Retirer',
                              color: AppColors.primaryBlue,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const WithdrawalScreen()),
                                );
                              },
                            ),
                            _buildQuickAction(
                              context,
                              icon: Icons.person_add_alt_1,
                              label: 'Inviter',
                              color: AppColors.accentGold,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ReferralScreen()),
                                );
                              },
                            ),
                            _buildQuickAction(
                              context,
                              icon: Icons.group_work,
                              label: 'Mon Équipe',
                              color: AppColors.successGreen,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const MyTeamScreen()),
                                );
                              },
                            ),
                            _buildQuickAction(
                              context,
                              icon: Icons.receipt_long,
                              label: 'Historique',
                              color: AppColors.navyBlue,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Stats Grid (Commissions / Équipe)
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                title: 'Commissions',
                                value: Formatters.formatCurrency(dash.totalCommissions),
                                subtitle: 'Cumul perçu',
                                icon: Icons.trending_up,
                                color: AppColors.successGreen,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Réseau affilié',
                                value: '${dash.totalTeamCount} membres',
                                subtitle: 'N1: ${dash.level1Count} | N2: ${dash.level2Count} | N3: ${dash.level3Count}',
                                icon: Icons.hub_outlined,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Recent Transactions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Transactions récentes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                                );
                              },
                              child: const Text('Voir tout'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (dash.recentTransactions.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'Aucune transaction récente.',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          )
                        else
                          Container(
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
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: dash.recentTransactions.take(4).length,
                              separatorBuilder: (_, _) => const Divider(height: 1, indent: 64),
                              itemBuilder: (context, index) {
                                final tx = dash.recentTransactions[index];
                                final isCredit = tx.type.toLowerCase().contains('commission');
                                final isHold = tx.type.toLowerCase().contains('hold');

                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: isHold
                                        ? AppColors.accentGold.withValues(alpha: 0.12)
                                        : (isCredit ? AppColors.successGreen.withValues(alpha: 0.12) : AppColors.errorRed.withValues(alpha: 0.12)),
                                    child: Icon(
                                      isHold
                                          ? Icons.lock_clock
                                          : (isCredit ? Icons.arrow_downward : Icons.arrow_upward),
                                      size: 16,
                                      color: isHold
                                          ? AppColors.accentGold
                                          : (isCredit ? AppColors.successGreen : AppColors.errorRed),
                                    ),
                                  ),
                                  title: Text(
                                    Formatters.formatTransactionType(tx.type),
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  subtitle: Text(
                                    Formatters.formatDateTime(tx.createdAt),
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                  trailing: Text(
                                    '${isCredit ? "+" : (isHold ? "" : "-")}${Formatters.formatCurrency(tx.amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isHold
                                          ? AppColors.accentGold
                                          : (isCredit ? AppColors.successGreen : AppColors.errorRed),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
