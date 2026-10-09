import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/services/sound_service.dart';
import '../../core/utils/formatters.dart';
import '../../features/membership/screens/membership_payment_screen.dart';
import '../../features/referral/models/referral_models.dart';

class GoldNuggetLevelsCard extends StatefulWidget {
  final LevelProgressionModel progression;
  final String referralCode;
  final String shareUrl;

  const GoldNuggetLevelsCard({
    super.key,
    required this.progression,
    required this.referralCode,
    required this.shareUrl,
  });

  @override
  State<GoldNuggetLevelsCard> createState() => _GoldNuggetLevelsCardState();
}

class _GoldNuggetLevelsCardState extends State<GoldNuggetLevelsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showLevelDetails(BuildContext context, LevelTierModel tier) {
    if (tier.isUnlocked) {
      // Joue le carillon de félicitations pour célébrer le niveau débloqué
      SoundService.playUnlockChime();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GoldLevelDetailSheet(
        tier: tier,
        referralCode: widget.referralCode,
        shareUrl: widget.shareUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prog = widget.progression;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0B1329)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB800).withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('✨', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pépites d\'Or & Niveaux 3D',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Débloquez vos 3 niveaux de commissions',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge de niveau actuel
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  prog.currentUnlockedLevel > 0
                      ? 'Niveau ${prog.currentUnlockedLevel} / 3'
                      : '0 / 3 Débloqué',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Niveaux de Pépites en Grille
          Row(
            children: [
              Expanded(
                child: _buildNuggetCard(
                  context,
                  tier: prog.level1,
                  badgeLabel: 'N1 • 2 200 F',
                  assetPath: 'assets/images/pepite_or_n1.jpg',
                  glowColor: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildNuggetCard(
                  context,
                  tier: prog.level2,
                  badgeLabel: 'N2 • 900 F',
                  assetPath: 'assets/images/pepite_or_n2.jpg',
                  glowColor: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildNuggetCard(
                  context,
                  tier: prog.level3,
                  badgeLabel: 'N3 • 500 F',
                  assetPath: 'assets/images/pepite_or_n3.jpg',
                  glowColor: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),

          // Alerte Or en Attente (si N2 ou N3 verrouillé avec des gains en réserve)
          if (prog.totalGoldPending > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB800).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_clock_rounded, color: Color(0xFFFFD700), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${Formatters.formatCurrency(prog.totalGoldPending)} en attente dans votre réseau ! Complétez vos quêtes pour débloquer ces pépites.',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNuggetCard(
    BuildContext context, {
    required LevelTierModel tier,
    required String badgeLabel,
    required String assetPath,
    required Color glowColor,
  }) {
    final isUnlocked = tier.isUnlocked;

    return GestureDetector(
      onTap: () => _showLevelDetails(context, tier),
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final floatOffset = isUnlocked ? math.sin(_animController.value * math.pi) * 3.5 : 0.0;
          final pulseGlow = isUnlocked ? _animController.value : 0.0;

          return Transform.translate(
            offset: Offset(0, -floatOffset),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? const Color(0xFF1E293B).withValues(alpha: 0.9)
                    : const Color(0xFF0F172A).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isUnlocked
                      ? const Color(0xFFFFD700).withValues(alpha: 0.7 + 0.3 * pulseGlow)
                      : Colors.white12,
                  width: isUnlocked ? 1.8 : 1.0,
                ),
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.2 + 0.15 * pulseGlow),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 3D Nugget Image Asset
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow circle behind unlocked nugget
                      if (isUnlocked)
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.35 * pulseGlow),
                                blurRadius: 16,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ColorFiltered(
                          colorFilter: isUnlocked
                              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                              : const ColorFilter.matrix([
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0,      0,      0,      0.65, 0,
                                ]),
                          child: Image.asset(
                            assetPath,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.diamond_rounded,
                              size: 40,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                        ),
                      ),
                      // Lock icon on locked
                      if (!isUnlocked)
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            size: 16,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    tier.title.split(' ').first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.white : Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Amount Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? const Color(0xFF10B981).withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isUnlocked
                            ? const Color(0xFF10B981).withValues(alpha: 0.5)
                            : Colors.white12,
                      ),
                    ),
                    child: Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isUnlocked ? const Color(0xFF34D399) : Colors.white54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Status Chip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isUnlocked ? Icons.check_circle_rounded : Icons.touch_app_rounded,
                        size: 11,
                        color: isUnlocked ? const Color(0xFFFFD700) : Colors.white38,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isUnlocked ? 'Actif' : 'Quêtes',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked ? const Color(0xFFFFD700) : Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class GoldLevelDetailSheet extends StatelessWidget {
  final LevelTierModel tier;
  final String referralCode;
  final String shareUrl;

  const GoldLevelDetailSheet({
    super.key,
    required this.tier,
    required this.referralCode,
    required this.shareUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = tier.isUnlocked;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(22, 16, 22, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3D Nugget Image Large
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isUnlocked)
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    tier.assetPath,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.diamond_rounded,
                      size: 60,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Title & Honorific
          Center(
            child: Column(
              children: [
                Text(
                  tier.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    'Rang : ${tier.honorificTitle} • Gain : ${Formatters.formatCurrency(tier.commissionAmount)} / membre',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quests Checklist
          const Text(
            'Quêtes requises pour ce niveau :',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),

          ...tier.tasks.map((task) => _buildTaskRow(task)),

          const SizedBox(height: 20),

          // Action Buttons
          if (isUnlocked) ...[
            ElevatedButton.icon(
              onPressed: () {
                SoundService.playUnlockChime();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔔 Carillon de Victoire Kobson Cash déclenché !'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.volume_up_rounded, color: Colors.black),
              label: const Text(
                'Célébrer la Victoire (Rejouer le Son)',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                if (shareUrl.isEmpty || referralCode.isEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MembershipPaymentScreen()),
                  );
                } else {
                  SharePlus.instance.share(
                    ShareParams(
                      text: 'Rejoins mon équipe sur Kobson Cash et active ton Coffre pour générer des gains quotidiens par Mobile Money !\nLien d\'inscription : $shareUrl',
                    ),
                  );
                }
              },
              icon: Icon(
                shareUrl.isEmpty || referralCode.isEmpty ? Icons.vpn_key_rounded : Icons.share_rounded,
                color: Colors.black,
              ),
              label: Text(
                shareUrl.isEmpty || referralCode.isEmpty
                    ? 'Activer mon Coffre pour parrainer'
                    : 'Partager mon lien de parrainage',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskRow(LevelQuestTaskModel task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? const Color(0xFF10B981).withValues(alpha: 0.1)
            : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.4)
              : Colors.white12,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            task.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: task.isCompleted ? const Color(0xFF34D399) : Colors.white38,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: task.isCompleted ? Colors.white : Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.description,
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
                if (!task.isCompleted && task.targetProgress > 1) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: task.currentProgress / task.targetProgress,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${task.currentProgress}/${task.targetProgress}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
