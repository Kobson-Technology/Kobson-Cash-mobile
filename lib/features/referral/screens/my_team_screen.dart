import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/gold_nugget_levels_card.dart';
import '../../../shared/widgets/quest_board_widget.dart';
import '../../../shared/widgets/diamond_chest_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../models/referral_models.dart';
import '../providers/referral_provider.dart';

class MyTeamScreen extends ConsumerWidget {
  const MyTeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treeAsync = ref.watch(referralTreeProvider);
    final levelsAsync = ref.watch(levelProgressionProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Mon Équipe & Pépites 3D'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(referralTreeProvider);
              ref.invalidate(levelProgressionProvider);
            },
          ),
        ],
      ),
      body: treeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
        data: (tree) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section 3D Gold Nuggets Progression
                levelsAsync.when(
                  data: (prog) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GoldNuggetLevelsCard(
                      progression: prog,
                      referralCode: tree.myReferralCode,
                      shareUrl: tree.shareUrl,
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),

                // Carte Clé Diamant Supérieure (VIP)
                const DiamondChestCard(
                  hasActiveGoldChest: true,
                  hasActiveDiamondChest: false,
                ),

                // Section Quêtes & Primes Cash (dont 5 Filleuls N1 = +500 FCFA)
                const QuestBoardWidget(),

                // Top Level Breakdown Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildTeamCard(
                        'Niveau 1',
                        tree.level1Count,
                        AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTeamCard(
                        'Niveau 2',
                        tree.level2Count,
                        AppColors.accentGold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTeamCard(
                        'Niveau 3',
                        tree.level3Count,
                        AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'Filleuls directs (Niveau 1)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                if (tree.directReferrals.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.group_off_outlined, size: 48, color: AppColors.textSecondary),
                          SizedBox(height: 12),
                          Text(
                            'Aucun filleul direct pour le moment.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tree.directReferrals.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final member = tree.directReferrals[index];
                      return _buildMemberCard(member);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeamCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          const Text(
            'membres',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(ReferralNodeModel member) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
            child: Text(
              member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : 'M',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  'Inscrit le ${Formatters.formatDate(member.joinedAt)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Code: ${member.referralCode}',
                  style: const TextStyle(fontSize: 11, color: AppColors.navyBlue, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(status: member.status),
              if (member.totalCommissionsGenerated > 0) ...[
                const SizedBox(height: 6),
                Text(
                  '+${Formatters.formatCurrency(member.totalCommissionsGenerated)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
