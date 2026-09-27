import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'doctor_repository.dart';
import 'models.dart';

/// Synthetic, deterministic data for the demo: 16 pseudonymous patients with
/// visits, findings, 30 days of checks, messages and alerts. Works offline.
/// With [liveDemo] on, a new alert arrives every 40 s so the live board can
/// be shown without a network.
class DemoDoctorRepository implements DoctorRepository {
  /// All dates are relative to [now], so tests can pin it.
  DemoDoctorRepository({DateTime? now, this.liveInterval = const Duration(seconds: 40)})
      : _now = now ?? DateTime.now() {
    _seed();
  }

  final DateTime _now;
  final Duration liveInterval;

  @override
  String get doctorId => 'demo-doctor';

  final _patients = <Patient>[];
  final _scans = <Scan>[];
  final _findings = <Finding>[];
  final _checks = <Check>[];
  final _alerts = <Alert>[];
  final _messages = <Message>[];
  final _shares = <Share>[];

  final _changes = StreamController<void>.broadcast();

  /// "Démo live": a new alert every [liveInterval].
  final ValueNotifier<bool> liveDemo = ValueNotifier(false);
  Timer? _liveTimer;
  int _liveCount = 0;

  List<Patient> get allPatients => List.unmodifiable(_patients);
  List<Scan> get allScans => List.unmodifiable(_scans);
  List<Finding> get allFindings => List.unmodifiable(_findings);
  List<Check> get allChecks => List.unmodifiable(_checks);
  List<Alert> get allAlerts => List.unmodifiable(_alerts);
  List<Message> get allMessages => List.unmodifiable(_messages);

  void setLiveDemo(bool on) {
    liveDemo.value = on;
    _liveTimer?.cancel();
    _liveTimer = on ? Timer.periodic(liveInterval, (_) => pushLiveAlert()) : null;
  }

  /// Adds one live alert now (what the "Démo live" timer calls).
  Alert pushLiveAlert() {
    final template = _liveTemplates[_liveCount % _liveTemplates.length];
    final patient = _patients[(_liveCount * 5 + 3) % _patients.length];
    _liveCount++;
    final alert = Alert(
      id: _uuid(),
      patientId: patient.id,
      level: template.$1,
      source: template.$2,
      title: template.$3,
      body: template.$4,
      createdAt: DateTime.now(),
    );
    _alerts.insert(0, alert);
    _emit();
    return alert;
  }

