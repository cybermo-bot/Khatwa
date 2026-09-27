import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The dark stage behind the 3D hologram foot: a deep navy glow, a light ring
/// the foot floats above, two faint orbits and a few particles. Drawn once
/// (no animation), so it costs nothing next to the 3D view. The same in light
/// and dark themes: the hologram needs the dark to glow.
class HoloBackdrop extends StatelessWidget {
  /// Where the ring sits, from the top (0) to the bottom (1) of the stage.
  final double ringY;
  const HoloBackdrop({super.key, this.ringY = 0.8});

  static const navy = Color(0xFF061726);
  static const deep = Color(0xFF0B2B3F);
  static const cyan = Color(0xFF5EF2E6);

  /// Text and icons laid on the stage.
  static const ink = Color(0xFFE6FBFA);
  static const inkSoft = Color(0xB3CFEFEF);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.15),
          radius: 1.0,
          colors: [deep, navy],
        ),
      ),
      child: CustomPaint(painter: _HoloPainter(ringY), size: Size.infinite),
    );
  }
}

class _HoloPainter extends CustomPainter {
  final double ringY;
  _HoloPainter(this.ringY);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final ring = Offset(w / 2, h * ringY);
    const cyan = HoloBackdrop.cyan;

    // The beam rising from the ring into the foot.
    final beam = Rect.fromLTRB(w * 0.30, h * 0.18, w * 0.70, ring.dy);
    canvas.drawRect(
      beam,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [cyan.withAlpha(46), cyan.withAlpha(0)],
        ).createShader(beam),
    );

    // The platform: a soft pool of light and three thin rings.
    final pool = Rect.fromCenter(center: ring, width: w * 0.9, height: h * 0.16);
    canvas.drawOval(
      pool,
      Paint()
        ..shader = RadialGradient(colors: [cyan.withAlpha(70), cyan.withAlpha(0)]).createShader(pool),
    );
    for (final (k, a) in [(0.34, 150), (0.52, 90), (0.72, 45)]) {
      canvas.drawOval(
        Rect.fromCenter(center: ring, width: w * k, height: h * k * 0.2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = cyan.withAlpha(a),
      );
    }
    canvas.drawCircle(ring, 3, Paint()..color = cyan);
    canvas.drawCircle(ring, 10, Paint()..color = cyan.withAlpha(40)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Two faint orbits around the foot.
    for (final (cy, rw, rh, a) in [(0.42, 0.86, 0.16, 38), (0.6, 0.94, 0.2, 28)]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w / 2, h * cy), width: w * rw, height: h * rh),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = cyan.withAlpha(a),
      );
    }

    // Particles, placed by a fixed seed so the stage looks the same each time.
    final rnd = math.Random(7);
    for (var i = 0; i < 34; i++) {
      final p = Offset(rnd.nextDouble() * w, rnd.nextDouble() * h * 0.92);
      final r = 0.8 + rnd.nextDouble() * 1.6;
      final a = 60 + rnd.nextInt(150);
      canvas.drawCircle(p, r * 2.6, Paint()..color = cyan.withAlpha(a ~/ 6));
      canvas.drawCircle(p, r, Paint()..color = cyan.withAlpha(a));
    }
  }

  @override
  bool shouldRepaint(_HoloPainter old) => old.ringY != ringY;
}
