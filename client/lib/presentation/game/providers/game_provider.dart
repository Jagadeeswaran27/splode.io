import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client/application/ai/ai_isolate_worker.dart';
import 'package:client/domain/engine/game_engine.dart';
import 'package:client/domain/models/ai_difficulty.dart';
import 'package:client/domain/models/fast_board.dart';
import 'package:client/domain/models/game_state.dart';
import 'package:client/domain/models/match_config.dart';
import 'package:client/presentation/game/providers/bot_history_provider.dart';
import 'package:client/presentation/game/services/game_persistence_service.dart';

final matchConfigProvider = StateProvider<MatchConfig>((ref) {
  return const MatchConfig(
    rows: 9,
    cols: 6,
    players: [
      PlayerConfig(id: 'p1', name: 'Player 1', color: Color(0xFFD4A44C)),
      PlayerConfig(id: 'p2', name: 'Player 2', color: Color(0xFFF5F0E8)),
    ],
  );
});

final bpChangeProvider = StateProvider<int?>((ref) => null);

final gameHistoryProvider = StateProvider<List<GameState>>((ref) => []);
final viewIndexProvider = StateProvider<int>((ref) => 0);

final viewedGameStateProvider = Provider<GameState>((ref) {
  final history = ref.watch(gameHistoryProvider);
  final viewIndex = ref.watch(viewIndexProvider);
  final liveState = ref.watch(gameStateProvider);

  if (history.isEmpty || viewIndex >= history.length - 1) {
    return liveState;
  }
  return history[viewIndex];
});

final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((
  ref,
) {
  return GameStateNotifier(ref);
});

class GameStateNotifier extends StateNotifier<GameState> {
  final Ref ref;

  GameStateNotifier(this.ref)
    : super(GameEngine.createInitialState(9, 6, ['p1', 'p2']));

  bool _isProcessing = false;

  void initialize(MatchConfig config) {
    ref.read(bpChangeProvider.notifier).state = null;
    final initialState = GameEngine.createInitialState(
      config.rows,
      config.cols,
      config.players.map((p) => p.id).toList(),
    ).copyWith(isTutorial: config.isTutorial);
    state = initialState;
    ref.read(gameHistoryProvider.notifier).state = [initialState];
    ref.read(viewIndexProvider.notifier).state = 0;
    _saveState();
    _checkAiTurn();
  }

  void restoreState(GameState savedState) {
    ref.read(bpChangeProvider.notifier).state = null;
    state = savedState;
    ref.read(gameHistoryProvider.notifier).state = [savedState];
    ref.read(viewIndexProvider.notifier).state = 0;
    _checkAiTurn();
  }

  void stepBackward() {
    final idx = ref.read(viewIndexProvider);
    if (idx > 0) {
      ref.read(viewIndexProvider.notifier).state = idx - 1;
    }
  }

  void stepForward() {
    final idx = ref.read(viewIndexProvider);
    final history = ref.read(gameHistoryProvider);
    if (idx < history.length - 1) {
      ref.read(viewIndexProvider.notifier).state = idx + 1;
    }
  }

  void jumpToLatest() {
    final history = ref.read(gameHistoryProvider);
    if (history.isNotEmpty) {
      ref.read(viewIndexProvider.notifier).state = history.length - 1;
    }
  }

  void jumpToStart() {
    ref.read(viewIndexProvider.notifier).state = 0;
  }

  Future<void> _saveState() async {
    final config = ref.read(matchConfigProvider);
    await ref.read(gamePersistenceServiceProvider).saveGame(state, config);
  }

  void quitGame() {
    ref.read(gamePersistenceServiceProvider).clearSavedGame();

    // If ranked game is in progress and they quit in the middle of it, count as a loss.
    if (!state.isGameOver && state.turnCount > 0) {
      final config = ref.read(matchConfigProvider);
      final bots = config.players.where((p) => p.isAi).toList();

      if (bots.isNotEmpty && config.isRanked) {
        final bot = bots.first;
        final difficulty = bot.aiDifficulty?.name ?? 'easy';

        // Fire and forget backend save for the loss penalty
        ref
            .read(botHistoryManagerProvider)
            .recordMatch(difficulty, 'loss', isRanked: true);
      }
    }
  }

