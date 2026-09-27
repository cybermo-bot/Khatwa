import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared data for the demo: the patient's twin, findings and alerts live in
/// Supabase so the doctor dashboard sees them. The patient is signed in
/// anonymously and known only by a pseudonym and a random reference: no name
/// or phone number from the local account ever leaves the phone.
///
/// Everything here fails softly: without a network the app keeps working on
/// the phone, and the 3D and voice features say they need a connection.
class KhatwaCloud extends ChangeNotifier {
  KhatwaCloud._();
  static final KhatwaCloud instance = KhatwaCloud._();

  // The publishable key is meant to ship in apps; row-level security protects the data.
  static const _url = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://tycubqajrtfbivypfthe.supabase.co');
  static const _key =
      String.fromEnvironment('SUPABASE_KEY', defaultValue: 'sb_publishable_c0a9zBxyO3EDzqMSgVbp-w_QALR1fRh');
  static const _fallbackServer = String.fromEnvironment('KHATWA_SERVER', defaultValue: 'http://127.0.0.1:8765');

  bool ready = false;
  String serverUrl = _fallbackServer;
  String? patientId;
  String? patientRef;
  String? pseudonym;
  String? lastError;

  SupabaseClient get db => Supabase.instance.client;
  String? get accessToken => ready ? db.auth.currentSession?.accessToken : null;
  bool get hasPatient => patientId != null;
  bool get isDoctor => _doctor;
  bool _doctor = false;

  Future<void> init() async {
    try {
      await Supabase.initialize(url: _url, publishableKey: _key);
      ready = true;
    } catch (e) {
      lastError = '$e';
    }
    notifyListeners();
    // The network part runs after the first screen: without a connection it
    // would hold the app on a blank page for several seconds.
    if (ready) unawaited(_warmUp());
  }

  Future<void> _warmUp() async {
    await _loadServer().timeout(const Duration(seconds: 8), onTimeout: () {});
    await _restoreDoctor().timeout(const Duration(seconds: 8), onTimeout: () {});
    notifyListeners();
  }

  /// A doctor signed in on this device stays signed in (Supabase keeps the session).
  Future<void> _restoreDoctor() async {
    final user = db.auth.currentUser;
    if (user == null || user.isAnonymous) return;
    try {
      final row = await db.from('doctors').select().eq('user_id', user.id).maybeSingle();
      _doctor = row != null;
      doctorName = row?['display_name'] as String?;
    } catch (_) {}
  }

  Future<void> _loadServer() async {
    try {
      final row = await db.from('app_config').select('value').eq('key', 'server_url').maybeSingle();
      final v = row?['value'] as String?;
      if (v != null && v.startsWith('http')) serverUrl = v.replaceAll(RegExp(r'/+$'), '');
    } catch (_) {}
  }

  /// Signs in anonymously if needed and makes sure this phone has a patient record.
  Future<bool> ensurePatient() async {
    if (!ready) return false;
    if (patientId != null) return true;
    try {
      if (db.auth.currentSession == null) await db.auth.signInAnonymously();
      final uid = db.auth.currentUser!.id;
      final mine = await db.from('patients').select().eq('owner', uid).limit(1);
      if (mine.isNotEmpty) {
        _take(mine.first);
      } else {
        final prefs = await SharedPreferences.getInstance();
        final r = Random.secure();
        const chars = 'abcdefghijkmnpqrstuvwxyz23456789';
        final ref = 'k-${List.generate(10, (_) => chars[r.nextInt(chars.length)]).join()}';
        final row = await db
            .from('patients')
            .insert({
              'ref': ref,
              'owner': uid,
              'display_name': 'Patient ${1000 + r.nextInt(9000)}',
              'governorate': prefs.getString('khatwa_governorate'),
            })
            .select()
            .single();
        _take(row);
      }
      lastError = null;
      notifyListeners();
      return true;
    } catch (e) {
      lastError = '$e';
      notifyListeners();
      return false;
    }
  }

  void _take(Map<String, dynamic> row) {
    patientId = row['id'] as String;
    patientRef = row['ref'] as String;
    pseudonym = row['display_name'] as String?;
  }

  /// Doctor sign-in (email and password given to the team).
  Future<String?> signInDoctor(String email, String password) async {
    if (!ready) return 'Pas de connexion au serveur de données.';
    try {
      await db.auth
          .signInWithPassword(email: email.trim(), password: password)
          .timeout(const Duration(seconds: 20));
      final row = await db.from('doctors').select().eq('user_id', db.auth.currentUser!.id).maybeSingle();
      _doctor = row != null;
      doctorName = row?['display_name'] as String?;
      resetPatient();
      if (!_doctor) await db.auth.signOut();
      notifyListeners();
      return _doctor ? null : 'Ce compte n’est pas un compte médecin.';
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Connexion impossible.';
    }
  }

  /// The doctor's display name in the shared data, once signed in there.
  String? doctorName;

