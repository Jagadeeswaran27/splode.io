import 'package:flutter/material.dart';

/// Action affordance circle for [TutorialCard].
/// Displays an animated rotating chevron for unlocked modules,
/// or a subtle lock icon for locked modules.
class TutorialCardAffordance extends StatelessWidget {
  final bool isUnlocked;
  final bool isExpanded;
  final double progress;
  final Animation<double>? rotationAnimation;

  const TutorialCardAffordance({
    super.key,
    required this.isUnlocked,
    this.isExpanded = false,
    this.progress = 0.0,
    this.rotationAnimation,
  });

  @override
  Widget build(BuildContext context) {
    const amberGold = Color(0xFFD4A44C);
    const brightAmber = Color(0xFFFFDF7D);
    final effProgress =
        rotationAnimation != null ? progress : (isExpanded ? 1.0 : 0.0);

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isUnlocked
            ? amberGold.withValues(alpha: 0.12 + 0.10 * effProgress)
            : Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: isUnlocked
              ? amberGold.withValues(alpha: 0.30 + 0.15 * effProgress)
              : Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: amberGold.withValues(alpha: 0.08 + 0.12 * effProgress),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: isUnlocked
            ? (rotationAnimation != null
                ? RotationTransition(
                    turns: rotationAnimation!,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: brightAmber,
                    ),
                  )
                : AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOutCubic,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: brightAmber,
                    ),
                  ))
            : const Icon(
                Icons.lock_outline_rounded,
                size: 15,
                color: Colors.white38,
              ),
      ),
    );
  }
}
