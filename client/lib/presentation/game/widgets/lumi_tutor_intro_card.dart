import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';

/// A regal hero introduction card on the Training screen introducing Lumi,
/// the Grandmaster and royal mentor of Splode. Features an animated breathing
/// orb emblem, imperial gold glassmorphism, and interactive royal wisdom quotes.
class LumiTutorIntroCard extends StatefulWidget {
  const LumiTutorIntroCard({super.key});

  @override
  State<LumiTutorIntroCard> createState() => _LumiTutorIntroCardState();
}

class _LumiTutorIntroCardState extends State<LumiTutorIntroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  int _currentQuoteIndex = 0;

  static const List<String> _tutorQuotes = [
    '“Greetings, Commander! I am Lumi, Grandmaster of the Grid. Follow my guidance in the trials below, and together we shall master the art of critical mass!”',
    '“Royal Wisdom: Corner cells reach critical mass at just 2 orbs. Claim them early to anchor your sovereign territory!”',
    '“Royal Wisdom: Edge cells burst at 3 orbs. Ignite them to unleash devastating flank strikes across the battlefield!”',
    '“Royal Wisdom: Chain reactions conquer enemy territory instantly. A single strategic strike can overthrow an entire empire!”',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _nextQuote() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentQuoteIndex = (_currentQuoteIndex + 1) % _tutorQuotes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _nextQuote,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF242232), Color(0xFF161522), Color(0xFF0F0E16)],
            stops: [0.0, 0.5, 1.0],
          ),
          border: Border.all(
            color: const Color(0xFFD4A44C).withValues(alpha: 0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFFD4A44C).withValues(alpha: 0.12),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Ambient golden radial aura in upper corner
              Positioned(
                left: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFD4A44C).withValues(alpha: 0.28),
                        const Color(0xFFD4A44C).withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Decorative royal corner star (top right)
              Positioned(
                top: 14,
                right: 18,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: const Color(0xFFD4A44C).withValues(alpha: 0.4),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '✦',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFD4A44C).withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: Grandmaster Lumi Orb + Titles
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildRoyalLumiOrb(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'LUMI',
                                    style: GoogleFonts.outfit(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFFFFE8A0),
                                      letterSpacing: 3,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFD4A44C,
                                      ).withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFD4A44C,
                                        ).withValues(alpha: 0.45),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'GRANDMASTER',
                                      style: GoogleFonts.outfit(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFFFDF7D),
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Keeper of the Spheres • Grid Mentor',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Imperial decree speech box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0E16).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFD4A44C).withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Royal vertical gold ribbon bar
                            Container(
                              width: 3.5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFFFDF7D),
                                    Color(0xFFD4A44C),
                                    Color(0xFFAA7B2E),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 320),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.0, 0.08),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      _tutorQuotes[_currentQuoteIndex],
                                      key: ValueKey<int>(_currentQuoteIndex),
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        color: const Color(0xFFF7E7C4),
                                        height: 1.48,
                                        fontStyle: FontStyle.italic,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Footer: wisdom quote progress dots + interactive prompt
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Progress pips
                                      Row(
                                        children: List.generate(
                                          _tutorQuotes.length,
                                          (index) {
                                            final isSelected =
                                                index == _currentQuoteIndex;
                                            return AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              width: isSelected ? 16 : 6,
                                              height: 6,
                                              margin: const EdgeInsets.only(
                                                right: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                color: isSelected
                                                    ? const Color(0xFFD4A44C)
                                                    : Colors.white.withValues(
                                                        alpha: 0.18,
                                                      ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      // Consult prompt
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.touch_app_rounded,
                                            size: 13,
                                            color: Color(0xFFFFDF7D),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Tap for Royal Wisdom',
                                            style: GoogleFonts.outfit(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFFFFDF7D),
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoyalLumiOrb() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [
                  Color(0xFFFFF7D6),
                  Color(0xFFFFDF7D),
                  Color(0xFFD4A44C),
                  Color(0xFF7A5416),
                ],
                stops: [0.0, 0.35, 0.72, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFFD4A44C,
                  ).withValues(alpha: 0.45 + 0.25 * _pulseController.value),
                  blurRadius: 20 * _pulseAnimation.value,
                  spreadRadius: 3 * _pulseAnimation.value,
                ),
                BoxShadow(
                  color: const Color(0xFFFFDF7D).withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ornate concentric celestial ring
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                ),
                // Glowing inner diamond core
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.98),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.9),
                        blurRadius: 12,
                        spreadRadius: 3,
                      ),
                      BoxShadow(
                        color: const Color(0xFFFFE8A0).withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
