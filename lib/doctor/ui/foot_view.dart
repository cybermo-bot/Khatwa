import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import 'labels.dart';
import 'style.dart';

/// A zone of the model foot: 3D position and normal from
/// `assets/models/foot_regions.json` (metres, y up, left foot).
class FootRegion {
  final String name;
  final List<double> position;
  final List<double> normal;
  final int vertex;

  const FootRegion(this.name, this.position, this.normal, this.vertex);

  /// The same zone on the right foot: the model is mirrored across z (the
  /// medial to lateral axis), and model-viewer does not scale hotspots.
  FootRegion mirrored() => FootRegion(
        name,
        [position[0], position[1], -position[2]],
        [normal[0], normal[1], -normal[2]],
        vertex,
      );
}

Map<String, FootRegion> parseFootRegions(String json) {
  final data = jsonDecode(json) as Map<String, dynamic>;
  final regions = data['regions'] as Map<String, dynamic>;
  return {
    for (final e in regions.entries)
      e.key: FootRegion(
        e.key,
        [for (final v in (e.value['position'] as List)) (v as num).toDouble()],
        [for (final v in (e.value['normal'] as List)) (v as num).toDouble()],
        (e.value['vertex'] as num).toInt(),
      ),
  };
}

Future<Map<String, FootRegion>>? _regions;

Future<Map<String, FootRegion>> loadFootRegions() =>
    _regions ??= rootBundle.loadString('assets/models/foot_regions.json').then(parseFootRegions);

/// One pin on the foot.
class FootPin {
  final String region;
  final String level; // none | soon | urgent
  final int count;
  final String label;

  const FootPin({required this.region, required this.level, this.count = 1, this.label = ''});
}

/// Whether the 3D viewer can run here (web, Android, iOS). Elsewhere, and in
/// widget tests, a flat map of the pins is shown instead.
bool get footViewer3dSupported =>
    kIsWeb || defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;

/// The 3D foot with pins placed from `foot_regions.json`.
class FootView extends StatelessWidget {
  final List<FootPin> pins;
  final String side; // L | R
  /// A scan's twin URL; null shows the model foot.
  final String? src;
  final bool enable3d;
  /// Scale pin size by count (public health view).
  final bool sizeByCount;
  final double height;

  const FootView({
    super.key,
    required this.pins,
    this.side = 'L',
    this.src,
    this.enable3d = true,
    this.sizeByCount = false,
    this.height = 340,
  });

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    return SizedBox(
      height: height,
      child: FutureBuilder<Map<String, FootRegion>>(
        future: loadFootRegions(),
        builder: (context, snap) {
          final regions = snap.data;
          if (regions == null) {
            return Center(child: CircularProgressIndicator(color: p.primary, strokeWidth: 2));
          }
          final placed = {
            for (final e in regions.entries) e.key: side == 'R' ? e.value.mirrored() : e.value,
          };
          if (enable3d && footViewer3dSupported) {
            return _Foot3d(pins: pins, regions: placed, side: side, src: src, sizeByCount: sizeByCount, palette: p);
          }
          return _FootMap(pins: pins, regions: placed, side: side, sizeByCount: sizeByCount);
        },
      ),
    );
  }
}

double _pinSize(FootPin pin, bool sizeByCount, int maxCount) {
  if (!sizeByCount) return 22;
  final t = maxCount <= 1 ? 1.0 : (pin.count - 1) / (maxCount - 1);
  return 18 + 30 * t;
}

String _css(Color c) =>
    'rgba(${(c.r * 255).round()},${(c.g * 255).round()},${(c.b * 255).round()},${c.a.toStringAsFixed(2)})';

class _Foot3d extends StatelessWidget {
  final List<FootPin> pins;
  final Map<String, FootRegion> regions;
  final String side;
  final String? src;
  final bool sizeByCount;
  final DPalette palette;

