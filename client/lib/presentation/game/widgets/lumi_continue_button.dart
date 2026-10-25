import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

/// Animated continue button for Lumi tutorial cards.
class LumiContinueButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String? label;

  const LumiContinueButton({
    super.key,
    required this.onPressed,
    this.label,
  });

  @override
  State<LumiContinueButton> createState() => _LumiContinueButtonState();
}

class _LumiContinueButtonState extends State<LumiContinueButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _arrowController;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = widget.label != null;
    final text = widget.label ?? 'CONTINUE';

    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCustom ? 16 : 12,
          vertical: isCustom ? 9 : 7,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isCustom ? 12 : 10),
          gradient: isCustom
              ? const LinearGradient(
                  colors: [Color(0xFFE8C87A), Color(0xFFD4A44C)],
                )
              : null,
          color: isCustom
              ? null
              : const Color(0xFFD4A44C).withValues(alpha: 0.15),
          border: isCustom
              ? null
              : Border.all(
                  color: const Color(0xFFD4A44C).withValues(alpha: 0.3),
                ),
          boxShadow: isCustom
              ? [
                  BoxShadow(
                    color: const Color(0xFFD4A44C).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCustom) ...[
              const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFF1E1E24),
                size: 16,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: GoogleFonts.outfit(
                color: isCustom
                    ? const Color(0xFF1E1E24)
                    : const Color(0xFFD4A44C),
                fontSize: isCustom ? 12 : 11,
                fontWeight: isCustom ? FontWeight.w800 : FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 5),
            AnimatedBuilder(
              animation: _arrowController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_arrowController.value * 3, 0),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: isCustom
                        ? const Color(0xFF1E1E24)
                        : const Color(0xFFD4A44C),
                    size: 14,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
