import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'cloud.dart';

class ServerError implements Exception {
  final int status;
  final String message;
  ServerError(this.status, this.message);
  @override
  String toString() => message;
}

/// The Khatwa compute server: 3D reconstruction, photo and sole mapping, the
/// voice assistant and FHIR export. It is found through Supabase (its address
/// changes with the tunnel) and trusts the patient's Supabase sign-in.
/// Files travel as bytes so the same code runs on Android and in the browser.
class KhatwaServer {
  KhatwaServer({http.Client? client}) : _http = client ?? http.Client();
  final http.Client _http;

  KhatwaCloud get _cloud => KhatwaCloud.instance;
  String get _base => _cloud.serverUrl;
  String get _p => _cloud.patientRef ?? '';

  Uri _u(String path, [Map<String, String>? q]) => Uri.parse('$_base$path').replace(queryParameters: q);

  Future<Map<String, String>> _auth() async {
    await _cloud.ensurePatient();
    final t = _cloud.accessToken;
    return t == null ? {} : {'Authorization': 'Bearer $t'};
  }

  dynamic _json(http.Response r) {
    final body = utf8.decode(r.bodyBytes);
    if (r.statusCode >= 400) {
      String msg = body;
      try {
        msg = (jsonDecode(body) as Map)['detail']?.toString() ?? body;
      } catch (_) {}
      throw ServerError(r.statusCode, msg);
    }
    return body.isEmpty ? null : jsonDecode(body);
  }

  Future<Map<String, dynamic>> health() async =>
      _json(await _http.get(_u('/health')).timeout(const Duration(seconds: 8)));

  // ---------------------------------------------------------------- voice

  Future<Map<String, dynamic>> voiceTurn({
    Uint8List? audio,
    String audioMime = 'audio/mp4',
    String? text,
    required List<Map<String, String>> history,
    required String language,
    bool allowModel = true,
  }) async {
    final req = http.MultipartRequest('POST', _u('/voice/turn'))
      ..headers.addAll(await _auth())
      ..fields['history'] = jsonEncode(history)
      ..fields['language'] = language
      ..fields['allow_model'] = allowModel.toString()
      ..fields['speak'] = 'false';
    if (_p.isNotEmpty) req.fields['patient'] = _p;
    if (text != null) req.fields['text'] = text;
    if (audio != null) {
      final parts = audioMime.split('/');
      req.files.add(http.MultipartFile.fromBytes('audio', audio,
          filename: 'voice.${parts.last == 'mp4' ? 'm4a' : parts.last}', contentType: MediaType(parts.first, parts.last)));
    }
    return _json(await http.Response.fromStream(await _http.send(req).timeout(const Duration(seconds: 60))));
  }

  /// Audio of an answer, or null when the phone should speak it itself.
  Future<({Uint8List bytes, String mime})?> speak(String text, String language) async {
    final r = await _http
        .post(_u('/voice/speak'), headers: await _auth(), body: {'text': text, 'language': language})
        .timeout(const Duration(seconds: 60));
    if (r.statusCode == 204) return null;
    if (r.statusCode >= 400) _json(r);
    return (bytes: r.bodyBytes, mime: r.headers['content-type'] ?? 'audio/wav');
  }

  // ---------------------------------------------------------------- twin

  Future<String> createScan(Uint8List video, String filename, String side) async {
    final req = http.MultipartRequest('POST', _u('/twin/scans'))
      ..headers.addAll(await _auth())
      ..fields['patient'] = _p
      ..fields['side'] = side
      ..fields['mat_name'] = 'khatwa-a4-v1'
      ..files.add(http.MultipartFile.fromBytes('video', video, filename: filename));
    final r = await http.Response.fromStream(await _http.send(req).timeout(const Duration(minutes: 5)));
    return (_json(r) as Map)['scan_id'] as String;
  }

  Future<Map<String, dynamic>> scanStatus(String id) async =>
      _json(await _http.get(_u('/twin/scans/$id'), headers: await _auth()).timeout(const Duration(seconds: 20)));

  Future<void> deleteScan(String id) async =>
      _json(await _http.delete(_u('/twin/patients/$_p/scans/$id'), headers: await _auth()));

  Future<List<dynamic>> history(String side) async =>
      (_json(await _http.get(_u('/twin/patients/$_p/$side/history'), headers: await _auth())) as Map)['scans'] as List;

  Future<Uint8List> model(String scanId, {String look = 'skin'}) async {
    final r = await _http.get(_u('/twin/patients/$_p/scans/$scanId/model.glb', {'look': look}), headers: await _auth());
    if (r.statusCode >= 400) _json(r);
    return r.bodyBytes;
  }

  Future<Map<String, dynamic>> change(String side) async =>
      _json(await _http.get(_u('/twin/patients/$_p/$side/change'), headers: await _auth()));

  Future<Map<String, dynamic>> addPhoto(Uint8List photo, String view, String day, String side) async {
    final req = http.MultipartRequest('POST', _u('/twin/photos'))
      ..headers.addAll(await _auth())
      ..fields['patient'] = _p
      ..fields['side'] = side
      ..fields['view'] = view
      ..fields['day'] = day
      ..files.add(http.MultipartFile.fromBytes('photo', photo, filename: 'photo.jpg', contentType: MediaType('image', 'jpeg')));
    return _json(await http.Response.fromStream(await _http.send(req).timeout(const Duration(minutes: 2))));
  }

  /// Returns {"finding": ..., "advice": {"level": none|soon|urgent, "message": ...}}.
  Future<Map<String, dynamic>> addFinding({
    required String side,
    required String kind,
    required String day,
    String? photoId,
    List<List<double>>? points,
    String? region,
    String language = 'fr',
  }) async {
    final fields = {
      'patient': _p,
      'side': side,
      'kind': kind,
      'day': day,
      'language': language,
      if (photoId != null) 'photo_id': photoId,
      if (points != null) 'points': jsonEncode(points),
      if (region != null) 'region': region,
    };
    return _json(await _http.post(_u('/twin/findings'), headers: await _auth(), body: fields));
  }

  Future<Map<String, dynamic>> findings(String side) async =>
      _json(await _http.get(_u('/twin/patients/$_p/$side/findings'), headers: await _auth()));

  /// The FHIR R4 Bundle of this patient's twin and findings.
  Future<Map<String, dynamic>> fhir() async =>
      _json(await _http.get(_u('/twin/patients/$_p/fhir'), headers: await _auth()));
}