  const _Foot3d({
    required this.pins,
    required this.regions,
    required this.side,
    required this.src,
    required this.sizeByCount,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final maxCount = pins.fold<int>(1, (m, pin) => pin.count > m ? pin.count : m);
    final html = StringBuffer();
    var i = 0;
    for (final pin in pins) {
      final r = regions[pin.region];
      if (r == null) continue;
      final size = _pinSize(pin, sizeByCount, maxCount).round();
      final color = _css(palette.level(pin.level));
      final title = const HtmlEscape().convert(
          '${regionLabels[pin.region] ?? pin.region}${pin.label.isEmpty ? '' : ' : ${pin.label}'}');
      html.write('<button class="pin" slot="hotspot-${i++}" '
          'data-position="${r.position.join(' ')}" data-normal="${r.normal.join(' ')}" '
          'title="$title" style="width:${size}px;height:${size}px;background:$color">'
          '${pin.count > 1 ? pin.count : ''}</button>');
    }
    // A new key rebuilds the web view when the pins or the foot change.
    final key = ValueKey('$side|$src|${html.toString().hashCode}');
    return ClipRRect(
      borderRadius: BorderRadius.circular(dRadius),
      child: ModelViewer(
        key: key,
        src: src ?? 'assets/models/foot_model.glb',
        alt: 'Modèle 3D du ${sideLabel(side).toLowerCase()} avec les zones signalées',
        cameraControls: true,
        disableZoom: false,
        autoRotate: false,
        cameraOrbit: '35deg 65deg auto',
        scale: side == 'R' && src == null ? '1 1 -1' : null,
        backgroundColor: Colors.transparent,
        shadowIntensity: 0.6,
        exposure: 1.05,
        innerModelViewerHtml: html.toString(),
        relatedCss: '''
.pin {
  border-radius: 50%;
  border: 2px solid rgba(255,255,255,0.9);
  box-shadow: 0 0 14px ${_css(palette.glow.withValues(alpha: 0.7))};
  color: #03211F;
  font: 600 11px sans-serif;
  padding: 0;
  cursor: pointer;
}
.pin:not([data-visible]) { opacity: 0.35; }
''',
      ),
    );
  }
}

/// Flat fallback: the pins seen from above the sole (x along the foot,
/// z across it), in a soft capsule.
class _FootMap extends StatelessWidget {
  final List<FootPin> pins;
  final Map<String, FootRegion> regions;
  final String side;
  final bool sizeByCount;

  const _FootMap({required this.pins, required this.regions, required this.side, required this.sizeByCount});

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    final maxCount = pins.fold<int>(1, (m, pin) => pin.count > m ? pin.count : m);
    return LayoutBuilder(builder: (context, box) {
      final h = box.maxHeight;
      final w = (h * 0.52).clamp(120.0, box.maxWidth);
      // x: -0.13 (heel) .. 0.13 (toes); z: -0.06 .. 0.06.
      Offset place(FootRegion r) => Offset(
            w / 2 + r.position[2] / 0.06 * (w * 0.42),
            h / 2 - r.position[0] / 0.13 * (h * 0.44),
          );
      return Center(
        child: SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(w / 2),
                    border: Border.all(color: p.glassBorder),
                    gradient: RadialGradient(
                      colors: [p.glow.withValues(alpha: 0.16), p.glow.withValues(alpha: 0.02)],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: Text(sideLabel(side), textAlign: TextAlign.center, style: DText.small(p)),
              ),
              for (final pin in pins)
                if (regions[pin.region] case final r?)
                  Builder(builder: (context) {
                    final size = _pinSize(pin, sizeByCount, maxCount);
                    final at = place(r);
                    return Positioned(
                      left: at.dx - size / 2,
                      top: at.dy - size / 2,
                      width: size,
                      height: size,
                      child: Tooltip(
                        message: '${regionLabels[pin.region] ?? pin.region}'
                            '${pin.label.isEmpty ? '' : ' : ${pin.label}'}',
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: p.level(pin.level),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2),
                            boxShadow: [BoxShadow(color: p.glow.withValues(alpha: 0.5), blurRadius: 12)],
                          ),
                          child: pin.count > 1
                              ? Text('${pin.count}',
                                  style: const TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF03211F)))
                              : null,
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      );
    });
  }
}
