import 'dart:convert';
import 'dart:io';

import 'package:diabetic_foot_app/doctor/data/demo_repository.dart';
import 'package:diabetic_foot_app/doctor/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 29, 10);
  late DemoDoctorRepository repo;

  setUp(() => repo = DemoDoctorRepository(now: now));
  tearDown(() => repo.dispose());

  test('16 pseudonymous patients within the demo ranges', () {
    final patients = repo.allPatients;
    expect(patients, hasLength(16));
    for (final p in patients) {
      expect(p.displayName, matches(RegExp(r'^Patient \d{2}$')));
      expect(p.ref, matches(RegExp(r'^k-[0-9a-f]{10}$')));
      expect(p.age, inInclusiveRange(38, 81));
      expect(p.diabetesType, isIn(['1', '2']));
      expect(p.iwgdfRisk, inInclusiveRange(0, 3));
      expect(governorates, contains(p.governorate));
    }
    expect({for (final p in patients) p.iwgdfRisk}, {0, 1, 2, 3});
  });

  test('ids are unique', () {
    void unique(Iterable<String> ids, String what) =>
        expect(ids.toSet().length, ids.length, reason: '$what ids must be unique');
    unique(repo.allPatients.map((p) => p.id), 'patient');
    unique(repo.allPatients.map((p) => p.ref), 'patient ref');
    unique(repo.allScans.map((s) => s.id), 'scan');
    unique(repo.allFindings.map((f) => f.id), 'finding');
    unique(repo.allChecks.map((c) => c.id), 'check');
    unique(repo.allAlerts.map((a) => a.id), 'alert');
    unique(repo.allMessages.map((m) => m.id), 'message');
  });

  test('same data on every run', () {
    final other = DemoDoctorRepository(now: now);
    addTearDown(other.dispose);
    expect(other.allPatients.map((p) => p.ref), repo.allPatients.map((p) => p.ref));
    expect(other.allFindings.map((f) => f.id), repo.allFindings.map((f) => f.id));
  });

  test('the two urgent alerts of the demo are present and open', () {
    final urgent = repo.allAlerts.where((a) => a.urgent && !a.acknowledged).toList();
    expect(urgent.map((a) => a.title), containsAll(['Orteil noirci signalé', 'Plaie sous l\'avant-pied']));
    final voice = urgent.firstWhere((a) => a.title == 'Orteil noirci signalé');
    expect(voice.source, 'voice');
  });

  test('every finding zone exists in foot_regions.json', () {
    final json = jsonDecode(File('assets/models/foot_regions.json').readAsStringSync()) as Map<String, dynamic>;
    final regions = json['regions'] as Map<String, dynamic>;
    for (final f in repo.allFindings) {
      expect(regions.keys, contains(f.region), reason: 'finding ${f.id}');
      expect(f.vertex, regions[f.region]['vertex'], reason: 'finding ${f.id} vertex');
    }
    expect(footRegions.toSet(), regions.keys.toSet());
  });

  test('values match the data contract', () {
    for (final s in repo.allScans) {
      expect(s.side, isIn(['L', 'R']));
      expect(s.glbPath, startsWith('twins/${s.patientId}/'));
    }
    for (final f in repo.allFindings) {
      expect(f.level, isIn(['none', 'soon', 'urgent']));
      expect(f.status,
          isIn(['new', 'worse', 'no_improvement', 'still_there', 'healed', 'reported_healed', 'not_seen']));
      expect(f.source, isIn(['photo', 'sole_photo', 'twin_tap', 'clinician']));
    }
    for (final a in repo.allAlerts) {
      expect(a.level, isIn(['info', 'soon', 'urgent']));
      expect(a.source, isIn(['voice', 'finding', 'check', 'scan', 'share']));
    }
    for (final c in repo.allChecks) {
      expect(c.result, isIn(['green', 'amber', 'red']));
    }
  });

  test('1 to 4 visits per patient and 30 days of checks', () {
    for (final p in repo.allPatients) {
      final scans = repo.allScans.where((s) => s.patientId == p.id).toList();
      final visits = scans.where((s) => s.side == 'L').length;
      expect(visits, inInclusiveRange(1, 4));
      final checks = repo.allChecks.where((c) => c.patientId == p.id);
      expect(checks.every((c) => now.difference(c.day).inDays < 31), isTrue);
    }
    final days = {for (final c in repo.allChecks) c.day};
    expect(days.length, 30);
  });

  test('actions update the streams', () async {
    final alert = repo.allAlerts.firstWhere((a) => a.urgent && !a.acknowledged);
    await repo.acknowledgeAlert(alert.id);
    final alerts = await repo.alerts().first;
    expect(alerts.firstWhere((a) => a.id == alert.id).acknowledgedBy, repo.doctorId);

    final finding = repo.allFindings.firstWhere((f) => f.isActive);
    await repo.markFindingHealed(finding.id);
    final findings = await repo.findings(patientId: finding.patientId).first;
    expect(findings.firstWhere((f) => f.id == finding.id).status, 'healed');

    final patient = repo.allPatients.first;
    await repo.sendMessage(patient.id, 'Bonjour');
    final messages = await repo.messages(patient.id).first;
    expect(messages.last.body, 'Bonjour');
    expect(messages.last.sender, 'doctor');
  });

  test('live demo adds alerts', () async {
    final before = repo.allAlerts.length;
    repo.pushLiveAlert();
    expect(repo.allAlerts.length, before + 1);
    final stats = await repo.populationStats().first;
    expect(stats.patients, 16);
    expect(stats.patientsByGovernorate.keys, hasLength(24));
  });
}
