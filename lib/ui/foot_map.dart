import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'foot_art.dart';
import 'foot_shapes.dart';
import 'k_image.dart';

/// Tappable zones of `map_sole.png` and `map_top.png`, read from
/// `assets/images/map_zones.json`. Zone names are those of
/// `assets/models/foot_regions.json`. Polygons are normalised for a LEFT foot
/// (big toe on the right edge); the right foot is the mirror image.
class FootMapZones {
  final Map<FootView, Map<String, List<Offset>>> zones;
  final double aspect;

  const FootMapZones(this.zones, this.aspect);

  static const empty = FootMapZones({}, 0.5);

  static final ValueNotifier<FootMapZones?> _loaded = ValueNotifier(null);
  static bool _loading = false;

  static ValueListenable<FootMapZones?> get loaded {
    if (!_loading) {
      _loading = true;
      rootBundle.loadString('assets/images/map_zones.json').then(
            (text) => _loaded.value = parse(text),
            onError: (Object _) => _loaded.value = empty,
          );
    }
    return _loaded;
  }

  static FootMapZones parse(String text) {
    final json = jsonDecode(text) as Map<String, dynamic>;
    final raw = json['zones'] as Map<String, dynamic>;
    final result = <FootView, Map<String, List<Offset>>>{};
    for (final view in FootView.values) {
      final byName = raw[view.name] as Map<String, dynamic>? ?? const {};
      result[view] = {
        for (final entry in byName.entries)
          entry.key: [
            for (final p in entry.value as List)
              Offset(
                  ((p as List)[0] as num).toDouble(), (p[1] as num).toDouble()),
          ],
      };
    }
    return FootMapZones(result, (json['aspect'] as num?)?.toDouble() ?? 0.5);
  }

  /// The zone polygons of [view] for [side], in normalised display space.
  Map<String, List<Offset>> of(FootView view, FootSide side) {
    final byName = zones[view] ?? const {};
    if (side == FootSide.left) return byName;
    return {
      for (final e in byName.entries)
        e.key: [for (final p in e.value) Offset(1 - p.dx, p.dy)],
    };
  }
}

/// The app's teaching zones on the map zones.
extension FootZoneRegions on FootZone {
  List<String> get regions {
    switch (this) {
      case FootZone.toes:
        return const ['hallux', 'lesser_toes'];
      case FootZone.betweenToes:
        return const ['interdigital'];
      case FootZone.nails:
        return const ['hallux', 'lesser_toes'];
      case FootZone.ball:
        return const ['forefoot_plantar'];
      case FootZone.arch:
        return const ['midfoot_plantar'];
      case FootZone.heel:
        return const ['heel_plantar', 'heel_posterior'];
      case FootZone.top:
        return const ['dorsum'];
      case FootZone.outerEdge:
        return const ['lateral_side'];
      case FootZone.innerEdge:
        return const ['medial_side'];
    }
  }
}

bool _contains(List<Offset> poly, Offset p) {
  var inside = false;
  for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    final a = poly[i], b = poly[j];
    if ((a.dy > p.dy) != (b.dy > p.dy) &&
        p.dx < (b.dx - a.dx) * (p.dy - a.dy) / (b.dy - a.dy) + a.dx) {
      inside = !inside;
    }
  }
  return inside;
}

Offset _centre(List<Offset> poly) {
  var x = 0.0, y = 0.0;
  for (final p in poly) {
    x += p.dx;
    y += p.dy;
  }
  return Offset(x / poly.length, y / poly.length);
}

/// A marker placed on a [FootMap], at a normalised position of the displayed
/// image (already mirrored for the right foot).
class FootMapMarker {
  final Offset position;
  final Widget child;
  final double size;
  const FootMapMarker(
      {required this.position, required this.child, this.size = 48});
}

/// One foot, seen from below ([FootView.sole]) or above ([FootView.top]),
/// from the image rendered off the 3D model, with its zones. Zones can be
/// lit up ([highlight], breathing with [pulse]), chosen ([selected]) and
/// tapped ([onZoneTap]). While the image is missing, the zones themselves
/// draw a quiet mosaic of the foot, so the map still works.
class FootMap extends StatelessWidget {
  final FootSide side;
  final FootView view;
  final Set<String> highlight;
  final Set<String> selected;
  final double pulse;
  final Color? color;
  final ValueChanged<String>? onZoneTap;
  final String Function(String zone)? zoneLabel;
  final List<FootMapMarker> markers;

  const FootMap({
    super.key,
    required this.side,
    required this.view,
    this.highlight = const {},
    this.selected = const {},
    this.pulse = 0,
    this.color,
    this.onZoneTap,
    this.zoneLabel,
    this.markers = const [],
  });

