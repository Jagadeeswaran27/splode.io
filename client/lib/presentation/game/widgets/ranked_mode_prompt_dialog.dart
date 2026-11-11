import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:client/domain/models/ai_difficulty.dart';
import 'package:client/presentation/core/utils/splode_snackbar.dart';

/// A simple, elegant dialog to choose between Ranked Mode and Casual Practice,
/// matching the existing theme and UI style of the app.
class RankedModePromptDialog extends StatelessWidget {
  final AiDifficulty difficulty;
  final String botName;
  final bool isOnline;

  const RankedModePromptDialog({
    super.key,
    required this.difficulty,
    required this.botName,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final bpReward = difficulty == AiDifficulty.expert ? '+20' : '+10';
    final bpLoss = difficulty == AiDifficulty.expert ? '-10' : '-5';

    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFFD4A44C).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      title: Text(
        'Select Match Mode',
        style: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Challenge $botName in Ranked mode to earn Blast Points, or play Casual Practice.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Option 1: Ranked Match
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              if (!isOnline) {
                SplodeSnackbar.show(
                  context: context,
                  message: 'Connect to the internet to play Ranked.',
                  type: SnackbarType.info,
                );
                return;
              }
              Navigator.of(context).pop(true);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isOnline
                    ? const Color(0xFFD4A44C).withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isOnline
                      ? const Color(0xFFD4A44C).withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    color: isOnline
                        ? const Color(0xFFD4A44C)
                        : Colors.white38,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Ranked Match',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isOnline
                                    ? Colors.white
                                    : Colors.white38,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isOnline
                                    ? const Color(0xFFD4A44C)
                                    : Colors.white12,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$bpReward BP',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isOnline
                                      ? const Color(0xFF111111)
                                      : Colors.white38,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isOnline
                              ? 'Win: $bpReward BP • Loss: $bpLoss BP'
                              : 'Requires internet connection',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isOnline ? Colors.white60 : Colors.white30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Option 2: Casual Practice
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop(false);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sports_esports_rounded,
                    color: Colors.white70,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Casual Practice',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Play risk-free with no BP at stake',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(
            'CANCEL',
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

