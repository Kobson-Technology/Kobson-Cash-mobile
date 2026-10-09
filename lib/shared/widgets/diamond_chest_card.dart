import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../features/auth/providers/auth_provider.dart';

class DiamondChestCard extends ConsumerStatefulWidget {
  final bool hasActiveGoldChest;
  final bool hasActiveDiamondChest;

  const DiamondChestCard({
    super.key,
    required this.hasActiveGoldChest,
    required this.hasActiveDiamondChest,
  });

  @override
  ConsumerState<DiamondChestCard> createState() => _DiamondChestCardState();
}

class _DiamondChestCardState extends ConsumerState<DiamondChestCard> {
  bool _isLoading = false;

  Future<void> _initiateDiamondPayment() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final endpoint = widget.hasActiveGoldChest
          ? '/api/v1/memberships/upgrade-diamond'
          : '/api/v1/memberships/diamond';

      final res = await apiClient.post(endpoint);
      final checkoutUrl = res['checkoutUrl']?.toString();

      if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
        final uri = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Impossible d\'ouvrir le lien de paiement.');
        }
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasActiveDiamondChest) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0369A1), Color(0xFF0284C7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0284C7).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/coffre_diamant_3d.jpg',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(Icons.diamond_rounded, color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💎 Clé Diamant VIP Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Vous touchez le taux maximum : 7 000 FCFA en N1 • 3 000 FCFA en N2 • 1 500 FCFA en N3 !',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final price = widget.hasActiveGoldChest ? 10500.0 : 15000.0;
    final actionLabel = widget.hasActiveGoldChest
        ? 'Passer au Coffre Diamant (${Formatters.formatCurrency(price)})'
        : 'Activer la Clé Diamant (${Formatters.formatCurrency(price)})';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF082F49), Color(0xFF0C4A6E), Color(0xFF0369A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image & Title
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.asset(
                  'assets/images/coffre_diamant_3d.jpg',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 100,
                    color: const Color(0xFF0369A1),
                    child: const Center(child: Icon(Icons.diamond_rounded, size: 50, color: Colors.white)),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white70),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, color: AppColors.accentGold, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'VIP x2.3 GAINS',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('💎', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'Clé Supérieure • Coffre Diamant',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Activez le Coffre Diamant pour multiplier vos commissions jusqu\'à 7 000 FCFA par filleul direct au lieu de 2 200 FCFA !',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 14),

                // Commission comparison grid
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('NIVEAU 1', style: TextStyle(color: Color(0xFF7DD3FC), fontSize: 10, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('7 000 F', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          Text('(au lieu de 2 200 F)', style: TextStyle(color: Colors.white54, fontSize: 9)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('NIVEAU 2', style: TextStyle(color: Color(0xFF7DD3FC), fontSize: 10, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('3 000 F', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          Text('(au lieu de 900 F)', style: TextStyle(color: Colors.white54, fontSize: 9)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('NIVEAU 3', style: TextStyle(color: Color(0xFF7DD3FC), fontSize: 10, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('1 500 F', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          Text('(au lieu de 500 F)', style: TextStyle(color: Colors.white54, fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFF0284C7).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _initiateDiamondPayment,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/cle_diamant_3d.jpg',
                                width: 20,
                                height: 20,
                                errorBuilder: (_, _, _) => const Icon(Icons.vpn_key, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  actionLabel,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
