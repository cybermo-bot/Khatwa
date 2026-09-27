import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/khatwa_server.dart';
import '../../ui/app_theme.dart';
import '../common.dart';
import 'twin_page.dart';

const _views = [
  ('plantar', 'Plante du pied'),
  ('dorsal', 'Dessus du pied'),
  ('toes', 'Orteils'),
  ('medial', 'Bord intérieur'),
  ('lateral', 'Bord extérieur'),
  ('posterior', 'Arrière du talon'),
];
// The serious kinds first, "Je ne sais pas" last. Nothing is preselected.
const _kinds = [
  'wound', 'colour', 'blister', 'redness', 'swelling', 'callus', 'corn', 'heel-cracks', 'fungus', 'nails', 'dry-skin',
  'other', 'unsure',
];
const _backRegions = ['heel_posterior', 'heel_plantar', 'ankle'];

/// A photo of the foot on the 3D twin. With `sole`, the photo of the sole is
/// placed on the twin's sole (2 to 3 mm on straight-on photos) and shown there
/// in 3D; any photo can then carry a sign the patient marks with a touch,
/// which gets the triage table's advice.
class PhotoSignPage extends StatefulWidget {
  final String? side;
  final bool sole;
  const PhotoSignPage({super.key, this.side, this.sole = false});

  @override
  State<PhotoSignPage> createState() => _PhotoSignPageState();
}

class _PhotoSignPageState extends State<PhotoSignPage> {
  final _server = KhatwaServer();
  late String? _side = widget.side;
  late String _view = widget.sole ? 'plantar' : 'dorsal';
  String? _kind;
  String _backRegion = 'heel_posterior';
  Uint8List? _photo;
  Size? _imageSize;
  Map<String, dynamic>? _uploaded;
  final _points = <Offset>[];
  bool _busy = false;
  bool _marking = false;
  Map<String, dynamic>? _placed;
  Map<String, dynamic>? _advice;

  void _resetPhoto() {
    _photo = null;
    _imageSize = null;
    _uploaded = null;
    _points.clear();
    _placed = null;
    _advice = null;
    _marking = false;
  }

