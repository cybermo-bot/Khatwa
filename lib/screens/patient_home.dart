import 'package:flutter/material.dart';

import '../data/auth_store.dart';
import '../data/khatwa_store.dart';
import '../data/risk_profile.dart';
import '../data/triage.dart';
import '../ui/app_theme.dart';
import '../ui/strings.dart';

/// Shared triage presentation and the patient profile snapshot. The patient
/// app itself lives in shell.dart and the tabs folder.

// ---------------------------------------------------------------- shared bits

class LevelDot extends StatelessWidget {
  final TriageLevel level;
  final double size;

  const LevelDot({super.key, required this.level, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: levelSoftColor(level),
        borderRadius: BorderRadius.circular(size * 0.36),
      ),
      alignment: Alignment.center,
      child: Icon(levelIcon(level), color: levelColor(level), size: size * 0.5),
    );
  }
}

Color levelColor(TriageLevel level) {
  switch (level) {
    case TriageLevel.green:
      return K.ok;
    case TriageLevel.amber:
      return K.warn;
    case TriageLevel.red:
      return K.danger;
  }
}

Color levelSoftColor(TriageLevel level) {
  switch (level) {
    case TriageLevel.green:
      return K.okSoft;
    case TriageLevel.amber:
      return K.warnSoft;
    case TriageLevel.red:
      return K.dangerSoft;
  }
}

IconData levelIcon(TriageLevel level) {
  switch (level) {
    case TriageLevel.green:
      return Icons.check_rounded;
    case TriageLevel.amber:
      return Icons.visibility_outlined;
    case TriageLevel.red:
      return Icons.priority_high_rounded;
  }
}

String levelHeadline(String lang, TriageLevel level) {
  switch (level) {
    case TriageLevel.green:
      return S.t(lang, 'level.none');
    case TriageLevel.amber:
      return S.t(lang, 'level.yellow');
    case TriageLevel.red:
      return S.t(lang, 'level.red');
  }
}

String levelShort(String lang, TriageLevel level) {
  switch (level) {
    case TriageLevel.green:
      return S.t(lang, 'level.label.none');
    case TriageLevel.amber:
      return S.t(lang, 'level.label.yellow');
    case TriageLevel.red:
      return S.t(lang, 'level.label.red');
  }
}

String formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  final h = date.hour.toString().padLeft(2, '0');
  final min = date.minute.toString().padLeft(2, '0');
  return '$d/$m/${date.year}, $h:$min';
}

/// Patient profile snapshot handed to the AI layer and stored with the case.
/// The IWGDF risk category travels with it, because the same photo means a
/// different urgency for a category 3 patient than for a category 0.
Map<String, dynamic> patientProfile() {
  final store = KhatwaStore.instance;
  final account = AuthStore.instance.current;
  final risk = RiskProfile.latest();

  return {
    'name': account?.name ?? store.patientName,
    'diabetesType': store.diabetesType,
    'medications': store.medications,
    'allergies': store.allergies,
    'otherConditions': store.otherConditions,
    if (risk != null) ...{
      'iwgdfRiskCategory': risk.category,
      'lossOfProtectiveSensation': risk.neuropathy,
      'peripheralArterialDisease': risk.arterial,
      'footDeformity': risk.deformity,
      'previousUlcerOrAmputation': risk.history,
    },
  };
}
