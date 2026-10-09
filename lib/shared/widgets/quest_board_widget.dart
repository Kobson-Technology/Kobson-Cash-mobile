import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/sound_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/providers/dashboard_provider.dart';
import '../../features/referral/models/quest_models.dart';
import '../../features/referral/providers/referral_provider.dart';

class QuestBoardWidget extends ConsumerStatefulWidget {
  const QuestBoardWidget({super.key});

  @override
  ConsumerState<QuestBoardWidget> createState() => _QuestBoardWidgetState();
}

class _QuestBoardWidgetState extends ConsumerState<QuestBoardWidget> {
  final Set<String> _claimingQuests = {};

  Future<void> _claimReward(QuestModel quest) async {
    if (_claimingQuests.contains(quest.code)) return;

    setState(() {
      _claimingQuests.add(quest.code);
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final res = await apiClient.post('/api/v1/quests/${quest.code}/claim');
      final result = ClaimQuestResultModel.fromJson(res as Map<String, dynamic>);

      // Trigger celebratory audio and haptic feedback
      await SoundService.playUnlockChime();
      HapticFeedback.heavyImpact();

      // Refresh providers
      ref.invalidate(questsProvider);
      ref.invalidate(dashboardProvider);

      if (mounted) {
        _showCelebrationDialog(quest, result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _claimingQuests.remove(quest.code);
        });
      }
    }
  }

  void _showCelebrationDialog(QuestModel quest, ClaimQuestResultModel result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF34D399), width: 2),
        ),
        title: const Column(
          children: [
            Text('🎉', style: TextStyle(fontSize: 48)),
            SizedBox(height: 8),
            Text(
              'FÉLICITATIONS !',
              style: TextStyle(
                color: Color(0xFF34D399),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Vous venez d\'encaisser votre prime cash de',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF34D399)),
              ),
              child: Text(
                '+${Formatters.formatCurrency(result.rewardAmount)}',
                style: const TextStyle(
                  color: Color(0xFF34D399),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              result.message,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Super !', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questsAsync = ref.watch(questsProvider);

    return questsAsync.when(
      data: (quests) {
        if (quests.isEmpty) return const SizedBox.shrink();

        final starQuest = quests.firstWhere(
          (q) => q.isCompleted,
          orElse: () => quests.firstWhere(
            (q) => q.isInProgress,
            orElse: () => quests.first,
          ),
        );

        final otherQuests = quests.where((q) => q.code != starQuest.code).toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF064E3B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: starQuest.isCompleted ? const Color(0xFF34D399) : const Color(0xFF1E293B),
              width: starQuest.isCompleted ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (starQuest.isCompleted ? const Color(0xFF10B981) : Colors.black).withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.stars_rounded, color: Color(0xFF34D399), size: 24),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quêtes & Primes Cash',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Encaisser des primes cash en plus de vos commissions',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Highlighted Star Quest Card (5 Filleuls N1 = +500 FCFA)
              _buildStarQuestCard(starQuest),

              if (otherQuests.isNotEmpty) ...[
                const SizedBox(height: 12),
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(
                      'Voir les autres quêtes (+${otherQuests.length})',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: otherQuests.map((q) => _buildSecondaryQuestItem(q)).toList(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildStarQuestCard(QuestModel quest) {
    final isClaiming = _claimingQuests.contains(quest.code);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: quest.isCompleted ? const Color(0xFF34D399) : Colors.white12,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        quest.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF047857),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+${Formatters.formatCurrency(quest.rewardAmount)} NET',
                  style: const TextStyle(
                    color: Color(0xFF6EE7B7),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            quest.description,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 10),

          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                quest.type == 5
                    ? 'Progression : ${quest.currentProgress == 1 ? "100%" : "Profil incomplet"}'
                    : 'Progression : ${quest.currentProgress} / ${quest.targetThreshold}',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              Text(
                '${(quest.progressPercentage * 100).toInt()}%',
                style: TextStyle(
                  color: quest.isCompleted ? const Color(0xFF34D399) : AppColors.accentGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: quest.progressPercentage,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                quest.isCompleted ? const Color(0xFF10B981) : AppColors.accentGold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Action State
          if (quest.isClaimed) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF065F46).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Prime de +${Formatters.formatCurrency(quest.rewardAmount)} Déjà Encaissée',
                    style: const TextStyle(
                      color: Color(0xFF6EE7B7),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (quest.isCompleted) ...[
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  elevation: 4,
                  shadowColor: const Color(0xFF10B981).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isClaiming ? null : () => _claimReward(quest),
                child: isClaiming
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Réclamer mes ${Formatters.formatCurrency(quest.rewardAmount)} !',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white54, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    quest.type == 5
                        ? 'Ajoutez votre photo dans votre profil pour débloquer vos 50 FCFA.'
                        : (quest.type == 6 || quest.type == 7)
                            ? 'Activez votre coffre pour débloquer vos ${Formatters.formatCurrency(quest.rewardAmount)}.'
                            : 'Parrainez encore ${quest.targetThreshold - quest.currentProgress} membre(s) actif(s) pour débloquer votre prime cash.',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSecondaryQuestItem(QuestModel quest) {
    final isClaiming = _claimingQuests.contains(quest.code);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: quest.isCompleted ? const Color(0xFF34D399).withValues(alpha: 0.4) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        quest.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+${Formatters.formatCurrency(quest.rewardAmount)}',
                      style: const TextStyle(
                        color: Color(0xFF34D399),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${quest.currentProgress} / ${quest.targetThreshold} • ${quest.description}',
                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (quest.isClaimed) ...[
            const Icon(Icons.check_circle, color: Color(0xFF34D399), size: 18),
          ] else if (quest.isCompleted) ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isClaiming ? null : () => _claimReward(quest),
              child: isClaiming
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Réclamer', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ] else ...[
            Text(
              '${(quest.progressPercentage * 100).toInt()}%',
              style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }
}
