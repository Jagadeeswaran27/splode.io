import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:client/domain/models/match_config.dart';
import 'package:client/presentation/core/widgets/constellation_background.dart';
import 'package:client/presentation/game/providers/game_provider.dart';
import 'package:client/presentation/game/providers/tutorial_provider.dart';
import 'package:client/presentation/game/widgets/game_board_widget.dart';
import 'package:client/presentation/game/widgets/mascot_widget.dart';

/// A chess.com-inspired interactive tutorial screen.
///
/// Layout: The board is the hero, centered and occupying most of the screen.
/// Lumi's dialogue overlay floats at the bottom over the board, chess.com
/// coach style. A subtle step progress bar sits at the very top below the
/// AppBar. The constellation background ties it to the app's royal theme.
class TutorialScreen extends ConsumerStatefulWidget {
  final String moduleId;
  const TutorialScreen({super.key, this.moduleId = 'basics'});

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

    if (success) {
      final randomGoodMsg = [
        'Good move!',
        'Nice! Right on target!',
        'Excellent placement!',
        'Perfect!',
      ][math.Random().nextInt(4)];
      ref.read(tutorialProvider.notifier).setFeedback(randomGoodMsg);
      await Future.delayed(const Duration(milliseconds: 1400));
      ref.read(tutorialProvider.notifier).advanceStep();
    } else {
      ref.read(tutorialProvider.notifier).setProcessing(false);
    }
  }

  String? getNextTutorialId(String current) {
    if (current == 'basics') return 'capturing';
    if (current == 'capturing') return 'chain_reactions';
    return null;
  }

  String? getNextTutorialName(String current) {
    if (current == 'basics') return 'Capturing';
    if (current == 'capturing') return 'Chain Reactions';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(gameStateProvider);
    final tutorialState = ref.watch(tutorialProvider);
    final step = tutorialState.currentStep;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
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
                const mascotHeight = 175.0;
                // AppBar approx height = 48
                final availableHForBoard =
                    constraints.maxHeight - 48 - (showMascot ? mascotHeight : 0);
                final cellW = (constraints.maxWidth - 32) / liveState.cols;
                final cellH = (availableHForBoard - 32) / liveState.rows;
                final cellSize = math.min(cellW, cellH);
                final boardWidth = (cellSize * liveState.cols) + 32;

                String displayMessage = step?.message ?? '';
                String? nextLabel;
                VoidCallback? onNext;
                bool isFeedback = tutorialState.feedbackMessage != null;

                return Column(
                  children: [
                    // Custom AppBar (full width)
                    _TutorialAppBar(onBack: () => context.pop()),

                    // Center the Board and Mascot together
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: boardWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: GameBoardWidget(
                                  gameState: liveState,
                                  matchConfig: tutorialMatchConfig,
                                  onCellTapped: _handleCellTapped,
                                  isTutorialTarget: (row, col) {
                                    return step != null &&
                                        step.targetRow == row &&
                                        step.targetCol == col;
                                  },
                                ),
                              ),
                              if (showMascot)
                                SizedBox(
                                  height: mascotHeight,
                                  child: LumiMascot(
                                    message: displayMessage,
                                    stepIndex: tutorialState.stepIndex,
                                    totalSteps: tutorialState.totalSteps,
                                    isFeedback: isFeedback,
                                    onNextPressed: onNext,
                                    nextButtonLabel: nextLabel,
                                  ),
                                ),
                            ],
                          ),
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
            _TutorialCompleteOverlay(
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

// ─────────────────────── App Bar ───────────────────────

class _TutorialAppBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TutorialAppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white60,
              size: 24,
            ),
            onPressed: onBack,
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.school_rounded,
                color: Color(0xFFD4A44C),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'HOW TO PLAY',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _TutorialCompleteOverlay extends ConsumerWidget {
  final String moduleId;
  final Function(String?) onNext;

  const _TutorialCompleteOverlay({
    required this.moduleId,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // determine the next tutorial based on moduleId
    String? nextId;
    String nextName = '';

    if (moduleId == 'basics') {
      nextId = 'capturing';
      nextName = 'Capturing';
    } else if (moduleId == 'capturing') {
      nextId = 'chain_reactions';
      nextName = 'Chain Reactions';
    } else if (moduleId == 'chain_reactions') {
      nextId = null;
    }

    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFD4A44C),
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'TUTORIAL COMPLETE',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You have mastered this module!',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (nextId != null)
                ElevatedButton(
                  onPressed: () => onNext(nextId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4A44C),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'NEXT: ${nextName.toUpperCase()}',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              if (nextId != null) const SizedBox(height: 16),
              TextButton(
                onPressed: () => onNext(null),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white60,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  nextId == null ? 'FINISH' : 'BACK TO MENU',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
