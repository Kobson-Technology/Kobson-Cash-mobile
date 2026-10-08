import 'package:flutter/material.dart';
import '../../features/withdrawals/models/withdrawal_models.dart';

/// Un composant visuel ultra-net affichant le logo officiel de marque
/// de chaque opérateur Mobile Money (Wave, Orange Money, MTN MoMo, Moov Money, Djamo).
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
    final key = operator?.brandKey ?? operatorKey?.toLowerCase() ?? 'wave';

    switch (key) {
      case 'wave':
        return _buildWaveLogo();
      case 'orange':
      case 'orangemoney':
        return _buildOrangeMoneyLogo();
      case 'mtn':
      case 'momo':
        return _buildMtnLogo();
      case 'moov':
        return _buildMoovLogo();
      case 'djamo':
        return _buildDjamoLogo();
      default:
        return _buildDefaultLogo();
    }
  }

  // ==================== 1. WAVE ====================
  // Fond Bleu Cyan officiel Wave (#1DC4F9) + Silhouette Pingouin Wave
  Widget _buildWaveLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1DC4F9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1DC4F9).withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.68, size * 0.68),
          painter: _WavePenguinPainter(),
        ),
      ),
    );
  }

  // ==================== 2. ORANGE MONEY ====================
  // Fond Orange officiel (#FF7900) + Cercles concentriques Orange Money
  Widget _buildOrangeMoneyLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFF7900),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7900).withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.65, size * 0.65),
          painter: _OrangeMoneyPainter(),
        ),
      ),
    );
  }

  // ==================== 3. MTN MOBILE MONEY ====================
  // Fond Jaune vif MTN (#FFCC00) + Ovale Bleu Marine et lettrage MoMo
  Widget _buildMtnLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFCC00),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFCC00).withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.82,
          height: size * 0.52,
          decoration: BoxDecoration(
            color: const Color(0xFF004F71),
            borderRadius: BorderRadius.circular(size * 0.3),
          ),
          child: Center(
            child: Text(
              'MoMo',
              style: TextStyle(
                color: const Color(0xFFFFCC00),
                fontWeight: FontWeight.w900,
                fontSize: size * 0.26,
                letterSpacing: -0.2,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== 4. MOOV MONEY ====================
  // Fond Bleu Royal Moov (#005CA9) + Arc Orange (#FF6600) + Texte Moov
  Widget _buildMoovLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF005CA9),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005CA9).withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arc orange signature Moov
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6600),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Text(
              'moov',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: size * 0.28,
                letterSpacing: -0.3,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 5. DJAMO ====================
  // Fond Bleu Nuit (#0A192F) + Symbole "D" Turquoise Moderne (#00D2B4)
  Widget _buildDjamoLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0A192F),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D2B4).withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.58,
          height: size * 0.58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00D2B4), Color(0xFF00B4D8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size * 0.1),
              bottomLeft: Radius.circular(size * 0.1),
              topRight: Radius.circular(size * 0.35),
              bottomRight: Radius.circular(size * 0.35),
            ),
          ),
          child: Center(
            child: Container(
              width: size * 0.26,
              height: size * 0.26,
              decoration: const BoxDecoration(
                color: Color(0xFF0A192F),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
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

/// Dessine le pingouin emblématique de Wave (corps bleu marine, ventre blanc, bec orange)
class _WavePenguinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Corps du pingouin (Bleu nuit foncé)
    final bodyPaint = Paint()
      ..color = const Color(0xFF081C3B)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.1, w * 0.7, h * 0.85),
      Radius.circular(w * 0.35),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // 2. Ventre blanc
    final bellyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final bellyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.35, w * 0.44, h * 0.55),
      Radius.circular(w * 0.22),
    );
    canvas.drawRRect(bellyRect, bellyPaint);

    // 3. Yeux
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.36, h * 0.26), w * 0.05, eyePaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.26), w * 0.05, eyePaint);

    final pupilPaint = Paint()..color = const Color(0xFF081C3B);
    canvas.drawCircle(Offset(w * 0.36, h * 0.26), w * 0.025, pupilPaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.26), w * 0.025, pupilPaint);

    // 4. Bec orange
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

/// Dessine le symbole des cercles imbriqués Orange Money
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

    // Deux cercles imbriqués / entrelacés caractéristiques
    canvas.drawCircle(Offset(w * 0.38, h * 0.5), w * 0.26, paintStroke);
    canvas.drawCircle(Offset(w * 0.62, h * 0.5), w * 0.26, paintStroke);

    // Centre rempli
    final paintFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.1, paintFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
