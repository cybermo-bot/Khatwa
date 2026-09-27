import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ui/app_state.dart';
import '../ui/app_theme.dart';
import '../ui/strings.dart';

/// Assistant language code for the app's language setting.
String langCode([String? appLang]) => switch (appLang ?? appLanguage.value) {
      'العربية' => 'ar',
      'Français' => 'fr',
      'English' => 'en',
      _ => 'aeb',
    };

String today() => DateTime.now().toIso8601String().substring(0, 10);

/// A zone of `foot_regions.json` in the app's language.
String regionName(Object? code) {
  final key = 'zone.$code';
  final v = S.t(appLanguage.value, key);
  return v == key ? '$code' : v;
}

/// What the patient says a sign is, in the app's language.
String kindName(Object? code) => switch (code) {
      'callus' => tr('Callosité', aeb: 'جلدة قاسية', ar: 'تصلّب الجلد', en: 'Callus'),
      'corn' => tr('Cor', aeb: 'عين الحوت', ar: 'مسمار القدم', en: 'Corn'),
      'blister' => tr('Ampoule', aeb: 'فقاعة', ar: 'فقاعة', en: 'Blister'),
      'wound' => tr('Plaie', aeb: 'جرح', ar: 'جرح', en: 'Wound'),
      'redness' => tr('Rougeur', aeb: 'حمورية', ar: 'احمرار', en: 'Redness'),
      'swelling' => tr('Gonflement', aeb: 'نفخة', ar: 'تورّم', en: 'Swelling'),
      'colour' => tr('Changement de couleur', aeb: 'تبدّل اللون', ar: 'تغيّر اللون', en: 'Colour change'),
      'heel-cracks' => tr('Crevasse', aeb: 'تشقّق الكعب', ar: 'تشقّق الكعب', en: 'Heel crack'),
      'fungus' => tr('Mycose', aeb: 'فطريات', ar: 'فطريات', en: 'Fungus'),
      'nails' => tr('Ongle', aeb: 'الظفر', ar: 'الظفر', en: 'Nail'),
      'dry-skin' => tr('Peau sèche', aeb: 'جلد شايح', ar: 'جفاف الجلد', en: 'Dry skin'),
      'other' => tr('Autre', aeb: 'حاجة أخرى', ar: 'آخر', en: 'Other'),
      'unsure' => tr('Je ne sais pas', aeb: 'ما نعرفش', ar: 'لا أعرف', en: 'I don’t know'),
      _ => '$code',
    };

/// Finding statuses. None depends on photo area (not validated yet).
String statusName(Object? code) => switch (code) {
      'new' => tr('nouveau', aeb: 'جديد', ar: 'جديد', en: 'new'),
      'worse' => tr('aggravé : à montrer au soignant', aeb: 'زاد : ورّيه للطبيب', ar: 'ازداد: اعرضه على الطبيب', en: 'worse: show it to a health professional'),
      'no_improvement' => tr('pas d’amélioration : à montrer au soignant',
          aeb: 'ما تحسّنش : ورّيه للطبيب', ar: 'لا تحسّن: اعرضه على الطبيب', en: 'no better: show it to a health professional'),
      'still_there' => tr('toujours là', aeb: 'مازال موجود', ar: 'ما زال موجودًا', en: 'still there'),
      'healed' => tr('guéri (soignant)', aeb: 'برا (حسب الطبيب)', ar: 'شُفي (حسب الطبيب)', en: 'healed (health professional)'),
      'reported_healed' => tr('guéri selon vous, à confirmer par un soignant',
          aeb: 'برا حسب رأيك، يلزم الطبيب يأكّد', ar: 'شُفي حسب رأيك، ويؤكّده الطبيب', en: 'healed in your view, to be confirmed by a health professional'),
      'not_seen' => tr('non revu au dernier contrôle', aeb: 'ما تشافش في آخر فحص', ar: 'لم يُرَ في آخر فحص', en: 'not seen at the last check'),
      _ => '$code',
    };

/// Measures with their estimated precision (1.96 SD of repeated synthetic scans
/// through the server pipeline, rounded up, never below 2 mm), whole numbers.
const measurePrecision = {
  'foot_length_mm': 4,
  'ball_width_mm': 2,
  'heel_width_mm': 2,
  'ball_girth_mm': 6,
  'instep_height_mm': 13,
  'volume_to_8cm_ml': 45,
};

