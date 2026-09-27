import 'package:flutter/material.dart';

import '../../data/cloud.dart';
import '../../data/khatwa_server.dart';
import '../../ui/app_state.dart';
import '../../ui/app_theme.dart';
import '../../ui/strings.dart';
import '../common.dart';
import 'foot_viewer.dart';
import 'photo_sign_page.dart';
import 'scan_page.dart';

/// Server notes in the app's language. The server writes them in English for developers.
String _note(String note) {
  if (note.startsWith('Small local differences')) {
    return tr('De petites différences locales restent dans le bruit de mesure : aucun changement n’est signalé.',
        aeb: 'فروقات صغار في بلايص قعدو في هامش القيس: ما فمّا حتى تبديل.',
        ar: 'بقيت فروق محلية صغيرة ضمن هامش القياس: لا يوجد تغيير.',
        en: 'Small local differences stay within measurement noise: no change is reported.');
  }
  final unseen = RegExp(r'^(\d+)% of the foot surface was not seen').firstMatch(note);
  if (unseen != null) {
    final n = unseen.group(1);
    return tr('$n % de la surface n’a pas été vue dans les deux scans (la plante repose au sol).',
        aeb: '$n % من سطح الساق ما تشافش في السكانين (تحت الساق على الأرض).',
        ar: '$n % من سطح القدم لم يُرَ في المسحين (باطن القدم على الأرض).',
        en: '$n % of the surface was not seen in both scans (the sole rests on the floor).');
  }
  return tr('Note technique du serveur.', aeb: 'ملاحظة تقنية من السيرفر.', ar: 'ملاحظة تقنية من الخادم.', en: note);
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
      _error = tr('Le serveur Khatwa n’a pas pu répondre.', aeb: 'سيرفر خطوة ما جاوبش.', ar: 'لم يتمكن خادم خطوة من الرد.', en: 'The Khatwa server could not answer.');
    } catch (_) {
      _error = tr('Pas de connexion au serveur Khatwa. Le jumeau 3D a besoin du serveur.',
          aeb: 'ما فمّاش اتصال بسيرفر خطوة. الساق 3D تستحق السيرفر.',
          ar: 'لا يوجد اتصال بخادم خطوة. القدم ثلاثية الأبعاد تحتاج إلى الخادم.',
          en: 'No connection to the Khatwa server. The 3D twin needs the server.');
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
      kToast(context, ok ? _sentText() : _notSentText(), error: !ok);
    } catch (_) {
      if (mounted) kToast(context, _notSentText(), error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _sentText() => tr('Envoyé à votre médecin.', aeb: 'تبعث للطبيب متاعك.', ar: 'أُرسل إلى طبيبك.', en: 'Sent to your doctor.');
  String _notSentText() =>
      tr('Envoi impossible pour le moment.', aeb: 'ما نجمناش نبعثو توّا.', ar: 'تعذّر الإرسال حاليًا.', en: 'Could not send for now.');

  void _open(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)).then((_) => _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: K.ground,
      appBar: AppBar(
          title: Text(tr('Mon ${sideName(_side)} en 3D', aeb: '${sideName(_side)} في 3D', ar: '${sideName(_side)} ثلاثية الأبعاد', en: 'My ${sideName(_side)} in 3D')),
          backgroundColor: K.ground,
          foregroundColor: K.ink),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'L', label: Text(S.t(appLanguage.value, 'twin.left'))),
              ButtonSegment(value: 'R', label: Text(S.t(appLanguage.value, 'twin.right'))),
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
        KCard(
            child: Text(
                tr('Pas encore de ${sideName(_side)} en 3D. Faites un premier scan.',
                    aeb: 'مازال ما فمّاش ${sideName(_side)} في 3D. اعمل أول سكان.',
                    ar: 'لا توجد بعد ${sideName(_side)} ثلاثية الأبعاد. قم بأول مسح.',
                    en: 'No ${sideName(_side)} in 3D yet. Make a first scan.'),
                style: K.body)),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ScanPage())),
          child: Text(tr('Scanner mon pied', aeb: 'اعمل سكان لساقي', ar: 'امسح قدمي', en: 'Scan my foot')),
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
          borderRadius: BorderRadius.circular(32),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: K.glassBorder),
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 0.95,
                colors: [K.primarySoft, Color.lerp(K.primarySoft, K.surface, 0.6)!, K.surface],
                stops: const [0, 0.55, 1],
              ),
            ),
            child: _model == null
                ? const Center(child: CircularProgressIndicator())
                : FootViewer(
                    model: _model!,
                    pinsHtml: pinsHtml(pins, (p) => kindName(p['kind'])),
                    cameraOrbit: _fromBelow ? '0deg 165deg auto' : '35deg 70deg auto',
                  ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
          tr('Les zones grises n’ont été vues ni par le scan ni par une photo.',
              aeb: 'البلايص الرمادية ما تشافوش لا بالسكان لا بالتصويرة.',
              ar: 'المناطق الرمادية لم يرها المسح ولا الصورة.',
              en: 'Grey areas were seen neither by the scan nor by a photo.'),
          style: K.small.copyWith(color: K.muted)),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'skin', label: Text(tr('Peau', aeb: 'الجلد', ar: 'الجلد', en: 'Skin'))),
              ButtonSegment(value: 'regions', label: Text(tr('Zones', aeb: 'البلايص', ar: 'المناطق', en: 'Zones'))),
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
          tooltip: _fromBelow
              ? tr('Voir de dessus', aeb: 'شوف من الفوق', ar: 'انظر من الأعلى', en: 'See from above')
              : tr('Voir la plante', aeb: 'شوف من تحت', ar: 'انظر إلى باطن القدم', en: 'See the sole'),
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
        label: Text(tr('Envoyer au médecin', aeb: 'ابعث للطبيب', ar: 'أرسل إلى الطبيب', en: 'Send to the doctor')),
      ),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _open(PhotoSignPage(side: _side, sole: true)),
            icon: const Icon(Icons.flip_rounded),
            label: Text(tr('Plante du pied', aeb: 'تحت الساق', ar: 'باطن القدم', en: 'Sole')),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _open(PhotoSignPage(side: _side)),
            icon: const Icon(Icons.add_location_alt_rounded),
            label: Text(tr('Noter un signe', aeb: 'سجّل علامة', ar: 'سجّل علامة', en: 'Note a sign')),
          ),
        ),
      ]),
      const SizedBox(height: 16),
      KCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              '${tr('Dernier scan', aeb: 'آخر سكان', ar: 'آخر مسح', en: 'Last scan')}, ${(last['time'] as String).substring(0, 10)}',
              style: K.h2),
          const SizedBox(height: 8),
          for (final key in measurePrecision.keys)
            if (m[key] != null) _row(measureName(key), fmtMeasure(key, m[key])),
          const SizedBox(height: 8),
          Text(precisionNote(), style: K.small.copyWith(color: K.muted)),
        ]),
      ),
      if (_change != null) ...[const SizedBox(height: 12), _changeCard()],
      const SizedBox(height: 12),
      KCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr('Signes notés', aeb: 'العلامات المسجّلة', ar: 'العلامات المسجّلة', en: 'Signs noted'), style: K.h2),
          const SizedBox(height: 8),
          if (tracks.isEmpty)
            Text(tr('Aucun pour ce pied.', aeb: 'حتى شي في الساق هذي.', ar: 'لا شيء لهذه القدم.', en: 'None for this foot.'), style: K.body),
          for (final t in tracks)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.place_rounded, color: K.primary),
              title: Text('${kindName((t as Map)['kind'])}, ${regionName(t['region'])}'),
              subtitle: Text(
                  '${statusName(t['status'])}, ${tr('vu le', aeb: 'تشاف نهار', ar: 'شوهد في', en: 'seen on')} ${t['last_seen']}'),
            ),
        ]),
      ),
      const SizedBox(height: 12),
      Text(
          tr('${_scans.length} scan(s) de ce pied.',
              aeb: 'عدد السكانات للساق هذي: ${_scans.length}',
              ar: 'عدد المسوح لهذه القدم: ${_scans.length}',
              en: '${_scans.length} scan(s) of this foot.'),
          style: K.small.copyWith(color: K.muted)),
    ]);
  }

  Widget _changeCard() {
    final c = _change!;
    final sig = ((c['significant_measurements'] as List?) ?? []).cast<String>();
    final meas = (c['measurements'] ?? {}) as Map;
    final notes = ((c['notes'] as List?) ?? []).cast<String>();
    return KCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr('Évolution depuis le premier scan', aeb: 'التبديل من أول سكان', ar: 'التطوّر منذ أول مسح', en: 'Change since the first scan'),
            style: K.h2),
        Text(tr('Recherche, seuils provisoires', aeb: 'بحث، عتبات مؤقتة', ar: 'بحث، عتبات مؤقتة', en: 'Research, provisional thresholds'),
            style: K.small.copyWith(color: K.muted)),
        const SizedBox(height: 8),
        if (sig.isEmpty)
          Text(
              tr('Pas de différence au-delà des seuils provisoires.',
                  aeb: 'ما فمّا حتى فرق فوق العتبات المؤقتة.',
                  ar: 'لا فرق يتجاوز العتبات المؤقتة.',
                  en: 'No difference beyond the provisional thresholds.'),
              style: K.body),
        for (final k in sig)
          if (meas[k] is num)
            _row(
              measureName(k),
              '${(meas[k] as num) >= 0 ? '+' : ''}${(meas[k] as num).round()} ${measureUnit(k)} '
                  '(${(meas[k] as num) >= 0 ? tr('plus grand qu’au premier scan', aeb: 'أكبر من أول سكان', ar: 'أكبر من أول مسح', en: 'larger than at the first scan') : tr('plus petit qu’au premier scan', aeb: 'أصغر من أول سكان', ar: 'أصغر من أول مسح', en: 'smaller than at the first scan')})',
            ),
        const SizedBox(height: 8),
        Text(
            tr('Le scan ne voit ni la chaleur ni la couleur : continuez le contrôle quotidien.',
                aeb: 'السكان ما يشوفش السخانة ولا اللون: كمّل الفحص كل يوم.',
                ar: 'المسح لا يرى الحرارة ولا اللون: واصل الفحص اليومي.',
                en: 'The scan sees neither warmth nor colour: keep up the daily check.'),
            style: K.bodyStrong),
        for (final n in notes)
          Padding(padding: const EdgeInsets.only(top: 6), child: Text(_note(n), style: K.small.copyWith(color: K.muted))),
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
