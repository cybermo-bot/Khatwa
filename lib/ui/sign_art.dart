import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'foot_art.dart';
import 'foot_shapes.dart';

/// Authored, schematic illustrations of what each warning sign and each care
/// act looks like, drawn in code on the patient's own skin tone.
///
/// These are teaching drawings, not clinical photographs: they show the shape,
/// place and colour of a sign so a patient can recognise it. They are drawn,
/// never generated from or presented as real patient images.
enum ArtKind {
  dryskin,
  heelCracks,
  callus,
  corn,
  blister,
  fungus,
  nails,
  redness,
  swelling,
  colour,
  wound,
  numbness,
  wash,
  dry,
  moisturise,
  nailCare,
  shoes,
  move,
}

ArtKind? artFor(String articleId) {
  const map = {
    'dry-skin': ArtKind.dryskin,
    'heel-cracks': ArtKind.heelCracks,
    'callus': ArtKind.callus,
    'corn': ArtKind.corn,
    'blister': ArtKind.blister,
    'fungus': ArtKind.fungus,
    'nails': ArtKind.nails,
    'redness': ArtKind.redness,
    'swelling': ArtKind.swelling,
    'colour': ArtKind.colour,
    'wound': ArtKind.wound,
    'numbness': ArtKind.numbness,
    'wash': ArtKind.wash,
    'dry': ArtKind.dry,
    'moisturise': ArtKind.moisturise,
    'nail-care': ArtKind.nailCare,
    'socks-shoes': ArtKind.shoes,
    'move': ArtKind.move,
  };
  return map[articleId];
}

class SignArt extends StatelessWidget {
  final ArtKind kind;
  final double pulse;
  final Color? ground;

