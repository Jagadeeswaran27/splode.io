import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

/// Overline metadata pill for [TutorialCard] displaying module number,
/// step count, and BP reward bounty.
class TutorialCardPill extends StatelessWidget {
  final String moduleNumber;
  final int stepCount;
  final bool isUnlocked;
  final int bpReward;
  final bool isCompleted;

  const TutorialCardPill({
    super.key,
    required this.moduleNumber,
    required this.stepCount,
    required this.isUnlocked,
    this.bpReward = 0,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    const amberGold = Color(0xFFD4A44C);
    const brightAmber = Color(0xFFFFDF7D);

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? amberGold.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isUnlocked
                    ? amberGold.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.06),
                width: 0.8,
              ),
            ),
            child: Text(
              'MODULE $moduleNumber',
              style: GoogleFonts.outfit(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: isUnlocked ? brightAmber : Colors.white38,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? amberGold.withValues(alpha: 0.45)
                  : Colors.white24,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            '$stepCount STEPS',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isUnlocked ? Colors.white54 : Colors.white24,
              letterSpacing: 0.6,
            ),
          ),
          if (bpReward > 0) ...[
            const SizedBox(width: 7),
            Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked
                    ? amberGold.withValues(alpha: 0.45)
                    : Colors.white24,
              ),
            ),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF4ADE80).withValues(alpha: 0.15)
                    : (isUnlocked
                          ? amberGold.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.04)),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF4ADE80).withValues(alpha: 0.30)
                      : (isUnlocked
                            ? amberGold.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.06)),
                  width: 0.8,
                ),
              ),
              child: Text(
                isCompleted ? '✓ $bpReward BP' : '+$bpReward BP',
                style: GoogleFonts.outfit(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: isCompleted
                      ? const Color(0xFF4ADE80)
                      : (isUnlocked ? brightAmber : Colors.white38),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
