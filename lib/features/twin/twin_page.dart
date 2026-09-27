import 'package:flutter/material.dart';

import '../../data/cloud.dart';
import '../../data/khatwa_server.dart';
import '../../ui/app_theme.dart';
import '../common.dart';
import 'foot_viewer.dart';
import 'photo_sign_page.dart';
import 'scan_page.dart';

/// Server notes in French. The server writes them in English for developers.
String _noteFr(String note) {
  if (note.startsWith('Small local differences')) {
    return 'De petites différences locales restent dans le bruit de mesure : aucun changement n’est signalé.';
  }
  final unseen = RegExp(r'^(\d+)% of the foot surface was not seen').firstMatch(note);
  if (unseen != null) {
    return '${unseen.group(1)} % de la surface n’a pas été vue dans les deux scans (la plante repose au sol).';
  }
  return note;
}

/// The patient's 3D twin: turn it, see the sole photo on it, the measures,
/// how they changed, the signs noted, and send it all to the doctor.
class TwinPage extends StatefulWidget {
  final String side;
  final bool showSole;
  const TwinPage({super.key, this.side = 'L', this.showSole = false});

  @override
  State<TwinPage> createState() => _TwinPageState();
}

class _TwinPageState extends State<TwinPage> {
  final _server = KhatwaServer();
  late String _side = widget.side;
  late bool _fromBelow = widget.showSole;
  List<dynamic> _scans = [];
  Map<String, dynamic>? _change;
  Map<String, dynamic>? _findings;
  String _look = 'skin';
  FootModel? _model;
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _model = null;
    });
    try {
      _scans = await _server.history(_side);
      _change = null;
      _findings = null;
      if (_scans.isNotEmpty) {
        _findings = await _server.findings(_side);
        if (_scans.length >= 2) {
          try {
            _change = await _server.change(_side);
          } catch (_) {}
        }
        await _loadModel();
      }
    } on ServerError {
      _error = 'Le serveur Khatwa n’a pas pu répondre.';
    } catch (_) {
      _error = 'Pas de connexion au serveur Khatwa.';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadModel() async {
    final last = _scans.last['id'] as String;
    final bytes = await _server.model(last, look: _look);
    if (mounted) setState(() => _model = FootModel.bytes(bytes, '${last}_${_look}_${bytes.length}'));
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    try {
      final fhir = await _server.fhir();
      final ok = await KhatwaCloud.instance.shareWithDoctor(fhir);
      if (!mounted) return;
      kToast(context, ok ? 'Envoyé à votre médecin.' : 'Envoi impossible pour le moment.', error: !ok);
    } catch (_) {
      if (mounted) kToast(context, 'Envoi impossible pour le moment.', error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _open(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)).then((_) => _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: K.ground,
      appBar: AppBar(title: Text('Mon ${sideFr(_side)} en 3D'), backgroundColor: K.ground, foregroundColor: K.ink),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'L', label: Text('Pied gauche')),
              ButtonSegment(value: 'R', label: Text('Pied droit')),
            ],
            selected: {_side},
            onSelectionChanged: _loading
                ? null
                : (v) {
                    setState(() => _side = v.first);
                    _load();
                  },
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? NeedsServer(message: _error!, onRetry: _load)
                  : _scans.isEmpty
                      ? _empty()
                      : RefreshIndicator(onRefresh: _load, child: _content()),
        ),
      ]),
    );
  }

  Widget _empty() => ListView(padding: const EdgeInsets.all(16), children: [
        KCard(child: Text('Pas encore de ${sideFr(_side)} en 3D. Faites un premier scan.', style: K.body)),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ScanPage())),
          child: const Text('Scanner mon pied'),
        ),
      ]);

  Widget _content() {
    final last = _scans.last as Map;
    final m = (last['measurements'] ?? {}) as Map;
    final tracks = (_findings?['tracks'] as List?) ?? [];
    final pins = (_findings?['pins'] as List?) ?? [];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 32), children: [
      SizedBox(
        height: 380,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.1,
                colors: [Color(0xFF123846), Color(0xFF07131A)],
              ),
            ),
            child: _model == null
                ? const Center(child: CircularProgressIndicator())
                : FootViewer(
                    model: _model!,
                    pinsHtml: pinsHtml(pins, (p) => kindFr[p['kind']] ?? '${p['kind']}'),
                    cameraOrbit: _fromBelow ? '0deg 165deg auto' : '35deg 70deg auto',
                  ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text('Les zones grises n’ont été vues ni par le scan ni par une photo.', style: K.small.copyWith(color: K.muted)),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'skin', label: Text('Peau')),
              ButtonSegment(value: 'regions', label: Text('Zones')),
            ],
            selected: {_look},
            onSelectionChanged: (v) async {
              setState(() {
                _look = v.first;
                _model = null;
              });
              await _loadModel();
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: _fromBelow ? 'Voir de dessus' : 'Voir la plante',
          onPressed: () => setState(() => _fromBelow = !_fromBelow),
          icon: Icon(_fromBelow ? Icons.north_rounded : Icons.south_rounded),
        ),
      ]),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: _sending ? null : _send,
        icon: _sending
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send_rounded),
        label: const Text('Envoyer au médecin'),
      ),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _open(PhotoSignPage(side: _side, sole: true)),
            icon: const Icon(Icons.flip_rounded),
            label: const Text('Plante du pied'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _open(PhotoSignPage(side: _side)),
            icon: const Icon(Icons.add_location_alt_rounded),
            label: const Text('Noter un signe'),
          ),
        ),
      ]),
      const SizedBox(height: 16),
      KCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Dernier scan, ${(last['time'] as String).substring(0, 10)}', style: K.h2),
          const SizedBox(height: 8),
          for (final e in measureFr.entries)
            if (m[e.key] != null) _row(e.value.$1, fmtMeasure(e.key, m[e.key])),
          const SizedBox(height: 8),
          Text(precisionNote, style: K.small.copyWith(color: K.muted)),
        ]),
      ),
      if (_change != null) ...[const SizedBox(height: 12), _changeCard()],
      const SizedBox(height: 12),
      KCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Signes notés', style: K.h2),
          const SizedBox(height: 8),
          if (tracks.isEmpty) Text('Aucun pour ce pied.', style: K.body),
          for (final t in tracks)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.place_rounded, color: K.primary),
              title: Text('${kindFr[(t as Map)['kind']] ?? t['kind']}, ${regionFr[t['region']] ?? t['region']}'),
              subtitle: Text('${statusFr[t['status']] ?? t['status']}, vu le ${t['last_seen']}'),
            ),
        ]),
      ),
      const SizedBox(height: 12),
      Text('${_scans.length} scan(s) de ce pied.', style: K.small.copyWith(color: K.muted)),
    ]);
  }

  Widget _changeCard() {
    final c = _change!;
    final sig = ((c['significant_measurements'] as List?) ?? []).cast<String>();
    final meas = (c['measurements'] ?? {}) as Map;
    final notes = ((c['notes'] as List?) ?? []).cast<String>();
    return KCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Évolution depuis le premier scan', style: K.h2),
        Text('Recherche, seuils provisoires', style: K.small.copyWith(color: K.muted)),
        const SizedBox(height: 8),
        if (sig.isEmpty) Text('Pas de différence au-delà des seuils provisoires.', style: K.body),
        for (final k in sig)
          if (meas[k] is num)
            _row(
              measureFr[k]?.$1 ?? k,
              '${(meas[k] as num) >= 0 ? '+' : ''}${(meas[k] as num).round()} ${measureFr[k]?.$2 ?? ''} '
                  '(${(meas[k] as num) >= 0 ? 'plus grand' : 'plus petit'} qu’au premier scan)',
            ),
        const SizedBox(height: 8),
        Text('Le scan ne voit ni la chaleur ni la couleur : continuez le contrôle quotidien.', style: K.bodyStrong),
        for (final n in notes)
          Padding(padding: const EdgeInsets.only(top: 6), child: Text(_noteFr(n), style: K.small.copyWith(color: K.muted))),
      ]),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(label, style: K.body.copyWith(color: K.inkSoft))),
          const SizedBox(width: 8),
          Flexible(child: Text(value, textAlign: TextAlign.end, style: K.bodyStrong)),
        ]),
      );
}
