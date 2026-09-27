import 'package:flutter/material.dart';

import '../../data/khatwa_server.dart';
import '../common.dart';
import '../voice/voice_page.dart';
import 'foot_viewer.dart';
import 'photo_sign_page.dart';
import 'scan_page.dart';
import 'twin_page.dart';

/// Home screen hero: the patient's own 3D foot turning slowly (the model foot
/// until the first scan), with the three things to do with it.
class FootHero extends StatefulWidget {
  const FootHero({super.key});

  @override
  State<FootHero> createState() => _FootHeroState();
}

class _FootHeroState extends State<FootHero> {
  final _server = KhatwaServer();
  FootModel _model = FootModel.modelFoot;
  String? _caption;
  String _side = 'L';
  bool _mine = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      Map<String, dynamic>? newest;
      for (final side in ['L', 'R']) {
        final scans = await _server.history(side);
        if (scans.isNotEmpty) {
          final s = scans.last as Map<String, dynamic>;
          if (newest == null || (s['time'] as String).compareTo(newest['time'] as String) > 0) newest = s;
        }
      }
      if (newest == null || !mounted) return;
      final bytes = await _server.model(newest['id'] as String);
      if (!mounted) return;
      setState(() {
        _side = newest!['side'] as String;
        _model = FootModel.bytes(bytes, '${newest['id']}_${bytes.length}');
        _mine = true;
        _caption = 'Votre ${sideFr(_side)}, scanné le ${(newest['time'] as String).substring(0, 10)}';
      });
    } catch (_) {
      // No server or no scan yet: the model foot stays.
    }
  }

  void _open(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)).then((_) => _load());

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.2, -0.35),
            radius: 1.2,
            colors: [Color(0xFF1A4B5A), Color(0xFF0B2530), Color(0xFF07131A)],
            stops: [0, 0.55, 1],
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x2219C3B5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x6619C3B5)),
                ),
                child: const Text('JUMEAU NUMÉRIQUE 3D',
                    style: TextStyle(color: Color(0xFF7FF3E8), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              ),
              const Spacer(),
              if (_mine) const Icon(Icons.verified_rounded, color: Color(0xFF7FF3E8), size: 20),
            ]),
          ),
          SizedBox(
            height: 260,
            child: FootViewer(model: _model, autoRotate: true, alt: 'Votre pied en 3D'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
            child: Text(
              _caption ?? 'Scannez votre pied : Khatwa suit chaque changement, même sous la plante.',
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.35, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
            child: Row(children: [
              _HeroAction(
                icon: Icons.threed_rotation_rounded,
                label: _mine ? 'Mon pied 3D' : 'Scanner',
                onTap: () => _open(_mine ? TwinPage(side: _side) : const ScanPage()),
              ),
              _HeroAction(
                icon: Icons.flip_rounded,
                label: 'Plante',
                onTap: () => _open(PhotoSignPage(side: _mine ? _side : null, sole: true)),
              ),
              _HeroAction(icon: Icons.mic_rounded, label: 'Parler', onTap: () => _open(const VoicePage()), glow: true),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool glow;
  const _HeroAction({required this.icon, required this.label, required this.onTap, this.glow = false});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Material(
            color: glow ? const Color(0xFF19C3B5) : const Color(0x1FFFFFFF),
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(children: [
                  Icon(icon, color: glow ? const Color(0xFF07131A) : Colors.white),
                  const SizedBox(height: 4),
                  Text(label,
                      style: TextStyle(
                          color: glow ? const Color(0xFF07131A) : Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5)),
                ]),
              ),
            ),
          ),
        ),
      );
}
