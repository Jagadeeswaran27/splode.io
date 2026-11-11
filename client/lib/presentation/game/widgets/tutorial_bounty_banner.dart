import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

/// A prominent Academy Bounty Banner displayed on the Training screen.
///
/// Communicates to the player that completing the training modules awards up to
/// 50 Blast Points (BP), and dynamically visualizes their claimed progress.
class TutorialBountyBanner extends StatelessWidget {
  final int earnedBp;
  final int totalBp;

  const TutorialBountyBanner({
    super.key,
    required this.earnedBp,
    this.totalBp = 50,
  });

  @override
  Widget build(BuildContext context) {
    const amberGold = Color(0xFFD4A44C);
    const brightAmber = Color(0xFFFFDF7D);

    final isAllClaimed = earnedBp >= totalBp;
    final progress = totalBp > 0 ? (earnedBp / totalBp).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF181824).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAllClaimed
              ? const Color(0xFF4ADE80).withValues(alpha: 0.45)
              : amberGold.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          if (!isAllClaimed)
            BoxShadow(
              color: amberGold.withValues(alpha: 0.10),
              blurRadius: 16,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Trophy / Bounty Icon with Radial Aura
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isAllClaimed
                          ? const Color(0xFF4ADE80)
                          : amberGold)
                      .withValues(alpha: 0.15),
                  border: Border.all(
                    color: (isAllClaimed
                            ? const Color(0xFF4ADE80)
                            : brightAmber)
                        .withValues(alpha: 0.40),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isAllClaimed
                        ? Icons.check_circle_rounded
                        : Icons.emoji_events_rounded,
                    color: isAllClaimed
                        ? const Color(0xFF4ADE80)
                        : brightAmber,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Title & Subtitle Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'ACADEMY BOUNTY',
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: isAllClaimed
                                  ? const Color(0xFF4ADE80)
                                  : brightAmber,
                              letterSpacing: 1.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: (isAllClaimed
                                    ? const Color(0xFF4ADE80)
                                    : amberGold)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isAllClaimed ? '✓ 50 BP' : '+50 BP',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isAllClaimed
                                  ? const Color(0xFF4ADE80)
                                  : brightAmber,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isAllClaimed
                          ? 'Academy Mastered • All 50 BP claimed!'
                          : '$earnedBp of $totalBp BP earned • Complete modules to claim',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Micro Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 4,
              color: Colors.white.withValues(alpha: 0.08),
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: isAllClaimed
                          ? const [Color(0xFF22C55E), Color(0xFF4ADE80)]
                          : const [amberGold, brightAmber],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

