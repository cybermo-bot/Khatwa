import 'package:flutter/material.dart';

import 'app_state.dart';
import 'app_theme.dart';
import 'foot_shapes.dart';

/// Skin tones for the illustrations. The app never uses them for interface
/// chrome; they belong to the feet alone.
class SkinTone {
  final String name;
  final Color base;
  final Color light;
  final Color shade;
  final Color pad;
  final Color nail;

  const SkinTone({
    required this.name,
    required this.base,
    required this.light,
    required this.shade,
    required this.pad,
    required this.nail,
  });

  static const fair = SkinTone(
    name: 'fair',
    base: Color(0xFFF0CBAE),
    light: Color(0xFFF8DECA),
    shade: Color(0xFFD1A07F),
    pad: Color(0xFFF8D5C2),
    nail: Color(0xFFFBEADF),
  );

  static const medium = SkinTone(
    name: 'medium',
    base: Color(0xFFE2AE88),
    light: Color(0xFFF0C9A8),
    shade: Color(0xFFBF855F),
    pad: Color(0xFFF2C2A6),
    nail: Color(0xFFF7DDCD),
  );

  static const deep = SkinTone(
    name: 'deep',
    base: Color(0xFF9C6644),
    light: Color(0xFFB57C57),
    shade: Color(0xFF74472C),
    pad: Color(0xFFB98163),
    nail: Color(0xFFD7B19A),
  );

  static const all = [fair, medium, deep];

  /// The tone the patient chose in Settings.
  static SkinTone get current =>
      all.firstWhere((t) => t.name == appSkinTone.value, orElse: () => medium);

  bool get isDeep => name == 'deep';
}

/// Marker colours on skin. Fixed, not themed: skin does not change with the
/// theme, so the marker must contrast with skin in light and dark alike.
const kMarkerOnSkin = Color(0xFF0B4F5A);
const kUrgentOnSkin = Color(0xFFA8231B);

/// Places on the foot the app talks about. Positions are for the right foot,
/// seen as the person sees it looking down, and are mirrored for the left.
enum FootZone {
  toes,
  betweenToes,
  nails,
  ball,
  arch,
  heel,
  top,
  outerEdge,
  innerEdge
}

extension FootZonePosition on FootZone {
  Offset get anchor {
    switch (this) {
      case FootZone.toes:
        return const Offset(0.46, 0.12);
      case FootZone.betweenToes:
        return const Offset(0.33, 0.17);
      case FootZone.nails:
        return const Offset(0.24, 0.06);
      case FootZone.ball:
        return const Offset(0.50, 0.29);
      case FootZone.arch:
        return const Offset(0.40, 0.58);
      case FootZone.heel:
        return const Offset(0.53, 0.88);
      case FootZone.top:
        return const Offset(0.54, 0.46);
      case FootZone.outerEdge:
        return const Offset(0.82, 0.56);
      case FootZone.innerEdge:
        return const Offset(0.32, 0.72);
    }
  }
}

/// Draws a zone marker that can never be mistaken for a mark on the skin: a
/// crisp white separation ring around a petrol ring, and a thin echo that
/// grows and fades with [pulse]. Nothing filled, nothing blurred.
void paintZoneMarker(
    Canvas canvas, Offset c, double r, double pulse, Color color) {
  if (pulse > 0) {
    canvas.drawCircle(
      c,
      r * (1.15 + 0.75 * pulse),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = color.withAlpha(((1 - pulse) * 170).round()),
    );
  }
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.62
      ..color = Colors.white.withAlpha(235),
  );
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.34
      ..color = color,
  );
  canvas.drawCircle(c, r * 0.26, Paint()..color = color);
}

class FootArtPainter extends CustomPainter {
  final FootSide side;
  final FootView view;
  final List<FootZone> zones;
  final double pulse;
  final SkinTone tone;
  final Color marker;
  final Color ground;
  final double fade; // 0 = ground only, 1 = full skin
  final bool tendon;

  FootArtPainter({
    required this.side,
    required this.view,
    this.zones = const [],
    this.pulse = 0,
    required this.tone,
    this.marker = kMarkerOnSkin,
    required this.ground,
    this.fade = 1,
    this.tendon = true,
  });

