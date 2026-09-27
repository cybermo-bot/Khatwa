import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import 'app_theme.dart';
import 'foot_map.dart';
import 'foot_shapes.dart';

/// Where the camera looks at the twin from. [free] is the three-quarter
/// view the home opens on; the patient can then turn it freely.
enum TwinView { free, top, sole }

/// State of a zone on the twin, for its pin colour.
enum ZoneStatus { none, watch, urgent }

/// One zone of `assets/models/foot_regions.json`: a point on the surface of
/// `foot_model.glb` (metres, y up, sole on y = 0, left foot) and its normal.
class TwinRegion {
  final String name;
  final List<double> position;
  final List<double> normal;
  const TwinRegion(this.name, this.position, this.normal);

  static final ValueNotifier<List<TwinRegion>?> _loaded = ValueNotifier(null);
  static bool _loading = false;

  static ValueListenable<List<TwinRegion>?> get loaded {
    if (!_loading) {
      _loading = true;
      rootBundle.loadString('assets/models/foot_regions.json').then(
        (text) {
          final json = jsonDecode(text) as Map<String, dynamic>;
          final regions = json['regions'] as Map<String, dynamic>;
          _loaded.value = [
            for (final e in regions.entries)
              TwinRegion(
                e.key,
                [
                  for (final v in (e.value as Map)['position'] as List)
                    (v as num).toDouble()
                ],
                [
                  for (final v in (e.value as Map)['normal'] as List)
                    (v as num).toDouble()
                ],
              ),
          ];
        },
        onError: (Object _) => _loaded.value = const [],
      );
    }
    return _loaded;
  }
}

/// The patient's foot as a 3D clinical hologram: `foot_holo.glb` (the model
/// foot with a translucent teal material), turned with one finger, zoomed
/// with two, with a pin on each zone. The right foot is the left mirrored.
///
/// Where no 3D view is possible (widget tests, desktop builds) it shows the
/// zone map of the foot instead, so the screen still reads.
class FootTwin extends StatelessWidget {
  final FootSide side;
  final TwinView view;
  final Map<String, ZoneStatus> status;
  final String Function(String zone) zoneLabel;
  final String alt;

  /// The patient's own twin (a URL, data address or file), already of the
  /// right side; null shows the model foot hologram.
  final String? src;

  /// Zones whose label is always shown; the others show a dot only, unless
  /// they have a status.
  final Set<String> labelled;

  const FootTwin({
    super.key,
    required this.side,
    required this.view,
    required this.zoneLabel,
    required this.alt,
    this.src,
    this.status = const {},
    this.labelled = const {
      'hallux',
      'forefoot_plantar',
      'heel_plantar',
      'dorsum'
    },
  });

  static bool get supported {
    final binding = WidgetsBinding.instance.runtimeType.toString();
    if (binding.contains('Test')) return false;
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  String get _orbit {
    switch (view) {
      case TwinView.free:
        return '-150deg 55deg 110%';
      case TwinView.top:
        return '-90deg 8deg 100%';
      case TwinView.sole:
        return '90deg 172deg 100%';
    }
  }

  static String _escape(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  String _hotspots(List<TwinRegion> regions) {
    final mirror = side == FootSide.right && src == null;
    final out = StringBuffer();
    for (final r in regions) {
      final z = mirror ? -r.position[2] : r.position[2];
      final nz = mirror ? -r.normal[2] : r.normal[2];
      final s = status[r.name] ?? ZoneStatus.none;
      final showLabel = labelled.contains(r.name) || s != ZoneStatus.none;
      out.write('<div class="hs ${s.name}" slot="hotspot-${r.name}" '
          'data-position="${r.position[0]} ${r.position[1]} $z" '
          'data-normal="${r.normal[0]} ${r.normal[1]} $nz" '
          'data-visibility-attribute="visible">'
          '<span class="dot"></span>');
      if (showLabel) {
        out.write('<span class="lbl">${_escape(zoneLabel(r.name))}</span>');
      }
      out.write('</div>');
    }
    return out.toString();
  }

  String get _css {
    String hex(Color c) =>
        '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    final chip = K.isDark ? 'rgba(13,32,41,0.88)' : 'rgba(255,255,255,0.92)';
    return '''
model-viewer { --poster-color: transparent; background: transparent; }
.hs { display: flex; align-items: center; gap: 6px; pointer-events: none;
  transition: opacity 200ms; font-family: 'Readex Pro', system-ui, sans-serif; }
.hs:not([data-visible]) { opacity: 0; }
.hs .dot { width: 10px; height: 10px; border-radius: 50%; background: ${hex(K.glow)};
  box-shadow: 0 0 0 5px ${hex(K.glow)}33, 0 0 12px ${hex(K.glow)}; }
.hs.watch .dot { background: ${hex(K.warn)}; box-shadow: 0 0 0 5px ${hex(K.warn)}33; }
.hs.urgent .dot { background: ${hex(K.danger)}; box-shadow: 0 0 0 6px ${hex(K.danger)}40; }
.hs .lbl { font-size: 11px; font-weight: 600; color: ${hex(K.ink)};
  background: $chip; border: 1px solid ${hex(K.glassBorder)};
  padding: 3px 8px; border-radius: 999px; white-space: nowrap; }
''';
  }

  @override
  Widget build(BuildContext context) {
    if (!supported) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: FootMap(
            side: side,
            view: view == TwinView.sole ? FootView.sole : FootView.top,
          ),
        ),
      );
    }
    return ValueListenableBuilder<List<TwinRegion>?>(
      valueListenable: TwinRegion.loaded,
      builder: (context, regions, _) {
        if (regions == null) return const SizedBox.expand();
        return ModelViewer(
          key: ValueKey('twin-${side.name}-${view.name}-${K.isDark}-${src.hashCode}'),
          src: src ?? 'assets/models/foot_holo.glb',
          alt: alt,
          backgroundColor: Colors.transparent,
          cameraControls: true,
          disablePan: true,
          touchAction: TouchAction.none,
          interactionPrompt: InteractionPrompt.none,
          autoRotate: view == TwinView.free,
          autoRotateDelay: 2500,
          rotationPerSecond: '12deg',
          cameraOrbit: _orbit,
          minCameraOrbit: 'auto auto 60%',
          maxCameraOrbit: 'auto auto 180%',
          exposure: 1.1,
          shadowIntensity: 0,
          scale: side == FootSide.right && src == null ? '1 1 -1' : null,
          innerModelViewerHtml: _hotspots(regions),
          relatedCss: _css,
        );
      },
    );
  }
}
