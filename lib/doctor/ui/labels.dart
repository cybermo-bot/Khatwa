/// Wording of the dashboard values, in French, or in English when the app is
/// in English. The app never diagnoses: these name what was seen or reported.
library;

import '../../ui/app_state.dart';

/// The dashboard reads English when the app is in English, French otherwise.
bool get dashboardEnglish => appLanguage.value == 'English';

/// French or English text for the dashboard.
String dl(String fr, String en) => dashboardEnglish ? en : fr;

const _regionFr = {
  'hallux': 'Gros orteil',
  'lesser_toes': 'Petits orteils',
  'interdigital': 'Entre les orteils',
  'forefoot_plantar': 'Sous l\'avant-pied',
  'midfoot_plantar': 'Voûte plantaire',
  'heel_plantar': 'Sous le talon',
  'heel_posterior': 'Arrière du talon',
  'dorsum': 'Dessus du pied',
  'medial_side': 'Bord interne',
  'lateral_side': 'Bord externe',
  'ankle': 'Cheville',
};

const _regionEn = {
  'hallux': 'Big toe',
  'lesser_toes': 'Lesser toes',
  'interdigital': 'Between the toes',
  'forefoot_plantar': 'Under the ball of the foot',
  'midfoot_plantar': 'Arch',
  'heel_plantar': 'Under the heel',
  'heel_posterior': 'Back of the heel',
  'dorsum': 'Top of the foot',
  'medial_side': 'Inner edge',
  'lateral_side': 'Outer edge',
  'ankle': 'Ankle',
};

Map<String, String> get regionLabels => dashboardEnglish ? _regionEn : _regionFr;

const _kindFr = {
  'callus': 'Callosité',
  'corn': 'Cor',
  'blister': 'Ampoule',
  'wound': 'Plaie',
  'redness': 'Rougeur',
  'swelling': 'Gonflement',
  'colour': 'Changement de couleur',
  'dry_skin': 'Peau sèche',
  'fissure': 'Fissure',
  'fungus': 'Mycose',
  'ingrown_nail': 'Ongle incarné',
  'unsure': 'À préciser',
};

const _kindEn = {
  'callus': 'Callus',
  'corn': 'Corn',
  'blister': 'Blister',
  'wound': 'Wound',
  'redness': 'Redness',
  'swelling': 'Swelling',
  'colour': 'Colour change',
  'dry_skin': 'Dry skin',
  'fissure': 'Fissure',
  'fungus': 'Fungal infection',
  'ingrown_nail': 'Ingrown nail',
  'unsure': 'To be specified',
};

Map<String, String> get kindLabels => dashboardEnglish ? _kindEn : _kindFr;

const _statusFr = {
  'new': 'Nouveau',
  'worse': 'S\'aggrave',
  'no_improvement': 'Sans amélioration',
  'still_there': 'Toujours présent',
  'healed': 'Guéri',
  'reported_healed': 'Guéri selon le patient',
  'not_seen': 'Non vu',
};

const _statusEn = {
  'new': 'New',
  'worse': 'Getting worse',
  'no_improvement': 'No improvement',
  'still_there': 'Still present',
  'healed': 'Healed',
  'reported_healed': 'Healed per patient',
  'not_seen': 'Not seen',
};

Map<String, String> get statusLabels => dashboardEnglish ? _statusEn : _statusFr;

Map<String, String> get findingLevelLabels => dashboardEnglish
    ? const {'none': 'Monitoring', 'soon': 'See soon', 'urgent': 'Urgent'}
    : const {'none': 'Surveillance', 'soon': 'À voir bientôt', 'urgent': 'Urgent'};

Map<String, String> get alertLevelLabels => dashboardEnglish
    ? const {'info': 'Info', 'soon': 'Soon', 'urgent': 'Urgent'}
    : const {'info': 'Info', 'soon': 'Bientôt', 'urgent': 'Urgent'};

Map<String, String> get checkLabels => dashboardEnglish
    ? const {'green': 'Green', 'amber': 'Amber', 'red': 'Red'}
    : const {'green': 'Vert', 'amber': 'Orange', 'red': 'Rouge'};

const _sourceFr = {
  'voice': 'Voix',
  'finding': 'Lésion',
  'check': 'Contrôle',
  'scan': 'Scan',
  'share': 'Partage',
  'photo': 'Photo',
  'sole_photo': 'Photo de la plante',
  'twin_tap': 'Touché sur le jumeau',
  'clinician': 'Clinicien',
};

const _sourceEn = {
  'voice': 'Voice',
  'finding': 'Finding',
  'check': 'Check',
  'scan': 'Scan',
  'share': 'Share',
  'photo': 'Photo',
  'sole_photo': 'Sole photo',
  'twin_tap': 'Tapped on the twin',
  'clinician': 'Clinician',
};

Map<String, String> get sourceLabels => dashboardEnglish ? _sourceEn : _sourceFr;

/// Label and unit of a measurement key of `scans.measurements`.
(String, String) measurementLabel(String key) => switch (key) {
      'foot_length_mm' => (dl('Longueur du pied', 'Foot length'), 'mm'),
      'forefoot_width_mm' => (dl('Largeur de l\'avant-pied', 'Forefoot width'), 'mm'),
      'arch_height_mm' => (dl('Hauteur de l\'arche', 'Arch height'), 'mm'),
      'instep_height_mm' => (dl('Hauteur du cou-de-pied', 'Instep height'), 'mm'),
      'volume_to_8cm_ml' => (dl('Volume jusqu\'à 8 cm', 'Volume up to 8 cm'), 'mL'),
      _ => (key, ''),
    };

String sideLabel(String side) =>
    side == 'R' ? dl('Pied droit', 'Right foot') : dl('Pied gauche', 'Left foot');

String riskLabel(int? risk) => risk == null ? dl('Risque inconnu', 'Unknown risk') : 'IWGDF $risk';

String typeLabel(String? type) => switch (type) {
      '1' => 'Type 1',
      '2' => 'Type 2',
      'other' => dl('Autre diabète', 'Other diabetes'),
      _ => dl('Type inconnu', 'Unknown type'),
    };

const _monthsFr = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
const _monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String shortDate(DateTime d) => '${d.day} ${(dashboardEnglish ? _monthsEn : _monthsFr)[d.month - 1]}';

String dateTime(DateTime d) =>
    '${shortDate(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String ago(DateTime d, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(d);
  if (diff.inMinutes < 1) return dl('à l\'instant', 'just now');
  if (diff.inMinutes < 60) return dl('il y a ${diff.inMinutes} min', '${diff.inMinutes} min ago');
  if (diff.inHours < 24) return dl('il y a ${diff.inHours} h', '${diff.inHours} h ago');
  if (diff.inDays < 7) return dl('il y a ${diff.inDays} j', '${diff.inDays} d ago');
  return shortDate(d);
}
