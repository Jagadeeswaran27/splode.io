import 'dart:ui' as dart_ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:client/presentation/core/providers/audio_provider.dart';
import 'package:client/presentation/game/providers/game_provider.dart';
import 'package:client/domain/models/match_config.dart';
import 'package:client/presentation/game/widgets/game_board_widget.dart';
import 'package:client/presentation/game/widgets/move_history_bottom_sheet.dart';
import 'package:client/presentation/core/widgets/auth_button.dart';

/// The local match screen — now powered entirely by Flutter widgets
/// instead of the Flame engine.
class LocalMatchScreen extends ConsumerStatefulWidget {
  const LocalMatchScreen({super.key});

  @override
  ConsumerState<LocalMatchScreen> createState() => _LocalMatchScreenState();
}

class _LocalMatchScreenState extends ConsumerState<LocalMatchScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AudioController _audioController;

  @override
  void initState() {
    super.initState();
    _audioController = ref.read(audioProvider);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Stop the menu background music when entering a match
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioController.stopMusic();
    });
  }

  @override
  void dispose() {
    // Resume the menu background music when leaving the match safely via cached controller
    _audioController.playMenuMusic();

    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(gameStateProvider);
    final viewedState = ref.watch(viewedGameStateProvider);
    final matchConfig = ref.watch(matchConfigProvider);
    final bpChange = ref.watch(bpChangeProvider);

    PlayerConfig getPlayerConfig(String playerId) {
      return matchConfig.players.firstWhere(
        (p) => p.id == playerId,
        orElse: () => matchConfig.players.first,
      );
    }

    Future<bool> showExitDialog() async {
      final isRankedPenalty =
          matchConfig.isRanked &&
          liveState.turnCount > 0 &&
          !liveState.isGameOver;

      final warningText = isRankedPenalty
          ? 'Are you sure you want to leave? This will count as a loss and you will lose 5 BP.'
          : 'Are you sure you want to leave? This match will be abandoned.';

      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          title: Text(
            'Quit Match?',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            warningText,
            style: GoogleFonts.inter(
              color: isRankedPenalty ? const Color(0xFFF43F5E) : Colors.white70,
              fontWeight: isRankedPenalty ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: Text(
                'CANCEL',
                style: GoogleFonts.outfit(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(gameStateProvider.notifier).quitGame();
                context.pop(true);
              },
              child: Text(
                'QUIT',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFF43F5E), // Rose red
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      return shouldExit ?? false;
    }

    final canExitWithoutPrompt =
        liveState.isGameOver || liveState.turnCount == 0;

    return PopScope(
      canPop: canExitWithoutPrompt,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showExitDialog();
        if (shouldExit && context.mounted) {
          context.pop(result);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF111111),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              if (canExitWithoutPrompt) {
                context.pop();
              } else {
                final shouldExit = await showExitDialog();
                if (shouldExit && context.mounted) {
                  context.pop();
                }
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.history_rounded, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const MoveHistoryBottomSheet(),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          title: Builder(
            builder: (context) {
              final isBotMatch = matchConfig.players.any((p) => p.isAi);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isBotMatch
                        ? Icons.smart_toy_rounded
                        : Icons.people_alt_rounded,
                    color: const Color(0xFFD4A44C),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBotMatch ? 'BOT MATCH' : 'LOCAL MATCH',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                      fontSize: 16,
                    ),
                  ),
                ],
              );
            },
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // Dynamic Game Board Background
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                final currentPlayerConfig = getPlayerConfig(
                  viewedState.currentPlayer,
                );
                final glowColor = currentPlayerConfig.color;

                return CustomPaint(
                  size: Size.infinite,
                  painter: _GameBoardBackgroundPainter(
                    pulseValue: _pulseController.value,
                    glowColor: glowColor,
                  ),
                );
              },
            ),

            // Game Content
            Column(
              children: [
                // Turn Indicator (Fixed height to prevent layout shifts, fades out on Game Over)
                SizedBox(
                  height: 110,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: viewedState.isGameOver ? 0.0 : 1.0,
                    child: Center(
                      child: Builder(
                        builder: (context) {
                          final currentPlayerConfig = getPlayerConfig(
                            viewedState.currentPlayer,
                          );
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: currentPlayerConfig.color.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: currentPlayerConfig.color.withValues(
                                    alpha: 0.15,
                                  ),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (currentPlayerConfig.isAi)
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: currentPlayerConfig.color
                                          .withValues(alpha: 0.2),
                                    ),
                                    child: Icon(
                                      Icons.smart_toy_rounded,
                                      size: 16,
                                      color: currentPlayerConfig.color,
                                    ),
                                  )
                                else
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: currentPlayerConfig.color,
                                      boxShadow: [
                                        BoxShadow(
                                          color: currentPlayerConfig.color
                                              .withValues(alpha: 0.6),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(width: 16),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentPlayerConfig.isAi
                                          ? 'BOT THINKING...'
                                          : 'CURRENT TURN',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white54,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    Text(
                                      currentPlayerConfig.name,
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: currentPlayerConfig.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GameBoardWidget(
                    gameState: viewedState,
                    matchConfig: matchConfig,
                    onCellTapped: (row, col) {
                      if (liveState.turnCount != viewedState.turnCount ||
                          liveState.isGameOver) {
                        return;
                      }
                      ref
                          .read(gameStateProvider.notifier)
                          .processMove(row, col);
                    },
                  ),
                ),
                const _PlaybackControls(),
              ],
            ),
            if (liveState.isGameOver && viewedState.isGameOver) ...[
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, child) {
                    return BackdropFilter(
                      filter: dart_ui.ImageFilter.blur(
                        sigmaX: 12 * value,
                        sigmaY: 12 * value,
                      ),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.4 * value),
                      ),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    final winnerConfig = getPlayerConfig(liveState.winner!);
                    final isBotWin = winnerConfig.isAi;
                    final titleText = isBotWin ? 'DEFEAT' : 'VICTORY';

                    return Center(
                      child: Transform.scale(
                        scale: value.clamp(0.0, double.infinity),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: winnerConfig.color.withValues(
                                  alpha: 0.15,
                                ),
                                blurRadius: 40,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: BackdropFilter(
                              filter: dart_ui.ImageFilter.blur(
                                sigmaX: 16,
                                sigmaY: 16,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 32,
                                ),
                                decoration: BoxDecoration(
                                  color: winnerConfig.color.withValues(
                                    alpha: 0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color: winnerConfig.color.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      titleText,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: winnerConfig.color,
                                        letterSpacing: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${winnerConfig.name} WINS',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.outfit(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                    ),
                                    if (bpChange != null && bpChange != 0) ...[
                                      const SizedBox(height: 24),
                                      _BpChangeAnimation(bpChange: bpChange),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AuthButton(
                          text: 'Play Again',
                          icon: const Icon(Icons.refresh_rounded),
                          style: AuthButtonStyle.primary,
                          onPressed: () {
                            ref
                                .read(gameStateProvider.notifier)
                                .initialize(matchConfig);
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthButton(
                          text: 'Review Match',
                          icon: const Icon(Icons.history_rounded),
                          style: AuthButtonStyle.secondary,
                          onPressed: () {
                            ref.read(gameStateProvider.notifier).jumpToStart();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GameBoardBackgroundPainter extends CustomPainter {
  final double pulseValue;
  final Color glowColor;

  _GameBoardBackgroundPainter({
    required this.pulseValue,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw the subtle dot matrix grid
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    const double spacing = 40.0;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }

    // 2. Draw the dynamic player-colored radial pulse
    // The pulse expands slightly and changes opacity
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.7;
    final pulseRadius = baseRadius + (pulseValue * size.width * 0.1);

    // Smooth easing for opacity (sine wave)
    final double opacity = 0.05 + (pulseValue * 0.08);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withValues(alpha: opacity),
          glowColor.withValues(alpha: 0.0),
        ],
        stops: const [0.2, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: pulseRadius))
      ..blendMode = BlendMode.screen;

    canvas.drawRect(Offset.zero & size, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _GameBoardBackgroundPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.glowColor != glowColor;
  }
}

class _BpChangeAnimation extends StatefulWidget {
  final int bpChange;

  const _BpChangeAnimation({required this.bpChange});

  @override
  State<_BpChangeAnimation> createState() => _BpChangeAnimationState();
}

class _BpChangeAnimationState extends State<_BpChangeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.5,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_controller);
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Start BP animation immediately with the modal
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.bpChange > 0;
    final color = isPositive ? Colors.blueAccent : Colors.redAccent;
    final text = '${isPositive ? '+' : ''}${widget.bpChange} BP';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
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

class _PlaybackControls extends ConsumerWidget {
  const _PlaybackControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(gameHistoryProvider);
    final currentIndex = ref.watch(viewIndexProvider);
    final viewedState = ref.watch(viewedGameStateProvider);

    if (history.isEmpty) return const SizedBox.shrink();

    final isLatest = currentIndex >= history.length - 1;
    final lastMove = viewedState.lastMove;

    final canGoBack = currentIndex > 0;
    final canGoForward = currentIndex < history.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isLatest
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFD4A44C).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isLatest
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFFD4A44C).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.skip_previous_rounded,
                color: canGoBack ? Colors.white70 : Colors.white24,
              ),
              onPressed: canGoBack
                  ? () => ref.read(gameStateProvider.notifier).jumpToStart()
                  : null,
            ),
            IconButton(
              icon: Icon(
                Icons.navigate_before_rounded,
                color: canGoBack ? Colors.white : Colors.white24,
              ),
              onPressed: canGoBack
                  ? () => ref.read(gameStateProvider.notifier).stepBackward()
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                lastMove != null
                    ? 'T${lastMove.turnNumber}: ${lastMove.toAlgebraic()}'
                    : 'Start',
                style: GoogleFonts.outfit(
                  color: isLatest ? Colors.white : const Color(0xFFD4A44C),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.navigate_next_rounded,
                color: canGoForward ? Colors.white : Colors.white24,
              ),
              onPressed: canGoForward
                  ? () => ref.read(gameStateProvider.notifier).stepForward()
                  : null,
            ),
            IconButton(
              icon: Icon(
                Icons.skip_next_rounded,
                color: canGoForward ? Colors.white70 : Colors.white24,
              ),
              onPressed: canGoForward
                  ? () => ref.read(gameStateProvider.notifier).jumpToLatest()
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
