import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConstellationBackground extends StatefulWidget {
  const ConstellationBackground({super.key});

  @override
  State<ConstellationBackground> createState() =>
      _ConstellationBackgroundState();
}

class _ConstellationBackgroundState extends State<ConstellationBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ConstellationPainter(animationValue: _controller.value),
        );
      },
    );
  }
}

/// A highly premium, perfectly looping constellation network that features
/// deterministic "chain reaction" explosions.
class _ConstellationPainter extends CustomPainter {
  final double animationValue;

  // Pre-seed 65 nodes for a dense but elegant network
  static final List<_Node> _nodes = _generateNodes(65, 42);

  // Deterministic explosions simulating a chain reaction
  static const List<_Explosion> _explosions = [
    // First Chain Reaction (Left to Right)
    _Explosion(x: 0.3, y: 0.6, triggerTime: 0.1),
    _Explosion(x: 0.5, y: 0.4, triggerTime: 0.18),
    _Explosion(x: 0.7, y: 0.3, triggerTime: 0.26),

    // Second Chain Reaction (Bottom Right spreading)
    _Explosion(x: 0.8, y: 0.8, triggerTime: 0.5),
    _Explosion(x: 0.6, y: 0.9, triggerTime: 0.58),
    _Explosion(x: 0.85, y: 0.5, triggerTime: 0.62),
  ];

  _ConstellationPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Calculate base positions for all nodes
    final List<Offset> positions = [];
    for (final node in _nodes) {
      final double dx =
          math.sin(animationValue * 2 * math.pi + node.phaseX) *
          node.driftRadius *
          size.width;
      final double dy =
          math.cos(animationValue * 2 * math.pi + node.phaseY) *
          node.driftRadius *
          size.height;

      positions.add(
        Offset(size.width * node.baseX + dx, size.height * node.baseY + dy),
      );
    }

    // 2. Calculate Explosion Shockwaves and Node Reactions
    final double maxExplosionRadius = size.width * 0.35;
    final List<double> nodeReactionGlows = List.filled(_nodes.length, 0.0);

    for (final exp in _explosions) {
      final Offset expPos = Offset(size.width * exp.x, size.height * exp.y);

      // Draw the shockwave ring if active
      if (animationValue >= exp.triggerTime &&
          animationValue <= exp.triggerTime + exp.duration) {
        final double progress =
            (animationValue - exp.triggerTime) / exp.duration;
        final double currentRadius = progress * maxExplosionRadius;
        // Ease out opacity
        final double alpha = math.pow(1.0 - progress, 2).toDouble() * 0.5;

        final ringPaint = Paint()
          ..color = const Color(0xFFD4A44C).withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(expPos, currentRadius, ringPaint);
      }

      // Calculate reactions for each node
      for (int i = 0; i < positions.length; i++) {
        final double dist = (positions[i] - expPos).distance;
        if (dist < maxExplosionRadius) {
          final double hitProgress = dist / maxExplosionRadius;
          final double hitTime = exp.triggerTime + (hitProgress * exp.duration);

          if (animationValue >= hitTime) {
            final double timeSinceHit = animationValue - hitTime;
            // Nodes glow for a short duration after being hit by the shockwave
            if (timeSinceHit < exp.reactionDuration) {
              final double glow = 1.0 - (timeSinceHit / exp.reactionDuration);
              // Accumulate glow if hit by multiple shockwaves
              nodeReactionGlows[i] += glow;
            }
          }
        }
      }
    }

    // 3. Draw connections (lines) between close nodes
    final double maxDistance = size.width * 0.22;

    for (int i = 0; i < positions.length; i++) {
      for (int j = i + 1; j < positions.length; j++) {
        final p1 = positions[i];
        final p2 = positions[j];

        if ((p1.dx - p2.dx).abs() > maxDistance ||
            (p1.dy - p2.dy).abs() > maxDistance) {
          continue;
        }

        final distance = (p1 - p2).distance;
        if (distance < maxDistance) {
          final double intensity = 1.0 - (distance / maxDistance);
          final double easeIntensity = math.pow(intensity, 1.5).toDouble();

          // If both connected nodes are reacting, the connection line also glows intensely
          final double reactionBoost =
              (nodeReactionGlows[i] + nodeReactionGlows[j]) * 0.5;
          final double finalAlpha = (easeIntensity * 0.4 + reactionBoost * 0.6)
              .clamp(0.0, 1.0);

          final paint = Paint()
            ..color = const Color(0xFFD4A44C).withValues(alpha: finalAlpha)
            ..strokeWidth = 0.5 + (easeIntensity * 1.5) + (reactionBoost * 2.0)
            ..style = PaintingStyle.stroke;

          canvas.drawLine(p1, p2, paint);
        }
      }
    }

    // 4. Draw the nodes
    for (int i = 0; i < positions.length; i++) {
      final node = _nodes[i];
      final pos = positions[i];
      final double reaction = nodeReactionGlows[i].clamp(0.0, 1.5);

      final double currentRadius = node.radius * (1.0 + reaction * 1.5);
      final double currentBrightness = (node.brightness + reaction).clamp(
        0.0,
        1.0,
      );

      final glowPaint = Paint()
        ..color =
            (node.isAmber ? const Color(0xFFD4A44C) : const Color(0xFFF5F0E8))
                .withValues(alpha: 0.15 * currentBrightness + (reaction * 0.3))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0 + reaction * 4.0);

      final corePaint = Paint()
        ..color =
            (node.isAmber ? const Color(0xFFD4A44C) : const Color(0xFFF5F0E8))
                .withValues(alpha: 0.5 * currentBrightness + (reaction * 0.5))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pos, currentRadius * 2.5, glowPaint);
      canvas.drawCircle(pos, currentRadius, corePaint);
    }
  }

  static List<_Node> _generateNodes(int count, int seed) {
    final rng = math.Random(seed);
    return List.generate(count, (_) {
      return _Node(
        baseX: -0.1 + rng.nextDouble() * 1.2,
        baseY: -0.1 + rng.nextDouble() * 1.2,
        phaseX: rng.nextDouble() * 2 * math.pi,
        phaseY: rng.nextDouble() * 2 * math.pi,
        driftRadius: 0.05 + rng.nextDouble() * 0.08,
        radius: 1.0 + rng.nextDouble() * 2.0,
        brightness: 0.4 + rng.nextDouble() * 0.6,
        isAmber: rng.nextBool(),
      );
    });
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class _Explosion {
  final double x;
  final double y;
  final double triggerTime;
  final double duration = 0.15;
  final double reactionDuration = 0.1;

  const _Explosion({
    required this.x,
    required this.y,
    required this.triggerTime,
  });
}

class _Node {
  final double baseX;
  final double baseY;
  final double phaseX;
  final double phaseY;
  final double driftRadius;
  final double radius;
  final double brightness;
  final bool isAmber;

  const _Node({
    required this.baseX,
    required this.baseY,
    required this.phaseX,
    required this.phaseY,
    required this.driftRadius,
    required this.radius,
    required this.brightness,
    required this.isAmber,
  });
}
