import 'package:client/domain/models/cell.dart';
import 'package:client/domain/models/game_state.dart';
import 'package:client/domain/models/move_record.dart';

class GameEngine {
  static GameState createInitialState(
    int rows,
    int cols,
    List<String> players,
  ) {
    final board = List.generate(
      rows,
      (_) => List.generate(cols, (_) => const Cell()),
    );

    return GameState(
      board: board,
      rows: rows,
      cols: cols,
      players: players,
      currentPlayerIndex: 0,
    );
  }

  static bool isValidMove(GameState state, int row, int col, String playerId) {
    if (state.isGameOver) return false;
    if (row < 0 || row >= state.rows || col < 0 || col >= state.cols) {
      return false;
    }
    final cell = state.board[row][col];
    return cell.ownerId == null || cell.ownerId == playerId;
  }

  static int getCriticalMass(int row, int col, int maxRows, int maxCols) {
    int neighbors = 0;
    if (row > 0) neighbors++;
    if (row < maxRows - 1) neighbors++;
    if (col > 0) neighbors++;
    if (col < maxCols - 1) neighbors++;
    return neighbors;
  }

  static List<List<int>> _getUnstableCells(
    List<List<Cell>> board,
    int rows,
    int cols,
  ) {
    final List<List<int>> unstable = [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (board[r][c].orbCount >= getCriticalMass(r, c, rows, cols)) {
          unstable.add([r, c]);
        }
      }
    }
    return unstable;
  }

  static List<GameState> processMove(
    GameState initialState,
    int row,
    int col,
    String playerId,
  ) {
    if (!isValidMove(initialState, row, col, playerId)) {
      return [];
    }

    final List<GameState> steps = [];
    GameState currentState = initialState;

    // Single mutable board buffer to avoid massive GC pressure
    List<List<Cell>> buffer = currentState.cloneBoard();

    void emitState() {
      currentState = currentState.copyWith(
        board: buffer.map((r) => List<Cell>.from(r)).toList(),
      );
      steps.add(currentState);
    }

    // 1. Initial Placement
    buffer[row][col] = buffer[row][col].copyWith(
      ownerId: () => playerId,
      orbCount: buffer[row][col].orbCount + 1,
    );

    List<List<int>> unstableCells = _getUnstableCells(
      buffer,
      currentState.rows,
      currentState.cols,
    );

    currentState = currentState.copyWith(
      turnCount: currentState.turnCount + 1,
      lastMove: () => MoveRecord(
        playerId: playerId,
        row: row,
        col: col,
        turnNumber: currentState.turnCount + 1,
        causedExplosion: unstableCells.isNotEmpty,
      ),
    );
    emitState();

    while (unstableCells.isNotEmpty) {
      // Phase 1: Explode (remove orbs from unstable cells)
      for (final cellPos in unstableCells) {
        final r = cellPos[0];
        final c = cellPos[1];
        final criticalMass = getCriticalMass(
          r,
          c,
          currentState.rows,
          currentState.cols,
        );

        buffer[r][c] = buffer[r][c].copyWith(
          orbCount: buffer[r][c].orbCount - criticalMass,
        );
      }

      emitState(); // Intermediate state: Orbs are "in flight"

      // Phase 2: Distribute (add orbs to neighbors)
      for (final cellPos in unstableCells) {
        final r = cellPos[0];
        final c = cellPos[1];

        final neighbors = [
          if (r > 0) [r - 1, c],
          if (r < currentState.rows - 1) [r + 1, c],
          if (c > 0) [r, c - 1],
          if (c < currentState.cols - 1) [r, c + 1],
        ];

        for (final n in neighbors) {
          final nr = n[0];
          final nc = n[1];
          buffer[nr][nc] = buffer[nr][nc].copyWith(
            ownerId: () => playerId,
            orbCount: buffer[nr][nc].orbCount + 1,
          );
        }
      }

      // Cleanup owners if orbCount is 0
      for (int r = 0; r < currentState.rows; r++) {
        for (int c = 0; c < currentState.cols; c++) {
          if (buffer[r][c].orbCount == 0 && buffer[r][c].ownerId != null) {
            buffer[r][c] = buffer[r][c].copyWith(ownerId: () => null);
          } else if (buffer[r][c].orbCount > 0 &&
              buffer[r][c].ownerId == null) {
            buffer[r][c] = buffer[r][c].copyWith(ownerId: () => playerId);
          }
        }
      }

      emitState(); // Settled state: Orbs have landed

      if (_checkWinCondition(currentState)) {
        currentState = _applyWinCondition(currentState);
        steps[steps.length - 1] =
            currentState; // Update last step to include win state
        break;
      }

      unstableCells = _getUnstableCells(
        buffer,
        currentState.rows,
        currentState.cols,
      );
    }

    // Switch turn
    if (!currentState.isGameOver) {
      final finalState = currentState.copyWith(
        currentPlayerIndex:
            (currentState.currentPlayerIndex + 1) % currentState.players.length,
      );
      steps[steps.length - 1] = finalState;
    }

    return steps;
  }

  static bool _checkWinCondition(GameState state) {
    if (state.turnCount <= 1 || state.isTutorial) return false;

    final activePlayers = <String>{};
    for (int r = 0; r < state.rows; r++) {
      for (int c = 0; c < state.cols; c++) {
        final owner = state.board[r][c].ownerId;
        if (owner != null) {
          activePlayers.add(owner);
        }
      }
    }

    return activePlayers.length == 1 && state.turnCount > state.players.length;
  }

  static GameState _applyWinCondition(GameState state) {
    String? winner;
    for (int r = 0; r < state.rows; r++) {
      for (int c = 0; c < state.cols; c++) {
        final owner = state.board[r][c].ownerId;
        if (owner != null) {
          winner = owner;
          break;
        }
      }
      if (winner != null) break;
    }

    return state.copyWith(isGameOver: true, winner: () => winner);
  }
}
