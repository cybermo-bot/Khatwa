import 'dart:convert';
import 'dart:io' if (dart.library.js_interop) 'web_stub.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../ui/foot_twin.dart' show modelAsset;

/// Where a 3D foot comes from: the model foot bundled with the app, or a
/// twin's glTF bytes from the Khatwa server.
class FootModel {
  final String? asset;
  final Uint8List? glb;
  final String id; // changes when the model changes, so the viewer reloads
  const FootModel.asset(this.asset)
      : glb = null,
        id = 'asset';
  const FootModel.bytes(this.glb, this.id) : asset = null;

  static const modelFoot = FootModel.asset('assets/models/foot_model.glb');
}

/// A glTF twin as something the 3D viewer can load: a data address in the
/// browser, a file on Android (a new name per model defeats its cache).
Future<String> glbSource(Uint8List glb, String id) async {
  if (kIsWeb) return 'data:model/gltf-binary;base64,${base64Encode(glb)}';
  final f = File('${(await getTemporaryDirectory()).path}/twin_$id.glb');
  await f.writeAsBytes(glb);
  return 'file://${f.path}';
}

/// A 3D foot the patient can turn with a finger, on Android and in the browser.
class FootViewer extends StatefulWidget {
  final FootModel model;
  final String pinsHtml; // model-viewer hotspots
  final bool autoRotate;
  final Color background;
  final String alt;
  final String cameraOrbit; // "35deg 70deg auto" from above; "0deg 160deg auto" shows the sole
  const FootViewer({
    super.key,
    required this.model,
    this.pinsHtml = '',
    this.autoRotate = false,
    this.background = Colors.transparent,
    this.alt = 'Pied en 3D',
    this.cameraOrbit = '35deg 70deg auto',
  });

  @override
  State<FootViewer> createState() => _FootViewerState();
}

class _FootViewerState extends State<FootViewer> {
  String? _src;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void didUpdateWidget(FootViewer old) {
    super.didUpdateWidget(old);
    if (old.model.id != widget.model.id) {
      setState(() => _src = null);
      _prepare();
    }
  }

  Future<void> _prepare() async {
    final m = widget.model;
    String src;
    if (m.asset != null) {
      src = modelAsset(m.asset!);
    } else {
      src = await glbSource(m.glb!, m.id);
    }
    if (mounted) setState(() => _src = src);
  }

  // Widget tests have no web view to draw 3D in.
  static final bool _inTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  @override
  Widget build(BuildContext context) {
    if (_inTest) return const Center(child: Icon(Icons.view_in_ar_rounded, size: 48));
    final src = _src;
    if (src == null) return const Center(child: CircularProgressIndicator());
    return ModelViewer(
      key: ValueKey('${widget.model.id}|${widget.pinsHtml.hashCode}|${widget.cameraOrbit}'),
      src: src,
      alt: widget.alt,
      cameraControls: true,
      autoRotate: widget.autoRotate,
      autoRotateDelay: 0,
      rotationPerSecond: '18deg',
      disableZoom: false,
      shadowIntensity: 0.6,
      exposure: 1.05,
      cameraOrbit: widget.cameraOrbit,
      backgroundColor: widget.background,
      innerModelViewerHtml: widget.pinsHtml,
    );
  }
}

/// Pins for signs noted on the foot (model-viewer hotspots).
String pinsHtml(List<dynamic> pins, String Function(Map p) label) {
  final b = StringBuffer();
  for (var i = 0; i < pins.length; i++) {
    final p = pins[i] as Map;
    final pos = (p['position'] as List).join('m ');
    final nor = (p['normal'] as List).join(' ');
    b.write('<button slot="hotspot-$i" data-position="${pos}m" data-normal="$nor" '
        'style="background:rgba(7,19,26,.86);color:#fff;border:1.5px solid #19C3B5;border-radius:14px;'
        'padding:4px 10px;font:600 13px sans-serif;box-shadow:0 0 12px rgba(25,195,181,.5)">${label(p)}</button>');
  }
  return b.toString();
}
