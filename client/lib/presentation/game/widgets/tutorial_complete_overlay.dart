import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:client/domain/models/tutorial_module.dart';

/// Fullscreen overlay displayed when a training module is completed.
/// Allows the player to advance to the next module or return to the tutorial list.
class TutorialCompleteOverlay extends ConsumerWidget {
  final String moduleId;
  final void Function(String? nextId) onNext;

  const TutorialCompleteOverlay({
    super.key,
    required this.moduleId,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentModule = TutorialModule.fromId(moduleId);
    final next = currentModule.nextModule;
    final nextId = next?.id;
    final nextName = next?.title ?? '';

    String completeSubtitle = 'You have mastered this module!';
    if (currentModule == TutorialModule.edgesAndCorners) {
      completeSubtitle =
          "You've mastered the high ground! Lock down corners early, use edges to flank, and let the center come to you.";
    }

    return Container(
      color: Colors.black87,
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFD4A44C),
                size: 72,
              ),
              const SizedBox(height: 20),
              Text(
                'TUTORIAL COMPLETE',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                completeSubtitle,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              // Celebratory BP Reward Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A44C).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFDF7D).withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4A44C).withValues(alpha: 0.25),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFFFDF7D),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${currentModule.bpReward} BP EARNED!',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFDF7D),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              if (nextId != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: ElevatedButton(
                    onPressed: () => onNext(nextId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A44C),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'NEXT: ${nextName.toUpperCase()}',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              if (nextId != null) const SizedBox(height: 16),
              TextButton(
                onPressed: () => onNext(null),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white60,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  nextId == null ? 'FINISH' : 'BACK TO MENU',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

