import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AuthButtonStyle { primary, secondary, outline }

/// A highly customizable, pill-shaped auth button with subtle press animation.
///
/// Supports three styles:
/// - [AuthButtonStyle.primary]: Amber gradient background, dark text. Ideal for the main CTA (e.g. Guest Login).
/// - [AuthButtonStyle.secondary]: Cream background, dark text. Good for standard logins (e.g. Google).
/// - [AuthButtonStyle.outline]: Transparent with amber outline, light text. Good for secondary actions (e.g. Email).
class AuthButton extends StatefulWidget {
  final String text;
  final Widget icon;
  final VoidCallback onPressed;
  final AuthButtonStyle style;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.style = AuthButtonStyle.secondary,
    this.isLoading = false,
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  BoxDecoration _getDecoration() {
    switch (widget.style) {
      case AuthButtonStyle.primary:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8C87A), Color(0xFFD4A44C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A44C).withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case AuthButtonStyle.secondary:
        return BoxDecoration(
          color: const Color(0xFFF5F0E8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A44C).withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case AuthButtonStyle.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4A44C).withValues(alpha: 0.5),
            width: 1.5,
          ),
        );
    }
  }

  Color _getTextColor() {
    switch (widget.style) {
      case AuthButtonStyle.primary:
      case AuthButtonStyle.secondary:
        return const Color(0xFF2A2A2A);
      case AuthButtonStyle.outline:
        return const Color(0xFFF5F0E8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _getTextColor();

    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => _controller.forward(),
      onTapUp: widget.isLoading
          ? null
          : (_) {
              _controller.reverse();
              widget.onPressed();
            },
      onTapCancel: widget.isLoading ? null : () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: _getDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.isLoading
                ? [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    ),
                  ]
                : [
                    IconTheme(
                      data: IconThemeData(color: textColor, size: 22),
                      child: widget.icon,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.text,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
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
