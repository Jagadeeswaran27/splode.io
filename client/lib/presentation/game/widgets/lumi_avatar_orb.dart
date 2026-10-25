import 'package:flutter/material.dart';

/// Reusable glowing Lumi mascot orb widget matching the How-to-Play tutorial design.
/// Features a radiant amber radial gradient, glowing white core, and pulsating shadow.
class LumiAvatarOrb extends StatelessWidget {
  final double size;
  final bool isTrail;
  final double glowProgress;

  const LumiAvatarOrb({
    super.key,
    required this.size,
    this.isTrail = false,
    this.glowProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFFFFE8A0),
            Color(0xFFD4A44C),
            Color(0xFFAA7B2E),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: isTrail
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFFD4A44C).withValues(
                    alpha: 0.45 + 0.2 * glowProgress,
                  ),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
      ),
      child: isTrail
          ? null
          : Center(
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.8),
                      blurRadius: size * 0.2,
                      spreadRadius: size * 0.05,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