  Offset _place(Offset p, Size size) => Offset(
        (side == FootSide.left ? 1 - p.dx : p.dx) * size.width,
        p.dy * size.height,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final outline = FootShape.outline(size, side);
    final bounds = outline.getBounds();

    // Skin: a soft top-to-heel light, then a darker rim that gives volume.
    final skin = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(ground, tone.light, fade)!,
          Color.lerp(ground, tone.base, fade)!,
        ],
      ).createShader(bounds);
    canvas.drawPath(outline, skin);

    canvas.save();
    canvas.clipPath(outline);
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.05)
      ..color = tone.shade.withAlpha((110 * fade).round());
    canvas.drawPath(outline, rim);

    if (view == FootView.sole) {
      final pads = FootShape.stamp(size, side);
      canvas.drawPath(
        pads,
        Paint()
          ..color = tone.pad.withAlpha((200 * fade).round())
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.025),
      );
      final crease = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = tone.shade.withAlpha((90 * fade).round());
      for (final line in FootShape.creases(size, side)) {
        final p = Path()..moveTo(line.first.dx, line.first.dy);
        for (var i = 1; i < line.length; i++) {
          final prev = line[i - 1];
          final cur = line[i];
          p.quadraticBezierTo(
              prev.dx, prev.dy, (prev.dx + cur.dx) / 2, (prev.dy + cur.dy) / 2);
        }
        p.lineTo(line.last.dx, line.last.dy);
        canvas.drawPath(p, crease);
      }
    } else {
      // Toenails, sitting near the tip of each toe.
      final nail = Paint()
        ..color = Color.lerp(ground, tone.nail, fade)!.withAlpha(235);
      final nailEdge = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = tone.shade.withAlpha((80 * fade).round());
      for (final pad in FootShape.toes(size, side)) {
        final rr = nailRect(pad);
        canvas.drawRRect(rr, nail);
        canvas.drawRRect(rr, nailEdge);
      }
      if (tendon) {
        final line = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.05
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.03)
          ..color = tone.light.withAlpha((120 * fade).round());
        canvas.drawLine(_place(const Offset(0.30, 0.26), size),
            _place(const Offset(0.44, 0.62), size), line);
      }
    }
    canvas.restore();

    // Crisp edge.
    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = tone.shade.withAlpha((150 * fade).round()),
    );

    for (final zone in zones) {
      paintZoneMarker(
          canvas, _place(zone.anchor, size), size.width * 0.085, pulse, marker);
    }
  }

  /// The nail on a toe pad, as drawn in the top view.
  static RRect nailRect(Rect pad) {
    final r = Rect.fromCenter(
      center: pad.center.translate(0, -pad.height * 0.18),
      width: pad.width * 0.62,
      height: pad.height * 0.58,
    );
    return RRect.fromRectAndRadius(r, Radius.circular(r.width * 0.45));
  }

  @override
  bool shouldRepaint(covariant FootArtPainter old) =>
      old.pulse != pulse ||
      old.fade != fade ||
      old.side != side ||
      old.view != view ||
      old.tone != tone ||
      old.marker != marker ||
      old.ground != ground ||
      old.tendon != tendon ||
      old.zones != zones;
}

/// A pair of feet side by side: left foot on the left, the person's own view.
class FeetPair extends StatelessWidget {
  final FootView view;
  final List<FootZone> leftZones;
  final List<FootZone> rightZones;
  final double pulse;
  final double height;
  final Color? ground;

  const FeetPair({
    super.key,
    this.view = FootView.top,
    this.leftZones = const [],
    this.rightZones = const [],
    this.pulse = 0,
    this.height = 200,
    this.ground,
  });

  @override
  Widget build(BuildContext context) {
    final w = height * 0.56;
    final tone = SkinTone.current;
    Widget foot(FootSide side, List<FootZone> zones) => SizedBox(
          width: w,
          height: height,
          child: CustomPaint(
            painter: FootArtPainter(
              side: side,
              view: view,
              zones: zones,
              pulse: pulse,
              tone: tone,
              ground: ground ?? K.surface,
            ),
          ),
        );
    // Feet are anatomy, not text: they never mirror for right-to-left.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          foot(FootSide.left, leftZones),
          SizedBox(width: height * 0.04),
          foot(FootSide.right, rightZones),
        ],
      ),
    );
  }
}

/// The four photos of a daily check, in capture order: right sole, left sole,
/// right top, left top. Taken ones carry a check; the next one breathes.
/// Skin always keeps its full colour: a faded foot reads as discoloured skin,
/// which is itself a warning sign. Pending ones are told apart by the label.
class PhotoPositions extends StatelessWidget {
  final int taken;
  final double pulse;
  final double footHeight;
  final Color ground;
  final List<String> labels;
  final bool showNext;

  const PhotoPositions({
    super.key,
    required this.taken,
    required this.ground,
    required this.labels,
    this.pulse = 0,
    this.footHeight = 128,
    this.showNext = true,
  });

  static const order = [
    (FootSide.right, FootView.sole),
    (FootSide.left, FootView.sole),
    (FootSide.right, FootView.top),
    (FootSide.left, FootView.top),
  ];

  @override
  Widget build(BuildContext context) {
    final tone = SkinTone.current;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < order.length; i++)
          Expanded(
            child: Semantics(
              label: labels.length > i ? labels[i] : '${i + 1}',
              checked: i < taken,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: KMotion.standard,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(K.r14),
                        border: Border.all(
                          width: 2,
                          color: showNext && i == taken
                              ? K.primary.withAlpha((120 + 135 * pulse).round())
                              : Colors.transparent,
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          SizedBox(
                            height: footHeight,
                            width: footHeight * 0.56,
                            child: CustomPaint(
                              painter: FootArtPainter(
                                side: order[i].$1,
                                view: order[i].$2,
                                tone: tone,
                                ground: ground,
                              ),
                            ),
                          ),
                          if (i < taken)
                            Positioned(
                              bottom: -4,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: K.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: ground, width: 2.5),
                                ),
                                child: Icon(Icons.check_rounded,
                                    size: 17, color: K.onPrimary),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${i + 1}',
                      style: K.label.copyWith(
                        color: i <= taken ? K.primaryStrong : K.inkSoft,
                        fontWeight: showNext && i == taken
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
