import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../membership/screens/membership_payment_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../referral/screens/referral_screen.dart';
import '../../wallet/screens/wallet_screen.dart';
import '../../withdrawals/screens/withdrawal_screen.dart';
import 'dashboard_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    DashboardScreen(),
    WalletScreen(),
    WithdrawalScreen(),
    ReferralScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    // Onglet Retrait (index 2) — verrouillé si pas de coffre actif
    if (index == 2) {
      final user = ref.read(authProvider).user;
      final hasChest = user?.hasActiveMembership ?? false;
      if (!hasChest) {
        _showChestLockedDialog();
        return;
      }
    }
    setState(() => _currentIndex = index);
  }

  void _showChestLockedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: Color(0xFFD97706), size: 26),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Coffre Verrouillé',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Text(
          'Les retraits sont réservés aux membres ayant activé leur Coffre aux Gains (4 500 FCFA). Obtenez votre Clé d\'Or pour débloquer les décaissements Mobile Money.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fermer', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MembershipPaymentScreen()),
              );
            },
            icon: const Icon(Icons.vpn_key_rounded, size: 18),
            label: const Text('Obtenir la Clé', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasChest = ref.watch(authProvider).user?.hasActiveMembership ?? false;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Accueil',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Portefeuille',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                hasChest ? Icons.payments_outlined : Icons.lock_rounded,
                color: hasChest ? null : const Color(0xFFD97706),
              ),
              activeIcon: Icon(
                hasChest ? Icons.payments : Icons.lock_rounded,
                color: hasChest ? null : const Color(0xFFD97706),
              ),
              label: 'Retrait',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              activeIcon: Icon(Icons.people_alt),
              label: 'Réseau',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