  String get imageName => view == FootView.sole ? 'map_sole' : 'map_top';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FootMapZones?>(
      valueListenable: FootMapZones.loaded,
      builder: (context, data, _) => ValueListenableBuilder<Set<String>?>(
        valueListenable: KImage.assets,
        builder: (context, assets, _) {
          final zones = (data ?? FootMapZones.empty).of(view, side);
          final hasImage = assets?.contains(KImage.path(imageName)) ?? false;
          return AspectRatio(
            aspectRatio: data?.aspect ?? 0.5,
            // Feet are anatomy, not text: they never mirror for right-to-left.
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: LayoutBuilder(builder: (context, box) {
                final size = box.biggest;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (hasImage)
                      Positioned.fill(
                        child: KImage(
                          imageName,
                          fit: BoxFit.contain,
                          radius: 0,
                          mirror: side == FootSide.right,
                          placeholder: const SizedBox.shrink(),
                        ),
                      ),
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: onZoneTap == null
                            ? null
                            : (d) {
                                final p = Offset(
                                    d.localPosition.dx / size.width,
                                    d.localPosition.dy / size.height);
                                for (final e in zones.entries) {
                                  if (_contains(e.value, p)) {
                                    onZoneTap!(e.key);
                                    return;
                                  }
                                }
                              },
                        child: CustomPaint(
                          painter: _ZonesPainter(
                            zones: zones,
                            silhouette: !hasImage,
                            highlight: highlight,
                            selected: selected,
                            pulse: pulse,
                            color: color ?? K.glow,
                            outline: onZoneTap != null,
                            base: K.isDark
                                ? Colors.white.withAlpha(22)
                                : K.primary.withAlpha(22),
                            edge: K.glassBorder,
                          ),
                        ),
                      ),
                    ),
                    if (onZoneTap != null && zoneLabel != null)
                      for (final e in zones.entries)
                        Positioned(
                          left: _centre(e.value).dx * size.width - 14,
                          top: _centre(e.value).dy * size.height - 14,
                          width: 28,
                          height: 28,
                          child: Semantics(
                            button: true,
                            selected: selected.contains(e.key),
                            label: zoneLabel!(e.key),
                            onTap: () => onZoneTap!(e.key),
                            child: const SizedBox.expand(),
                          ),
                        ),
                    for (final m in markers)
                      Positioned(
                        left: m.position.dx * size.width - m.size / 2,
                        top: m.position.dy * size.height - m.size / 2,
                        width: m.size,
                        height: m.size,
                        child: m.child,
                      ),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

class _ZonesPainter extends CustomPainter {
  final Map<String, List<Offset>> zones;
  final bool silhouette;
  final Set<String> highlight;
  final Set<String> selected;
  final double pulse;
  final Color color;
  final bool outline;
  final Color base;
  final Color edge;

  _ZonesPainter({
    required this.zones,
    required this.silhouette,
    required this.highlight,
    required this.selected,
    required this.pulse,
    required this.color,
    required this.outline,
    required this.base,
    required this.edge,
  });

  Path _path(List<Offset> poly, Size size) => Path()
    ..addPolygon(
        [for (final p in poly) Offset(p.dx * size.width, p.dy * size.height)],
        true);

  @override
  void paint(Canvas canvas, Size size) {
    for (final e in zones.entries) {
      final path = _path(e.value, size);
      final lit = highlight.contains(e.key);
      final chosen = selected.contains(e.key);
      if (silhouette) {
        canvas.drawPath(path, Paint()..color = base);
      }
      if (lit || chosen) {
        final alpha = chosen ? 150 : (70 + 70 * pulse).round();
        canvas.drawPath(
          path,
          Paint()
            ..color = color.withAlpha(alpha)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
      if (silhouette || outline || lit || chosen) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = lit || chosen ? 1.6 : 1
            ..strokeJoin = StrokeJoin.round
            ..color = lit || chosen ? color : edge,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ZonesPainter old) =>
      old.zones != zones ||
      old.silhouette != silhouette ||
      !setEquals(old.highlight, highlight) ||
      !setEquals(old.selected, selected) ||
      old.pulse != pulse ||
      old.color != color;
}

/// Both feet side by side, the person's own view: left foot on the left.
class FootMapPair extends StatelessWidget {
  final FootView view;
  final Set<String> highlight;
  final double pulse;
  final double height;

  const FootMapPair({
    super.key,
    this.view = FootView.top,
    this.highlight = const {},
    this.pulse = 0,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    Widget foot(FootSide side) => SizedBox(
          height: height,
          child: FootMap(
              side: side, view: view, highlight: highlight, pulse: pulse),
        );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          foot(FootSide.left),
          SizedBox(width: height * 0.06),
          foot(FootSide.right),
        ],
      ),
    );
  }
}
