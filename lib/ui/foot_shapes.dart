import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_theme.dart';

enum FootSide { right, left }

enum FootView { sole, top }

/// Where the scan frame sits on screen. The person can move and resize it,
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

/// The camera overlay: everything outside the scan frame is dimmed, the
/// frame's corners breathe while you aim, and the frame turns solid green the
/// moment the shot is taken. The foot inside is shown by the map image placed
/// over the frame by the capture page, not drawn here.
class ScanFramePainter extends CustomPainter {
  final double pulse; // 0..1 animation value
  final bool locked; // true right after a successful capture
  final FootFrame frame;
  final bool adjusting; // true while the person is moving or resizing it

  ScanFramePainter({
    required this.pulse,
    required this.locked,
    this.frame = const FootFrame(),
    this.adjusting = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = frame.rectIn(size);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(K.r28));

    // Dim the world outside the frame.
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Offset.zero & size)
        ..addRRect(rrect),
      Paint()..color = Colors.black.withAlpha(locked ? 150 : 120),
    );

    final color = locked
        ? K.ok
        : Color.lerp(const Color(0xFF19C3B5), Colors.white, 0.35 * pulse)!;

    // Hairline edge, then bright corners.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = locked ? 3 : 1
        ..color = color.withAlpha(locked ? 255 : (adjusting ? 200 : 110)),
    );
    if (!locked) {
      // Soft glow that breathes.
      canvas.drawRRect(
        rrect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..color = color.withAlpha((30 + 40 * pulse).round())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    final arm = math.min(rect.width, rect.height) * 0.16;
    final corner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = color;
    const r = K.r28;
    for (final (c, sx, sy) in [
      (rect.topLeft, 1.0, 1.0),
      (rect.topRight, -1.0, 1.0),
      (rect.bottomLeft, 1.0, -1.0),
      (rect.bottomRight, -1.0, -1.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy + sy * (r + arm))
          ..lineTo(c.dx, c.dy + sy * r)
          ..arcToPoint(Offset(c.dx + sx * r, c.dy),
              radius: const Radius.circular(r), clockwise: sx * sy > 0)
          ..lineTo(c.dx + sx * (r + arm), c.dy),
        corner,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScanFramePainter old) =>
      old.pulse != pulse ||
      old.locked != locked ||
      old.adjusting != adjusting ||
      old.frame.scale != frame.scale ||
      old.frame.shift != frame.shift;
}

/// Four segments that fill as the positions are captured, the Face ID cue.
class CaptureRingPainter extends CustomPainter {
  final int total;
  final List<bool> done;
  final int active;

  CaptureRingPainter(
      {required this.total, required this.done, required this.active});

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
