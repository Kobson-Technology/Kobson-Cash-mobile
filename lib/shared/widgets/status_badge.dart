import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label = status;

    switch (status.toLowerCase()) {
      case 'active':
      case 'completed':
      case 'success':
      case 'paid':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        label = status == 'active' ? 'Actif' : 'Effectué';
        break;

      case 'pending':
      case 'processing':
      case 'pendingpayment':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = status == 'pending' ? 'En attente' : 'En traitement';
        break;

      case 'failed':
      case 'rejected':
      case 'cancelled':
      case 'suspended':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = status == 'failed' ? 'Échoué' : 'Rejeté';
        break;

      default:
        bg = const Color(0xFFE2E8F0);
        fg = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
