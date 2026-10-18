import 'dart:math';
import 'package:client/domain/models/ai_difficulty.dart';
import 'package:client/domain/models/fast_board.dart';

class AiEngine {
  static final _random = Random();
  static bool _timeIsUp = false;

  /// Entry point for AI computation
  static int computeBestMove(
    FastBoard board,
    AiDifficulty difficulty,
    int aiPlayerIndex,
  ) {
    switch (difficulty) {
      case AiDifficulty.easy:
        return _computeEasy(board, aiPlayerIndex);
      case AiDifficulty.medium:
        return _computeMedium(board, aiPlayerIndex);
      case AiDifficulty.hard:
        return _computeHard(board, aiPlayerIndex);
      case AiDifficulty.expert:
        return _computeExpert(board, aiPlayerIndex);
    }
  }

  /// EASY: Random move, mostly. Slight bias to empty cells if available.
  static int _computeEasy(FastBoard board, int aiPlayerIndex) {
    final validMoves = board.getValidMoves(aiPlayerIndex);
    if (validMoves.isEmpty) return -1;

    final emptyMoves = validMoves
        .where((idx) => FastBoard.getOwner(board.grid[idx]) == 0)
        .toList();
    if (emptyMoves.isNotEmpty && _random.nextDouble() > 0.3) {
      return emptyMoves[_random.nextInt(emptyMoves.length)];
    }

    return validMoves[_random.nextInt(validMoves.length)];
  }

  /// MEDIUM: Greedy. Looks 1 move ahead. Picks the move yielding the best immediate board score.
  static int _computeMedium(FastBoard board, int aiPlayerIndex) {
    final validMoves = board.getValidMoves(aiPlayerIndex);
    if (validMoves.isEmpty) return -1;

    int bestMove = validMoves[0];
    double bestScore = -double.infinity;

    for (final move in validMoves) {
      final simBoard = board.clone();
      final r = move ~/ board.cols;
      final c = move % board.cols;

      simBoard.executeMove(r, c, aiPlayerIndex);
      final score = simBoard.evaluateScore(aiPlayerIndex);

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  /// HARD: Minimax with Alpha-Beta Pruning. Fixed depth 3.
  static int _computeHard(FastBoard board, int aiPlayerIndex) {
    final validMoves = board.getValidMoves(aiPlayerIndex);
    if (validMoves.isEmpty) return -1;
    if (validMoves.length == 1) return validMoves[0];

    int bestMove = validMoves[0];
    double bestScore = -double.infinity;
    const int maxDepth = 3;

    for (final move in validMoves) {
      final simBoard = board.clone();
      final r = move ~/ board.cols;
      final c = move % board.cols;

      simBoard.executeMove(r, c, aiPlayerIndex);

      double score = _minimax(
        simBoard,
        maxDepth - 1,
        false, // Next turn is enemy
        -double.infinity,
        double.infinity,
        aiPlayerIndex,
      );

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  /// EXPERT: Iterative Deepening with strict time limit.
  static int _computeExpert(FastBoard board, int aiPlayerIndex) {
    final validMoves = board.getValidMoves(aiPlayerIndex);
    if (validMoves.isEmpty) return -1;
    if (validMoves.length == 1) return validMoves[0];

    int bestMove = validMoves[0];
    _timeIsUp = false;

    // Time limit: 1400 milliseconds (to leave 100ms buffer for isolate transfer if targeting 1.5s)
    final stopwatch = Stopwatch()..start();
    const timeLimitMs = 1400;

    int currentDepth = 1;

    while (!_timeIsUp && currentDepth <= 10) {
      // Max depth cap for safety
      int currentBestMove = bestMove;
      double bestScore = -double.infinity;

      for (final move in validMoves) {
        if (stopwatch.elapsedMilliseconds > timeLimitMs) {
          _timeIsUp = true;
          break;
        }

        final simBoard = board.clone();
        final r = move ~/ board.cols;
        final c = move % board.cols;

        simBoard.executeMove(r, c, aiPlayerIndex);

        double score = _minimax(
          simBoard,
          currentDepth - 1,
          false,
          -double.infinity,
          double.infinity,
          aiPlayerIndex,
          stopwatch,
          timeLimitMs,
        );

        if (_timeIsUp) break;

        if (score > bestScore) {
          bestScore = score;
          currentBestMove = move;
        }
      }

      if (!_timeIsUp) {
        bestMove = currentBestMove;
      }

      currentDepth++;
    }

    return bestMove;
  }

  static double _minimax(
    FastBoard board,
    int depth,
    bool isMaximizing,
    double alpha,
    double beta,
    int aiPlayerIndex, [
    Stopwatch? stopwatch,
    int? timeLimitMs,
  ]) {
    if (stopwatch != null &&
        timeLimitMs != null &&
        stopwatch.elapsedMilliseconds > timeLimitMs) {
      _timeIsUp = true;
      return 0.0;
    }

    if (depth == 0 || board.checkWinCondition()) {
      return board.evaluateScore(aiPlayerIndex);
    }

    final currentPlayerIndex = isMaximizing
        ? aiPlayerIndex
        : (aiPlayerIndex == 1 ? 2 : 1);
    final validMoves = board.getValidMoves(currentPlayerIndex);

    if (validMoves.isEmpty) {
      return board.evaluateScore(aiPlayerIndex);
    }

    if (isMaximizing) {
      double maxEval = -double.infinity;
      for (final move in validMoves) {
        final simBoard = board.clone();
        simBoard.executeMove(
          move ~/ board.cols,
          move % board.cols,
          currentPlayerIndex,
        );
        double eval = _minimax(
          simBoard,
          depth - 1,
          false,
          alpha,
          beta,
          aiPlayerIndex,
          stopwatch,
          timeLimitMs,
        );
        if (_timeIsUp) return 0.0;

        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break; // Beta cutoff
      }
      return maxEval;
    } else {
      double minEval = double.infinity;
      for (final move in validMoves) {
        final simBoard = board.clone();
        simBoard.executeMove(
          move ~/ board.cols,
          move % board.cols,
          currentPlayerIndex,
        );
        double eval = _minimax(
          simBoard,
          depth - 1,
          true,
          alpha,
          beta,
          aiPlayerIndex,
          stopwatch,
          timeLimitMs,
        );
        if (_timeIsUp) return 0.0;

        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break; // Alpha cutoff
      }
      return minEval;
    }
  }
}
