import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/khatwa_server.dart';
import '../../ui/app_theme.dart';
import '../common.dart';
import 'photo_sign_page.dart';
import 'twin_page.dart';

/// Guided 3D scan: which foot, instructions, a 25 second landscape video
/// circling the foot (the phone's camera app in the browser), then the server
/// builds the twin. Next step offered: the photo of the sole.
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

enum _Step { side, intro, camera, uploading, processing, done, rejected }

String? _reject(Object? code) => switch (code) {
      'video_unreadable' => tr('La vidéo n’a pas pu être lue. Recommencez l’enregistrement.',
          aeb: 'الفيديو ما تقراش. عاود صوّر.', ar: 'تعذّرت قراءة الفيديو. أعد التسجيل.', en: 'The video could not be read. Record it again.'),
      'mat_not_seen' => tr('La feuille Khatwa n’était pas assez visible. Gardez toute la feuille dans l’image et tournez plus lentement.',
          aeb: 'ورقة خطوة ما بانتش مليح. خلّي الورقة الكل في التصويرة ودور بشوية.',
          ar: 'ورقة خطوة لم تكن واضحة بما يكفي. أبقِ الورقة كاملة في الصورة ودُر ببطء أكثر.',
          en: 'The Khatwa sheet was not visible enough. Keep the whole sheet in the picture and turn more slowly.'),
      'foot_not_seen' => tr('Le pied n’a pas été reconnu sur assez d’images. Gardez tout le pied dans l’image, à environ 50 cm.',
          aeb: 'الساق ما تعرفتش في تصاور كافية. خلّي الساق الكل في التصويرة، على بعد 50 صم تقريب.',
          ar: 'لم يُتعرّف على القدم في صور كافية. أبقِ القدم كاملة في الصورة، على بعد 50 سم تقريبًا.',
          en: 'The foot was not recognised in enough frames. Keep the whole foot in the picture, about 50 cm away.'),
      'too_few_points' => tr('Pas assez de détails du pied. Recommencez avec plus de lumière, sans contre-jour.',
          aeb: 'تفاصيل الساق موش كافية. عاود مع ضو أكثر، والضو موش من التالي.',
          ar: 'تفاصيل القدم غير كافية. أعد المحاولة بإضاءة أكثر ودون إضاءة خلفية.',
          en: 'Not enough detail of the foot. Try again with more light, not against the light.'),
      'erased' => tr('Les données ont été effacées.', aeb: 'المعطيات تفسخت.', ar: 'حُذفت البيانات.', en: 'The data was erased.'),
      _ => null,
    };

class _ScanPageState extends State<ScanPage> {
  static const _seconds = 25;
  static const _minSeconds = 12;
  final _server = KhatwaServer();
  _Step _step = _Step.side;
  String _side = 'L';
  CameraController? _cam;
  Timer? _timer;
  int _elapsed = 0;
  bool _recording = false;
  String _message = '';
  Map<String, dynamic>? _result;
  bool _sideConfirmed = false;

  @override
  void dispose() {
    _timer?.cancel();
    _cam?.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  String get _title => tr('Scanner le ${sideName(_side)}',
      aeb: 'سكان ${sideName(_side)}', ar: 'مسح ${sideName(_side)}', en: 'Scan the ${sideName(_side)}');

  Future<void> _openCamera() async {
    if (kIsWeb) {
      // In the browser the phone's own camera app films; it returns the video.
      final x = await ImagePicker().pickVideo(source: ImageSource.camera, maxDuration: const Duration(seconds: 30));
      if (x != null) await _upload(await x.readAsBytes(), x.name.isEmpty ? 'scan.mp4' : x.name);
      return;
    }
    try {
      final cams = await availableCameras();
      final back = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cams.first);
      await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      final c = CameraController(back, ResolutionPreset.high, enableAudio: false);
      await c.initialize();
      await c.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
      setState(() {
        _cam = c;
        _step = _Step.camera;
      });
    } catch (e) {
      if (mounted) {
        kToast(
            context,
            tr('Caméra indisponible. Autorisez la caméra et réessayez.',
                aeb: 'الكاميرا موش متوفرة. اسمح بالكاميرا وعاود.',
                ar: 'الكاميرا غير متاحة. اسمح بالكاميرا وأعد المحاولة.',
                en: 'Camera unavailable. Allow the camera and try again.'),
            error: true);
      }
    }
  }

