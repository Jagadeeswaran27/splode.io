import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:client/domain/models/game_state.dart';
import 'package:client/domain/models/match_config.dart';
import 'package:client/presentation/game/widgets/game_cell_widget.dart';
import 'package:client/presentation/game/widgets/flying_orb_overlay.dart';

/// Lays out the game grid as rows of [GameCellWidget]s, sized to
/// fit the available space while maintaining square cells.
class GameBoardWidget extends StatelessWidget {
  final GameState gameState;
  final MatchConfig matchConfig;
  final Function(int, int) onCellTapped;
  final bool Function(int row, int col)? isTutorialTarget;

  const GameBoardWidget({
    super.key,
    required this.gameState,
    required this.matchConfig,
    required this.onCellTapped,
    this.isTutorialTarget,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const margin = 16.0;
        final availableW = constraints.maxWidth - margin * 2;
        final availableH = constraints.maxHeight - margin * 2;

        final cellW = availableW / gameState.cols;
        final cellH = availableH / gameState.rows;
        final cellSize = math.min(cellW, cellH);

        return Center(
          child: SizedBox(
            width: cellSize * gameState.cols,
            height: cellSize * gameState.rows,
            child: Stack(
              children: [
                // Premium Board Background Panel
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1E1E2C).withValues(alpha: 0.95),
                        const Color(0xFF111111).withValues(alpha: 0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(
                        0xFFD4A44C,
                      ).withValues(alpha: 0.25), // Subtle Amber edge
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 40,
                        spreadRadius: 10,
                        offset: const Offset(0, 20), // Deep 3D drop shadow
                      ),
                    ],
                  ),
                ),
                // The Grid Cells
                Column(
                  children: List.generate(gameState.rows, (r) {
                    return Row(
                      children: List.generate(gameState.cols, (c) {
                        return GameCellWidget(
                          key: ValueKey('cell_${r}_$c'),
                          cell: gameState.board[r][c],
                          matchConfig: matchConfig,
                          row: r,
                          col: c,
                          cellSize: cellSize,
                          totalRows: gameState.rows,
                          totalCols: gameState.cols,
                          isLastMove:
                              gameState.lastMove?.row == r &&
                              gameState.lastMove?.col == c,
                          lastMovePlayerId:
                              (gameState.lastMove?.row == r &&
                                      gameState.lastMove?.col == c)
                                  ? gameState.lastMove?.playerId
                                  : null,
                          isTutorialTarget:
                              isTutorialTarget?.call(r, c) ?? false,
                          onTap: () => onCellTapped(r, c),
                        );
                      }),
                    );
                  }),
                ),
                // Flying Orbs (Animations)
                FlyingOrbOverlay(
                  gameState: gameState,
                  matchConfig: matchConfig,
                  cellSize: cellSize,
                  boardWidth: cellSize * gameState.cols,
                  boardHeight: cellSize * gameState.rows,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
