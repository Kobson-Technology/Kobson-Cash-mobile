import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AnimatedGlowingChest extends StatefulWidget {
  final double size;
  final bool hasKey;
  final bool showBadge;
  final bool showFloatingKey;
  final VoidCallback? onTap;

  const AnimatedGlowingChest({
    super.key,
    this.size = 140,
    this.hasKey = false,
    this.showBadge = true,
    this.showFloatingKey = true,
    this.onTap,
  });

  @override
  State<AnimatedGlowingChest> createState() => _AnimatedGlowingChestState();
}

class _AnimatedGlowingChestState extends State<AnimatedGlowingChest>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final floatOffset = math.sin(_controller.value * 2 * math.pi) * 5.0;
        final pulseGlow = (math.sin(_controller.value * 2 * math.pi) + 1.0) / 2.0; // 0.0 to 1.0

        return GestureDetector(
          onTap: widget.onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(0, floatOffset),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Outer Radiant Golden Aura
                    Container(
                      width: widget.size * 0.95,
                      height: widget.size * 0.95,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB800).withValues(alpha: 0.25 + 0.35 * pulseGlow),
                            blurRadius: 28 + 16 * pulseGlow,
                            spreadRadius: 4 + 8 * pulseGlow,
                          ),
                          BoxShadow(
                            color: const Color(0xFFFF8800).withValues(alpha: 0.15 + 0.25 * pulseGlow),
                            blurRadius: 45 + 15 * pulseGlow,
                            spreadRadius: 2 + 6 * pulseGlow,
                          ),
                        ],
                      ),
                    ),

                    // Chest Image Container
                    Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.7 + 0.3 * pulseGlow),
                          width: 2.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          widget.hasKey
                              ? 'assets/images/golden_chest.jpg'
                              : 'assets/images/golden_chest_key.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.navyBlue,
                              child: const Center(
                                child: Icon(
                                  Icons.savings_rounded,
                                  color: AppColors.accentGold,
                                  size: 48,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Sparkle particles
                    Positioned(
                      top: -4 + math.sin((_controller.value + 0.2) * 2 * math.pi) * 3,
                      right: 4,
                      child: Opacity(
                        opacity: 0.4 + 0.6 * pulseGlow,
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFFFEA79),
                          size: 20,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10 + math.cos((_controller.value + 0.5) * 2 * math.pi) * 3,
                      left: -2,
                      child: Opacity(
                        opacity: 0.3 + 0.7 * (1.0 - pulseGlow),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFFFD700),
                          size: 16,
                        ),
                      ),
                    ),

                    // Floating Key Indicator if not unlocked yet
                    if (!widget.hasKey && widget.showFloatingKey)
                      Positioned(
                        bottom: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9900), Color(0xFFFF5500)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.vpn_key_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Clé requise',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (widget.hasKey && widget.showBadge)
                      Positioned(
                        bottom: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_open_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Coffre Débloqué',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.showBadge) const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }
}