  const SignArt({super.key, required this.kind, this.pulse = 0, this.ground});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SignPainter(
        kind: kind,
        tone: SkinTone.current,
        ground: ground ?? K.primarySoft,
        pulse: pulse,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _Frame {
  final FootView view;
  final Rect focus; // normalised foot coordinates to fill the canvas
  const _Frame(this.view, this.focus);
}

const _whole = Rect.fromLTRB(0.04, 0.0, 0.96, 1.0);
const _toes = Rect.fromLTRB(0.06, 0.0, 0.94, 0.36);
const _forefoot = Rect.fromLTRB(0.06, 0.10, 0.94, 0.50);
const _heel = Rect.fromLTRB(0.18, 0.60, 0.88, 1.0);

const _frames = <ArtKind, _Frame>{
  ArtKind.dryskin: _Frame(FootView.sole, Rect.fromLTRB(0.14, 0.48, 0.90, 1.0)),
  ArtKind.heelCracks: _Frame(FootView.sole, _heel),
  ArtKind.callus: _Frame(FootView.sole, _forefoot),
  ArtKind.corn: _Frame(FootView.top, _toes),
  ArtKind.blister: _Frame(FootView.top, _toes),
  ArtKind.fungus: _Frame(FootView.top, Rect.fromLTRB(0.14, 0.02, 0.84, 0.30)),
  ArtKind.nails: _Frame(FootView.top, _toes),
  ArtKind.redness: _Frame(FootView.top, Rect.fromLTRB(0.04, 0.0, 0.96, 0.72)),
  ArtKind.swelling: _Frame(FootView.top, Rect.fromLTRB(-0.06, 0.0, 1.06, 1.0)),
  ArtKind.colour: _Frame(FootView.top, Rect.fromLTRB(0.06, 0.0, 0.94, 0.46)),
  ArtKind.wound: _Frame(FootView.sole, _forefoot),
  ArtKind.numbness: _Frame(FootView.sole, _whole),
  ArtKind.wash: _Frame(FootView.top, _whole),
  ArtKind.dry: _Frame(FootView.top, Rect.fromLTRB(0.14, 0.02, 0.84, 0.30)),
  ArtKind.moisturise: _Frame(FootView.sole, _whole),
  ArtKind.nailCare: _Frame(FootView.top, _toes),
  ArtKind.move: _Frame(FootView.top, Rect.fromLTRB(-0.10, -0.06, 1.10, 1.06)),
};

// Toe pads (right foot): centre x, centre y, radius x, radius y, as in FootShape.
const _pads = <List<double>>[
  [0.228, 0.098, 0.088, 0.072],
  [0.386, 0.100, 0.055, 0.048],
  [0.512, 0.114, 0.050, 0.044],
  [0.622, 0.140, 0.045, 0.040],
  [0.716, 0.172, 0.040, 0.036],
];

// The spaces between the toes, seen from above.
const _webs = <Offset>[
  Offset(0.307, 0.150),
  Offset(0.449, 0.158),
  Offset(0.567, 0.178),
  Offset(0.669, 0.204),
];

const _ink = Color(0xFF14232A);
const _crack = Color(0xFF6B2A20);
const _blood = Color(0xFFB53A2F);
const _callusHue = Color(0xFFE6CC86);
const _macerated = Color(0xFFF4F1E6);
const _dusky = Color(0xFF5D4A8A);
const _woundBase = Color(0xFFC0463E);
const _woundDeep = Color(0xFF7E2320);
const _slough = Color(0xFFE2C35A);
const _waterHue = Color(0xFF6FB3C2);

class SignPainter extends CustomPainter {
  final ArtKind kind;
  final SkinTone tone;
  final Color ground;
  final double pulse;

  SignPainter(
      {required this.kind,
      required this.tone,
      required this.ground,
      this.pulse = 0});

  late Size _f; // foot size in canvas pixels

  Offset o(double x, double y) => Offset(x * _f.width, y * _f.height);
  double w(double v) => v * _f.width;
  double h(double v) => v * _f.height;

  Color get _callus =>
      Color.lerp(tone.base, _callusHue, tone.isDeep ? 0.35 : 0.55)!;
  Color get _flush =>
      tone.isDeep ? const Color(0xFF5A1E2E) : const Color(0xFFD9473F);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    if (kind == ArtKind.shoes) {
      _shoe(canvas, size);
      canvas.restore();
      return;
    }

    if (_pairKinds.contains(kind)) {
      _pair(canvas, size);
    } else {
      final frame = _frames[kind]!;
      final f = frame.focus;
      final unitW = f.width * 0.56;
      final unitH = f.height;
      final k = math.min(size.width * 0.9 / unitW, size.height * 0.9 / unitH);
      _f = Size(0.56 * k, k);
      canvas.translate(
        size.width / 2 - f.center.dx * _f.width,
        size.height / 2 - f.center.dy * _f.height,
      );
      _foot(canvas, frame.view, swollen: false, overlays: true);
    }
    canvas.restore();

    if (kind == ArtKind.wash) _badge(canvas, size, '< 37 °C');
  }

  /// Whole-foot subjects are shown as a pair, the person's own view: left
  /// foot on the left. Swelling is about one foot being bigger than the other,
  /// so the right foot is drawn swollen next to a normal left foot.
  static const _pairKinds = {
    ArtKind.swelling,
    ArtKind.numbness,
    ArtKind.wash,
    ArtKind.moisturise,
    ArtKind.move,
  };

  void _pair(Canvas canvas, Size size) {
    final view = _frames[kind]!.view;
    final fh = size.height * (kind == ArtKind.move ? 0.74 : 0.86);
    final fw = fh * 0.56;
    final gap = fh * (kind == ArtKind.swelling ? 0.16 : 0.08);
    final total = fw * 2 + gap;
    final left = (size.width - total) / 2;
    final top = (size.height - fh) / 2;
    _f = Size(fw, fh);

    for (final isLeft in [true, false]) {
      canvas.save();
      canvas.translate(isLeft ? left : left + fw + gap, top);
      if (isLeft) {
        // Mirror the right foot to draw the left one; overlays mirror with it.
        canvas.translate(fw, 0);
        canvas.scale(-1, 1);
      }
      final swollen = kind == ArtKind.swelling && !isLeft;
      final overlays = kind != ArtKind.move || !isLeft;
      _foot(canvas, view,
          swollen: swollen, overlays: overlays && kind != ArtKind.wash);
      canvas.restore();
    }

    if (kind == ArtKind.wash) {
      _water(canvas, size, top + fh * 0.64);
    }
  }

  void _foot(Canvas canvas, FootView view,
      {required bool swollen, required bool overlays}) {
    final outline = FootShape.outline(_f, FootSide.right);
    if (swollen) {
      canvas.save();
      final c = o(0.52, 0.56);
      canvas.translate(c.dx, c.dy);
      canvas.scale(1.2, 1.03);
      canvas.translate(-c.dx, -c.dy);
      FootArtPainter(
              side: FootSide.right,
              view: view,
              tone: tone,
              ground: ground,
              tendon: false)
          .paint(canvas, _f);
      // Tight, shiny skin.
      canvas.drawOval(
        Rect.fromCenter(center: o(0.52, 0.46), width: w(0.36), height: h(0.26)),
        Paint()
          ..color = Colors.white.withAlpha(70)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w(0.06)),
      );
      canvas.restore();
      // The normal size, for comparison.
      _dashed(canvas, outline, _ink.withAlpha(170), math.max(1.4, w(0.014)));
      return;
    }
    FootArtPainter(side: FootSide.right, view: view, tone: tone, ground: ground)
        .paint(canvas, _f);
    if (!overlays) return;
    canvas.save();
    canvas.clipPath(outline);
    _inside(canvas);
    canvas.restore();
    _outside(canvas);
  }

