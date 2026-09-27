import 'package:diabetic_foot_app/data/rule_engine.dart';
import 'package:diabetic_foot_app/data/triage.dart';
import 'package:diabetic_foot_app/data/twin_signal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('only growth beyond the noise counts as swelling', () {
    expect(
      TwinSignal.describe({
        'significant_measurements': ['volume_to_8cm_ml', 'ball_girth_mm', 'foot_length_mm'],
        'measurements': {'volume_to_8cm_ml': 72.4, 'ball_girth_mm': 9.2, 'foot_length_mm': 4.0, 'heel_width_mm': 2.0},
      }),
      'volume up to 8 cm +72 mL, ball girth +9 mm',
    );
    // Smaller than before, or not significant: no swelling.
    expect(
      TwinSignal.describe({
        'significant_measurements': ['volume_to_8cm_ml'],
        'measurements': {'volume_to_8cm_ml': -70.0, 'ball_girth_mm': 20.0},
      }),
      isNull,
    );
  });

  test('3D swelling raises to amber, with a colour change to red', () {
    TriageResult run(Map<String, dynamic> a) => RuleEngine.evaluate(answers: a, profile: const {}, lang: 'Français');
    expect(run({'twin_swelling': false}).level, TriageLevel.green);
    final amber = run({'twin_swelling': true});
    expect(amber.level, TriageLevel.amber);
    expect(amber.findings.single.source, 'twin');
    expect(run({'twin_swelling': true, 'color': true}).level, TriageLevel.red);
  });
}
