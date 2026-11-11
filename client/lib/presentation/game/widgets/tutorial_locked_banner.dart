import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:client/presentation/core/utils/responsive_layout.dart';

/// A sleek, muted banner displayed inside expanded locked training module cards.
class TutorialLockedBanner extends StatelessWidget {
  final String previousModuleName;

  const TutorialLockedBanner({
    super.key,
    required this.previousModuleName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: context.isShortScreen ? 9.0 : 11.5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            size: 15,
            color: Colors.white38,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'LOCKED • COMPLETE ${previousModuleName.toUpperCase()} FIRST',
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Colors.white38,
                letterSpacing: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

