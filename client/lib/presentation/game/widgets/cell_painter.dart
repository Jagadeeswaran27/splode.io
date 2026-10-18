import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:client/domain/models/cell.dart';
import 'package:client/domain/models/match_config.dart';
import 'package:client/presentation/game/widgets/orb_renderer.dart';

/// Stateless [CustomPainter] that renders a single grid cell with
/// realistic 3D orbs. When [cell.orbCount] > 1, the [rotation] value
/// (radians) drives the orbital positions around the cell center.
class CellPainter extends CustomPainter {
  final Cell cell;
  final MatchConfig matchConfig;
  final double rotation;
  final double pulse;
  final int criticalMass;
  final bool isLastMove;
  final String? lastMovePlayerId;
  final bool isTutorialTarget;

  const CellPainter({
    required this.cell,
    required this.matchConfig,
    required this.rotation,
    required this.pulse,
    required this.criticalMass,
    this.isLastMove = false,
    this.lastMovePlayerId,
    this.isTutorialTarget = false,
  });

  // ──────────────────────────── paint ────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    if (cell.orbCount > 0) {
      _drawOrbs(canvas, size);
    }
  }

  // ──────────────────────── grid background ──────────────────────

  void _drawGrid(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(6),
    );

    // Faint fill
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.03)
        ..style = PaintingStyle.fill,
    );

    Color borderColor = Colors.white.withValues(alpha: 0.12);
    double strokeWidth = 1.0;

    if (isTutorialTarget) {
      // Very obvious pulsating border for the tutorial target
      final pulseAlpha = (math.sin(pulse) + 1.0) / 2.0; // 0.0 to 1.0
      borderColor = const Color(
        0xFFD4A44C,
      ).withValues(alpha: 0.5 + (0.5 * pulseAlpha));
      strokeWidth = 3.0;

      canvas.drawRRect(
        rrect,
        Paint()
          ..color = const Color(0xFFD4A44C).withValues(alpha: 0.2 * pulseAlpha)
          ..style = PaintingStyle.fill,
      );
    } else if (isLastMove) {
      Color highlightColor = Colors.white.withValues(alpha: 0.8);
      final highlightOwnerId = cell.ownerId ?? lastMovePlayerId;
      if (highlightOwnerId != null) {
        final playerConfig = matchConfig.players.firstWhere(
          (p) => p.id == highlightOwnerId,
          orElse: () => matchConfig.players.first,
        );
        highlightColor = playerConfig.color;
      }
      borderColor = highlightColor.withValues(alpha: 0.8);
      strokeWidth = 2.0;

      // Draw a glowing faint fill for the last move
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = highlightColor.withValues(alpha: 0.15)
          ..style = PaintingStyle.fill,
      );
    }

    // Border
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Near-critical glow
    if (cell.orbCount > 0 && cell.orbCount == criticalMass - 1) {
      final playerConfig = matchConfig.players.firstWhere(
        (p) => p.id == cell.ownerId,
        orElse: () => matchConfig.players.first,
      );
      final glowColor = playerConfig.color.withValues(alpha: 0.15);
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = glowColor
          ..style = PaintingStyle.fill,
      );
    }
  }

  // ──────────────────────── orb rendering ────────────────────────

  void _drawOrbs(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final orbRadius = size.width * 0.16;
    final pulseScale = 1.0 + math.sin(pulse) * 0.06;
    final r = orbRadius * pulseScale;
    final orbitRadius = size.width * 0.22;

    final positions = _orbPositions(center, orbitRadius);
    for (final pos in positions) {
      final playerConfig = matchConfig.players.firstWhere(
        (p) => p.id == (cell.ownerId ?? 'p1'),
        orElse: () => matchConfig.players.first,
      );
      OrbRenderer.paint(canvas, pos, r, playerConfig.color);
    }
  }

  /// Compute orb positions.
  ///
  /// - 1 orb  → static at [center].
  /// - 2 orbs → 180° apart, revolving.
  /// - 3 orbs → 120° apart, revolving.
  ///
  /// Formula: center + (cos(θ + i·step), sin(θ + i·step)) × orbitRadius
  List<Offset> _orbPositions(Offset center, double orbitRadius) {
    final count = cell.orbCount.clamp(1, 4);
    if (count == 1) return [center];

    final angleStep = 2 * math.pi / count;
    return List.generate(count, (i) {
      final angle = rotation + i * angleStep;
      return center +
          Offset(math.cos(angle) * orbitRadius, math.sin(angle) * orbitRadius);
    });
  }

  // ─────────────────────── shouldRepaint ─────────────────────────

  @override
  bool shouldRepaint(CellPainter oldDelegate) {
    if (oldDelegate.cell != cell ||
        oldDelegate.criticalMass != criticalMass ||
        oldDelegate.isLastMove != isLastMove ||
        oldDelegate.isTutorialTarget != isTutorialTarget) {
      return true;
    }
    // Only repaint for animation if we have orbs (for orbit + pulse).
    return cell.orbCount > 0;
  }
}
