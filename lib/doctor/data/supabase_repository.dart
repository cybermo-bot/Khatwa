import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'doctor_repository.dart';
import 'models.dart';

/// The dashboard on the shared Supabase data, live: a patient's urgent voice
/// answer, a sign placed on the foot or a shared twin shows up on the board
/// within a second or two (Supabase Realtime). Row-level security lets only
/// accounts in `doctors` read here.
class SupabaseDoctorRepository implements DoctorRepository {
  SupabaseDoctorRepository({SupabaseClient? client}) : _db = client ?? Supabase.instance.client;
  final SupabaseClient _db;
  final _subs = <StreamSubscription>[];

  @override
  String get doctorId => _db.auth.currentUser?.id ?? '';

  Stream<List<T>> _table<T>(String table, T Function(Map<String, dynamic>) from,
      {String? eq, Object? value, String order = 'created_at', bool ascending = false}) {
    var q = _db.from(table).stream(primaryKey: ['id']);
    final s = (eq != null ? q.eq(eq, value!) : q).order(order, ascending: ascending);
    return s.map((rows) => [for (final r in rows) from(r)]).asBroadcastStream();
  }

  @override
  Stream<List<Patient>> patients() => _table('patients', Patient.fromMap, order: 'last_active_at');

  @override
  Stream<List<Alert>> alerts() => _table('alerts', Alert.fromMap);

  @override
  Stream<List<Message>> messages(String patientId) =>
      _table('messages', Message.fromMap, eq: 'patient_id', value: patientId, ascending: true);

  @override
  Stream<List<Scan>> scans(String patientId) =>
      _table('scans', Scan.fromMap, eq: 'patient_id', value: patientId, ascending: true);

  @override
  Stream<List<Finding>> findings({String? patientId}) =>
      _table('findings', Finding.fromMap, eq: patientId == null ? null : 'patient_id', value: patientId);

  @override
  Stream<List<Check>> checks({String? patientId}) =>
      _table('checks', Check.fromMap, eq: patientId == null ? null : 'patient_id', value: patientId, order: 'day');

  @override
  Stream<List<Share>> shares(String patientId) => _table('shares', Share.fromMap, eq: 'patient_id', value: patientId);

  @override
  Stream<PopulationStats> populationStats() {
    final out = StreamController<PopulationStats>.broadcast();
    List<Patient> ps = [];
    List<Finding> fs = [];
    List<Alert> as_ = [];
    void emit() => out.add(_stats(ps, fs, as_));
    _subs
      ..add(patients().listen((v) {
        ps = v;
        emit();
      }))
      ..add(findings().listen((v) {
        fs = v;
        emit();
      }))
      ..add(alerts().listen((v) {
        as_ = v;
        emit();
      }));
    return out.stream;
  }

  PopulationStats _stats(List<Patient> patients, List<Finding> findings, List<Alert> alerts) {
    final byRegion = {for (final r in footRegions) r: 0};
    for (final f in findings.where((f) => f.isActive)) {
      byRegion[f.region] = (byRegion[f.region] ?? 0) + 1;
    }
    final byRisk = {0: 0, 1: 0, 2: 0, 3: 0};
    final byGov = {for (final g in governorates) g: 0};
    final urgentByGov = {for (final g in governorates) g: 0};
    final govOf = <String, String>{};
    for (final p in patients) {
      byRisk[p.iwgdfRisk ?? 0] = (byRisk[p.iwgdfRisk ?? 0] ?? 0) + 1;
      final g = p.governorate;
      if (g != null) {
        byGov[g] = (byGov[g] ?? 0) + 1;
        govOf[p.id] = g;
      }
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisMonday = today.subtract(Duration(days: today.weekday - 1));
    final byWeek = <DateTime, int>{
      for (var w = 7; w >= 0; w--) thisMonday.subtract(Duration(days: 7 * w)): 0,
    };
    for (final a in alerts) {
      final d = DateTime(a.createdAt.year, a.createdAt.month, a.createdAt.day);
      final monday = d.subtract(Duration(days: d.weekday - 1));
      if (byWeek.containsKey(monday)) byWeek[monday] = byWeek[monday]! + 1;
      final g = govOf[a.patientId];
      if (a.urgent && g != null) urgentByGov[g] = (urgentByGov[g] ?? 0) + 1;
    }
    return PopulationStats(
      patients: patients.length,
      findingsByRegion: byRegion,
      patientsByRisk: byRisk,
      alertsByWeek: byWeek,
      patientsByGovernorate: byGov,
      urgentByGovernorate: urgentByGov,
    );
  }

  @override
  Future<void> acknowledgeAlert(String alertId) =>
      _db.from('alerts').update({'acknowledged_by': doctorId}).eq('id', alertId);

  @override
  Future<void> markFindingReviewed(String findingId) =>
      _db.from('findings').update({'reviewed_by': doctorId}).eq('id', findingId);

  @override
  Future<void> markFindingHealed(String findingId) => _db
      .from('findings')
      .update({'reviewed_by': doctorId, 'status': 'healed', 'reporter': 'clinician'}).eq('id', findingId);

  @override
  Future<void> sendMessage(String patientId, String body) =>
      _db.from('messages').insert({'patient_id': patientId, 'sender': 'doctor', 'body': body});

  @override
  Future<void> setNextVisit(String patientId, DateTime when) => _db
      .from('patients')
      .update({'next_visit': when.toIso8601String().substring(0, 10)}).eq('id', patientId);

  @override
  Future<String?> glbUrl(Scan scan) async {
    try {
      return await _db.storage.from('twins').createSignedUrl(scan.glbPath, 3600);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> photoUrl(String path) async {
    try {
      return await _db.storage.from('photos').createSignedUrl(path, 3600);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
  }
}
