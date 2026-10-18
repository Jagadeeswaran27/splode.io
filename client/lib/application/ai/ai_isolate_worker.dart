import 'dart:typed_data';

import 'package:client/application/ai/ai_engine.dart';
import 'package:client/domain/models/ai_difficulty.dart';
import 'package:client/domain/models/fast_board.dart';

/// The payload sent to the isolate
class AiWorkerPayload {
  final int rows;
  final int cols;
  final Int32List gridData;
  final int turnCount;
  final int aiPlayerIndex;
  final AiDifficulty difficulty;

  AiWorkerPayload({
    required this.rows,
    required this.cols,
    required this.gridData,
    required this.turnCount,
    required this.aiPlayerIndex,
    required this.difficulty,
  });
}

/// The result returned from the isolate
class AiWorkerResult {
  final int row;
  final int col;

  AiWorkerResult(this.row, this.col);
}

/// The top-level function that runs inside the Isolate.
///
/// Note: This function must not depend on any Flutter UI or Riverpod state.
AiWorkerResult computeMoveInIsolate(AiWorkerPayload payload) {
  final fastBoard = FastBoard(
    rows: payload.rows,
    cols: payload.cols,
    grid: payload.gridData,
    turnCount: payload.turnCount,
    currentPlayerIndex: payload.aiPlayerIndex,
  );

  final bestMoveIndex = AiEngine.computeBestMove(
    fastBoard,
    payload.difficulty,
    payload.aiPlayerIndex,
  );

  if (bestMoveIndex == -1) {
    // Fallback if something goes catastrophically wrong
    return AiWorkerResult(0, 0);
  }

  final row = bestMoveIndex ~/ payload.cols;
  final col = bestMoveIndex % payload.cols;

  return AiWorkerResult(row, col);
}
