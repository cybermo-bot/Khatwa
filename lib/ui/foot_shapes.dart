import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_theme.dart';

enum FootSide { right, left }

enum FootView { sole, top }

/// The foot geometry of the app, drawn in code so it scales to any screen.
///
/// Two shapes live here and they are not the same thing:
///
///  * [outline] is the silhouette of a foot, hallux separated from the second
///    toe, toes tapering to the fifth, wide metatarsal ball, medial arch waist,
///    narrow heel. This is what the camera guide asks the person to fill.
///  * [stamp] is the plantar print, the part of the sole that actually touches
///    the ground: heel pad, lateral band, ball, and five separate toe pads with
///    the medial arch cut away. This is the mark used in the logo and the chips.
///
/// Both are built from control points on an interpolating spline (Catmull-Rom
/// converted to cubic Bezier), so the curve passes through every point instead
/// of being pulled away from it. That is why the toes stay toes at small sizes.
class FootShape {
  /// Right foot, hallux on the left, y from the toe tip down to the heel.
  static const _outlinePoints = <Offset>[
    Offset(0.500, 0.992), // heel, centre
    Offset(0.400, 0.980),
    Offset(0.320, 0.930),
    Offset(0.286, 0.855), // heel, medial corner
    Offset(0.292, 0.775),
    Offset(0.316, 0.690),
    Offset(0.332, 0.600), // medial arch, narrowest
    Offset(0.320, 0.520),
    Offset(0.272, 0.430),
    Offset(0.196, 0.340),
    Offset(0.148, 0.262), // first metatarsal head
    Offset(0.140, 0.190),
    Offset(0.158, 0.110),
    Offset(0.196, 0.048),
    Offset(0.240, 0.020), // hallux tip
    Offset(0.288, 0.038),
    Offset(0.306, 0.098),
    Offset(0.322, 0.178), // web space, hallux to second toe
    Offset(0.348, 0.126),
    Offset(0.372, 0.060),
    Offset(0.414, 0.054), // second toe
    Offset(0.438, 0.100),
    Offset(0.446, 0.156),
    Offset(0.470, 0.114),
    Offset(0.496, 0.074),
    Offset(0.534, 0.078), // third toe
    Offset(0.556, 0.120),
    Offset(0.564, 0.172),
    Offset(0.586, 0.132),
    Offset(0.610, 0.100),
    Offset(0.648, 0.108), // fourth toe
    Offset(0.666, 0.150),
    Offset(0.674, 0.198),
    Offset(0.698, 0.162),
    Offset(0.720, 0.138),
    Offset(0.756, 0.156), // fifth toe
    Offset(0.786, 0.206),
    Offset(0.824, 0.258),
    Offset(0.854, 0.330), // fifth metatarsal head
    Offset(0.862, 0.400),
    Offset(0.842, 0.480),
    Offset(0.812, 0.575),
    Offset(0.792, 0.672),
    Offset(0.780, 0.772),
    Offset(0.762, 0.872),
    Offset(0.706, 0.950),
    Offset(0.610, 0.990),
  ];

  /// The weight bearing part of the sole, arch removed.
  static const _stampPoints = <Offset>[
    Offset(0.500, 0.992),
    Offset(0.398, 0.978),
    Offset(0.318, 0.928),
    Offset(0.286, 0.852),
    Offset(0.300, 0.770),
    Offset(0.360, 0.690),
    Offset(0.470, 0.610), // the arch lifts off the ground here
    Offset(0.560, 0.520),
    Offset(0.556, 0.440),
    Offset(0.470, 0.372),
    Offset(0.330, 0.320),
    Offset(0.212, 0.290),
    Offset(0.168, 0.246),
    Offset(0.176, 0.204),
    Offset(0.260, 0.188),
    Offset(0.360, 0.190),
    Offset(0.470, 0.200),
    Offset(0.580, 0.212),
    Offset(0.680, 0.228),
    Offset(0.766, 0.250),
    Offset(0.828, 0.300),
    Offset(0.858, 0.372),
    Offset(0.842, 0.470),
    Offset(0.812, 0.575),
    Offset(0.792, 0.672),
    Offset(0.780, 0.772),
    Offset(0.762, 0.872),
    Offset(0.706, 0.950),
    Offset(0.610, 0.990),
  ];

  /// Toe pads: centre x, centre y, radius x, radius y.
  static const _toePads = <List<double>>[
    [0.228, 0.098, 0.088, 0.072],
    [0.386, 0.100, 0.055, 0.048],
    [0.512, 0.114, 0.050, 0.044],
    [0.622, 0.140, 0.045, 0.040],
    [0.716, 0.172, 0.040, 0.036],
  ];

