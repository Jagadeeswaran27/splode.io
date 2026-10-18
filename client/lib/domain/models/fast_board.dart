import 'dart:typed_data';

/// A highly optimized 1D representation of the Splode board.
///
/// Used exclusively by the AI Engine to simulate thousands of board states
/// per second without triggering Garbage Collection pauses.
///
/// Cell Integer Encoding:
/// - Bits 0-3 (4 bits): Orb count (0 to 15)
/// - Bits 4-7 (4 bits): Owner Index (0 = None, 1 = Player 1, 2 = Player 2)
class FastBoard {
  final int rows;
  final int cols;
  final Int32List grid;
  int turnCount;
  int currentPlayerIndex;

  FastBoard({
    required this.rows,
    required this.cols,
    required this.grid,
    required this.turnCount,
    required this.currentPlayerIndex,
  });

  /// Create a fresh copy of the board for simulation branching
  FastBoard clone() {
    return FastBoard(
      rows: rows,
      cols: cols,
      grid: Int32List.fromList(grid),
      turnCount: turnCount,
      currentPlayerIndex: currentPlayerIndex,
    );
  }

  /// Convert (row, col) to 1D index
  int getIndex(int r, int c) => r * cols + c;

  /// Extract the owner index from a cell value (0 = none, 1 = P1, 2 = P2)
  static int getOwner(int cellValue) => (cellValue >> 4) & 0xF;

  /// Extract the orb count from a cell value
  static int getOrbs(int cellValue) => cellValue & 0xF;

  /// Create a new cell value
  static int createCell(int owner, int orbs) => (owner << 4) | orbs;

  /// Get the critical mass for a specific row and col
  int getCriticalMass(int r, int c) {
    int neighbors = 0;
    if (r > 0) neighbors++;
    if (r < rows - 1) neighbors++;
    if (c > 0) neighbors++;
    if (c < cols - 1) neighbors++;
    return neighbors;
  }

  /// Validates if a move is legal for the current player
  bool isValidMove(int r, int c, int playerIndex) {
    final idx = getIndex(r, c);
    final cell = grid[idx];
    final owner = getOwner(cell);
    return owner == 0 || owner == playerIndex;
  }

  /// Get all valid moves (indices) for the current player
  List<int> getValidMoves(int playerIndex) {
    final List<int> moves = [];
    for (int i = 0; i < grid.length; i++) {
      final owner = getOwner(grid[i]);
      if (owner == 0 || owner == playerIndex) {
        moves.add(i);
      }
    }
    return moves;
  }

  /// Places an orb and processes all chain reactions instantly.
  /// Returns false if the game is over.
  bool executeMove(int r, int c, int playerIndex) {
    if (!isValidMove(r, c, playerIndex)) return false;

    // Initial placement
    final idx = getIndex(r, c);
    int currentOrbs = getOrbs(grid[idx]);
    grid[idx] = createCell(playerIndex, currentOrbs + 1);

    turnCount++;

    bool settled = false;
    while (!settled) {
      settled = true;

      // Find unstable cells
      // For speed, we just scan the grid instead of maintaining lists
      // Though for larger grids, maintaining a list might be faster.
      final unstable = <int>[];
      for (int i = 0; i < grid.length; i++) {
        final r2 = i ~/ cols;
        final c2 = i % cols;
        final mass = getCriticalMass(r2, c2);
        if (getOrbs(grid[i]) >= mass) {
          unstable.add(i);
        }
      }

      if (unstable.isNotEmpty) {
        settled = false;

        // Explode
        for (final uIdx in unstable) {
          final r2 = uIdx ~/ cols;
          final c2 = uIdx % cols;
          final mass = getCriticalMass(r2, c2);

          final cell = grid[uIdx];
          final orbs = getOrbs(cell);
          // Decrease orbs, keep owner for now (cleanup later)
          grid[uIdx] = createCell(playerIndex, orbs - mass);

          // Distribute
          final neighbors = [
            if (r2 > 0) getIndex(r2 - 1, c2),
            if (r2 < rows - 1) getIndex(r2 + 1, c2),
            if (c2 > 0) getIndex(r2, c2 - 1),
            if (c2 < cols - 1) getIndex(r2, c2 + 1),
          ];

          for (final nIdx in neighbors) {
            final nOrbs = getOrbs(grid[nIdx]);
            grid[nIdx] = createCell(playerIndex, nOrbs + 1);
          }
        }

        // Cleanup owners
        for (int i = 0; i < grid.length; i++) {
          if (getOrbs(grid[i]) == 0) {
            grid[i] = 0; // Completely empty
          }
        }

        // Check win condition
        if (checkWinCondition()) {
          return true; // Game over, move processed
        }
      }
    }

    // Next player turn (assuming 2 players)
    currentPlayerIndex = (currentPlayerIndex == 1) ? 2 : 1;

    return true; // Move executed, game continues
  }

  /// Returns true if someone has won (1 owner dominates)
  bool checkWinCondition() {
    if (turnCount <= 2) return false; // Needs at least > 1 turn

    int activeOwner = 0;
    for (int i = 0; i < grid.length; i++) {
      final owner = getOwner(grid[i]);
      if (owner != 0) {
        if (activeOwner == 0) {
          activeOwner = owner;
        } else if (activeOwner != owner) {
          return false; // Found multiple owners
        }
      }
    }
    return activeOwner != 0; // Only one owner remains
  }

  /// Calculates a heuristic score for the current board from the perspective of [evaluatingPlayer].
  /// Higher is better for [evaluatingPlayer].
  double evaluateScore(int evaluatingPlayer) {
    if (checkWinCondition()) {
      // Check who won
      int activeOwner = 0;
      for (int i = 0; i < grid.length; i++) {
        final owner = getOwner(grid[i]);
        if (owner != 0) {
          activeOwner = owner;
          break;
        }
      }
      if (activeOwner == evaluatingPlayer) {
        return 10000.0; // Win
      } else {
        return -10000.0; // Loss
      }
    }

    double score = 0.0;
    final enemyPlayer = evaluatingPlayer == 1 ? 2 : 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final idx = getIndex(r, c);
        final owner = getOwner(grid[idx]);
        final orbs = getOrbs(grid[idx]);

        if (owner == 0) continue;

        double cellScore = 0;

        // Base value for orbs
        cellScore += orbs;

        // Position value (corners/edges are safer)
        final mass = getCriticalMass(r, c);
        if (mass == 2) {
          cellScore += 0.5; // Corner
        } else if (mass == 3) {
          cellScore += 0.2; // Edge
        }

        // Volatility check (is an enemy going to explode next to me?)
        bool vulnerable = false;
        final neighbors = [
          if (r > 0) getIndex(r - 1, c),
          if (r < rows - 1) getIndex(r + 1, c),
          if (c > 0) getIndex(r, c - 1),
          if (c < cols - 1) getIndex(r, c + 1),
        ];

        for (final nIdx in neighbors) {
          final nOwner = getOwner(grid[nIdx]);
          final nOrbs = getOrbs(grid[nIdx]);
          final nr = nIdx ~/ cols;
          final nc = nIdx % cols;
          if (nOwner == enemyPlayer && nOrbs == getCriticalMass(nr, nc) - 1) {
            vulnerable = true;
            break;
          }
        }

        if (vulnerable) {
          cellScore -=
              orbs * 1.5; // Heavily penalize having orbs near an unstable enemy
        }

        if (owner == evaluatingPlayer) {
          score += cellScore;
        } else {
          score -= cellScore;
        }
      }
    }

    return score;
  }
}