  Future<void> _record() async {
    final c = _cam;
    if (c == null || _recording) return;
    try {
      await c.setFocusMode(FocusMode.auto);
      await c.setExposureMode(ExposureMode.auto);
    } catch (_) {}
    await c.startVideoRecording();
    HapticFeedback.mediumImpact();
    setState(() {
      _recording = true;
      _elapsed = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _elapsed++);
      // After the first second, focus and exposure stay fixed while circling.
      if (_elapsed == 1) _lockCamera(c);
      if (_elapsed >= _seconds) _finish();
    });
  }

  Future<void> _lockCamera(CameraController c) async {
    try {
      await c.setFocusMode(FocusMode.locked);
    } catch (_) {}
    try {
      await c.setExposureMode(ExposureMode.locked);
    } catch (_) {}
  }

  void _stopTapped() {
    if (_elapsed < _minSeconds) {
      kToast(
          context,
          tr('Continuez encore un peu : faites tout le tour du pied.',
              aeb: 'كمّل شوية: دور على الساق الكل.', ar: 'واصل قليلًا: دُر حول القدم كاملة.', en: 'Keep going a little: go all the way round the foot.'));
      return;
    }
    _finish();
  }

  Future<void> _finish() async {
    _timer?.cancel();
    final c = _cam;
    if (c == null || !_recording) return;
    final file = await c.stopVideoRecording();
    HapticFeedback.lightImpact();
    setState(() => _recording = false);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    await c.dispose();
    _cam = null;
    await _upload(await file.readAsBytes(), 'scan.mp4');
  }

  Future<void> _upload(Uint8List video, String name) async {
    setState(() => _step = _Step.uploading);
    try {
      final id = await _server.createScan(video, name, _side);
      setState(() => _step = _Step.processing);
      final deadline = DateTime.now().add(const Duration(minutes: 10));
      while (mounted) {
        await Future.delayed(const Duration(seconds: 3));
        if (DateTime.now().isAfter(deadline)) {
          _fail(tr('Le serveur met trop de temps. Réessayez plus tard.',
              aeb: 'السيرفر طوّل برشة. عاود من بعد.', ar: 'الخادم يستغرق وقتًا طويلًا. أعد المحاولة لاحقًا.', en: 'The server is taking too long. Try again later.'));
          break;
        }
        final Map<String, dynamic> st;
        try {
          st = await _server.scanStatus(id);
        } on ServerError {
          rethrow;
        } catch (_) {
          continue;
        }
        final state = st['state'];
        if (state == 'done') {
          setState(() {
            _result = st['result'] as Map<String, dynamic>;
            _sideConfirmed = false;
            _step = _Step.done;
          });
          break;
        }
        if (state == 'rejected' || state == 'failed' || state == 'erased') {
          _fail(_reject(st['code'] ?? state) ??
              tr('Le scan n’a pas pu être traité. Recommencez.',
                  aeb: 'السكان ما تعالجش. عاود.', ar: 'تعذّرت معالجة المسح. أعد المحاولة.', en: 'The scan could not be processed. Try again.'));
          break;
        }
      }
    } on ServerError {
      _fail(tr('Le serveur a refusé la vidéo. Recommencez.',
          aeb: 'السيرفر رفض الفيديو. عاود.', ar: 'رفض الخادم الفيديو. أعد المحاولة.', en: 'The server refused the video. Try again.'));
    } catch (_) {
      _fail(tr('Envoi impossible. Vérifiez la connexion.',
          aeb: 'ما نجمناش نبعثو. ثبّت في الكونكسيون.', ar: 'تعذّر الإرسال. تحقّق من الاتصال.', en: 'Could not send. Check the connection.'));
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _message = message;
      _step = _Step.rejected;
    });
  }

  Future<void> _deleteWrongSide() async {
    final id = _result?['id'] as String?;
    if (id == null) return;
    try {
      await _server.deleteScan(id);
      if (!mounted) return;
      kToast(context, tr('Scan supprimé.', aeb: 'السكان تفسخ.', ar: 'حُذف المسح.', en: 'Scan deleted.'));
      setState(() {
        _result = null;
        _step = _Step.side;
      });
    } catch (_) {
      if (mounted) {
        kToast(context, tr('Suppression impossible. Réessayez.', aeb: 'ما نجمناش نفسخو. عاود.', ar: 'تعذّر الحذف. أعد المحاولة.', en: 'Could not delete. Try again.'),
            error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _Step.side:
        return _page(
            tr('Scanner mon pied', aeb: 'اعمل سكان لساقي', ar: 'امسح قدمي', en: 'Scan my foot'),
            SidePicker(
                onPick: (s) => setState(() {
                      _side = s;
                      _step = _Step.intro;
                    }),
                title: tr('Quel pied allez-vous scanner ?', aeb: 'أما ساق باش تعمللها سكان؟', ar: 'أي قدم ستمسح؟', en: 'Which foot will you scan?')));
      case _Step.camera:
        return _cameraView();
      case _Step.intro:
        return _intro();
      case _Step.uploading:
      case _Step.processing:
        return _page(
          _title,
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                  _step == _Step.uploading
                      ? tr('Envoi de la vidéo…', aeb: 'قاعدين نبعثو في الفيديو…', ar: 'جارٍ إرسال الفيديو…', en: 'Sending the video…')
                      : tr('Construction de votre pied en 3D…\n(environ 2 minutes)',
                          aeb: 'قاعدين نبنيو ساقك في 3D…\n(دقيقتين تقريب)',
                          ar: 'جارٍ بناء قدمك ثلاثية الأبعاد…\n(دقيقتان تقريبًا)',
                          en: 'Building your 3D foot…\n(about 2 minutes)'),
                  textAlign: TextAlign.center, style: K.body),
            ]),
          ),
          back: false,
        );
      case _Step.done:
        return _done();
      case _Step.rejected:
        return _page(
          _title,
          ListView(padding: const EdgeInsets.all(16), children: [
            KCard(color: K.warnSoft, child: Text(_message, style: K.body)),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: () => setState(() => _step = _Step.intro),
                child: Text(tr('Recommencer', aeb: 'عاود', ar: 'أعد المحاولة', en: 'Start again'))),
          ]),
        );
    }
  }

  Widget _page(String title, Widget body, {bool back = true}) => Scaffold(
        backgroundColor: K.ground,
        appBar: AppBar(title: Text(title), automaticallyImplyLeading: back, backgroundColor: K.ground, foregroundColor: K.ink),
        body: body,
      );

  Widget _intro() => _page(
        _title,
        ListView(padding: const EdgeInsets.all(16), children: [
          _StepCard(
              n: 1,
              text: tr('Imprimez la feuille Khatwa à 100 % (taille réelle). Vérifiez la règle de 10 cm.',
                  aeb: 'اطبع ورقة خطوة بـ 100 % (القياس الحقيقي). ثبّت في المسطرة متاع 10 صم.',
                  ar: 'اطبع ورقة خطوة بنسبة 100 % (الحجم الحقيقي). تحقّق من مسطرة 10 سم.',
                  en: 'Print the Khatwa sheet at 100 % (actual size). Check the 10 cm ruler.')),
          _StepCard(
              n: 2,
              text: tr('Asseyez-vous, pied nu posé à plat, la feuille juste devant les orteils. Pas de pansement ni de chaussette.',
                  aeb: 'اقعد، ساقك حافية على الأرض، والورقة قدّام الصوابع. بلا ضمادة وبلا كلسيطة.',
                  ar: 'اجلس، القدم حافية ومسطحة، والورقة أمام الأصابع مباشرة. دون ضمادة أو جورب.',
                  en: 'Sit down, bare foot flat, the sheet just in front of the toes. No dressing, no sock.')),
          _StepCard(
              n: 3,
              text: tr(
                  'Une autre personne tient le téléphone à l’horizontale et fait lentement le tour du pied, à environ 50 cm, '
                      'pendant 25 secondes. Le pied et la feuille restent dans l’image.',
                  aeb: 'واحد آخر يشدّ التليفون بالعرض ويدور بشوية على الساق، على بعد 50 صم تقريب، مدة 25 ثانية. الساق والورقة يقعدو في التصويرة.',
                  ar: 'يمسك شخص آخر الهاتف أفقيًا ويدور ببطء حول القدم، على بعد 50 سم تقريبًا، لمدة 25 ثانية. تبقى القدم والورقة في الصورة.',
                  en: 'Someone else holds the phone sideways and slowly circles the foot, about 50 cm away, '
                      'for 25 seconds. The foot and the sheet stay in the picture.')),
          _StepCard(
              n: 4,
              text: tr('Si vous avez une plaie ouverte, ne faites pas de scan : montrez-la à un soignant.',
                  aeb: 'كان عندك جرح مفتوح، ما تعملش سكان: ورّيه للطبيب.',
                  ar: 'إذا كان لديك جرح مفتوح فلا تقم بالمسح: اعرضه على الطبيب.',
                  en: 'If you have an open wound, do not scan: show it to a health professional.')),
          const SizedBox(height: 8),
          FilledButton.icon(
              onPressed: _openCamera,
              icon: const Icon(Icons.videocam_rounded),
              label: Text(kIsWeb
                  ? tr('Filmer mon pied', aeb: 'صوّر ساقي فيديو', ar: 'صوّر قدمي فيديو', en: 'Film my foot')
                  : tr('Ouvrir la caméra', aeb: 'حلّ الكاميرا', ar: 'افتح الكاميرا', en: 'Open the camera'))),
        ]),
      );

  Widget _cameraView() {
    final c = _cam!;
    final left = _seconds - _elapsed;
    final tip = !_recording
        ? tr('Cadrez le ${sideName(_side)} et la feuille, puis appuyez sur le bouton.',
            aeb: 'حط ${sideName(_side)} والورقة في التصويرة، ومبعد اضغط على الزر.',
            ar: 'ضع ${sideName(_side)} والورقة في الإطار، ثم اضغط على الزر.',
            en: 'Frame the ${sideName(_side)} and the sheet, then press the button.')
        : _elapsed < 8
            ? tr('Tournez lentement autour du pied…', aeb: 'دور بشوية على الساق…', ar: 'دُر ببطء حول القدم…', en: 'Slowly circle the foot…')
            : _elapsed < 17
                ? tr('Continuez, gardez la feuille visible…', aeb: 'كمّل، خلّي الورقة باينة…', ar: 'واصل، وأبقِ الورقة ظاهرة…', en: 'Keep going, keep the sheet visible…')
                : tr('Encore un peu, finissez le tour.', aeb: 'شوية أخرى، كمّل الدورة.', ar: 'قليلًا بعد، أكمل الدورة.', en: 'A little more, finish the circle.');
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(fit: StackFit.expand, children: [
        Center(child: CameraPreview(c)),
        Positioned(
          left: 16,
          top: 16,
          right: 120,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(14)),
            child: Text(tip, style: const TextStyle(color: Colors.white, fontSize: 17)),
          ),
        ),
        Positioned(
          right: 24,
          top: 0,
          bottom: 0,
          child: Center(
            child: Semantics(
              button: true,
              label: _recording
                  ? tr('Arrêter', aeb: 'وقّف', ar: 'إيقاف', en: 'Stop')
                  : tr('Enregistrer', aeb: 'سجّل', ar: 'تسجيل', en: 'Record'),
              child: GestureDetector(
                onTap: _recording ? _stopTapped : _record,
                child: SizedBox(
                  width: 92,
                  height: 92,
                  child: Stack(alignment: Alignment.center, children: [
                    CircularProgressIndicator(
                        value: _recording ? _elapsed / _seconds : 0,
                        strokeWidth: 6,
                        color: Colors.white,
                        backgroundColor: Colors.white24),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(color: _recording ? K.danger : Colors.white, shape: BoxShape.circle),
                      child: _recording
                          ? Center(
                              child: Text('$left',
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)))
                          : Icon(Icons.fiber_manual_record_rounded, color: K.danger, size: 40),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _done() {
    final m = (_result?['measurements'] ?? {}) as Map;
    final q = (_result?['quality'] ?? {}) as Map;
    final detected = q['side_detected'] as String?;
    final mismatch = detected != null && detected != _side && !_sideConfirmed;
    return _page(
      tr('Pied scanné', aeb: 'الساق تعمللها سكان', ar: 'تم مسح القدم', en: 'Foot scanned'),
      ListView(padding: const EdgeInsets.all(16), children: [
        if (mismatch)
          KCard(
            color: K.warnSoft,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(
                  tr('La vidéo ressemble plutôt à un ${sideName(detected)}. Est-ce bien votre ${sideName(_side)} ?',
                      aeb: 'الفيديو يشبه أكثر لـ ${sideName(detected)}. متأكد إنها ${sideName(_side)}؟',
                      ar: 'يبدو الفيديو أقرب إلى ${sideName(detected)}. هل هي فعلًا ${sideName(_side)}؟',
                      en: 'The video looks more like a ${sideName(detected)}. Is it really your ${sideName(_side)}?'),
                  style: K.bodyStrong),
              const SizedBox(height: 12),
              FilledButton(
                  onPressed: () => setState(() => _sideConfirmed = true),
                  child: Text(tr('Oui, c’est le ${sideName(_side)}',
                      aeb: 'إيه، هي ${sideName(_side)}', ar: 'نعم، إنها ${sideName(_side)}', en: 'Yes, it is the ${sideName(_side)}'))),
              const SizedBox(height: 8),
              OutlinedButton(
                  onPressed: _deleteWrongSide,
                  child: Text(tr('Non : supprimer ce scan et recommencer',
                      aeb: 'لا: افسخ السكان هذا وعاود', ar: 'لا: احذف هذا المسح وأعد', en: 'No: delete this scan and start again'))),
            ]),
          )
        else ...[
          KCard(
            color: K.primarySoft,
            child: Text(
                tr('Votre ${sideName(_side)} en 3D est prêt (${q['views_used'] ?? '?'} vues utilisées).',
                    aeb: '${sideName(_side)} في 3D حاضرة (${q['views_used'] ?? '?'} تصويرة مستعملة).',
                    ar: '${sideName(_side)} ثلاثية الأبعاد جاهزة (${q['views_used'] ?? '?'} صورة مستخدمة).',
                    en: 'Your ${sideName(_side)} in 3D is ready (${q['views_used'] ?? '?'} views used).'),
                style: K.bodyStrong),
          ),
          const SizedBox(height: 12),
          KCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final key in measurePrecision.keys) _row(measureName(key), fmtMeasure(key, m[key])),
              const SizedBox(height: 8),
              Text(precisionNote(), style: K.small.copyWith(color: K.muted)),
            ]),
          ),
          const SizedBox(height: 12),
          KCard(
            child: Row(children: [
              Icon(Icons.flip_rounded, color: K.primary),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(
                      tr('Le scan ne voit pas la plante du pied. Ajoutez une photo de la plante pour la voir en 3D.',
                          aeb: 'السكان ما يشوفش تحت الساق. زيد تصويرة لتحت الساق باش تشوفها في 3D.',
                          ar: 'المسح لا يرى باطن القدم. أضف صورة لباطن القدم لتراه ثلاثي الأبعاد.',
                          en: 'The scan cannot see the sole. Add a photo of the sole to see it in 3D.'),
                      style: K.body)),
            ]),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (_) => PhotoSignPage(side: _side, sole: true))),
            icon: const Icon(Icons.photo_camera_rounded),
            label: Text(tr('Photographier la plante', aeb: 'صوّر تحت الساق', ar: 'صوّر باطن القدم', en: 'Photograph the sole')),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => TwinPage(side: _side))),
            child: Text(tr('Voir mon pied en 3D', aeb: 'شوف ساقي في 3D', ar: 'اعرض قدمي ثلاثية الأبعاد', en: 'See my foot in 3D')),
          ),
        ],
      ]),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(child: Text(label, style: K.body.copyWith(color: K.inkSoft))),
          Text(value, style: K.bodyStrong.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
        ]),
      );
}

class _StepCard extends StatelessWidget {
  final int n;
  final String text;
  const _StepCard({required this.n, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: KCard(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
                radius: 16,
                backgroundColor: K.primarySoft,
                child: Text('$n', style: TextStyle(color: K.primary, fontWeight: FontWeight.w700))),
            const SizedBox(width: 14),
            Expanded(child: Text(text, style: K.body)),
          ]),
        ),
      );
}