  /// The foot silhouette.
  static Path outline(Size size, FootSide side) =>
      _spline(_outlinePoints, size, side);

  /// The plantar print: body plus the five toe pads, as one fillable path.
  static Path stamp(Size size, FootSide side) {
    final path = _spline(_stampPoints, size, side);
    for (final pad in toes(size, side)) {
      path.addOval(pad);
    }
    return path;
  }

  /// The five toe pads on their own.
  static List<Rect> toes(Size size, FootSide side) {
    final list = <Rect>[];
    for (final pad in _toePads) {
      final cx = (side == FootSide.left ? 1 - pad[0] : pad[0]) * size.width;
      final cy = pad[1] * size.height;
      list.add(Rect.fromCenter(
        center: Offset(cx, cy),
        width: pad[2] * 2 * size.width,
        height: pad[3] * 2 * size.height,
      ));
    }
    return list;
  }

  /// Two anatomical reference lines, used as faint detail on the sole view:
  /// the metatarsal line under the ball, and the medial arch curve.
  static List<List<Offset>> creases(Size size, FootSide side) {
    const metatarsal = <Offset>[
      Offset(0.180, 0.252),
      Offset(0.400, 0.226),
      Offset(0.620, 0.242),
      Offset(0.800, 0.282),
    ];
    const arch = <Offset>[
      Offset(0.330, 0.330),
      Offset(0.470, 0.420),
      Offset(0.540, 0.540),
      Offset(0.440, 0.680),
      Offset(0.330, 0.760),
    ];

    List<Offset> place(List<Offset> raw) {
      final out = <Offset>[];
      for (final p in raw) {
        out.add(Offset(
          (side == FootSide.left ? 1 - p.dx : p.dx) * size.width,
          p.dy * size.height,
        ));
      }
      return out;
    }

    return [place(metatarsal), place(arch)];
  }

  /// Closed Catmull-Rom spline, written out as cubic Bezier segments.
  /// The curve passes through every control point, which a quadratic
  /// midpoint smoother does not do.
  static Path _spline(List<Offset> raw, Size size, FootSide side) {
    const tension = 0.85;

    final pts = <Offset>[];
    for (final p in raw) {
      pts.add(Offset(
        (side == FootSide.left ? 1 - p.dx : p.dx) * size.width,
        p.dy * size.height,
      ));
    }

    final n = pts.length;
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);

    for (var i = 0; i < n; i++) {
      final p0 = pts[(i - 1 + n) % n];
      final p1 = pts[i];
      final p2 = pts[(i + 1) % n];
      final p3 = pts[(i + 2) % n];

      final c1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6 * tension,
        p1.dy + (p2.dy - p0.dy) / 6 * tension,
      );
      final c2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6 * tension,
        p2.dy - (p3.dy - p1.dy) / 6 * tension,
      );

      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }

    path.close();
    return path;
  }
}

/// Where the guide outline sits on screen. The person can move and resize it,
/// so the geometry is computed in one place and shared by the painter and by
/// the gesture handling on the capture page.
class FootFrame {
  final double scale; // 1.0 is the default size
  final Offset shift; // in logical pixels, from the centre

  const FootFrame({this.scale = 1, this.shift = Offset.zero});

  FootFrame copyWith({double? scale, Offset? shift}) =>
      FootFrame(scale: scale ?? this.scale, shift: shift ?? this.shift);

  Rect rectIn(Size size) {
    final width = math.min(size.width * 0.62, size.height * 0.42) * scale;
    final height = width * 2.05;
    return Rect.fromLTWH(
      (size.width - width) / 2 + shift.dx,
      (size.height - height) / 2 + shift.dy,
      width,
      height,
    );
  }
}

/// The camera overlay: everything outside the foot is dimmed, the outline
/// breathes while you frame, and turns solid green the moment the shot is taken.
class FootGuidePainter extends CustomPainter {
  final FootSide side;
  final FootView view;
  final double pulse; // 0..1 animation value
  final bool locked; // true right after a successful capture
  final FootFrame frame;
  final bool adjusting; // true while the person is moving or resizing it

