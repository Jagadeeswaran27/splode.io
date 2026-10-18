import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SnackbarType { info, error, success }

class SplodeSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    SnackbarType type = SnackbarType.info,
  }) {
    Color glowColor;
    IconData icon;

    switch (type) {
      case SnackbarType.error:
        glowColor = const Color(0xFFF43F5E); // Rose Red
        icon = Icons.error_outline_rounded;
        break;
      case SnackbarType.success:
        glowColor = const Color(0xFF10B981); // Emerald Green
        icon = Icons.check_circle_outline_rounded;
        break;
      case SnackbarType.info:
        glowColor = const Color(0xFFD4A44C); // Splode Gold
        icon = Icons.info_outline_rounded;
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackbar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      padding: EdgeInsets.zero,
      duration: const Duration(seconds: 3),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF111111).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: glowColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.15),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: glowColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
