import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

/// Modal dialog prompting the player whether to resume an unfinished game.
///
/// Designed strictly in Splode's Gold, Black, and White color palette.
class ResumeGameDialog extends StatelessWidget {
  const ResumeGameDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const ResumeGameDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF161616),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFFD4A44C).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      title: Text(
        'Resume Game?',
        style: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      content: Text(
        'You have an unfinished game in progress. Would you like to resume it?',
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'New Game',
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Resume',
            style: GoogleFonts.inter(
              color: const Color(0xFFD4A44C),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