  FootGuidePainter({
    required this.side,
    required this.view,
    required this.pulse,
    required this.locked,
    this.frame = const FootFrame(),
    this.adjusting = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = frame.rectIn(size);
    final box = Size(rect.width, rect.height);
    final origin = rect.topLeft;

    final path = FootShape.outline(box, side).shift(origin);

    // Dim everything outside the foot.
    final scrim = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addPath(path, Offset.zero)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(scrim, Paint()..color = const Color(0xCC0A1420));

    final accent = locked ? K.ok : Colors.white;

    // Soft glow inside the outline.
    canvas.drawPath(
      path,
      Paint()
        ..color = locked
            ? K.ok.withAlpha(46)
            : Colors.white.withAlpha((14 + 14 * pulse).round()),
    );

    // The outline itself.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = locked ? 4 : 2.6 + pulse * 1.4
        ..color = locked ? K.ok : accent.withAlpha((170 + 70 * pulse).round()),
    );

    if (view == FootView.sole) {
      final detail = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = (locked ? K.ok : Colors.white).withAlpha(90);

      for (final line in FootShape.creases(box, side)) {
        final crease = Path()..moveTo(line.first.dx + origin.dx, line.first.dy + origin.dy);
        for (var i = 0; i < line.length - 1; i++) {
          final a = line[i] + origin;
          final b = line[i + 1] + origin;
          final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
          crease.quadraticBezierTo(a.dx, a.dy, mid.dx, mid.dy);
        }
        canvas.drawPath(crease, detail);
      }
    } else {
      // Ankle line for the top view.
      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = (locked ? K.ok : Colors.white).withAlpha(130);
      final y = origin.dy + rect.height * 0.80;
      canvas.drawLine(
        Offset(origin.dx + rect.width * 0.26, y),
        Offset(origin.dx + rect.width * 0.74, y),
        linePaint,
      );
    }

    _brackets(canvas, rect, accent);

    // While the person is dragging or pinching, show the handles so it is
    // obvious the outline is theirs to move.
    if (adjusting && !locked) {
      final handle = Paint()..color = Colors.white.withAlpha(220);
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withAlpha(120);
      for (final corner in [
        rect.inflate(18).topLeft,
        rect.inflate(18).topRight,
        rect.inflate(18).bottomLeft,
        rect.inflate(18).bottomRight,
      ]) {
        canvas.drawCircle(corner, 5, handle);
        canvas.drawCircle(corner, 11, ring);
      }
    }
  }

  void _brackets(Canvas canvas, Rect rect, Color color) {
    final inflated = rect.inflate(18);
    const len = 26.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color.withAlpha(locked ? 235 : 150);

    void corner(Offset a, Offset b, Offset c) {
      canvas.drawLine(a, b, paint);
      canvas.drawLine(b, c, paint);
    }

    corner(
      inflated.topLeft + const Offset(0, len),
      inflated.topLeft,
      inflated.topLeft + const Offset(len, 0),
    );
    corner(
      inflated.topRight + const Offset(-len, 0),
      inflated.topRight,
      inflated.topRight + const Offset(0, len),
    );
    corner(
      inflated.bottomRight + const Offset(0, -len),
      inflated.bottomRight,
      inflated.bottomRight + const Offset(-len, 0),
    );
    corner(
      inflated.bottomLeft + const Offset(len, 0),
      inflated.bottomLeft,
      inflated.bottomLeft + const Offset(0, -len),
    );
  }

  @override
  bool shouldRepaint(covariant FootGuidePainter old) =>
      old.pulse != pulse ||
      old.locked != locked ||
      old.side != side ||
      old.view != view ||
      old.adjusting != adjusting ||
      old.frame.scale != frame.scale ||
      old.frame.shift != frame.shift;
}

/// The plantar print used in the logo, the capture chips and the history rows.
class FootBadgePainter extends CustomPainter {
  final FootSide side;
  final Color color;
  final bool filled;

  FootBadgePainter({required this.side, required this.color, this.filled = false});

  @override
  void paint(Canvas canvas, Size size) {
    final box = Size(size.width * 0.58, size.height * 0.92);
    final origin = Offset((size.width - box.width) / 2, (size.height - box.height) / 2);
    final path = FootShape.stamp(box, side).shift(origin);

    canvas.drawPath(
      path,
      Paint()
        ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant FootBadgePainter old) =>
      old.color != color || old.filled != filled || old.side != side;
}

/// Four segments that fill as the positions are captured, the Face ID cue.
class CaptureRingPainter extends CustomPainter {
  final int total;
  final List<bool> done;
  final int active;

  CaptureRingPainter({required this.total, required this.done, required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: math.min(size.width, size.height) / 2 - 4,
    );

    const gap = 0.14;
    final sweep = (2 * math.pi / total) - gap;

    for (var i = 0; i < total; i++) {
      final start = -math.pi / 2 + i * (2 * math.pi / total) + gap / 2;
      final isDone = i < done.length && done[i];

      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = isDone ? 5 : 3.5
          ..color = isDone
              ? K.ok
              : (i == active ? Colors.white : Colors.white.withAlpha(70)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CaptureRingPainter old) =>
      old.done != done || old.active != active;
}
