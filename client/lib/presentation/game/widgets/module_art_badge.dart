import 'package:flutter/material.dart';

import 'package:client/presentation/game/widgets/module_art_painter.dart';

/// Distinctive tactical visual art badge for each Splode training module.
///
/// Features custom glowing orbs, orbital rings, collision vectors,
/// and geometric corner brackets matching the module's gameplay theme.
class ModuleArtBadge extends StatelessWidget {
  final String moduleId;
  final bool isUnlocked;
  final double size;

  const ModuleArtBadge({
    super.key,
    required this.moduleId,
    this.isUnlocked = true,
    this.size = 54.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF161620),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFFD4A44C).withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: const Color(0xFFD4A44C).withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle ambient radial background glow
            if (isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        const Color(0xFFD4A44C).withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

            // Module-specific thematic artwork
            CustomPaint(
              size: Size(size, size),
              painter: ModuleArtPainter(
                moduleId: moduleId,
                isUnlocked: isUnlocked,
              ),
            ),

            // Lock overlay if locked
            if (!isUnlocked)
              Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: const Center(
                  child: Icon(
                    Icons.lock_rounded,
                    color: Colors.white38,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
