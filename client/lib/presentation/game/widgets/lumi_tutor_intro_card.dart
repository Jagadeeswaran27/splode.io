import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:client/presentation/game/widgets/lumi_avatar_orb.dart';
import 'package:client/presentation/game/widgets/lumi_header_badge.dart';

/// A card-free, floating Lumi companion on the Training screen.
/// Lumi swoops in from the right like a bird, hovers weightlessly in the air
/// directly above the training modules, and reveals its tutor dialogue
/// with a smooth letter-by-letter typing animation.
class LumiTutorIntroCard extends StatefulWidget {
  const LumiTutorIntroCard({super.key});

  @override
  State<LumiTutorIntroCard> createState() => _LumiTutorIntroCardState();
}

class _LumiTutorIntroCardState extends State<LumiTutorIntroCard>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static const String _fullMessage =
      "I'm your guide through Splode. Pick a module below to start learning!";

  late final AnimationController _flightController;
  late final Animation<double> _flightAnimation;
  late final AnimationController _typingController;
  late final Animation<double> _typingAnimation;
  late final AnimationController _hoverController;
  late final Animation<double> _hoverAnimation;
  late final AnimationController _flutterController;
  late final Animation<double> _flutterAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _flightAnimation = CurvedAnimation(
      parent: _flightController,
      curve: Curves.easeOutCubic,
    );

    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _typingAnimation = CurvedAnimation(
      parent: _typingController,
      curve: Curves.linear,
    );

    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOutSine,
    );

    _flutterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _flutterAnimation = CurvedAnimation(
      parent: _flutterController,
      curve: Curves.easeOutBack,
    );

    _flightController.forward().then((_) {
      if (mounted) {
        _typingController.forward();
        _hoverController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _flightController.dispose();
    _typingController.dispose();
    _hoverController.dispose();
    _flutterController.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    if (_typingController.isAnimating) {
      _typingController.stop();
      _typingController.value = 1.0;
    } else if (!_flutterController.isAnimating) {
      _flutterController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _flightAnimation,
        _typingAnimation,
        _hoverAnimation,
        _flutterAnimation,
      ]),
      builder: (context, child) {
        final flightT = _flightAnimation.value;
        final isFlying = flightT < 1.0;

        // Bird flight trajectory (right to left swoop)
        // Dips gently downward during flight so the radiant glow never enters the header
        final flightX = (1.0 - flightT) * 250.0;
        final swoopY = isFlying
            ? 10.0 * math.sin(flightT * math.pi) -
                2.0 * math.sin(flightT * 3 * math.pi)
            : 0.0;
        final flightTilt = isFlying
            ? (1.0 - flightT) * -0.15 +
                0.04 * (1.0 - flightT) * math.sin(flightT * 3 * math.pi)
            : 0.0;

        // Weightless floating hover & tap flutter
        final hoverY = (1.0 - math.cos(_hoverAnimation.value * math.pi)) * 3.5;
        final flutterY = -7.0 * math.sin(_flutterAnimation.value * math.pi);
        final flutterTilt =
            0.10 * math.sin(_flutterAnimation.value * 2 * math.pi);

        // Letter-by-letter typewriter text
        final visibleCharCount =
            (_typingAnimation.value * _fullMessage.length).round();
        final displayedText = _fullMessage.substring(0, visibleCharCount);
        final isTyping = _typingController.isAnimating &&
            visibleCharCount < _fullMessage.length;
        final headerOpacity = ((flightT - 0.7) / 0.3).clamp(0.0, 1.0);

        return GestureDetector(
          onTap: _onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Transform.translate(
              offset: Offset(0, hoverY + flutterY),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Motion Trails during flight
                  if (isFlying && flightT > 0.08) ...[
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Transform.translate(
                          offset: Offset(flightX + 24, swoopY),
                          child: Opacity(
                            opacity: (1.0 - flightT) * 0.28,
                            child: const LumiAvatarOrb(size: 26, isTrail: true),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Transform.translate(
                          offset: Offset(flightX + 46, swoopY),
                          child: Opacity(
                            opacity: (1.0 - flightT) * 0.14,
                            child: const LumiAvatarOrb(size: 18, isTrail: true),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Mascot Orb + Floating Borderless Text
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(flightX, swoopY),
                        child: Transform.rotate(
                          angle: flightTilt + flutterTilt,
                          child: LumiAvatarOrb(
                            size: 44,
                            glowProgress: _hoverAnimation.value,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Opacity(
                              opacity: headerOpacity,
                              child: const LumiHeaderBadge(),
                            ),
                            const SizedBox(height: 6),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: displayedText,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.white
                                          .withValues(alpha: 0.82),
                                      height: 1.45,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  if (isTyping)
                                    const TextSpan(
                                      text: ' ▍',
                                      style: TextStyle(
                                        color: Color(0xFFD4A44C),
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