  Future<void> _take(ImageSource src) async {
    final x = await ImagePicker().pickImage(source: src, imageQuality: 90, maxWidth: 2000);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    final img = await decodeImageFromList(bytes);
    setState(() {
      _resetPhoto();
      _photo = bytes;
      _imageSize = Size(img.width.toDouble(), img.height.toDouble());
      _busy = true;
    });
    try {
      final r = await _server.addPhoto(bytes, _view, today(), _side!);
      setState(() => _uploaded = r);
      if (r['mapped'] != true && mounted) {
        kToast(
            context,
            _view == 'plantar'
                ? 'Plante non reconnue. Reprenez la photo bien en face, à environ 40 cm, toute la plante dans l’image.'
                : 'Le pied n’a pas été reconnu. Reprenez la photo de plus près, bien éclairée.',
            error: true);
      }
    } on ServerError catch (e) {
      if (mounted) kToast(context, e.status == 409 ? 'Scannez d’abord ce pied en 3D.' : 'Photo refusée par le serveur.', error: true);
    } catch (_) {
      if (mounted) kToast(context, 'Pas de connexion au serveur Khatwa.', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final kind = _kind;
    if (kind == null) return;
    setState(() => _busy = true);
    try {
      final Map<String, dynamic> r;
      if (_view == 'posterior') {
        r = await _server.addFinding(side: _side!, kind: kind, day: today(), region: _backRegion, language: langCode());
      } else {
        if (_uploaded == null || _points.isEmpty) return;
        r = await _server.addFinding(
          side: _side!,
          kind: kind,
          day: today(),
          photoId: _uploaded!['id'] as String,
          points: [for (final p in _points) [p.dx, p.dy]],
          language: langCode(),
        );
      }
      setState(() {
        _placed = r['finding'] as Map<String, dynamic>;
        _advice = r['advice'] as Map<String, dynamic>?;
      });
    } on ServerError catch (e) {
      if (mounted) {
        kToast(
            context,
            e.status == 409
                ? 'Scannez d’abord ce pied en 3D.'
                : e.status == 422
                    ? 'L’endroit touché n’est pas sur le pied. Touchez le pied sur la photo.'
                    : 'Enregistrement impossible.',
            error: true);
      }
    } catch (_) {
      if (mounted) kToast(context, 'Pas de connexion au serveur Khatwa.', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final side = _side;
    final title = widget.sole ? 'Plante du pied' : 'Noter un signe';
    if (side == null) {
      return _scaffold(title, SidePicker(onPick: (s) => setState(() => _side = s)));
    }
    final back = _view == 'posterior';
    final soleMapped = _view == 'plantar' && _uploaded?['sole'] == true;
    final ready = _kind != null && (back || (_uploaded?['mapped'] == true && _points.isNotEmpty));
    return _scaffold(
      '${widget.sole ? 'Plante' : 'Signe'} : ${sideFr(side)}',
      ListView(padding: const EdgeInsets.all(16), children: [
        if (!widget.sole) ...[
          Text('Quelle partie du pied ?', style: K.bodyStrong),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final (code, label) in _views)
              ChoiceChip(
                label: Text(label),
                selected: _view == code,
                onSelected: (_) => setState(() {
                  _view = code;
                  _resetPhoto();
                }),
              ),
          ]),
          const SizedBox(height: 16),
        ],
        if (_view == 'plantar' && _photo == null)
          KCard(
            color: K.primarySoft,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Pour une bonne photo de la plante', style: K.bodyStrong),
              const SizedBox(height: 6),
              Text(
                  'Asseyez-vous, la cheville posée sur l’autre genou. Une autre personne prend la photo bien en face de la plante, '
                  'à environ 40 cm, toute la plante dans l’image, avec une bonne lumière.',
                  style: K.body),
            ]),
          ),
        if (back) ...[
          KCard(
            color: K.primarySoft,
            child: Text('Les photos de l’arrière du talon ne peuvent pas être placées automatiquement. Choisissez l’endroit :',
                style: K.body),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final code in _backRegions)
              ChoiceChip(
                  label: Text(regionFr[code] ?? code),
                  selected: _backRegion == code,
                  onSelected: (_) => setState(() => _backRegion = code)),
          ]),
        ] else ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _busy ? null : () => _take(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_rounded),
                label: const Text('Photo'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : () => _take(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_rounded),
                label: const Text('Galerie'),
              ),
            ),
          ]),
          if (_busy && _placed == null) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
            const SizedBox(height: 4),
            Text(_view == 'plantar' ? 'Placement de la plante sur votre pied 3D…' : 'Lecture de la photo…',
                style: K.small.copyWith(color: K.muted)),
          ],
          if (soleMapped) ...[
            const SizedBox(height: 12),
            KCard(
              color: K.okSoft,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Icon(Icons.check_circle_rounded, color: K.ok),
                  const SizedBox(width: 10),
                  Expanded(child: Text('La plante est maintenant sur votre pied en 3D.', style: K.bodyStrong)),
                ]),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (_) => TwinPage(side: side, showSole: true))),
                  child: const Text('Voir ma plante en 3D'),
                ),
                if (!_marking)
                  TextButton(onPressed: () => setState(() => _marking = true), child: const Text('Noter un signe sur cette photo')),
              ]),
            ),
          ],
          if (_photo != null && (!widget.sole || _marking || _view != 'plantar')) ...[
            const SizedBox(height: 12),
            Text('Touchez l’endroit. Plusieurs touches entourent une zone.', style: K.small.copyWith(color: K.muted)),
            const SizedBox(height: 8),
            _TapImage(bytes: _photo!, imageSize: _imageSize!, points: _points, onTap: (p) => setState(() => _points.add(p))),
            Row(children: [
              TextButton(
                  onPressed: _points.isEmpty ? null : () => setState(() => _points.removeLast()),
                  child: const Text('Annuler la dernière touche')),
              TextButton(onPressed: _points.isEmpty ? null : () => setState(_points.clear), child: const Text('Tout effacer')),
            ]),
          ],
        ],
        if (back || _marking || !widget.sole) ...[
          const SizedBox(height: 12),
          Text('Qu’est-ce que c’est ?', style: K.bodyStrong),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final code in _kinds)
              ChoiceChip(
                label: Text(kindFr[code] ?? code),
                selected: _kind == code,
                onSelected: (_) => setState(() {
                  _kind = code;
                  _placed = null;
                  _advice = null;
                }),
              ),
          ]),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy || !ready ? null : _save,
            child: _busy && _uploaded != null
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Placer sur mon pied 3D'),
          ),
          if (_kind == null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Choisissez ce que c’est, ou « Je ne sais pas ».', style: K.small.copyWith(color: K.muted)),
            ),
        ],
        if (_placed != null) ...[
          const SizedBox(height: 12),
          AdviceCard(
            level: (_advice?['level'] ?? 'none') as String,
            message: (_advice?['message'] ?? '') as String,
            lead: '${kindFr[_placed!['kind']] ?? _placed!['kind']} noté : ${regionFr[_placed!['region']] ?? _placed!['region']}'
                '${_placed!['area_mm2'] != null && _placed!['source'] == 'sole_photo' ? ', environ ${(_placed!['area_mm2'] as num).round()} mm²' : ''}.',
          ),
        ],
        if (kIsWeb) const SizedBox(height: 24),
      ]),
    );
  }

  Widget _scaffold(String title, Widget body) => Scaffold(
        backgroundColor: K.ground,
        appBar: AppBar(title: Text(title), backgroundColor: K.ground, foregroundColor: K.ink),
        body: body,
      );
}

class _TapImage extends StatelessWidget {
  final Uint8List bytes;
  final Size imageSize;
  final List<Offset> points;
  final ValueChanged<Offset> onTap;
  const _TapImage({required this.bytes, required this.imageSize, required this.points, required this.onTap});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final scale = box.maxWidth / imageSize.width;
        final h = imageSize.height * scale;
        return GestureDetector(
          onTapUp: (d) => onTap(d.localPosition / scale), // widget pixels to photo pixels
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: box.maxWidth,
              height: h,
              child: Stack(fit: StackFit.expand, children: [
                Image.memory(bytes, fit: BoxFit.fill),
                CustomPaint(painter: _PointsPainter([for (final p in points) p * scale])),
              ]),
            ),
          ),
        );
      });
}

class _PointsPainter extends CustomPainter {
  final List<Offset> pts;
  _PointsPainter(this.pts);
  @override
  void paint(Canvas canvas, Size size) {
    const dot = Color(0xFF07131A);
    final ring = Paint()
      ..color = const Color(0xFF19C3B5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    if (pts.length >= 3) {
      canvas.drawPath(ui.Path()..addPolygon(pts, true), Paint()..color = const Color(0x5519C3B5));
    }
    for (final p in pts) {
      canvas.drawCircle(p, 9, Paint()..color = dot);
      canvas.drawCircle(p, 9, ring);
    }
  }

  @override
  bool shouldRepaint(covariant _PointsPainter old) => true;
}
