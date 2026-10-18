import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:client/domain/engine/game_engine.dart';
import 'package:client/domain/models/cell.dart';
import 'package:client/domain/models/match_config.dart';
import 'package:client/presentation/game/widgets/cell_painter.dart';
import 'package:client/presentation/game/widgets/tutorial_hand_pointer.dart';

/// A single grid cell that uses a looping [AnimationController] and
/// [AnimatedBuilder] to continuously orbit its orbs when count > 1.
///
/// The [AnimationController] acts as the single animation driver:
///   rotation = controller.value × 2π
///   pulse    = controller.value × 2π × 2
///
/// The [CellPainter] (a stateless CustomPainter) computes orb positions
/// from the current rotation using basic trigonometry (cos/sin).
class GameCellWidget extends StatefulWidget {
  final Cell cell;
  final MatchConfig matchConfig;
  final int row;
  final int col;
  final double cellSize;
  final int totalRows;
  final int totalCols;
  final bool isLastMove;
  final String? lastMovePlayerId;
  final bool isTutorialTarget;
  final VoidCallback onTap;

  const GameCellWidget({
    super.key,
    required this.cell,
    required this.matchConfig,
    required this.row,
    required this.col,
    required this.cellSize,
    required this.totalRows,
    required this.totalCols,
    this.isLastMove = false,
    this.lastMovePlayerId,
    this.isTutorialTarget = false,
    required this.onTap,
  });

  @override
  State<GameCellWidget> createState() => _GameCellWidgetState();
}

class _GameCellWidgetState extends State<GameCellWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.cell.orbCount > 0 || widget.isTutorialTarget) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(GameCellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldAnimate = widget.cell.orbCount > 0 || widget.isTutorialTarget;
    if (shouldAnimate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldAnimate && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final rotation = _controller.value * 2 * math.pi;
          final pulse = _controller.value * 2 * math.pi * 2;

          return Stack(
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  size: Size(widget.cellSize, widget.cellSize),
                  painter: CellPainter(
                    cell: widget.cell,
                    matchConfig: widget.matchConfig,
                    rotation: rotation,
                    pulse: pulse,
                    criticalMass: GameEngine.getCriticalMass(
                      widget.row,
                      widget.col,
                      widget.totalRows,
                      widget.totalCols,
                    ),
                    isLastMove: widget.isLastMove,
                    lastMovePlayerId: widget.lastMovePlayerId,
                    isTutorialTarget: widget.isTutorialTarget,
                  ),
                ),
              ),
              if (widget.isTutorialTarget)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: TutorialHandPointer(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
