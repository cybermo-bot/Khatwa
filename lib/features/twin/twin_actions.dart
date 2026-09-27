import 'package:flutter/material.dart';

import '../../data/khatwa_server.dart';
import '../../ui/app_theme.dart';
import '../common.dart';
import '../voice/voice_page.dart';
import 'foot_viewer.dart';
import 'photo_sign_page.dart';
import 'scan_page.dart';
import 'twin_page.dart';

/// The patient's latest scanned foot of one side, in the hologram look of the
/// home stage (their own shape), or null (no scan yet, or no connection): the
/// model foot is shown instead.
Future<String?> myTwinSource(String side) async {
  try {
    final server = KhatwaServer();
    final scans = await server.history(side);
    if (scans.isEmpty) return null;
    final id = (scans.last as Map)['id'] as String;
    final glb = await server.model(id, look: 'holo');
    return glbSource(glb, '${id}_${glb.length}');
  } catch (_) {
    return null;
  }
}

/// Under the 3D foot on the home screen: scan it, add the sole, talk to Khatwa.
class TwinActions extends StatelessWidget {
  const TwinActions({super.key});

  void _open(BuildContext context, Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _Action(
          icon: Icons.threed_rotation_rounded,
          label: tr('Mon pied 3D', aeb: 'ساقي 3D', ar: 'قدمي 3D', en: 'My 3D foot'),
          onTap: () => _open(context, const _TwinOrScan()),
        ),
        const SizedBox(width: 8),
        _Action(
          icon: Icons.flip_rounded,
          label: tr('Plante', aeb: 'تحت الساق', ar: 'باطن القدم', en: 'Sole'),
          onTap: () => _open(context, const PhotoSignPage(sole: true)),
        ),
        const SizedBox(width: 8),
        _Action(
          icon: Icons.mic_rounded,
          label: tr('Parler', aeb: 'احكي', ar: 'تحدّث', en: 'Talk'),
          primary: true,
          onTap: () => _open(context, const VoicePage()),
        ),
      ]));
}

/// Opens the twin when there is one, else the scan.
class _TwinOrScan extends StatefulWidget {
  const _TwinOrScan();
  @override
  State<_TwinOrScan> createState() => _TwinOrScanState();
}

class _TwinOrScanState extends State<_TwinOrScan> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    String? side;
    try {
      final server = KhatwaServer();
      for (final s in ['L', 'R']) {
        if ((await server.history(s)).isNotEmpty) {
          side = s;
          break;
        }
      }
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => side == null ? const ScanPage() : TwinPage(side: side)));
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(backgroundColor: K.ground, body: const Center(child: CircularProgressIndicator()));
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;
  const _Action({required this.icon, required this.label, required this.onTap, this.primary = false});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Material(
          color: primary ? K.primary : K.surface,
          shape: StadiumBorder(side: BorderSide(color: primary ? K.primary : K.line)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, size: 20, color: primary ? K.onPrimary : K.primary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: K.bodyStrong.copyWith(fontSize: 14.5, color: primary ? K.onPrimary : K.ink)),
                ),
              ]),
            ),
          ),
        ),
      );
}
