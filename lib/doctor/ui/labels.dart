/// French wording of the dashboard values. The app never diagnoses: these
/// name what was seen or reported.
library;

const regionLabels = {
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

const kindLabels = {
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

const statusLabels = {
  'new': 'Nouveau',
  'worse': 'S\'aggrave',
  'no_improvement': 'Sans amélioration',
  'still_there': 'Toujours présent',
  'healed': 'Guéri',
  'reported_healed': 'Guéri selon le patient',
  'not_seen': 'Non vu',
};

const findingLevelLabels = {
  'none': 'Surveillance',
  'soon': 'À voir bientôt',
  'urgent': 'Urgent',
};

const alertLevelLabels = {
  'info': 'Info',
  'soon': 'Bientôt',
  'urgent': 'Urgent',
};

const checkLabels = {
  'green': 'Vert',
  'amber': 'Orange',
  'red': 'Rouge',
};

const sourceLabels = {
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

String sideLabel(String side) => side == 'R' ? 'Pied droit' : 'Pied gauche';

String riskLabel(int? risk) => risk == null ? 'Risque inconnu' : 'IWGDF $risk';

String typeLabel(String? type) => switch (type) {
      '1' => 'Type 1',
      '2' => 'Type 2',
      'other' => 'Autre diabète',
      _ => 'Type inconnu',
    };

const _months = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];

String shortDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

String dateTime(DateTime d) =>
    '${shortDate(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String ago(DateTime d, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(d);
  if (diff.inMinutes < 1) return 'à l\'instant';
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
  return shortDate(d);
}
