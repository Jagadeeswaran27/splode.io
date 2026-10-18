import 'dart:ui' as dart_ui;

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

/// The Lumi mascot — a sentient glowing orb that guides users through
/// the tutorial. Designed to sit inside a dialogue overlay at the bottom
/// of the screen, chess.com-coach style.
class LumiMascot extends StatefulWidget {
  final String message;
  final int stepIndex;
  final int totalSteps;
  final VoidCallback? onNextPressed;
  final bool isFeedback;
  final String? nextButtonLabel;

  const LumiMascot({
    super.key,
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

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
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
    if (widget.stepIndex != _lastStepIndex) {
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
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: dart_ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1F).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFD4A44C).withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Lumi orb + step indicator
                        Row(
                          children: [
                            // Lumi Orb
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 36,
                                    height: 36,
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
                                          color: const Color(0xFFD4A44C)
                                              .withValues(
                                                alpha:
                                                    0.3 +
                                                    0.3 * _pulseAnimation.value,
                                              ),
                                          blurRadius:
                                              14 * _pulseAnimation.value,
                                          spreadRadius:
                                              2 * _pulseAnimation.value,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withValues(
                                                alpha: 0.6,
                                              ),
                                              blurRadius: 8,
                                              spreadRadius: 2,
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
                            // Title
                            Text(
                              'LUMI',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFD4A44C),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 4,
                              ),
                            ),
                            const Spacer(),
                            // Step dots
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(widget.totalSteps, (i) {
                                final isActive = i == widget.stepIndex;
                                final isComplete = i < widget.stepIndex;
                                return Container(
                                  width: isActive ? 20 : 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: isActive
                                        ? const Color(0xFFD4A44C)
                                        : isComplete
                                        ? const Color(
                                            0xFFD4A44C,
                                          ).withValues(alpha: 0.4)
                                        : Colors.white.withValues(alpha: 0.15),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Divider
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFFD4A44C).withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Message with animated transition
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.1),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: widget.isFeedback
                              ? Container(
                                  key: ValueKey<String>('fb_${widget.message}'),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFD4A44C,
                                    ).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFD4A44C,
                                      ).withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFFD4A44C),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          widget.message,
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFFFDF7D),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(
                                  widget.message,
                                  key: ValueKey<String>('msg_${widget.message}'),
                                  style: GoogleFonts.outfit(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                ),
                        ),
                        // "Tap to continue" or "Claim Victory" hint (only when onNextPressed is set)
                        if (widget.onNextPressed != null) ...[
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _ContinueButton(
                              onPressed: widget.onNextPressed!,
                              label: widget.nextButtonLabel,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  }
}

class _ContinueButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String? label;
  const _ContinueButton({
    required this.onPressed,
    this.label,
  });

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton>
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
          horizontal: isCustom ? 20 : 16,
          vertical: isCustom ? 12 : 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isCustom ? 14 : 12),
          gradient: isCustom
              ? const LinearGradient(
                  colors: [Color(0xFFE8C87A), Color(0xFFD4A44C)],
                )
              : null,
          color: isCustom ? null : const Color(0xFFD4A44C).withValues(alpha: 0.15),
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
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: GoogleFonts.outfit(
                color: isCustom ? const Color(0xFF1E1E24) : const Color(0xFFD4A44C),
                fontSize: isCustom ? 13 : 12,
                fontWeight: isCustom ? FontWeight.w800 : FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedBuilder(
              animation: _arrowController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_arrowController.value * 4, 0),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: isCustom ? const Color(0xFF1E1E24) : const Color(0xFFD4A44C),
                    size: 16,
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
