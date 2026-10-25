import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Custom painter rendering distinct tactical emblem graphics for each tutorial module.
class ModuleArtPainter extends CustomPainter {
  final String moduleId;
  final bool isUnlocked;

  const ModuleArtPainter({
    required this.moduleId,
    required this.isUnlocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final goldColor = isUnlocked ? const Color(0xFFD4A44C) : Colors.white38;
    final brightGold = isUnlocked ? const Color(0xFFFFDF7D) : Colors.white54;
    final redColor = isUnlocked ? const Color(0xFFE53935) : Colors.white38;

    switch (moduleId) {
      case 'basics':
        _paintBasics(canvas, center, goldColor, brightGold);
        break;
      case 'capturing':
        _paintCapturing(canvas, center, goldColor, redColor);
        break;
      case 'chain_reactions':
        _paintChainReactions(canvas, center, goldColor, brightGold);
        break;
      case 'edges_and_corners':
        _paintEdgesAndCorners(canvas, size, goldColor, brightGold);
        break;
      default:
        _paintBasics(canvas, center, goldColor, brightGold);
    }
  }

  /// Module 1: Single charged orb with expanding orbital rings
  void _paintBasics(
    Canvas canvas,
    Offset center,
    Color gold,
    Color brightGold,
  ) {
    // Outer dashed/dotted orbital ring
    final ringPaint = Paint()
      ..color = gold.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, 18, ringPaint);

    final innerRing = Paint()
      ..color = gold.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, 12, innerRing);

    // Glowing core orb
    final orbPaint = Paint()..color = brightGold;
    canvas.drawCircle(center, 6, orbPaint);

    // White highlight dot
    final hlPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center.translate(-2, -2), 1.8, hlPaint);
  }

  /// Module 2: Gold orb capturing & overtaking a red orb
  void _paintCapturing(
    Canvas canvas,
    Offset center,
    Color gold,
    Color red,
  ) {
    final goldCenter = center.translate(-7, 0);
    final redCenter = center.translate(8, 0);

    // Red enemy orb (being captured)
    final redPaint = Paint()..color = red.withValues(alpha: 0.7);
    canvas.drawCircle(redCenter, 5, redPaint);

    // Capture shockwave arc
    final wavePaint = Paint()
      ..color = gold.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: goldCenter, radius: 12),
      -math.pi / 3,
      2 * math.pi / 3,
      false,
      wavePaint,
    );

    // Golden player orb
    final goldPaint = Paint()..color = gold;
    canvas.drawCircle(goldCenter, 7.5, goldPaint);

    // Highlight
    final hlPaint = Paint()..color = Colors.white;
    canvas.drawCircle(goldCenter.translate(-2, -2), 2, hlPaint);
  }

  /// Module 3: 3 orbs in a cascading diagonal domino chain
  void _paintChainReactions(
    Canvas canvas,
    Offset center,
    Color gold,
    Color brightGold,
  ) {
    final p1 = center.translate(-11, 10);
    final p2 = center.translate(0, 0);
    final p3 = center.translate(11, -10);

    // Connecting energy vector line
    final linePaint = Paint()
      ..color = gold.withValues(alpha: 0.45)
      ..strokeWidth = 1.5;
    canvas.drawLine(p1, p2, linePaint);
    canvas.drawLine(p2, p3, linePaint);

    // Cascading orbs (growing in intensity)
    canvas.drawCircle(p1, 4, Paint()..color = gold.withValues(alpha: 0.6));
    canvas.drawCircle(p2, 5.5, Paint()..color = gold);
    canvas.drawCircle(p3, 7, Paint()..color = brightGold);

    // Spark highlight on final explosive orb
    canvas.drawCircle(p3.translate(-2, -2), 2, Paint()..color = Colors.white);
  }

  /// Module 4: Angular 90-degree corner fortress bracket with armed orb
  void _paintEdgesAndCorners(
    Canvas canvas,
    Size size,
    Color gold,
    Color brightGold,
  ) {
    final w = size.width;
    final h = size.height;

    // Corner bracket lines (representing board corner)
    final bracketPaint = Paint()
      ..color = gold.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(w * 0.22, h * 0.72)
      ..lineTo(w * 0.22, h * 0.28)
      ..lineTo(w * 0.72, h * 0.28);
    canvas.drawPath(path, bracketPaint);

    // Perimeter edge arrow dot
    canvas.drawCircle(
      Offset(w * 0.65, h * 0.28),
      2.5,
      Paint()..color = gold.withValues(alpha: 0.7),
    );
    canvas.drawCircle(
      Offset(w * 0.22, h * 0.65),
      2.5,
      Paint()..color = gold.withValues(alpha: 0.7),
    );

    // Armed corner fortress orb at the vertex
    final cornerPos = Offset(w * 0.38, h * 0.38);
    canvas.drawCircle(
      cornerPos,
      10,
      Paint()
        ..color = gold.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    canvas.drawCircle(cornerPos, 6.5, Paint()..color = brightGold);
    canvas.drawCircle(
      cornerPos.translate(-2, -2),
      2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant ModuleArtPainter oldDelegate) {
    return oldDelegate.moduleId != moduleId ||
        oldDelegate.isUnlocked != isUnlocked;
  }
}
