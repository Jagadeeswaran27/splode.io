import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:client/domain/models/tutorial_module.dart';
import 'package:client/presentation/core/utils/responsive_layout.dart';
import 'package:client/presentation/core/widgets/constellation_background.dart';
import 'package:client/presentation/core/widgets/responsive_content_container.dart';
import 'package:client/presentation/core/widgets/splode_app_bar.dart';
import 'package:client/presentation/game/providers/tutorial_progress_provider.dart';
import 'package:client/presentation/game/widgets/tutorial_bounty_banner.dart';
import 'package:client/presentation/game/widgets/tutorial_card.dart';

class TutorialListScreen extends ConsumerStatefulWidget {
  const TutorialListScreen({super.key});

  @override
  ConsumerState<TutorialListScreen> createState() => _TutorialListScreenState();
}

class _TutorialListScreenState extends ConsumerState<TutorialListScreen> {
  late final ScrollController _scrollController;
  final ValueNotifier<double> _scrollProgress = ValueNotifier<double>(0.0);
  TutorialModule? _expandedModule;

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
    final completedModules = ref.watch(tutorialProgressProvider);
    final progressNotifier = ref.watch(tutorialProgressProvider.notifier);
    final earnedBp = completedModules.fold(0, (sum, m) => sum + m.bpReward);

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
            child: ResponsiveContentContainer(
              maxWidth: SplodeBreakpoints.maxContentWidth,
              child: ListView(
                controller: _scrollController,
                clipBehavior: Clip.none,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                children: [
                  TutorialBountyBanner(
                    earnedBp: earnedBp,
                    totalBp: TutorialModule.totalBounty,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('TRAINING MODULES'),
                  const SizedBox(height: 16),
                  ...TutorialModule.values.map((module) {
                    final isUnlocked = progressNotifier.isUnlocked(module);
                    final isCompleted = progressNotifier.isCompleted(module);
                    final isExpanded = _expandedModule == module;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: TutorialCard(
                        module: module,
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                        isExpanded: isExpanded,
                        onExpansionChanged: (expanded) {
                          setState(() {
                            _expandedModule = expanded ? module : null;
                          });
                        },
                        onStart: () {
                          context.push('/tutorial/play', extra: module.id);
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFFD4A44C).withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFD4A44C),
              letterSpacing: 4,
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 36,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD4A44C).withValues(alpha: 0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
