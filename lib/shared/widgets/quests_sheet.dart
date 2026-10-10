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

// ─────────────────────────────────────────────────────────────────────────────
// Floating Action Button à placer dans le Scaffold du dashboard
// ─────────────────────────────────────────────────────────────────────────────
class QuestsFab extends StatelessWidget {
  const QuestsFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.lightImpact();
        showQuestsSheet(context);
      },
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      icon: const Text('⭐', style: TextStyle(fontSize: 18)),
      label: const Text(
        'Mes Quêtes',
        style: TextStyle(
          color: Color(0xFF34D399),
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ouvre le bottom sheet des quêtes
// ─────────────────────────────────────────────────────────────────────────────
void showQuestsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _QuestsSheet(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet interne
// ─────────────────────────────────────────────────────────────────────────────
class _QuestsSheet extends ConsumerStatefulWidget {
  const _QuestsSheet();

  @override
  ConsumerState<_QuestsSheet> createState() => _QuestsSheetState();
}

class _QuestsSheetState extends ConsumerState<_QuestsSheet> {
  final Set<String> _claiming = {};

  Future<void> _claimReward(QuestModel quest) async {
    if (_claiming.contains(quest.code)) return;
    setState(() => _claiming.add(quest.code));
    try {
      final apiClient = ref.read(apiClientProvider);
      final res = await apiClient.post('/api/v1/quests/${quest.code}/claim');
      final result = ClaimQuestResultModel.fromJson(res as Map<String, dynamic>);
      await SoundService.playUnlockChime();
      HapticFeedback.heavyImpact();
      ref.invalidate(questsProvider);
      ref.invalidate(dashboardProvider);
      if (mounted) _showCelebration(quest, result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ));
      }
    } finally {
      if (mounted) setState(() => _claiming.remove(quest.code));
    }
  }

  void _showCelebration(QuestModel quest, ClaimQuestResultModel result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF34D399), width: 2),
        ),
        title: const Column(children: [
          Text('🎉', style: TextStyle(fontSize: 48)),
          SizedBox(height: 8),
          Text('FÉLICITATIONS !',
              style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Prime cash encaissée :',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF34D399)),
            ),
            child: Text('+${Formatters.formatCurrency(result.rewardAmount)}',
                style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 26)),
          ),
          const SizedBox(height: 12),
          Text(result.message,
              style: const TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
        ]),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10)),
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
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      height: screenH * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ── Handle ──────────────────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.stars_rounded, color: Color(0xFF34D399), size: 26),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quêtes & Primes Cash',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Accomplis des objectifs, encaisse des primes',
                          style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54, size: 22),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 8),

          // ── Liste des quêtes ─────────────────────────────────────────────────
          Expanded(
            child: questsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF34D399)),
              ),
              error: (_, __) => const Center(
                child: Text('Impossible de charger les quêtes.',
                    style: TextStyle(color: Colors.white54)),
              ),
              data: (quests) {
                if (quests.isEmpty) {
                  return const Center(
                    child: Text('Aucune quête disponible pour le moment.',
                        style: TextStyle(color: Colors.white54)),
                  );
                }

                // Trier : complétées/à réclamer en premier, ensuite en cours, puis réclamées
                final sorted = [...quests]..sort((a, b) {
                    int score(QuestModel q) => q.isClaimed ? 2 : (q.isCompleted ? 0 : 1);
                    return score(a).compareTo(score(b));
                  });

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: sorted.length,
                  itemBuilder: (_, i) => _QuestCard(
                    quest: sorted[i],
                    isClaiming: _claiming.contains(sorted[i].code),
                    onClaim: () => _claimReward(sorted[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte individuelle d'une quête
// ─────────────────────────────────────────────────────────────────────────────
class _QuestCard extends StatelessWidget {
  final QuestModel quest;
  final bool isClaiming;
  final VoidCallback onClaim;

  const _QuestCard({
    required this.quest,
    required this.isClaiming,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = quest.isClaimed
        ? Colors.white10
        : quest.isCompleted
            ? const Color(0xFF34D399)
            : Colors.white12;

    final Color progressColor = quest.isCompleted || quest.isClaimed
        ? const Color(0xFF10B981)
        : AppColors.accentGold;

    final String emoji = quest.isClaimed
        ? '✅'
        : quest.isCompleted
            ? '🎁'
            : quest.type == 3 || quest.type == 4
                ? '💎'
                : '⭐';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: quest.isClaimed ? 0.5 : 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: quest.isCompleted && !quest.isClaimed ? 1.5 : 1),
        boxShadow: quest.isCompleted && !quest.isClaimed
            ? [BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.15), blurRadius: 10)]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Titre + Reward ──────────────────────────────────────────────
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  quest.title,
                  style: TextStyle(
                    color: quest.isClaimed ? Colors.white38 : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: quest.isClaimed
                      ? Colors.white10
                      : const Color(0xFF047857),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+${Formatters.formatCurrency(quest.rewardAmount)}',
                  style: TextStyle(
                    color: quest.isClaimed ? Colors.white38 : const Color(0xFF6EE7B7),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ── Description ─────────────────────────────────────────────────
          Text(
            quest.description,
            style: const TextStyle(color: Colors.white60, fontSize: 11, height: 1.3),
          ),

          const SizedBox(height: 10),

          // ── Barre de progression ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                quest.type == 5
                    ? (quest.currentProgress == 1 ? 'Profil complet ✓' : 'Photo manquante')
                    : '${quest.currentProgress} / ${quest.targetThreshold}',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              Text(
                '${(quest.progressPercentage * 100).toInt()}%',
                style: TextStyle(
                    color: progressColor, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: quest.progressPercentage,
              minHeight: 7,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),

          // ── Bouton ou statut ────────────────────────────────────────────
          if (quest.isClaimed) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 14),
                const SizedBox(width: 5),
                Text(
                  'Prime encaissée le ${quest.claimedAt != null ? Formatters.formatDate(quest.claimedAt!) : "—"}',
                  style: const TextStyle(color: Color(0xFF34D399), fontSize: 11),
                ),
              ],
            ),
          ] else if (quest.isCompleted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  elevation: 3,
                  shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isClaiming ? null : onClaim,
                icon: isClaiming
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 18),
                label: Text(
                  isClaiming ? 'Traitement…' : 'Réclamer +${Formatters.formatCurrency(quest.rewardAmount)} !',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
