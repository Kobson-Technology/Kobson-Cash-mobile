import 'package:flutter/material.dart';
import '../../features/withdrawals/models/withdrawal_models.dart';

/// Composant visuel affichant le logo officiel officiel de marque
/// de chaque opérateur Mobile Money (Wave, Orange Money, MTN MoMo, Moov Money, Djamo)
/// à partir des images officielles haute définition.
class OperatorBrandLogo extends StatelessWidget {
  final WithdrawalOperator? operator;
  final String? operatorKey;
  final double size;

  const OperatorBrandLogo({
    super.key,
    this.operator,
    this.operatorKey,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final rawKey = (operator?.brandKey ?? operatorKey ?? 'wave').toLowerCase().trim();

    if (rawKey.contains('wave')) {
      return _buildAssetLogo(
        'assets/images/wave.png',
        fallbackPainter: _WavePenguinPainter(),
        fallbackBg: const Color(0xFF1DC4F9),
      );
    } else if (rawKey.contains('orange')) {
      return _buildAssetLogo(
        'assets/images/orange.png',
        fallbackPainter: _OrangeMoneyPainter(),
        fallbackBg: const Color(0xFFFF7900),
      );
    } else if (rawKey.contains('mtn') || rawKey.contains('momo')) {
      return _buildAssetLogo(
        'assets/images/mtn.jpg',
        fallbackBg: const Color(0xFFFFCC00),
      );
    } else if (rawKey.contains('moov')) {
      return _buildAssetLogo(
        'assets/images/moov.png',
        fallbackBg: const Color(0xFF005CA9),
      );
    } else if (rawKey.contains('djamo')) {
      return _buildAssetLogo(
        'assets/images/djamo.png',
        fallbackBg: const Color(0xFF0A192F),
      );
    }

    return _buildDefaultLogo();
  }

  Widget _buildAssetLogo(
    String assetPath, {
    Color? fallbackBg,
    CustomPainter? fallbackPainter,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (fallbackPainter != null) {
            return Container(
              color: fallbackBg ?? const Color(0xFF3B82F6),
              child: Center(
                child: CustomPaint(
                  size: Size(size * 0.65, size * 0.65),
                  painter: fallbackPainter,
                ),
              ),
            );
          }
          return Container(
            color: fallbackBg ?? const Color(0xFF3B82F6),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: size * 0.55,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(
        Icons.account_balance_wallet_rounded,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}

/// Fallback : Dessine le pingouin Wave si l'image est indisponible
class _WavePenguinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()
      ..color = const Color(0xFF081C3B)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.1, w * 0.7, h * 0.85),
      Radius.circular(w * 0.35),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    final bellyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final bellyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.35, w * 0.44, h * 0.55),
      Radius.circular(w * 0.22),
    );
    canvas.drawRRect(bellyRect, bellyPaint);

    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.36, h * 0.26), w * 0.05, eyePaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.26), w * 0.05, eyePaint);

    final pupilPaint = Paint()..color = const Color(0xFF081C3B);
    canvas.drawCircle(Offset(w * 0.36, h * 0.26), w * 0.025, pupilPaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.26), w * 0.025, pupilPaint);

    final beakPaint = Paint()
      ..color = const Color(0xFFFF9E00)
      ..style = PaintingStyle.fill;
    final beakPath = Path()
      ..moveTo(w * 0.42, h * 0.32)
      ..lineTo(w * 0.58, h * 0.32)
      ..lineTo(w * 0.5, h * 0.42)
      ..close();
    canvas.drawPath(beakPath, beakPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fallback : Dessine les cercles Orange Money si l'image est indisponible
class _OrangeMoneyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.16
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawCircle(Offset(w * 0.38, h * 0.5), w * 0.26, paintStroke);
    canvas.drawCircle(Offset(w * 0.62, h * 0.5), w * 0.26, paintStroke);

    final paintFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.1, paintFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
