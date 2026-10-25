import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

/// Header widget for [TutorialCard] displaying the module index, category, and step count.
class TutorialCardHeader extends StatelessWidget {
  final String moduleNumber;
  final String category;
  final int stepCount;
  final bool isUnlocked;

  const TutorialCardHeader({
    super.key,
    required this.moduleNumber,
    required this.category,
    required this.stepCount,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    const amberGold = Color(0xFFD4A44C);
    const brightAmber = Color(0xFFFFDF7D);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Module Index & Category Tag (Flexible to prevent narrow screen overflow)
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? amberGold.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isUnlocked
                        ? amberGold.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Text(
                  'MODULE $moduleNumber',
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isUnlocked ? brightAmber : Colors.white38,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  category.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white38,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Step Count Chip
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.layers_outlined,
                size: 12,
                color: isUnlocked ? amberGold : Colors.white38,
              ),
              const SizedBox(width: 4),
              Text(
                '$stepCount STEPS',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked ? Colors.white70 : Colors.white38,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
