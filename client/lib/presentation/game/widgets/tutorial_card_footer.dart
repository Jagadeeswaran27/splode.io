import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

/// Footer action bar widget for [TutorialCard] displaying the simulation status and launch prompt.
class TutorialCardFooter extends StatelessWidget {
  final bool isUnlocked;

  const TutorialCardFooter({
    super.key,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    const amberGold = Color(0xFFD4A44C);
    const brightAmber = Color(0xFFFFDF7D);

    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              isUnlocked ? 'INTERACTIVE SIMULATION' : 'LOCKED MODULE',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: isUnlocked
                    ? amberGold.withValues(alpha: 0.8)
                    : Colors.white30,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isUnlocked ? 'START' : 'LOCKED',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isUnlocked ? Colors.white : Colors.white38,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked
                      ? amberGold.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.05),
                ),
                child: Icon(
                  isUnlocked
                      ? Icons.arrow_forward_rounded
                      : Icons.lock_outline_rounded,
                  size: 14,
                  color: isUnlocked ? brightAmber : Colors.white38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
