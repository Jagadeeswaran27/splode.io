import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

/// Reusable Lumi mascot name and tutor badge header widget.
class LumiHeaderBadge extends StatelessWidget {
  const LumiHeaderBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'LUMI',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFFFDF7D),
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFD4A44C).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFFD4A44C).withValues(alpha: 0.35),
              width: 0.8,
            ),
          ),
          child: Text(
            'TUTOR',
            style: GoogleFonts.outfit(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFDF7D),
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
