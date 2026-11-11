import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';

/// The hero combat card on the main hub for playing against the AI bot.
///
/// Designed with minimal, focused styling:
/// - Prominent imperial gold gradient border & ambient glow.
/// - Tactical AI crest with customizable icon.
/// - Clean, customizable mode title.
/// - Interactive press animation with haptic feedback.
class HubHeroBotCard extends StatefulWidget {
  final VoidCallback onTap;
  final String title;
  final IconData icon;

  const HubHeroBotCard({
    super.key,
    required this.onTap,
    this.title = 'PLAY WITH BOT',
    this.icon = Icons.psychology_rounded,
  });

  @override
  State<HubHeroBotCard> createState() => _HubHeroBotCardState();
}

class _HubHeroBotCardState extends State<HubHeroBotCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  static const _amberGold = Color(0xFFD4A44C);
  static const _brightAmber = Color(0xFFFFDF7D);

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressController.forward();
  void _onTapUp(TapUpDetails _) => _pressController.reverse();
  void _onTapCancel() => _pressController.reverse();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnimation.value, child: child),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E1C18), Color(0xFF121211)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _amberGold.withValues(alpha: 0.35),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: _amberGold.withValues(alpha: 0.10),
                blurRadius: 14,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // AI Crest
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _amberGold.withValues(alpha: 0.12),
                    border: Border.all(
                      color: _amberGold.withValues(alpha: 0.45),
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: _brightAmber,
                      size: 22,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Title
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.title,
                      style: GoogleFonts.outfit(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
