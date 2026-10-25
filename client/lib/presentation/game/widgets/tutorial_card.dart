import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:client/presentation/game/widgets/module_art_badge.dart';
import 'package:client/presentation/game/widgets/tutorial_card_footer.dart';
import 'package:client/presentation/game/widgets/tutorial_card_header.dart';

/// Premium tactical training module card for Splode.
///
/// Features a celestial mission dossier layout with:
/// - Distinctive module art badge with glowing particle vectors
/// - Module index tag & step count badge
/// - Tactical title, category subtitle, and description
/// - Interactive spring bounce micro-animation on press
/// - Golden amber glowing accent borders and ambient lighting
class TutorialCard extends StatefulWidget {
  final String moduleId;
  final String moduleNumber;
  final String category;
  final int stepCount;
  final String title;
  final String description;
  final bool isUnlocked;
  final VoidCallback onTap;

  const TutorialCard({
    super.key,
    required this.moduleId,
    required this.moduleNumber,
    required this.category,
    required this.stepCount,
    required this.title,
    required this.description,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  State<TutorialCard> createState() => _TutorialCardState();
}

class _TutorialCardState extends State<TutorialCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.isUnlocked) {
      _pressController.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.isUnlocked) {
      _pressController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.isUnlocked) {
      _pressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    const amberGold = Color(0xFFD4A44C);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () {
          if (!widget.isUnlocked) return;
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isUnlocked
                  ? [
                      const Color(0xFF1D1D29),
                      const Color(0xFF14141D),
                    ]
                  : [
                      const Color(0xFF16161F).withValues(alpha: 0.7),
                      const Color(0xFF111116).withValues(alpha: 0.7),
                    ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.isUnlocked
                  ? amberGold.withValues(alpha: 0.32)
                  : Colors.white.withValues(alpha: 0.06),
              width: 1.4,
            ),
            boxShadow: widget.isUnlocked
                ? [
                    BoxShadow(
                      color: amberGold.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TutorialCardHeader(
                  moduleNumber: widget.moduleNumber,
                  category: widget.category,
                  stepCount: widget.stepCount,
                  isUnlocked: widget.isUnlocked,
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ModuleArtBadge(
                      moduleId: widget.moduleId,
                      isUnlocked: widget.isUnlocked,
                      size: 58,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.outfit(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: widget.isUnlocked
                                  ? Colors.white
                                  : Colors.white54,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.description,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              color: widget.isUnlocked
                                  ? Colors.white.withValues(alpha: 0.72)
                                  : Colors.white38,
                              height: 1.42,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TutorialCardFooter(
                  isUnlocked: widget.isUnlocked,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
