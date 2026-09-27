import 'package:flutter/widgets.dart';

import '../data/doctor_repository.dart';
import '../data/models.dart';

/// What every dashboard screen needs, passed down once.
class DoctorScope extends InheritedWidget {
  final DoctorRepository repository;
  /// Clinicians may mark findings reviewed or healed; decision makers only read.
  final bool clinician;
  /// Off in widget tests: the 3D viewer needs a web view.
  final bool enable3d;
  final void Function(BuildContext context, Patient patient)? onExportFhir;

  const DoctorScope({
    super.key,
    required this.repository,
    required this.clinician,
    required this.enable3d,
    this.onExportFhir,
    required super.child,
  });

  static DoctorScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DoctorScope>();
    assert(scope != null, 'No DoctorScope above this widget');
    return scope!;
  }

  @override
  bool updateShouldNotify(DoctorScope old) =>
      repository != old.repository ||
      clinician != old.clinician ||
      enable3d != old.enable3d ||
      onExportFhir != old.onExportFhir;
}

/// Everything the triage board and the public health view show, kept fresh
/// from the repository streams.
class BoardData {
  final List<Patient> patients;
  final List<Alert> alerts;
  final List<Finding> findings;
  final List<Check> checks;

  const BoardData({
    this.patients = const [],
    this.alerts = const [],
    this.findings = const [],
    this.checks = const [],
  });

  BoardData copyWith({List<Patient>? patients, List<Alert>? alerts, List<Finding>? findings, List<Check>? checks}) =>
      BoardData(
        patients: patients ?? this.patients,
        alerts: alerts ?? this.alerts,
        findings: findings ?? this.findings,
        checks: checks ?? this.checks,
      );

  List<Alert> openAlertsOf(String patientId) =>
      alerts.where((a) => a.patientId == patientId && !a.acknowledged).toList();

  /// 0 urgent, 1 soon, 2 info, 3 nothing open.
  int priority(Patient p) {
    final open = openAlertsOf(p.id);
    if (open.any((a) => a.level == 'urgent') || p.lastCheck == 'red') return 0;
    if (open.any((a) => a.level == 'soon') || p.lastCheck == 'amber') return 1;
    if (open.isNotEmpty) return 2;
    return 3;
  }

  /// Urgent first, then higher IWGDF risk, then most recent alert.
  List<Patient> sorted(Iterable<Patient> list) {
    DateTime latest(Patient p) => alerts
        .where((a) => a.patientId == p.id)
        .fold(DateTime.fromMillisecondsSinceEpoch(0), (d, a) => a.createdAt.isAfter(d) ? a.createdAt : d);
    return list.toList()
      ..sort((a, b) {
        final byPriority = priority(a).compareTo(priority(b));
        if (byPriority != 0) return byPriority;
        final byRisk = (b.iwgdfRisk ?? 0).compareTo(a.iwgdfRisk ?? 0);
        if (byRisk != 0) return byRisk;
        return latest(b).compareTo(latest(a));
      });
  }
}