  // ------------------------------------------------------------ streams

  Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    await for (final _ in _changes.stream) {
      yield read();
    }
  }

  void _emit() {
    if (!_changes.isClosed) _changes.add(null);
  }

  @override
  Stream<List<Patient>> patients() => _watch(() => List.of(_patients));

  @override
  Stream<List<Alert>> alerts() =>
      _watch(() => List.of(_alerts)..sort((a, b) => b.createdAt.compareTo(a.createdAt)));

  @override
  Stream<List<Message>> messages(String patientId) => _watch(() =>
      _messages.where((m) => m.patientId == patientId).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt)));

  @override
  Stream<List<Scan>> scans(String patientId) => _watch(() =>
      _scans.where((s) => s.patientId == patientId).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt)));

  @override
  Stream<List<Finding>> findings({String? patientId}) => _watch(() => _findings
      .where((f) => patientId == null || f.patientId == patientId)
      .toList()
    ..sort((a, b) => b.day.compareTo(a.day)));

  @override
  Stream<List<Check>> checks({String? patientId}) => _watch(() =>
      _checks.where((c) => patientId == null || c.patientId == patientId).toList()
        ..sort((a, b) => b.day.compareTo(a.day)));

  @override
  Stream<List<Share>> shares(String patientId) =>
      _watch(() => _shares.where((s) => s.patientId == patientId).toList());

  @override
  Stream<PopulationStats> populationStats() => _watch(_stats);

  PopulationStats _stats() {
    final byRegion = {for (final r in footRegions) r: 0};
    for (final f in _findings.where((f) => f.isActive)) {
      byRegion[f.region] = (byRegion[f.region] ?? 0) + 1;
    }
    final byRisk = {0: 0, 1: 0, 2: 0, 3: 0};
    final byGov = {for (final g in governorates) g: 0};
    final urgentByGov = {for (final g in governorates) g: 0};
    final govOf = <String, String>{};
    for (final p in _patients) {
      byRisk[p.iwgdfRisk ?? 0] = byRisk[p.iwgdfRisk ?? 0]! + 1;
      final g = p.governorate;
      if (g != null) {
        byGov[g] = (byGov[g] ?? 0) + 1;
        govOf[p.id] = g;
      }
    }
    final today = DateTime(_now.year, _now.month, _now.day);
    final thisMonday = today.subtract(Duration(days: today.weekday - 1));
    final byWeek = <DateTime, int>{
      for (var w = 7; w >= 0; w--) thisMonday.subtract(Duration(days: 7 * w)): 0,
    };
    for (final a in _alerts) {
      final d = DateTime(a.createdAt.year, a.createdAt.month, a.createdAt.day);
      final monday = d.subtract(Duration(days: d.weekday - 1));
      if (byWeek.containsKey(monday)) byWeek[monday] = byWeek[monday]! + 1;
      final g = govOf[a.patientId];
      if (a.urgent && g != null) urgentByGov[g] = urgentByGov[g]! + 1;
    }
    return PopulationStats(
      patients: _patients.length,
      findingsByRegion: byRegion,
      patientsByRisk: byRisk,
      alertsByWeek: byWeek,
      patientsByGovernorate: byGov,
      urgentByGovernorate: urgentByGov,
    );
  }

  // ------------------------------------------------------------ actions

  @override
  Future<void> acknowledgeAlert(String alertId) async {
    final i = _alerts.indexWhere((a) => a.id == alertId);
    if (i < 0) return;
    _alerts[i] = _alerts[i].acknowledge(doctorId);
    _emit();
  }

  @override
  Future<void> markFindingReviewed(String findingId) async {
    final i = _findings.indexWhere((f) => f.id == findingId);
    if (i < 0) return;
    _findings[i] = _findings[i].copyWith(reviewedBy: doctorId);
    _emit();
  }

  @override
  Future<void> markFindingHealed(String findingId) async {
    final i = _findings.indexWhere((f) => f.id == findingId);
    if (i < 0) return;
    _findings[i] = _findings[i].copyWith(status: 'healed', reviewedBy: doctorId);
    _emit();
  }

  @override
  Future<void> sendMessage(String patientId, String body) async {
    final text = body.trim();
    if (text.isEmpty) return;
    _messages.add(Message(
      id: _uuid(),
      patientId: patientId,
      sender: 'doctor',
      body: text.length > 2000 ? text.substring(0, 2000) : text,
      createdAt: DateTime.now(),
    ));
    _emit();
  }

  @override
  Future<void> setNextVisit(String patientId, DateTime when) async {
    final i = _patients.indexWhere((p) => p.id == patientId);
    if (i < 0) return;
    _patients[i] = _patients[i].copyWith(nextVisit: when);
    _emit();
  }

  @override
  Future<String?> glbUrl(Scan scan) async => null;

  @override
  Future<String?> photoUrl(String path) async => null;

  @override
  void dispose() {
    _liveTimer?.cancel();
    liveDemo.dispose();
    _changes.close();
  }

  // ------------------------------------------------------------ seed

  final _rng = Random(2026);

  String _hex(int n) => List.generate(n, (_) => _rng.nextInt(16).toRadixString(16)).join();

  String _uuid() => '${_hex(8)}-${_hex(4)}-4${_hex(3)}-a${_hex(3)}-${_hex(12)}';

  DateTime _daysAgo(int days, {int hour = 9, int minute = 0}) {
    final d = _now.subtract(Duration(days: days));
    return DateTime(d.year, d.month, d.day, hour, minute);
  }

  DateTime _dayOnly(int daysAgo) {
    final d = _now.subtract(Duration(days: daysAgo));
    return DateTime(d.year, d.month, d.day);
  }

  // (age, sex, type, risk, governorate, visits)
  static const _people = [
    (67, 'M', '2', 3, 'Sfax', 4),
    (54, 'F', '2', 1, 'Tunis', 2),
    (72, 'M', '2', 3, 'Kairouan', 3),
    (46, 'F', '1', 0, 'Ariana', 1),
    (81, 'F', '2', 2, 'Sousse', 4),
    (59, 'M', '2', 2, 'Gabès', 3),
    (38, 'M', '1', 1, 'Bizerte', 2),
    (63, 'F', '2', 3, 'Médenine', 4),
    (70, 'M', '2', 2, 'Nabeul', 3),
    (49, 'F', '2', 0, 'Monastir', 1),
    (76, 'M', '2', 3, 'Kasserine', 4),
    (57, 'F', '2', 1, 'Ben Arous', 2),
    (44, 'M', '1', 1, 'Gafsa', 2),
    (68, 'F', '2', 2, 'Jendouba', 3),
    (61, 'M', '2', 2, 'Sidi Bouzid', 2),
    (79, 'M', '2', 3, 'Tozeur', 3),
  ];

  // (patient index, side, days ago, kind, region, level, status, source, note)
  static const _findingSeeds = [
    (0, 'L', 2, 'callus', 'forefoot_plantar', 'soon', 'worse', 'sole_photo', 'Épaississement plus marqué'),
    (0, 'L', 20, 'redness', 'hallux', 'soon', 'still_there', 'photo', ''),
    (0, 'R', 40, 'blister', 'heel_posterior', 'none', 'healed', 'photo', ''),
    (1, 'R', 6, 'dry_skin', 'heel_plantar', 'none', 'no_improvement', 'photo', ''),
    (2, 'L', 0, 'colour', 'hallux', 'urgent', 'new', 'twin_tap', 'Signalé par la voix : orteil noirci'),
    (2, 'L', 15, 'callus', 'lateral_side', 'soon', 'still_there', 'photo', ''),
    (4, 'R', 3, 'swelling', 'ankle', 'soon', 'new', 'photo', ''),
    (4, 'R', 12, 'corn', 'lesser_toes', 'soon', 'still_there', 'photo', ''),
    (4, 'L', 30, 'fissure', 'heel_plantar', 'none', 'healed', 'photo', ''),
    (5, 'L', 8, 'callus', 'midfoot_plantar', 'soon', 'new', 'sole_photo', ''),
    (6, 'R', 9, 'fungus', 'interdigital', 'none', 'still_there', 'photo', ''),
    (7, 'L', 1, 'blister', 'medial_side', 'soon', 'new', 'photo', ''),
    (7, 'R', 18, 'callus', 'forefoot_plantar', 'soon', 'no_improvement', 'sole_photo', ''),
    (7, 'R', 25, 'redness', 'dorsum', 'none', 'reported_healed', 'photo', ''),
    (8, 'L', 5, 'ingrown_nail', 'hallux', 'soon', 'worse', 'photo', ''),
    (10, 'R', 0, 'wound', 'forefoot_plantar', 'urgent', 'new', 'sole_photo', 'Plaie sous la tête des métatarsiens'),
    (10, 'R', 14, 'callus', 'forefoot_plantar', 'soon', 'worse', 'sole_photo', ''),
    (10, 'L', 22, 'dry_skin', 'heel_plantar', 'none', 'still_there', 'photo', ''),
    (11, 'L', 11, 'corn', 'lesser_toes', 'none', 'still_there', 'photo', ''),
    (13, 'R', 4, 'redness', 'lateral_side', 'soon', 'new', 'photo', ''),
    (13, 'L', 16, 'callus', 'heel_plantar', 'none', 'no_improvement', 'sole_photo', ''),
    (14, 'L', 7, 'swelling', 'dorsum', 'soon', 'still_there', 'photo', ''),
    (15, 'L', 2, 'unsure', 'heel_posterior', 'soon', 'new', 'photo', 'Photo floue, à revoir'),
    (15, 'R', 10, 'callus', 'forefoot_plantar', 'soon', 'worse', 'sole_photo', ''),
    (15, 'R', 35, 'blister', 'hallux', 'none', 'healed', 'photo', ''),
  ];

  static const _vertices = {
    'hallux': 40278, 'lesser_toes': 38444, 'interdigital': 37101,
    'forefoot_plantar': 12563, 'midfoot_plantar': 29752, 'heel_plantar': 41936,
    'heel_posterior': 7468, 'dorsum': 31071, 'medial_side': 24121,
    'lateral_side': 36070, 'ankle': 43049,
  };

  // (level, source, title, body)
  static const _liveTemplates = [
    ('soon', 'check', 'Contrôle orange', 'Rougeur signalée sur le dessus du pied.'),
    ('urgent', 'voice', 'Douleur vive signalée', 'Le patient signale une douleur vive et une chaleur du pied. Orienter vers le 190 si fièvre.'),
    ('info', 'scan', 'Nouveau scan reçu', 'Jumeau 3D mis à jour, mesures disponibles.'),
    ('soon', 'finding', 'Callosité plus épaisse', 'Zone sous l\'avant-pied, à revoir à la prochaine visite.'),
    ('info', 'share', 'Dossier partagé', 'Bundle FHIR reçu.'),
  ];

  void _seed() {
    for (var i = 0; i < _people.length; i++) {
      final (age, sex, type, risk, gov, _) = _people[i];
      final number = (i + 1).toString().padLeft(2, '0');
      _patients.add(Patient(
        id: _uuid(),
        ref: 'k-${_hex(10)}',
        displayName: 'Patient $number',
        isDemo: true,
        age: age,
        sex: sex,
        diabetesType: type,
        governorate: gov,
        iwgdfRisk: risk,
        sharedWithDoctor: true,
        createdAt: _daysAgo(120 + i * 3),
        lastActiveAt: _daysAgo(i % 3, hour: 8 + i % 10),
        nextVisit: i % 4 == 0 ? _daysAgo(-(7 + i), hour: 10) : null,
      ));
    }

    // Visits: each scans both feet. Measurements drift a little; high risk
    // feet flatten and swell slowly.
    for (var i = 0; i < _patients.length; i++) {
      final p = _patients[i];
      final visits = _people[i].$6;
      final risk = p.iwgdfRisk ?? 0;
      final length = 238.0 + _rng.nextInt(40);
      final width = 92.0 + _rng.nextInt(14);
      final arch = 17.0 + _rng.nextInt(8);
      final instep = 58.0 + _rng.nextInt(12);
      final volume = 610.0 + _rng.nextInt(160);
      for (var v = 0; v < visits; v++) {
        final daysAgo = (visits - 1 - v) * 28 + 1 + i % 5;
        for (final side in ['L', 'R']) {
          final drift = v * (risk >= 2 ? 1.0 : 0.25);
          final jitter = (_rng.nextDouble() - 0.5) * 1.2;
          final id = 's-${_hex(10)}';
          _scans.add(Scan(
            id: id,
            patientId: p.id,
            side: side,
            createdAt: _daysAgo(daysAgo, hour: 10, minute: side == 'L' ? 5 : 12),
            measurements: {
              'foot_length_mm': double.parse((length + jitter + (side == 'R' ? 1.5 : 0)).toStringAsFixed(1)),
              'forefoot_width_mm': double.parse((width + drift * 0.6 + jitter).toStringAsFixed(1)),
              'arch_height_mm': double.parse((arch - drift * 0.8 + jitter * 0.5).toStringAsFixed(1)),
              'instep_height_mm': v == 0 ? null : double.parse((instep + drift * 0.3 + jitter).toStringAsFixed(1)),
              'volume_to_8cm_ml': double.parse((volume + drift * 9 + jitter * 4).toStringAsFixed(0)),
            },
            quality: {'coverage': 0.86 + _rng.nextInt(12) / 100, 'frames': 90 + _rng.nextInt(60)},
            glbPath: 'twins/${p.id}/$id.glb',
            solePhotoPath: v.isEven ? null : 'photos/${p.id}/sole-$id.jpg',
            soleTextured: v.isOdd,
          ));
        }
      }
    }

    for (final (index, side, days, kind, region, level, status, source, note) in _findingSeeds) {
      final p = _patients[index];
      _findings.add(Finding(
        id: 'f-${_hex(10)}',
        patientId: p.id,
        side: side,
        day: _dayOnly(days),
        kind: kind,
        region: region,
        vertex: _vertices[region]!,
        areaMm2: kind == 'wound' ? 64 : (20 + _rng.nextInt(180)).toDouble(),
        level: level,
        status: status,
        source: source,
        reporter: source == 'clinician' ? 'clinician' : 'patient',
        note: note,
        reviewedBy: status == 'still_there' ? doctorId : null,
        createdAt: _daysAgo(days, hour: 8 + index % 9, minute: 20),
      ));
    }

    // 30 days of daily checks. Adherence falls a little with age; results
    // follow the active findings of that day.
    for (var i = 0; i < _patients.length; i++) {
      final p = _patients[i];
      final active = _findingSeeds.where((f) => f.$1 == i && f.$7 != 'healed').toList();
      for (var d = 29; d >= 0; d--) {
        final skip = _rng.nextInt(100) < 8 + (p.age ?? 60) ~/ 8;
        if (skip && d != 0 && i % 4 != 0) continue;
        if (d == 0 && i % 5 == 4) continue; // not everyone has checked today
        var result = 'green';
        for (final f in active) {
          if (d <= f.$3) {
            if (f.$6 == 'urgent') {
              result = 'red';
            } else if (f.$6 == 'soon' && result == 'green') {
              result = 'amber';
            }
          }
        }
        _checks.add(Check(
          id: _uuid(),
          patientId: p.id,
          day: _dayOnly(d),
          result: result,
          answers: {
            'looked': true,
            'new_mark': result != 'green',
            'pain': result == 'red',
            'shoes_checked': _rng.nextBool(),
          },
          createdAt: _daysAgo(d, hour: 7 + _rng.nextInt(4), minute: _rng.nextInt(60)),
        ));
      }
      final today = _checks.where((c) => c.patientId == p.id).toList()
        ..sort((a, b) => b.day.compareTo(a.day));
      if (today.isNotEmpty) _patients[i] = _patients[i].copyWith(lastCheck: today.first.result);
    }

    // Alerts, including the two urgent ones of the demo script.
    void alert(int index, String level, String source, String title, String body, int minutesAgo,
        {bool acknowledged = false}) {
      _alerts.add(Alert(
        id: _uuid(),
        patientId: _patients[index].id,
        level: level,
        source: source,
        title: title,
        body: body,
        acknowledgedBy: acknowledged ? doctorId : null,
        createdAt: _now.subtract(Duration(minutes: minutesAgo)),
      ));
    }

    alert(2, 'urgent', 'voice', 'Orteil noirci signalé',
        'Signalé par la voix : le gros orteil gauche est devenu noir. Signe urgent, orienter vers le 190.', 18);
    alert(10, 'urgent', 'finding', 'Plaie sous l\'avant-pied',
        'Plaie vue sur la photo de la plante, pied droit, sous la tête des métatarsiens.', 52);
    alert(0, 'soon', 'finding', 'Callosité qui s\'aggrave', 'Avant-pied gauche, plus épaisse qu\'au dernier contrôle.', 60 * 3);
    alert(7, 'soon', 'check', 'Contrôle orange', 'Ampoule sur le bord interne du pied gauche.', 60 * 20);
    alert(4, 'soon', 'check', 'Gonflement de la cheville', 'Cheville droite gonflée depuis trois jours.', 60 * 26);
    alert(8, 'soon', 'finding', 'Ongle incarné', 'Gros orteil gauche, rougeur autour de l\'ongle.', 60 * 50, acknowledged: true);
    alert(13, 'soon', 'check', 'Rougeur sur le bord externe', 'Pied droit, nouvelle depuis quatre jours.', 60 * 70);
    alert(15, 'info', 'scan', 'Photo à reprendre', 'La photo du talon est floue.', 60 * 40);
    alert(5, 'info', 'scan', 'Nouveau scan reçu', 'Jumeau 3D mis à jour.', 60 * 24 * 8, acknowledged: true);
    alert(1, 'info', 'share', 'Dossier partagé', 'Bundle FHIR reçu et validé.', 60 * 24 * 12, acknowledged: true);
    alert(15, 'soon', 'finding', 'Callosité plus épaisse', 'Avant-pied droit.', 60 * 24 * 10, acknowledged: true);
    alert(0, 'urgent', 'check', 'Contrôle rouge', 'Rougeur chaude du gros orteil, vu en consultation le jour même.', 60 * 24 * 20,
        acknowledged: true);
    alert(10, 'soon', 'finding', 'Callosité qui s\'aggrave', 'Avant-pied droit.', 60 * 24 * 14, acknowledged: true);
    alert(6, 'info', 'check', 'Contrôles manqués', 'Trois jours sans contrôle.', 60 * 24 * 30, acknowledged: true);
    alert(11, 'info', 'scan', 'Nouveau scan reçu', 'Jumeau 3D mis à jour.', 60 * 24 * 44, acknowledged: true);

    // A few conversations.
    void message(int index, String sender, String body, int minutesAgo) {
      _messages.add(Message(
        id: _uuid(),
        patientId: _patients[index].id,
        sender: sender,
        body: body,
        readAt: sender == 'patient' && minutesAgo > 120 ? _now.subtract(Duration(minutes: minutesAgo - 30)) : null,
        createdAt: _now.subtract(Duration(minutes: minutesAgo)),
      ));
    }

    message(2, 'patient', 'Mon gros orteil est devenu tout noir depuis hier soir.', 20);
    message(10, 'doctor', 'Bonjour, gardez le pied au repos et ne marchez pas pieds nus.', 60 * 24 * 13);
    message(10, 'patient', 'D\'accord docteur, merci.', 60 * 24 * 13 - 45);
    message(0, 'doctor', 'La callosité est à surveiller. Rendez-vous dans deux semaines.', 60 * 24 * 5);
    message(0, 'patient', 'Merci, je fais le contrôle tous les matins.', 60 * 24 * 5 - 90);
    message(7, 'patient', 'J\'ai une petite ampoule après une longue marche.', 60 * 21);
    message(4, 'patient', 'Ma cheville est un peu gonflée le soir.', 60 * 27);

    _shares.add(Share(
      id: _uuid(),
      patientId: _patients[1].id,
      fhir: {'resourceType': 'Bundle', 'type': 'collection', 'id': _patients[1].ref},
      gazelleReport: 'PASSED',
      createdAt: _now.subtract(const Duration(days: 12)),
    ));
  }
}