  void _water(Canvas canvas, Size size, double top) {
    final amp = size.height * 0.018;
    final water = Path()..moveTo(0, top);
    const waves = 6;
    for (var i = 0; i < waves; i++) {
      final x0 = size.width * i / waves;
      final x1 = size.width * (i + 1) / waves;
      water.quadraticBezierTo(
          (x0 + x1) / 2, top + (i.isEven ? -amp : amp), x1, top);
    }
    water
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(water, Paint()..color = _waterHue.withAlpha(110));
    final crest = Path()..moveTo(0, top);
    for (var i = 0; i < waves; i++) {
      final x0 = size.width * i / waves;
      final x1 = size.width * (i + 1) / waves;
      crest.quadraticBezierTo(
          (x0 + x1) / 2, top + (i.isEven ? -amp : amp), x1, top);
    }
    canvas.drawPath(
      crest,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.6, size.height * 0.008)
        ..color = _waterHue.withAlpha(235),
    );
  }

  /// Marks drawn on the skin, clipped to the foot.
  void _inside(Canvas canvas) {
    final rnd = math.Random(kind.index * 31 + 7);
    switch (kind) {
      case ArtKind.dryskin:
        final crazing = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.0, w(0.008))
          ..strokeCap = StrokeCap.round
          ..color = tone.shade.withAlpha(130);
        for (var i = 0; i < 46; i++) {
          final a = rnd.nextDouble() * math.pi * 2;
          final r = math.sqrt(rnd.nextDouble());
          var p =
              o(0.53 + math.cos(a) * r * 0.27, 0.80 + math.sin(a) * r * 0.17);
          final path = Path()..moveTo(p.dx, p.dy);
          for (var s = 0; s < 3; s++) {
            p = p.translate((rnd.nextDouble() - 0.5) * w(0.07),
                (rnd.nextDouble() - 0.5) * h(0.035));
            path.lineTo(p.dx, p.dy);
          }
          canvas.drawPath(path, crazing);
        }
        final flake = Paint()
          ..color = Color.lerp(tone.light, Colors.white, 0.55)!.withAlpha(215);
        for (var i = 0; i < 34; i++) {
          final a = rnd.nextDouble() * math.pi * 2;
          final r = math.sqrt(rnd.nextDouble());
          final c =
              o(0.53 + math.cos(a) * r * 0.26, 0.79 + math.sin(a) * r * 0.16);
          canvas.save();
          canvas.translate(c.dx, c.dy);
          canvas.rotate(rnd.nextDouble() * math.pi);
          canvas.drawOval(
            Rect.fromCenter(
                center: Offset.zero,
                width: w(0.02 + rnd.nextDouble() * 0.03),
                height: h(0.006 + rnd.nextDouble() * 0.008)),
            flake,
          );
          canvas.restore();
        }
      case ArtKind.heelCracks:
        canvas.drawPath(
          FootShape.outline(_f, FootSide.right),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = w(0.13)
            ..color = _callus.withAlpha(190)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, w(0.02)),
        );
        final crack = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.6, w(0.018))
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = _crack.withAlpha(210);
        final centre = o(0.53, 0.84);
        for (var i = 0; i < 7; i++) {
          final a = math.pi * (0.12 + i * 0.13);
          var p = centre + Offset(math.cos(a) * w(0.26), math.sin(a) * h(0.15));
          final path = Path()..moveTo(p.dx, p.dy);
          final depth = 3 + rnd.nextInt(2);
          for (var s = 0; s < depth; s++) {
            final toward = (centre - p) * (0.12 + rnd.nextDouble() * 0.06);
            p = p + toward + Offset((rnd.nextDouble() - 0.5) * w(0.03), 0);
            path.lineTo(p.dx, p.dy);
          }
          canvas.drawPath(path, crack);
          if (i == 3) {
            canvas.drawPath(
              path,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = math.max(0.8, w(0.007))
                ..color = _blood,
            );
          }
        }
      case ArtKind.callus:
        final rect = Rect.fromCenter(
            center: o(0.45, 0.28), width: w(0.42), height: h(0.12));
        canvas.drawOval(
          rect,
          Paint()
            ..color = _callus
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, w(0.02)),
        );
        final rings = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.8, w(0.006))
          ..color = tone.shade.withAlpha(70);
        for (var i = 1; i <= 3; i++) {
          canvas.drawOval(rect.deflate(i * w(0.03)), rings);
        }
        canvas.drawOval(
          Rect.fromCenter(
              center: o(0.40, 0.265), width: w(0.12), height: h(0.025)),
          Paint()..color = Colors.white.withAlpha(70),
        );
      case ArtKind.corn:
        for (final c in [o(0.72, 0.19), o(0.40, 0.15)]) {
          final r = w(0.05);
          canvas.drawCircle(
              c, r * 1.5, Paint()..color = _callus.withAlpha(200));
          canvas.drawCircle(
              c,
              r * 0.8,
              Paint()
                ..color =
                    Color.lerp(_callus, Colors.white, 0.45)!.withAlpha(235));
          canvas.drawCircle(
            c,
            r * 0.8,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = math.max(1.0, w(0.008))
              ..color = tone.shade,
          );
          canvas.drawCircle(
              c, r * 0.22, Paint()..color = tone.shade.withAlpha(200));
        }
      case ArtKind.blister:
        final c = o(0.235, 0.13);
        canvas.drawOval(
          Rect.fromCenter(center: c, width: w(0.2), height: h(0.08)),
          Paint()
            ..color = const Color(0xFFD9473F).withAlpha(tone.isDeep ? 70 : 90)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, w(0.02)),
        );
        final dome =
            Rect.fromCenter(center: c, width: w(0.14), height: h(0.055));
        canvas.drawOval(dome.shift(Offset(0, h(0.008))),
            Paint()..color = tone.shade.withAlpha(120));
        canvas.drawOval(dome, Paint()..color = Colors.white.withAlpha(150));
        canvas.drawOval(
          dome,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1.0, w(0.01))
            ..color = Colors.white.withAlpha(230),
        );
        canvas.drawArc(
            dome.deflate(w(0.02)),
            math.pi * 1.05,
            math.pi * 0.55,
            false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = math.max(1.4, w(0.014))
              ..color = Colors.white);
      case ArtKind.fungus:
        for (final (i, web) in _webs.indexed) {
          if (i == 0) continue;
          final strength = i == 1 ? 0.6 : 1.0;
          for (var b = 0; b < 6; b++) {
            final c = o(web.dx + (rnd.nextDouble() - 0.5) * 0.05,
                web.dy + (rnd.nextDouble() - 0.4) * 0.05);
            canvas.drawOval(
              Rect.fromCenter(
                  center: c,
                  width: w(0.035 + rnd.nextDouble() * 0.03),
                  height: h(0.02 + rnd.nextDouble() * 0.015)),
              Paint()..color = _macerated.withAlpha((230 * strength).round()),
            );
          }
          final peel = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(0.8, w(0.006))
            ..color = tone.shade.withAlpha(140);
          for (var e = 0; e < 3; e++) {
            final c = o(web.dx + (rnd.nextDouble() - 0.5) * 0.06,
                web.dy + (rnd.nextDouble() - 0.3) * 0.05);
            canvas.drawArc(Rect.fromCircle(center: c, radius: w(0.018)),
                rnd.nextDouble() * 6, 2.2, false, peel);
          }
        }
        final fissure = _webs[3];
        canvas.drawLine(
            o(fissure.dx - 0.01, fissure.dy - 0.015),
            o(fissure.dx + 0.012, fissure.dy + 0.02),
            Paint()
              ..strokeWidth = math.max(1.0, w(0.009))
              ..strokeCap = StrokeCap.round
              ..color = _blood.withAlpha(200));
      case ArtKind.nails:
        final hallux = _padRect(0);
        final nail = FootArtPainter.nailRect(hallux).inflate(w(0.012));
        canvas.drawRRect(nail, Paint()..color = const Color(0xFFCDA54E));
        final ridge = Paint()
          ..strokeWidth = math.max(0.8, w(0.006))
          ..color = const Color(0xFF93702E).withAlpha(200);
        for (var i = 1; i <= 3; i++) {
          final x = nail.left + nail.width * i / 4;
          canvas.drawLine(Offset(x, nail.top + nail.height * 0.15),
              Offset(x, nail.bottom - nail.height * 0.1), ridge);
        }
        // Ingrown edge: the skin fold beside the nail is red and swollen.
        canvas.drawArc(
          Rect.fromCenter(
              center: nail.outerRect.centerRight,
              width: w(0.06),
              height: nail.height * 1.2),
          -math.pi / 2,
          math.pi,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = w(0.025)
            ..color = _flush.withAlpha(170)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, w(0.006)),
        );
        final fourth = FootArtPainter.nailRect(_padRect(3));
        canvas.drawRRect(
            fourth, Paint()..color = const Color(0xFFCDA54E).withAlpha(220));
      case ArtKind.redness:
        final c = o(0.36, 0.34);
        canvas.drawOval(
          Rect.fromCenter(center: c, width: w(0.6), height: h(0.3)),
          Paint()
            ..shader = RadialGradient(colors: [
              _flush.withAlpha(tone.isDeep ? 170 : 150),
              _flush.withAlpha(0),
            ]).createShader(
                Rect.fromCenter(center: c, width: w(0.6), height: h(0.3))),
        );
      case ArtKind.colour:
        final toes = Rect.fromLTWH(0, 0, _f.width, h(0.32));
        canvas.drawRect(
          toes,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _dusky.withAlpha(tone.isDeep ? 150 : 170),
                _dusky.withAlpha(0)
              ],
            ).createShader(toes),
        );
        final spot = o(0.386, 0.075);
        canvas.drawCircle(spot, w(0.05),
            Paint()..color = const Color(0xFF4A2A22).withAlpha(120));
        canvas.drawCircle(
            spot, w(0.03), Paint()..color = const Color(0xFF231A1C));
      case ArtKind.wound:
        final c = o(0.27, 0.28);
        canvas.drawCircle(
          c,
          w(0.16),
          Paint()
            ..color = _flush.withAlpha(tone.isDeep ? 80 : 60)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, w(0.04)),
        );
        final crater =
            Rect.fromCenter(center: c, width: w(0.18), height: h(0.07));
        canvas.drawOval(
          crater.inflate(w(0.025)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = w(0.03)
            ..color = _callus,
        );
        canvas.drawOval(crater, Paint()..color = _woundBase);
        canvas.drawOval(crater.deflate(w(0.03)),
            Paint()..color = _woundDeep.withAlpha(200));
        for (final s in [
          const Offset(-0.03, -0.006),
          const Offset(0.025, 0.008),
          const Offset(0.005, -0.012)
        ]) {
          canvas.drawCircle(
              c + o(s.dx, s.dy), w(0.012), Paint()..color = _slough);
        }
        canvas.drawArc(
            crater.deflate(w(0.01)),
            math.pi * 1.15,
            math.pi * 0.4,
            false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = math.max(1.0, w(0.01))
              ..color = Colors.white.withAlpha(140));
      case ArtKind.moisturise:
        final cream = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = w(0.07)
          ..color = Colors.white.withAlpha(120)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w(0.02));
        canvas.drawArc(
            Rect.fromCenter(
                center: o(0.53, 0.85), width: w(0.4), height: h(0.14)),
            0.2,
            2.6,
            false,
            cream);
        canvas.drawArc(
            Rect.fromCenter(
                center: o(0.5, 0.30), width: w(0.55), height: h(0.12)),
            3.4,
            2.6,
            false,
            cream);
      default:
        break;
    }
  }

  /// Markers and guides drawn over the foot.
  void _outside(Canvas canvas) {
    switch (kind) {
      case ArtKind.redness:
        _dashed(
          canvas,
          Path()
            ..addOval(Rect.fromCenter(
                center: o(0.36, 0.34), width: w(0.5), height: h(0.24))),
          _ink.withAlpha(150),
          math.max(1.2, w(0.01)),
        );
      case ArtKind.numbness:
        const sites = [
          Offset(0.23, 0.09),
          Offset(0.51, 0.11),
          Offset(0.72, 0.17),
          Offset(0.26, 0.28),
          Offset(0.52, 0.26),
          Offset(0.79, 0.33),
          Offset(0.40, 0.55),
          Offset(0.74, 0.56),
          Offset(0.53, 0.88),
        ];
        for (final s in sites) {
          final c = o(s.dx, s.dy);
          canvas.drawCircle(
              c, w(0.045), Paint()..color = Colors.white.withAlpha(235));
          canvas.drawCircle(
            c,
            w(0.045),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = math.max(1.2, w(0.012))
              ..color = _ink,
          );
          canvas.drawCircle(c, w(0.012), Paint()..color = _ink);
        }
      case ArtKind.dry:
        for (final web in _webs) {
          paintZoneMarker(
              canvas, o(web.dx, web.dy + 0.012), w(0.04), pulse, kMarkerOnSkin);
        }
      case ArtKind.moisturise:
        // Not between the toes.
        final c = o(0.46, 0.20);
        final r = w(0.07);
        canvas.drawCircle(c, r, Paint()..color = Colors.white.withAlpha(230));
        final no = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.6, w(0.016))
          ..color = _ink;
        canvas.drawCircle(c, r, no);
        canvas.drawLine(
            c + Offset(-r * 0.7, -r * 0.7), c + Offset(r * 0.7, r * 0.7), no);
      case ArtKind.nailCare:
        final nail = FootArtPainter.nailRect(_padRect(0));
        final y = nail.top + nail.height * 0.3;
        final path = Path()
          ..moveTo(nail.left - w(0.05), y)
          ..lineTo(nail.right + w(0.05), y);
        _dashed(canvas, path, kMarkerOnSkin, math.max(1.6, w(0.014)));
      case ArtKind.move:
        final arrow = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2.0, w(0.022))
          ..strokeCap = StrokeCap.round
          ..color = kMarkerOnSkin;
        final ring = Rect.fromCenter(
            center: o(0.53, 0.86), width: w(1.0), height: h(0.26));
        canvas.drawArc(ring, math.pi * 0.15, math.pi * 1.55, false, arrow);
        const end = math.pi * 1.7;
        final tip = Offset(ring.center.dx + ring.width / 2 * math.cos(end),
            ring.center.dy + ring.height / 2 * math.sin(end));
        canvas.drawLine(tip, tip + Offset(-w(0.06), -h(0.005)), arrow);
        canvas.drawLine(tip, tip + Offset(-w(0.01), h(0.03)), arrow);
        final curl = Rect.fromCenter(
            center: o(0.47, 0.04), width: w(0.62), height: h(0.08));
        canvas.drawArc(curl, math.pi * 1.1, math.pi * 0.8, false, arrow);
      default:
        break;
    }
  }

  Rect _padRect(int i) {
    final p = _pads[i];
    return Rect.fromCenter(
      center: o(p[0], p[1]),
      width: p[2] * 2 * _f.width,
      height: p[3] * 2 * _f.height,
    );
  }

  void _dashed(Canvas canvas, Path path, Color color, double width) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..color = color;
    final dash = width * 3.2;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(
            metric.extractPath(d, math.min(d + dash, metric.length)), paint);
        d += dash * 2;
      }
    }
  }

  void _badge(Canvas canvas, Size size, String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: K.family,
          fontSize: math.max(11, size.height * 0.075),
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final pad = EdgeInsets.symmetric(
        horizontal: painter.height * 0.55, vertical: painter.height * 0.22);
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width - painter.width - pad.horizontal - size.width * 0.05,
        size.height * 0.06,
        painter.width + pad.horizontal,
        painter.height + pad.vertical,
      ),
      const Radius.circular(999),
    );
    canvas.drawRRect(r, Paint()..color = kMarkerOnSkin);
    painter.paint(canvas, Offset(r.left + pad.left, r.top + pad.top));
  }

  /// A closed shoe seen from the side, with a pebble inside: check before you wear it.
  void _shoe(Canvas canvas, Size size) {
    final s = math.min(size.width * 0.9, size.height * 1.45);
    final ox = (size.width - s) / 2;
    // The shoe spans 0.27 to 0.78 of its unit square; centre that band.
    final oy = (size.height - s * 0.51) / 2 - s * 0.27;
    Offset p(double x, double y) => Offset(ox + x * s, oy + y * s);

    final body = Path()
      ..moveTo(p(0.10, 0.72).dx, p(0.10, 0.72).dy)
      ..quadraticBezierTo(p(0.03, 0.72).dx, p(0.03, 0.72).dy, p(0.05, 0.62).dx,
          p(0.05, 0.62).dy)
      ..cubicTo(p(0.07, 0.52).dx, p(0.07, 0.52).dy, p(0.20, 0.46).dx,
          p(0.20, 0.46).dy, p(0.34, 0.44).dx, p(0.34, 0.44).dy)
      ..lineTo(p(0.52, 0.40).dx, p(0.52, 0.40).dy)
      ..cubicTo(p(0.58, 0.30).dx, p(0.58, 0.30).dy, p(0.66, 0.27).dx,
          p(0.66, 0.27).dy, p(0.73, 0.29).dx, p(0.73, 0.29).dy)
      ..lineTo(p(0.85, 0.29).dx, p(0.85, 0.29).dy)
      ..cubicTo(p(0.91, 0.29).dx, p(0.91, 0.29).dy, p(0.94, 0.40).dx,
          p(0.94, 0.40).dy, p(0.93, 0.52).dx, p(0.93, 0.52).dy)
      ..lineTo(p(0.93, 0.70).dx, p(0.93, 0.70).dy)
      ..quadraticBezierTo(p(0.93, 0.76).dx, p(0.93, 0.76).dy, p(0.87, 0.76).dx,
          p(0.87, 0.76).dy)
      ..lineTo(p(0.14, 0.76).dx, p(0.14, 0.76).dy)
      ..quadraticBezierTo(p(0.10, 0.76).dx, p(0.10, 0.76).dy, p(0.10, 0.72).dx,
          p(0.10, 0.72).dy)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFFF7F9FA));
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(Rect.fromPoints(p(0, 0.69), p(1, 0.8)),
        Paint()..color = _ink.withAlpha(45));
    canvas.restore();
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.6, s * 0.012)
        ..strokeJoin = StrokeJoin.round
        ..color = _ink.withAlpha(210),
    );
    // Opening of the shoe.
    canvas.drawOval(Rect.fromPoints(p(0.70, 0.29), p(0.88, 0.35)),
        Paint()..color = _ink.withAlpha(150));
    // A cut-away window showing a pebble inside.
    final window = RRect.fromRectAndRadius(
        Rect.fromPoints(p(0.26, 0.52), p(0.60, 0.68)),
        Radius.circular(s * 0.04));
    canvas.drawRRect(window, Paint()..color = const Color(0xFFE3E9EC));
    canvas.drawRRect(
      window,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, s * 0.006)
        ..color = _ink.withAlpha(120),
    );
    final pebble = p(0.42, 0.635);
    canvas.drawOval(
        Rect.fromCenter(center: pebble, width: s * 0.06, height: s * 0.04),
        Paint()..color = const Color(0xFF7D7166));
    paintZoneMarker(canvas, pebble.translate(0, -s * 0.005), s * 0.055, pulse,
        kMarkerOnSkin);
  }

  @override
  bool shouldRepaint(covariant SignPainter old) =>
      old.kind != kind ||
      old.tone != tone ||
      old.ground != ground ||
      old.pulse != pulse;
}
