import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

class BalanceCard extends StatefulWidget {
  final num availableBalance;
  final num heldBalance;
  final String currency;
  final VoidCallback? onWithdraw;
  final VoidCallback? onWithdrawPressed;
  final VoidCallback? onMembership;
  final bool hasActiveMembership;

  const BalanceCard({
    super.key,
    required this.availableBalance,
    required this.heldBalance,
    this.currency = 'FCFA',
    this.onWithdraw,
    this.onWithdrawPressed,
    this.onMembership,
    this.hasActiveMembership = true,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _obscure = false;

  @override
  Widget build(BuildContext context) {
    final withdrawCallback = widget.onWithdrawPressed ?? widget.onWithdraw;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF6FB1FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0052D4).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.savings_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Solde de mon Coffre',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withValues(alpha: 0.85),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _obscure ? '•••••• ${widget.currency}' : Formatters.formatCurrency(widget.availableBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_clock_rounded, color: AppTheme.accentGold, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Fonds réservés (HOLD) : ',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                ),
                Text(
                  _obscure ? '•••• ${widget.currency}' : Formatters.formatCurrency(widget.heldBalance),
                  style: const TextStyle(
                    color: AppTheme.accentGold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (withdrawCallback != null || widget.onMembership != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                if (withdrawCallback != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: withdrawCallback,
                      icon: Icon(
                        widget.hasActiveMembership ? Icons.arrow_upward_rounded : Icons.lock_rounded,
                        size: 18,
                        color: widget.hasActiveMembership ? AppTheme.primaryBlue : const Color(0xFFD97706),
                      ),
                      label: Text(
                        widget.hasActiveMembership ? 'Retirer' : 'Retirer',
                        style: TextStyle(
                          color: widget.hasActiveMembership ? AppTheme.primaryBlue : const Color(0xFF92400E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.hasActiveMembership ? Colors.white : const Color(0xFFFEF3C7),
                        foregroundColor: widget.hasActiveMembership ? AppTheme.primaryBlue : const Color(0xFF92400E),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: widget.hasActiveMembership
                              ? BorderSide.none
                              : const BorderSide(color: Color(0xFFF59E0B), width: 1.2),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (withdrawCallback != null && widget.onMembership != null)
                  const SizedBox(width: 12),
                if (widget.onMembership != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.onMembership,
                      icon: Icon(
                        widget.hasActiveMembership ? Icons.lock_open_rounded : Icons.vpn_key_rounded,
                        size: 18,
                      ),
                      label: Text(widget.hasActiveMembership ? 'Coffre Ouvert' : 'Obtenir la Clé'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.hasActiveMembership ? const Color(0xFF10B981) : AppTheme.accentGold,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