  /// Sends a 6-digit sign-in code by e-mail (Supabase Auth). False when it
  /// could not be sent: no network, or the mail quota of the hour is used.
  Future<bool> sendEmailCode(String email) async {
    if (!ready) return false;
    try {
      await db.auth.signInWithOtp(email: email.trim().toLowerCase(), shouldCreateUser: true)
          .timeout(const Duration(seconds: 20));
      return true;
    } catch (e) {
      lastError = '$e';
      return false;
    }
  }

  /// Checks the code. On success this device is signed in to the shared data
  /// as that e-mail's user, so the patient record is looked up again.
  Future<bool> verifyEmailCode(String email, String code) async {
    if (!ready) return false;
    try {
      final res = await db.auth
          .verifyOTP(email: email.trim().toLowerCase(), token: code.trim(), type: OtpType.email)
          .timeout(const Duration(seconds: 20));
      if (res.session == null) return false;
      resetPatient();
      await _restoreDoctor();
      notifyListeners();
      return true;
    } catch (e) {
      lastError = '$e';
      return false;
    }
  }

  /// Forgets the cached patient record (the signed in user changed).
  void resetPatient() {
    patientId = null;
    patientRef = null;
    pseudonym = null;
  }

  /// Leaves the shared data (on sign out), so the next person on this device
  /// never works under the previous account.
  Future<void> signOut() async {
    resetPatient();
    _doctor = false;
    doctorName = null;
    if (!ready) return;
    try {
      await db.auth.signOut();
    } catch (_) {}
    notifyListeners();
  }

  // ---------------------------------------------------------------- twin

  /// Scans of one foot, oldest first.
  Future<List<Map<String, dynamic>>> scans(String side) async {
    if (!await ensurePatient()) return [];
    final rows = await db.from('scans').select().eq('patient_id', patientId!).eq('side', side).order('created_at');
    return List<Map<String, dynamic>>.from(rows);
  }

  /// The newest scan of either foot, for the home screen.
  Future<Map<String, dynamic>?> latestScan() async {
    if (!await ensurePatient()) return null;
    final rows = await db.from('scans').select().eq('patient_id', patientId!).order('created_at', ascending: false).limit(1);
    return rows.isEmpty ? null : rows.first;
  }

  /// A short-lived address of a stored file (3D twin or photo).
  Future<String?> signedUrl(String bucket, String path) async {
    try {
      return await db.storage.from(bucket).createSignedUrl(path, 3600);
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> findings(String side) async {
    if (!await ensurePatient()) return [];
    final rows = await db.from('findings').select().eq('patient_id', patientId!).eq('side', side).order('created_at');
    return List<Map<String, dynamic>>.from(rows);
  }

  /// "Envoyer au médecin": the doctor sees the twin, the sole and the findings,
  /// with the FHIR bundle the server produced.
  Future<bool> shareWithDoctor(Map<String, dynamic> fhir) async {
    if (!await ensurePatient()) return false;
    try {
      await db.from('shares').insert({'patient_id': patientId, 'fhir': fhir});
      await db.from('patients').update({'shared_with_doctor': true, 'last_active_at': DateTime.now().toIso8601String()}).eq('id', patientId!);
      await db.from('alerts').insert({
        'patient_id': patientId,
        'level': 'info',
        'source': 'share',
        'title': 'Jumeau 3D partagé par le patient',
        'body': 'Scan, plante du pied et signes notés',
      });
      return true;
    } catch (e) {
      lastError = '$e';
      return false;
    }
  }

  /// The daily check result, so the doctor sees who checks their feet.
  Future<void> recordCheck(String result, Map<String, dynamic> answers) async {
    if (!await ensurePatient()) return;
    try {
      await db.from('checks').insert({
        'patient_id': patientId,
        'day': DateTime.now().toIso8601String().substring(0, 10),
        'result': result,
        'answers': answers,
      });
      await db.from('patients').update({'last_check': result}).eq('id', patientId!);
      if (result == 'red') {
        await db.from('alerts').insert({
          'patient_id': patientId,
          'level': 'urgent',
          'source': 'check',
          'title': 'Contrôle du jour : signe grave',
        });
      }
    } catch (_) {}
  }

  /// Messages from the doctor, newest last, updated live.
  Stream<List<Map<String, dynamic>>> messages() {
    if (patientId == null) return const Stream.empty();
    return db.from('messages').stream(primaryKey: ['id']).eq('patient_id', patientId!).order('created_at');
  }

  /// This patient's record, updated live: the doctor sets `next_visit`.
  Stream<Map<String, dynamic>?> myRecord() {
    if (patientId == null) return const Stream.empty();
    return db
        .from('patients')
        .stream(primaryKey: ['id'])
        .eq('id', patientId!)
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<void> sendMessage(String body) async {
    if (!await ensurePatient()) return;
    await db.from('messages').insert({'patient_id': patientId, 'sender': 'patient', 'body': body});
  }
}
