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

const _rejectFr = {
  'video_unreadable': 'La vidéo n’a pas pu être lue. Recommencez l’enregistrement.',
  'mat_not_seen': 'La feuille Khatwa n’était pas assez visible. Gardez toute la feuille dans l’image et tournez plus lentement.',
  'foot_not_seen': 'Le pied n’a pas été reconnu sur assez d’images. Gardez tout le pied dans l’image, à environ 50 cm.',
  'too_few_points': 'Pas assez de détails du pied. Recommencez avec plus de lumière, sans contre-jour.',
  'erased': 'Les données ont été effacées.',
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

  String get _title => 'Scanner le ${sideFr(_side)}';

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
      if (mounted) kToast(context, 'Caméra indisponible. Autorisez la caméra et réessayez.', error: true);
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
      kToast(context, 'Continuez encore un peu : faites tout le tour du pied.');
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
          _reject('Le serveur met trop de temps. Réessayez plus tard.');
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
          _reject(_rejectFr[st['code'] ?? state] ?? 'Le scan n’a pas pu être traité. Recommencez.');
          break;
        }
      }
    } on ServerError {
      _reject('Le serveur a refusé la vidéo. Recommencez.');
    } catch (_) {
      _reject('Envoi impossible. Vérifiez la connexion.');
    }
  }

  void _reject(String message) {
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
      kToast(context, 'Scan supprimé.');
      setState(() {
        _result = null;
        _step = _Step.side;
      });
    } catch (_) {
      if (mounted) kToast(context, 'Suppression impossible. Réessayez.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _Step.side:
        return _page('Scanner mon pied',
            SidePicker(onPick: (s) => setState(() {
                  _side = s;
                  _step = _Step.intro;
                }), title: 'Quel pied allez-vous scanner ?'));
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
              Text(_step == _Step.uploading ? 'Envoi de la vidéo…' : 'Construction de votre pied en 3D…\n(environ 2 minutes)',
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
            FilledButton(onPressed: () => setState(() => _step = _Step.intro), child: const Text('Recommencer')),
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
          const _StepCard(n: 1, text: 'Imprimez la feuille Khatwa à 100 % (taille réelle). Vérifiez la règle de 10 cm.'),
          const _StepCard(n: 2, text: 'Asseyez-vous, pied nu posé à plat, la feuille juste devant les orteils. Pas de pansement ni de chaussette.'),
          const _StepCard(
              n: 3,
              text: 'Une autre personne tient le téléphone à l’horizontale et fait lentement le tour du pied, à environ 50 cm, '
                  'pendant 25 secondes. Le pied et la feuille restent dans l’image.'),
          const _StepCard(n: 4, text: 'Si vous avez une plaie ouverte, ne faites pas de scan : montrez-la à un soignant.'),
          const SizedBox(height: 8),
          FilledButton.icon(
              onPressed: _openCamera,
              icon: const Icon(Icons.videocam_rounded),
              label: const Text(kIsWeb ? 'Filmer mon pied' : 'Ouvrir la caméra')),
        ]),
      );

  Widget _cameraView() {
    final c = _cam!;
    final left = _seconds - _elapsed;
    final tip = !_recording
        ? 'Cadrez le ${sideFr(_side)} et la feuille, puis appuyez sur le bouton.'
        : _elapsed < 8
            ? 'Tournez lentement autour du pied…'
            : _elapsed < 17
                ? 'Continuez, gardez la feuille visible…'
                : 'Encore un peu, finissez le tour.';
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
              label: _recording ? 'Arrêter' : 'Enregistrer',
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
      'Pied scanné',
      ListView(padding: const EdgeInsets.all(16), children: [
        if (mismatch)
          KCard(
            color: K.warnSoft,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('La vidéo ressemble plutôt à un ${sideFr(detected)}. Est-ce bien votre ${sideFr(_side)} ?', style: K.bodyStrong),
              const SizedBox(height: 12),
              FilledButton(onPressed: () => setState(() => _sideConfirmed = true), child: Text('Oui, c’est le ${sideFr(_side)}')),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: _deleteWrongSide, child: const Text('Non : supprimer ce scan et recommencer')),
            ]),
          )
        else ...[
          KCard(
            color: K.primarySoft,
            child: Text('Votre ${sideFr(_side)} en 3D est prêt (${q['views_used'] ?? '?'} vues utilisées).', style: K.bodyStrong),
          ),
          const SizedBox(height: 12),
          KCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final e in measureFr.entries) _row(e.value.$1, fmtMeasure(e.key, m[e.key])),
              const SizedBox(height: 8),
              Text(precisionNote, style: K.small.copyWith(color: K.muted)),
            ]),
          ),
          const SizedBox(height: 12),
          KCard(
            child: Row(children: [
              Icon(Icons.flip_rounded, color: K.primary),
              const SizedBox(width: 12),
              Expanded(
                  child: Text('Le scan ne voit pas la plante du pied. Ajoutez une photo de la plante pour la voir en 3D.',
                      style: K.body)),
            ]),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (_) => PhotoSignPage(side: _side, sole: true))),
            icon: const Icon(Icons.photo_camera_rounded),
            label: const Text('Photographier la plante'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => TwinPage(side: _side))),
            child: const Text('Voir mon pied en 3D'),
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
