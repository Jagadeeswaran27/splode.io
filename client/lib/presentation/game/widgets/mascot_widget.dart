import 'dart:ui' as dart_ui;

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:client/presentation/game/widgets/lumi_continue_button.dart';

/// The Lumi mascot — a sentient glowing coach orb in a horizontal dialogue card.
/// Features a two-tier coaching layout (bold action headline + concise tactical subtext)
/// paired with an animated pulsing orb, eliminating the need for internal scrolling.
class LumiMascot extends StatefulWidget {
  final String? headline;
  final String message;
  final int stepIndex;
  final int totalSteps;
  final VoidCallback? onNextPressed;
  final bool isFeedback;
  final String? nextButtonLabel;

  const LumiMascot({
    super.key,
    this.headline,
    required this.message,
    required this.stepIndex,
    required this.totalSteps,
    this.onNextPressed,
    this.nextButtonLabel,
    this.isFeedback = false,
  });

  @override
  State<LumiMascot> createState() => _LumiMascotState();
}

class _LumiMascotState extends State<LumiMascot> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  int _lastStepIndex = -1;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.90, end: 1.10).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _lastStepIndex = widget.stepIndex;
    _slideController.forward();
  }

  @override
  void didUpdateWidget(LumiMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stepIndex != _lastStepIndex ||
        widget.message != oldWidget.message ||
        widget.headline != oldWidget.headline) {
      _lastStepIndex = widget.stepIndex;
      _slideController.reset();
      _slideController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const amberGold = Color(0xFFD4A44C);
    const brightAmber = Color(0xFFFFDF7D);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: dart_ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF191922).withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: amberGold.withValues(alpha: 0.28),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: Glowing Animated Coach Lumi Orb
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [
                                  Color(0xFFFFE8A0),
                                  Color(0xFFD4A44C),
                                  Color(0xFFAA7B2E),
                                ],
                                stops: [0.0, 0.5, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: amberGold.withValues(
                                    alpha: 0.25 + 0.25 * _pulseAnimation.value,
                                  ),
                                  blurRadius: 12 * _pulseAnimation.value,
                                  spreadRadius: 1.5 * _pulseAnimation.value,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.92),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.white.withValues(alpha: 0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1.5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 14),

                    // Right: Coach Dialogue Column (Header, Headline & Tactical Subtext)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Meta Row: LUMI tag + Step count indicator
                          Row(
                            children: [
                              Text(
                                'LUMI',
                                style: GoogleFonts.outfit(
                                  color: amberGold,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white24,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'STEP ${widget.stepIndex + 1} OF ${widget.totalSteps}',
                                  style: GoogleFonts.inter(
                                    color: Colors.white54,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 3),

                          // Tier 1: Action Command Headline (if provided)
                          if (widget.headline != null &&
                              widget.headline!.isNotEmpty)
                            Text(
                              widget.headline!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: widget.isFeedback
                                    ? brightAmber
                                    : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),

                          // Tier 2: Concise Tactical Subtext / Instruction
                          Text(
                            widget.message,
                            maxLines: widget.onNextPressed != null ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.35,
                            ),
                          ),

                          // Action button when step requires explicit continue
                          if (widget.onNextPressed != null) ...[
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: LumiContinueButton(
                                onPressed: widget.onNextPressed!,
                                label: widget.nextButtonLabel,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
