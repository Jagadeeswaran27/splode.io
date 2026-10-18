import 'package:flutter/material.dart';

class TutorialHandPointer extends StatefulWidget {
  const TutorialHandPointer({super.key});

  @override
  State<TutorialHandPointer> createState() => _TutorialHandPointerState();
}

class _TutorialHandPointerState extends State<TutorialHandPointer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0.3), // Offset slightly to the bottom right
      end: const Offset(0, 0), // Slide to center
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ignore pointer events so it doesn't block taps on the cell
    return IgnorePointer(
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Icon(
            Icons.touch_app, // A finger pointing/tapping
            size: 48,
            color: Colors.white.withValues(alpha: 0.95),
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              // Inner glowing shadow for the premium look
              Shadow(
                color: const Color(0xFFD4A44C).withValues(alpha: 0.5),
                blurRadius: 20,
                offset: Offset.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
