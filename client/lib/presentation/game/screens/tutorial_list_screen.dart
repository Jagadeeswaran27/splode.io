import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:client/presentation/core/widgets/constellation_background.dart';
import 'package:client/presentation/core/widgets/splode_app_bar.dart';
import 'package:client/presentation/game/widgets/lumi_tutor_intro_card.dart';
import 'package:client/presentation/game/widgets/tutorial_card.dart';

class TutorialListScreen extends ConsumerStatefulWidget {
  const TutorialListScreen({super.key});

  @override
  ConsumerState<TutorialListScreen> createState() => _TutorialListScreenState();
}

class _TutorialListScreenState extends ConsumerState<TutorialListScreen> {
  late final ScrollController _scrollController;
  final ValueNotifier<double> _scrollProgress = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    final progress = (_scrollController.offset / 30.0).clamp(0.0, 1.0);
    if ((progress - _scrollProgress.value).abs() > 0.01) {
      _scrollProgress.value = progress;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF111111),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ValueListenableBuilder<double>(
          valueListenable: _scrollProgress,
          builder: (context, progress, _) {
            final bgColor = Color.lerp(
              Colors.transparent,
              const Color(0xFF111111),
              progress,
            )!;
            final borderColor = Color.lerp(
              Colors.transparent,
              Colors.white.withValues(alpha: 0.08),
              progress,
            )!;
            return SplodeAppBar(
              title: 'TRAINING',
              backgroundColor: bgColor,
              borderColor: borderColor,
            );
          },
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ConstellationBackground(),
          SafeArea(
            child: ListView(
              controller: _scrollController,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
                TutorialCard(
                  moduleId: 'basics',
                  moduleNumber: '01',
                  category: 'Foundation',
                  stepCount: 4,
                  title: 'The Basics',
                  description:
                      'Learn how to place orbs, reach critical mass, and trigger your first explosion.',
                  isUnlocked: true,
                  onTap: () {
                    context.push('/tutorial/play', extra: 'basics');
                  },
                ),
                const SizedBox(height: 16),
                TutorialCard(
                  moduleId: 'capturing',
                  moduleNumber: '02',
                  category: 'Tactics',
                  stepCount: 7,
                  title: 'Capturing',
                  description:
                      "The art of conquest. Explode into adjacent enemy cells to convert and command them.",
                  isUnlocked: true,
                  onTap: () {
                    context.push('/tutorial/play', extra: 'capturing');
                  },
                ),
                const SizedBox(height: 16),
                TutorialCard(
                  moduleId: 'chain_reactions',
                  moduleNumber: '03',
                  category: 'Mastery',
                  stepCount: 7,
                  title: 'Chain Reactions',
                  description:
                      'Master the domino effect. Trigger multi-wave cascades like the S-Curve and Whirlpool.',
                  isUnlocked: true,
                  onTap: () {
                    context.push('/tutorial/play', extra: 'chain_reactions');
                  },
                ),
                const SizedBox(height: 16),
                TutorialCard(
                  moduleId: 'edges_and_corners',
                  moduleNumber: '04',
                  category: 'Strategy',
                  stepCount: 6,
                  title: 'Edges and Corners',
                  description:
                      'Command the high ground. Fortify 2-orb corners and flank through perimeter highways.',
                  isUnlocked: true,
                  onTap: () {
                    context.push('/tutorial/play', extra: 'edges_and_corners');
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
