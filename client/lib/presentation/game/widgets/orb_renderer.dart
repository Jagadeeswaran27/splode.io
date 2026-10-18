import 'package:flutter/material.dart';

/// Shared utility that paints a single 3D orb with glow halo,
/// drop shadow, spherical gradient, and specular highlight.
///
/// Used by both [CellPainter] (for board orbs) and the flying orb
/// overlay (for in-flight orbs) to guarantee visual consistency.
class OrbRenderer {
  const OrbRenderer._();

  static void paint(Canvas canvas, Offset pos, double radius, Color baseColor) {
    // We can generate highlight and shadow from the baseColor
    final hsl = HSLColor.fromColor(baseColor);
    final highlightColor = hsl
        .withLightness((hsl.lightness + 0.3).clamp(0.0, 1.0))
        .toColor();
    final darkColor = hsl
        .withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0))
        .toColor();
    final glowColor = baseColor;

    // Outer glow halo
    canvas.drawCircle(
      pos,
      radius * 1.4,
      Paint()
        ..color = glowColor.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Drop shadow
    canvas.drawCircle(
      pos + const Offset(2, 3),
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // 3D sphere body gradient
    final bodyRect = Rect.fromCircle(center: pos, radius: radius);
    final bodyGradient = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      focal: const Alignment(-0.25, -0.3),
      focalRadius: 0.05,
      radius: 0.85,
      colors: [highlightColor, baseColor, darkColor],
      stops: const [0.0, 0.45, 1.0],
    );
    canvas.drawCircle(
      pos,
      radius,
      Paint()..shader = bodyGradient.createShader(bodyRect),
    );

    // Specular highlight
    final specCenter = pos + Offset(-radius * 0.25, -radius * 0.3);
    final specRect = Rect.fromCircle(center: specCenter, radius: radius * 0.35);
    final specGradient = RadialGradient(
      colors: [
        Colors.white.withValues(alpha: 0.7),
        Colors.white.withValues(alpha: 0.0),
      ],
    );
    canvas.drawCircle(
      specCenter,
      radius * 0.35,
      Paint()..shader = specGradient.createShader(specRect),
    );
  }
}
