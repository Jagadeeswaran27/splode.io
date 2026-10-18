import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:client/domain/models/game_state.dart';
import 'package:client/domain/models/match_config.dart';
import 'package:client/presentation/game/widgets/orb_renderer.dart';

/// Overlay that renders realistic flying-orb and explosion-burst
/// animations when cells explode. Diffs consecutive [GameState]s to
/// detect which cells lost orbs, then spawns:
///
/// 1. A radial **burst ring** at each source cell.
/// 2. **3D flying orbs** that follow a quadratic-bezier arc path to
///    each neighbor, scaling up mid-flight for a "pop" feel.
class FlyingOrbOverlay extends StatefulWidget {
  final GameState gameState;
  final MatchConfig matchConfig;
  final double cellSize;
  final double boardWidth;
  final double boardHeight;

  const FlyingOrbOverlay({
    super.key,
    required this.gameState,
    required this.matchConfig,
    required this.cellSize,
    required this.boardWidth,
    required this.boardHeight,
  });

  @override
  State<FlyingOrbOverlay> createState() => _FlyingOrbOverlayState();
}

class _FlyingOrbOverlayState extends State<FlyingOrbOverlay>
    with TickerProviderStateMixin {
  final List<_OrbFlight> _orbFlights = [];
  final List<_ExplosionBurst> _bursts = [];

  // ───────────────────── state diffing ─────────────────────────

  @override
  void didUpdateWidget(FlyingOrbOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameState != widget.gameState) {
      _detectExplosions(oldWidget.gameState, widget.gameState);
    }
  }

  void _detectExplosions(GameState prev, GameState next) {
    // Ignore board resets.
    if (prev.turnCount > next.turnCount || next.turnCount == 0) return;

    int staggerIndex = 0;

    for (int r = 0; r < prev.rows; r++) {
      for (int c = 0; c < prev.cols; c++) {
        final oldCell = prev.board[r][c];
        final newCell = next.board[r][c];
        if (oldCell.orbCount <= newCell.orbCount) continue;
        if (oldCell.ownerId == null) continue;

        final playerConfig = widget.matchConfig.players.firstWhere(
          (p) => p.id == oldCell.ownerId,
          orElse: () => widget.matchConfig.players.first,
        );
        final color = playerConfig.color;

        // ── Burst at source ──
        _spawnBurst(r, c, color);

        // ── Flying orbs to each neighbor ──
        final neighbors = [
          if (r > 0) [r - 1, c],
          if (r < prev.rows - 1) [r + 1, c],
          if (c > 0) [r, c - 1],
          if (c < prev.cols - 1) [r, c + 1],
        ];
        for (final n in neighbors) {
          _spawnOrb(r, c, n[0], n[1], color, staggerIndex);
          staggerIndex++;
        }
      }
    }

    if (staggerIndex > 0) setState(() {});
  }

  // ───────────────────── spawn helpers ─────────────────────────

  void _spawnBurst(int row, int col, Color color) {
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    final burst = _ExplosionBurst(
      row: row,
      col: col,
      color: color,
      controller: ctrl,
    );
    _bursts.add(burst);
    ctrl.forward().then((_) {
      if (!mounted) return;
      setState(() => _bursts.remove(burst));
      ctrl.dispose();
    });
  }

  void _spawnOrb(int sr, int sc, int er, int ec, Color color, int stagger) {
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    final flight = _OrbFlight(
      sr: sr,
      sc: sc,
      er: er,
      ec: ec,
      color: color,
      controller: ctrl,
    );
    _orbFlights.add(flight);

    // Slight per-orb stagger for organic feel.
    Future.delayed(Duration(milliseconds: stagger * 25), () {
      if (!mounted) return;
      ctrl.forward().then((_) {
        if (!mounted) return;
        setState(() => _orbFlights.remove(flight));
        ctrl.dispose();
      });
    });
  }

  // ──────────────────────── build ──────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.boardWidth,
      height: widget.boardHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ..._bursts.map(_buildBurst),
          ..._orbFlights.map(_buildFlyingOrb),
        ],
      ),
    );
  }

  // ── Burst ring ──

  Widget _buildBurst(_ExplosionBurst burst) {
    return AnimatedBuilder(
      animation: burst.controller,
      builder: (context, _) {
        final p = burst.controller.value;
        final cx = burst.col * widget.cellSize + widget.cellSize / 2;
        final cy = burst.row * widget.cellSize + widget.cellSize / 2;
        final radius = widget.cellSize * 0.6 * p;
        final opacity = (1.0 - p) * 0.55;
        final color = burst.color;

        return Positioned(
          left: cx - radius,
          top: cy - radius,
          width: radius * 2,
          height: radius * 2,
          child: RepaintBoundary(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _BurstPainter(color: color, opacity: opacity),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Flying orb on a bezier arc ──

  Widget _buildFlyingOrb(_OrbFlight flight) {
    return AnimatedBuilder(
      animation: flight.controller,
      builder: (context, _) {
        final t = Curves.easeInOutCubic.transform(flight.controller.value);
        final cs = widget.cellSize;
        final half = cs / 2;

        final sx = flight.sc * cs + half;
        final sy = flight.sr * cs + half;
        final ex = flight.ec * cs + half;
        final ey = flight.er * cs + half;

        // Quadratic bezier control point: arc upward from midpoint.
        final mx = (sx + ex) / 2;
        final my = (sy + ey) / 2 - cs * 0.3;

        final x = _qBez(sx, mx, ex, t);
        final y = _qBez(sy, my, ey, t);

        // Scale: swell mid-flight, shrink on arrival.
        final scale = 1.0 + math.sin(math.pi * t) * 0.35;
        final orbR = cs * 0.16 * scale;

        // Slight opacity trail at the tail end.
        final alpha = t < 0.85 ? 1.0 : (1.0 - t) / 0.15;

        return Positioned(
          left: x - orbR * 1.5,
          top: y - orbR * 1.5,
          width: orbR * 3,
          height: orbR * 3,
          child: RepaintBoundary(
            child: IgnorePointer(
              child: Opacity(
                opacity: alpha.clamp(0.0, 1.0),
                child: CustomPaint(
                  painter: _FlyingOrbPainter(color: flight.color, radius: orbR),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Quadratic bezier: (1-t)²·a + 2(1-t)t·b + t²·c
  static double _qBez(double a, double b, double c, double t) {
    final u = 1.0 - t;
    return u * u * a + 2 * u * t * b + t * t * c;
  }

  // ──────────────────────── dispose ────────────────────────────

  @override
  void dispose() {
    for (final f in _orbFlights) {
      f.controller.dispose();
    }
    for (final b in _bursts) {
      b.controller.dispose();
    }
    super.dispose();
  }
}

// ═══════════════════════ painters ═══════════════════════════════

/// Paints a single 3D orb using [OrbRenderer] (matches board orbs).
class _FlyingOrbPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _FlyingOrbPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    OrbRenderer.paint(canvas, center, radius, color);
  }

  @override
  bool shouldRepaint(_FlyingOrbPainter old) => true;
}

/// Paints a fading, expanding ring for the explosion flash.
class _BurstPainter extends CustomPainter {
  final Color color;
  final double opacity;

  const _BurstPainter({required this.color, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Filled glow
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: opacity * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Ring stroke
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_BurstPainter old) => true;
}

// ═══════════════════════ data classes ═══════════════════════════

class _OrbFlight {
  final int sr, sc, er, ec;
  final Color color;
  final AnimationController controller;
  _OrbFlight({
    required this.sr,
    required this.sc,
    required this.er,
    required this.ec,
    required this.color,
    required this.controller,
  });
}

class _ExplosionBurst {
  final int row, col;
  final Color color;
  final AnimationController controller;
  _ExplosionBurst({
    required this.row,
    required this.col,
    required this.color,
    required this.controller,
  });
}
