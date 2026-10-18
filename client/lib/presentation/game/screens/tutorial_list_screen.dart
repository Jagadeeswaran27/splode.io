import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:client/presentation/core/utils/splode_snackbar.dart';
import 'package:client/presentation/core/widgets/constellation_background.dart';
import 'package:client/presentation/game/widgets/lumi_tutor_intro_card.dart';

class TutorialListScreen extends ConsumerWidget {
  const TutorialListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Stack(
        children: [
          const ConstellationBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    children: [
                      const LumiTutorIntroCard(),
                      const SizedBox(height: 24),
                      Text(
                        'TRAINING MODULES',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFD4A44C),
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTutorialCard(
                        context: context,
                        title: 'The Basics',
                        description: 'Learn how to place orbs, reach critical mass, and expand your territory.',
                        icon: Icons.lightbulb_outline_rounded,
                        isUnlocked: true,
                        onTap: () {
                          context.push('/tutorial/play', extra: 'basics');
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTutorialCard(
                        context: context,
                        title: 'Capturing',
                        description: "The Art of War. Learn how to capture your opponent's orbs with explosions.",
                        icon: Icons.sports_martial_arts_rounded,
                        isUnlocked: true,
                        onTap: () {
                          context.push('/tutorial/play', extra: 'capturing');
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTutorialCard(
                        context: context,
                        title: 'Chain Reactions',
                        description: 'Master the cascade. Set up massive chain reactions to clear the board.',
                        icon: Icons.dynamic_feed_rounded,
                        isUnlocked: true,
                        onTap: () {
                          context.push('/tutorial/play', extra: 'chain_reactions');
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTutorialCard(
                        context: context,
                        title: 'Edges and Corners',
                        description: 'Advanced Tactics. Control the corners and edges to build an impenetrable defense.',
                        icon: Icons.crop_free_rounded,
                        isUnlocked: false,
                        onTap: () {
                          SplodeSnackbar.show(
                            context: context,
                            message: 'Module coming soon!',
                            type: SnackbarType.info,
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Text(
            'TRAINING',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFD4A44C),
              letterSpacing: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required bool isUnlocked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isUnlocked
              ? const Color(0xFF1E1E24)
              : const Color(0xFF1A1A1F).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked
                ? const Color(0xFFD4A44C).withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.05),
            width: isUnlocked ? 1.5 : 1.0,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: const Color(0xFFD4A44C).withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? const Color(0xFFD4A44C).withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUnlocked ? icon : Icons.lock_outline_rounded,
                color: isUnlocked ? const Color(0xFFD4A44C) : Colors.white38,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.white : Colors.white54,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isUnlocked
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.white38,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnlocked) ...[
              const SizedBox(width: 12),
              const Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFD4A44C),
                  size: 16,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