String measureName(String key) => switch (key) {
      'foot_length_mm' => tr('Longueur', aeb: 'الطول', ar: 'الطول', en: 'Length'),
      'ball_width_mm' => tr('Largeur de l’avant-pied', aeb: 'عرض قدّام الساق', ar: 'عرض مقدمة القدم', en: 'Width at the ball'),
      'heel_width_mm' => tr('Largeur du talon', aeb: 'عرض الكعب', ar: 'عرض الكعب', en: 'Heel width'),
      'ball_girth_mm' => tr('Tour de l’avant-pied', aeb: 'دورة قدّام الساق', ar: 'محيط مقدمة القدم', en: 'Girth at the ball'),
      'instep_height_mm' => tr('Hauteur du cou-de-pied', aeb: 'علو فوق الساق', ar: 'ارتفاع ظهر القدم', en: 'Instep height'),
      'volume_to_8cm_ml' => tr('Volume (jusqu’à 8 cm)', aeb: 'الحجم (حتى 8 صم)', ar: 'الحجم (حتى 8 سم)', en: 'Volume (up to 8 cm)'),
      _ => key,
    };

/// The unit of a measure, in the script of the app's language.
String measureUnit(String key) => key.endsWith('_ml')
    ? tr('mL', aeb: 'مل', ar: 'مل', en: 'mL')
    : tr('mm', aeb: 'مم', ar: 'مم', en: 'mm');

String precisionNote() => tr('Précision estimée sur données simulées. Mesures de recherche, pas un diagnostic.',
    aeb: 'الدقة مقدّرة على معطيات مصطنعة. قياسات بحث، موش تشخيص.',
    ar: 'الدقة مقدّرة على بيانات محاكاة. قياسات بحثية وليست تشخيصًا.',
    en: 'Precision estimated on simulated data. Research measurements, not a diagnosis.');

/// "pied gauche" / "pied droit" in the app's language.
String sideName(String? side) => side == 'L'
    ? tr('pied gauche', aeb: 'الساق اليسار', ar: 'القدم اليسرى', en: 'left foot')
    : tr('pied droit', aeb: 'الساق اليمين', ar: 'القدم اليمنى', en: 'right foot');

/// "254 ± 4 mm": whole numbers with the estimated precision, "-" when not measured.
String fmtMeasure(String key, Object? value) {
  final p = measurePrecision[key];
  if (value is! num || p == null) return '-';
  return '${value.round()} ± $p ${measureUnit(key)}';
}

/// Text direction for a string: Arabic script reads right to left.
TextDirection dirOf(String s) => RegExp(r'[؀-ۿ]').hasMatch(s) ? TextDirection.rtl : TextDirection.ltr;

Future<void> call190() => launchUrl(Uri(scheme: 'tel', path: '190'));

/// The go-now banner in the app's language, with a full-width call button.
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
              child: Text(
                  tr('Signe grave : appelez le 190 maintenant',
                      aeb: 'علامة خطيرة: اطلب 190 توّا', ar: 'علامة خطيرة: اتصل بالرقم 190 الآن', en: 'Serious sign: call 190 now'),
                  style: TextStyle(color: K.danger, fontWeight: FontWeight.w700, fontSize: 17)),
            ),
          ]),
          const SizedBox(height: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: K.danger, minimumSize: const Size.fromHeight(56)),
            onPressed: call190,
            icon: const Icon(Icons.call_rounded),
            label: Text(tr('Appeler le 190', aeb: 'اطلب 190', ar: 'اتصل بـ 190', en: 'Call 190')),
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
              soon
                  ? '${tr('À voir dans les 24 heures.', aeb: 'لازم يتشاف في ظرف 24 ساعة.', ar: 'يجب فحصه خلال 24 ساعة.', en: 'To be seen within 24 hours.')} $message'
                  : tr('Noté. Continuez à regarder vos pieds chaque jour.',
                      aeb: 'تسجّل. كمّل شوف ساقيك كل يوم.', ar: 'سُجّل. واصل فحص قدميك كل يوم.', en: 'Noted. Keep looking at your feet every day.'),
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
        Text(title ?? tr('Quel pied ?', aeb: 'أما ساق؟', ar: 'أي قدم؟', en: 'Which foot?'), style: K.h1),
        const SizedBox(height: 20),
        for (final code in const ['L', 'R']) ...[
          SizedBox(
            height: 88,
            child: FilledButton(
              onPressed: () => onPick(code),
              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              child: Text(_capital(sideName(code)), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ]);
}

String _capital(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

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
        OutlinedButton(onPressed: onRetry, child: Text(S.t(appLanguage.value, 'common.retry'))),
      ]);
}

/// A short text in the app's language (derja by default).
String tr(String fr, {required String aeb, required String ar, required String en}) => switch (langCode()) {
      'aeb' => aeb,
      'ar' => ar,
      'en' => en,
      _ => fr,
    };
