import 'package:diabetic_foot_app/doctor/data/demo_repository.dart';
import 'package:diabetic_foot_app/doctor/screens/doctor_dashboard.dart';
import 'package:diabetic_foot_app/doctor/screens/patient_view.dart';
import 'package:diabetic_foot_app/doctor/screens/triage_board.dart';
import 'package:diabetic_foot_app/doctor/ui/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 29, 10);

  Future<DemoDoctorRepository> pumpDashboard(WidgetTester tester, Size size, {double textScale = 1}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = DemoDoctorRepository(now: now);
    addTearDown(repo.dispose);
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: DoctorDashboard(repository: repo, enable3d: false, today: now),
    ));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    return repo;
  }

  String rowName(WidgetTester tester, int index) =>
      tester.widgetList<PatientRow>(find.byType(PatientRow)).elementAt(index).patient.displayName;

  testWidgets('triage board shows the KPIs and the urgent patients first', (tester) async {
    await pumpDashboard(tester, const Size(420, 1400));

    expect(find.text('Patients suivis'), findsOneWidget);
    expect(find.text('Alertes urgentes'), findsOneWidget);
    expect(find.text('Lésions actives'), findsOneWidget);
    expect(find.text('Contrôles du jour'), findsOneWidget);
    expect(find.text('16'), findsWidgets);

    // The two urgent alerts of the demo: Patient 03 (blackened toe, by voice)
    // and Patient 11 (wound under the ball of the foot).
    final kpiUrgent = find.ancestor(of: find.text('Alertes urgentes'), matching: find.byType(Column)).first;
    expect(find.descendant(of: kpiUrgent, matching: find.text('2')), findsOneWidget);
    expect({rowName(tester, 0), rowName(tester, 1)}, {'Patient 03', 'Patient 11'});
    expect(find.text('Orteil noirci signalé'), findsOneWidget);
  });

  testWidgets('search filters by pseudonym', (tester) async {
    await pumpDashboard(tester, const Size(420, 1400));
    await tester.enterText(find.byType(TextField).first, 'Patient 07');
    await tester.pump();
    expect(find.byType(PatientRow), findsOneWidget);
    expect(rowName(tester, 0), 'Patient 07');
  });

  testWidgets('wide screen shows the board and the patient side by side', (tester) async {
    await pumpDashboard(tester, const Size(1400, 1000));
    expect(find.byType(TriageBoard), findsOneWidget);
    expect(find.byType(PatientView), findsOneWidget);
    expect(find.text('Exporter FHIR'), findsOneWidget);
    expect(find.text('Jumeau 3D'.toUpperCase()), findsOneWidget);
  });

  testWidgets('a new live alert makes the patient pulse and moves the KPI', (tester) async {
    // Tall enough for the whole list: the new alert goes to a low risk patient.
    final repo = await pumpDashboard(tester, const Size(420, 3200));
    repo.pushLiveAlert(); // the first template is "soon"
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Contrôle orange'), findsWidgets);
    expect(find.byType(LivePulse), findsOneWidget);
  });

  for (final size in [const Size(420, 1400), const Size(900, 1200), const Size(1400, 1000)]) {
    testWidgets('lays out at text scale 1.3 on ${size.width.toInt()} px', (tester) async {
      await pumpDashboard(tester, size, textScale: 1.3);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Santé publique'));
      await tester.tap(find.text('Santé publique'));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(tester.takeException(), isNull);
      expect(find.text('LÉSIONS ACTIVES, TOUS PATIENTS'), findsOneWidget);
    });
  }
}
