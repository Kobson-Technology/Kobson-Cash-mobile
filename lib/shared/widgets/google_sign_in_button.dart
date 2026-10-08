import 'package:flutter/material.dart';

/// Composant officiel "Continuer avec Google" avec logo vectoriel quadri-colore Google
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Continuer avec Google',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF3C4043),
          side: const BorderSide(color: Color(0xFFDADCE0), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: Color(0xFF4285F4)),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomPaint(
                    size: Size(20, 20),
                    painter: GoogleLogoPainter(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFF3C4043),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Painter vectoriel ultra-précis dessinant le célèbre "G" officiel de Google (Bleu, Rouge, Jaune, Vert)
class GoogleLogoPainter extends CustomPainter {
  const GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Épaisseur de trait proportionnelle
    final strokeWidth = w * 0.22;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    // 1. Arc Rouge (Haut)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -3.14159 * 0.75, 3.14159 * 0.55, false, paint);

    // 2. Arc Jaune (Gauche)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, -3.14159 * 1.2, 3.14159 * 0.45, false, paint);

    // 3. Arc Vert (Bas)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 3.14159 * 0.25, 3.14159 * 0.55, false, paint);

    // 4. Arc Bleu (Droite)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -3.14159 * 0.2, 3.14159 * 0.45, false, paint);

    // Barre horizontale centrale bleue du "G"
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.48, h * 0.40, w * 0.48, h * 0.20),
        Radius.circular(w * 0.04),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