  Future<bool> processMove(int row, int col) async {
    if (_isProcessing || state.isGameOver) return false;

    final valid = GameEngine.isValidMove(state, row, col, state.currentPlayer);
    if (!valid) return false;

    _isProcessing = true;
    final steps = GameEngine.processMove(state, row, col, state.currentPlayer);
    for (int i = 0; i < steps.length; i++) {
      state = steps[i];

      if (i == 0) {
        // Initial placement
        await Future.delayed(const Duration(milliseconds: 100));
      } else if (i % 2 == 1) {
        // Odd index: Explode phase (orbs in flight)
        // Match the 350ms duration from FlyingOrbOverlay
        await Future.delayed(const Duration(milliseconds: 350));
      } else {
        // Even index (except 0): Distribute phase (orbs landed)
        // Brief pause so the player sees the result before the next explosion
        await Future.delayed(const Duration(milliseconds: 100));
      }
      _saveState();
    }
    _isProcessing = false;

    // Push the stable post-move state to history
    final currentHistory = ref.read(gameHistoryProvider);
    ref.read(gameHistoryProvider.notifier).state = [...currentHistory, state];

    // Jump the view to the latest, but only if they are not actively scrubbing history.
    // If they are watching a chain reaction, we should keep them at the present.
    ref.read(viewIndexProvider.notifier).state = currentHistory.length;

    if (state.isGameOver) {
      _handleGameOver();
    } else {
      _checkAiTurn();
    }

    return true;
  }

  Future<void> _handleGameOver() async {
    final config = ref.read(matchConfigProvider);
    final bots = config.players.where((p) => p.isAi).toList();

    // Only save if playing against a bot
    if (bots.isEmpty) {
      return;
    }

    final bot = bots.first;
    final result = (state.winner == bot.id) ? 'loss' : 'win';
    final difficulty = bot.aiDifficulty?.name ?? 'easy';

    int bpChange = 0;
    if (config.isRanked) {
      if (difficulty == 'hard') {
        bpChange = result == 'win' ? 10 : -5;
      } else if (difficulty == 'expert') {
        bpChange = result == 'win' ? 20 : -5;
      }
    }

    // Set UI state immediately!
    ref.read(bpChangeProvider.notifier).state = bpChange;

    // Fire and forget backend save
    ref
        .read(botHistoryManagerProvider)
        .recordMatch(difficulty, result, isRanked: config.isRanked);
  }

  void _checkAiTurn() async {
    if (_isProcessing || state.isGameOver) return;

    final config = ref.read(matchConfigProvider);
    final currentPlayerConfig = config.players[state.currentPlayerIndex];

    if (!currentPlayerConfig.isAi) return;

    _isProcessing = true;

    // Simulate thinking time and let UI settle
    final minimumThinkingTime = Future.delayed(
      const Duration(milliseconds: 600),
    );

    // Convert GameState to FastBoard Int32List
    final gridData = Int32List(config.rows * config.cols);
    for (int r = 0; r < config.rows; r++) {
      for (int c = 0; c < config.cols; c++) {
        final cell = state.board[r][c];
        final orbs = cell.orbCount;
        int ownerIndex = 0;
        if (cell.ownerId != null) {
          ownerIndex =
              config.players.indexWhere((p) => p.id == cell.ownerId) + 1;
        }
        gridData[r * config.cols + c] = FastBoard.createCell(ownerIndex, orbs);
      }
    }

    final payload = AiWorkerPayload(
      rows: config.rows,
      cols: config.cols,
      gridData: gridData,
      turnCount: state.turnCount,
      aiPlayerIndex: state.currentPlayerIndex + 1, // 1-indexed for FastBoard
      difficulty: currentPlayerConfig.aiDifficulty ?? AiDifficulty.easy,
    );

    final result = await Isolate.run(() => computeMoveInIsolate(payload));

    await minimumThinkingTime; // Ensure we waited at least 600ms

    _isProcessing = false;
    processMove(result.row, result.col);
  }
}
