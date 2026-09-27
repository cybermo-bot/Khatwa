import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ui/app_state.dart';
import '../ui/app_theme.dart';

/// Assistant language code for the app's language setting.
String langCode([String? appLang]) => switch (appLang ?? appLanguage.value) {
      'العربية' => 'ar',
      'Français' => 'fr',
      'English' => 'en',
      _ => 'aeb',
    };

String today() => DateTime.now().toIso8601String().substring(0, 10);

const regionFr = {
  'hallux': 'gros orteil',
  'lesser_toes': 'petits orteils',
  'interdigital': 'entre les orteils',
  'forefoot_plantar': 'avant de la plante',
  'midfoot_plantar': 'milieu de la plante',
  'heel_plantar': 'talon (dessous)',
  'heel_posterior': 'arrière du talon',
  'dorsum': 'dessus du pied',
  'medial_side': 'bord intérieur',
  'lateral_side': 'bord extérieur',
  'ankle': 'cheville',
};

const kindFr = {
  'callus': 'Callosité',
  'corn': 'Cor',
  'blister': 'Ampoule',
  'wound': 'Plaie',
  'redness': 'Rougeur',
  'swelling': 'Gonflement',
  'colour': 'Changement de couleur',
  'heel-cracks': 'Crevasse',
  'fungus': 'Mycose',
  'nails': 'Ongle',
  'dry-skin': 'Peau sèche',
  'other': 'Autre',
  'unsure': 'Je ne sais pas',
};

/// Finding statuses. None depends on photo area (not validated yet).
const statusFr = {
  'new': 'nouveau',
  'worse': 'aggravé : à montrer au soignant',
  'no_improvement': 'pas d’amélioration : à montrer au soignant',
  'still_there': 'toujours là',
  'healed': 'guéri (soignant)',
  'reported_healed': 'guéri selon vous, à confirmer par un soignant',
  'not_seen': 'non revu au dernier contrôle',
};

/// Measures with their estimated precision (1.96 SD of repeated synthetic scans
/// through the server pipeline, rounded up, never below 2 mm), whole numbers.
const measureFr = {
  'foot_length_mm': ('Longueur', 'mm', 4),
  'ball_width_mm': ('Largeur de l’avant-pied', 'mm', 2),
  'heel_width_mm': ('Largeur du talon', 'mm', 2),
  'ball_girth_mm': ('Tour de l’avant-pied', 'mm', 6),
  'instep_height_mm': ('Hauteur du cou-de-pied', 'mm', 13),
  'volume_to_8cm_ml': ('Volume (jusqu’à 8 cm)', 'mL', 45),
};

const precisionNote = 'Précision estimée sur données simulées. Mesures de recherche, pas un diagnostic.';

String sideFr(String side) => side == 'L' ? 'pied gauche' : 'pied droit';

/// "254 ± 4 mm": whole numbers with the estimated precision, "-" when not measured.
String fmtMeasure(String key, Object? value) {
  final m = measureFr[key];
  if (value is! num || m == null) return '-';
  return '${value.round()} ± ${m.$3} ${m.$2}';
}

/// Text direction for a string: Arabic script reads right to left.
TextDirection dirOf(String s) => RegExp(r'[؀-ۿ]').hasMatch(s) ? TextDirection.rtl : TextDirection.ltr;

Future<void> call190() => launchUrl(Uri(scheme: 'tel', path: '190'));

/// The go-now banner, in derja and French, with a full-width call button.
class UrgentBanner extends StatelessWidget {
  const UrgentBanner({super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: K.dangerSoft,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Icon(Icons.emergency_rounded, color: K.danger),
            const SizedBox(width: 10),
            Expanded(
              child: Text('علامة خطيرة: اطلب 190 توّا',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: K.danger, fontWeight: FontWeight.w700, fontSize: 17)),
            ),
          ]),
          const SizedBox(height: 2),
          Text('Signe grave : appelez le 190 maintenant',
              style: TextStyle(color: K.danger, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: K.danger, minimumSize: const Size.fromHeight(56)),
            onPressed: call190,
            icon: const Icon(Icons.call_rounded),
            label: const Text('اطلب 190  /  Appeler le 190'),
          ),
        ]),
      );
}

/// What the triage table says about a sign: urgent (with the call button),
/// within 24 hours, or nothing more than the daily check.
class AdviceCard extends StatelessWidget {
  final String level; // none | soon | urgent
  final String message;
  final String? lead;
  const AdviceCard({super.key, required this.level, required this.message, this.lead});

  @override
  Widget build(BuildContext context) {
    if (level == 'urgent') {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (lead != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(lead!, style: K.body)),
        ClipRRect(borderRadius: BorderRadius.circular(24), child: const UrgentBanner()),
        const SizedBox(height: 8),
        Text(message, style: K.body.copyWith(color: K.danger)),
      ]);
    }
    final soon = level == 'soon';
    return KCard(
      color: soon ? K.warnSoft : K.primarySoft,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (lead != null) ...[Text(lead!, style: K.body), const SizedBox(height: 8)],
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(soon ? Icons.schedule_rounded : Icons.check_circle_outline_rounded, color: soon ? K.warn : K.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              soon ? 'À voir dans les 24 heures. $message' : 'Noté. Continuez à regarder vos pieds chaque jour.',
              style: K.body,
            ),
          ),
        ]),
      ]),
    );
  }
}

/// First step of the scan and photo flows: which foot, with two big buttons.
class SidePicker extends StatelessWidget {
  final ValueChanged<String> onPick;
  final String? title;
  const SidePicker({super.key, required this.onPick, this.title});

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
        Text(title ?? 'Quel pied ?', style: K.h1),
        const SizedBox(height: 4),
        Text('أما ساق؟', textDirection: TextDirection.rtl, style: K.h2.copyWith(color: K.inkSoft)),
        const SizedBox(height: 20),
        for (final (code, fr, ar) in const [('L', 'Pied gauche', 'الساق اليسار'), ('R', 'Pied droit', 'الساق اليمين')]) ...[
          SizedBox(
            height: 96,
            child: FilledButton(
              onPressed: () => onPick(code),
              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(fr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                Text(ar, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 18)),
              ]),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ]);
}

/// A card saying the feature needs the Khatwa server, with a retry.
class NeedsServer extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const NeedsServer({super.key, required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
        KCard(
          color: K.warnSoft,
          child: Row(children: [
            Icon(Icons.cloud_off_rounded, color: K.warn),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: K.body)),
          ]),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
      ]);
}

/// A short text in the app's language (derja by default).
String tr(String fr, {required String aeb, required String ar, required String en}) => switch (langCode()) {
      'aeb' => aeb,
      'ar' => ar,
      'en' => en,
      _ => fr,
    };
