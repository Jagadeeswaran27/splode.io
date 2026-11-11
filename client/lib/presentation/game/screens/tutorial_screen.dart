import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:client/domain/models/match_config.dart';
import 'package:client/domain/models/tutorial_module.dart';
import 'package:client/presentation/core/utils/responsive_layout.dart';
import 'package:client/presentation/core/widgets/constellation_background.dart';
import 'package:client/presentation/core/widgets/responsive_content_container.dart';
import 'package:client/presentation/core/widgets/splode_app_bar.dart';
import 'package:client/presentation/game/providers/game_provider.dart';
import 'package:client/presentation/game/providers/tutorial_provider.dart';
import 'package:client/presentation/game/widgets/game_board_widget.dart';
import 'package:client/presentation/game/widgets/mascot_widget.dart';
import 'package:client/presentation/game/widgets/tutorial_complete_overlay.dart';

/// A chess.com-inspired interactive tutorial screen.
///
/// Layout: The board is the hero, centered and occupying most of the screen.
/// Lumi's dialogue overlay floats at the bottom over the board, chess.com
/// coach style. A subtle step progress bar sits at the very top below the
/// AppBar. The constellation background ties it to the app's royal theme.
class TutorialScreen extends ConsumerStatefulWidget {
  final TutorialModule module;

  const TutorialScreen({
    super.key,
    this.module = TutorialModule.basics,
  });

  String get moduleId => module.id;

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  late MatchConfig tutorialMatchConfig;

  @override
  void initState() {
    super.initState();
    tutorialMatchConfig = const MatchConfig(
      rows: 9,
      cols: 6,
      players: [
        PlayerConfig(id: 'p1', name: 'You', color: Color(0xFFD4A44C)),
        PlayerConfig(id: 'p2', name: 'Opponent', color: Color(0xFFF5F0E8)),
      ],
      isTutorial: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(gameStateProvider.notifier).initialize(tutorialMatchConfig);
      ref.read(tutorialProvider.notifier).loadModule(widget.moduleId);
    });
  }

  void _handleCellTapped(int row, int col) async {
    final liveState = ref.read(gameStateProvider);
    final tutorialState = ref.read(tutorialProvider);
    final step = tutorialState.currentStep;

    if (liveState.isGameOver || step == null) return;

    // Forced move: only the target cell is tappable
    if (row != step.targetRow || col != step.targetCol) return;

    ref.read(tutorialProvider.notifier).setProcessing(true);

    final success = await ref
        .read(gameStateProvider.notifier)
        .processMove(row, col);

    if (!mounted) return;

    if (success) {
      final randomGoodMsg = [
        'Good move!',
        'Nice! Right on target!',
        'Excellent placement!',
        'Perfect!',
      ][math.Random().nextInt(4)];
      ref.read(tutorialProvider.notifier).setFeedback(randomGoodMsg);
      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;
      ref.read(tutorialProvider.notifier).setFeedback(null);
      ref.read(tutorialProvider.notifier).advanceStep();
    } else {
      ref.read(tutorialProvider.notifier).setProcessing(false);
    }
  }

  String? getNextTutorialId(String current) {
    if (current == 'basics') return 'capturing';
    if (current == 'capturing') return 'chain_reactions';
    if (current == 'chain_reactions') return 'edges_and_corners';
    return null;
  }

  String? getNextTutorialName(String current) {
    if (current == 'basics') return 'Capturing';
    if (current == 'capturing') return 'Chain Reactions';
    if (current == 'chain_reactions') return 'Edges and Corners';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(gameStateProvider);
    final tutorialState = ref.watch(tutorialProvider);
    final step = tutorialState.currentStep;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF111111),
      appBar: const SplodeAppBar(title: 'HOW TO PLAY'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Constellation background (same as menu)
          const ConstellationBackground(),

          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showMascot = step != null;
                const mascotHeight = 132.0;

                final isFeedback = tutorialState.feedbackMessage != null;
                final displayMessage = isFeedback
                    ? (tutorialState.feedbackMessage ?? step?.message ?? '')
                    : (step?.message ?? '');
                String? nextLabel;
                VoidCallback? onNext;

                Widget buildMascot() {
                  if (!showMascot) return const SizedBox.shrink();
                  return SizedBox(
                    height: mascotHeight,
                    child: LumiMascot(
                      headline: isFeedback ? 'EXCELLENT!' : step.headline,
                      message: displayMessage,
                      stepIndex: tutorialState.stepIndex,
                      totalSteps: tutorialState.totalSteps,
                      isFeedback: isFeedback,
                      onNextPressed: onNext,
                      nextButtonLabel: nextLabel,
                    ),
                  );
                }

                Widget buildBoard() {
                  return GameBoardWidget(
                    gameState: liveState,
                    matchConfig: tutorialMatchConfig,
                    onCellTapped: _handleCellTapped,
                    isTutorialTarget: (row, col) {
                      return step != null &&
                          step.targetRow == row &&
                          step.targetCol == col;
                    },
                  );
                }

                if (context.isLandscape && constraints.maxWidth >= 600) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 320,
                          child: SingleChildScrollView(
                            child: buildMascot(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Center(
                            child: buildBoard(),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final availableHForBoard =
                    constraints.maxHeight - (showMascot ? mascotHeight : 0);
                final cellW = (constraints.maxWidth - 32) / liveState.cols;
                final cellH = (availableHForBoard - 32) / liveState.rows;
                final cellSize = math.min(cellW, cellH);
                final boardWidth = (cellSize * liveState.cols) + 32;

                return Column(
                  children: [
                    if (showMascot)
                      ResponsiveContentContainer(
                        maxWidth: 520,
                        child: buildMascot(),
                      ),
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: boardWidth,
                          child: buildBoard(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Tutorial Complete Overlay
          if (tutorialState.isTutorialComplete)
            TutorialCompleteOverlay(
              moduleId: tutorialState.moduleId,
              onNext: (nextId) {
                if (nextId == null) {
                  context.pop(); // Go back to list
                } else {
                  context.pushReplacement('/tutorial/play', extra: nextId);
                }
              },
            ),
        ],
      ),
    );
  }
}
