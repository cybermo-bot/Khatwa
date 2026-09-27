/// Doctor dashboard data, one class per table of the data contract
/// (`supabase/migrations/0001_khatwa_demo.sql`). Field names follow the
/// columns; `fromMap` and `toMap` use the column names as they are, so a
/// Supabase row maps straight in.
library;

DateTime _date(Object? value) =>
    value is DateTime ? value : DateTime.tryParse('${value ?? ''}') ?? DateTime.fromMillisecondsSinceEpoch(0);

DateTime? _dateOrNull(Object? value) =>
    value == null ? null : (value is DateTime ? value : DateTime.tryParse('$value'));

String _day(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

Map<String, dynamic> _json(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

/// The 24 Tunisian governorates, in the usual order.
const governorates = [
  'Tunis', 'Ariana', 'Ben Arous', 'Manouba', 'Nabeul', 'Zaghouan',
  'Bizerte', 'Béja', 'Jendouba', 'Le Kef', 'Siliana', 'Sousse',
  'Monastir', 'Mahdia', 'Sfax', 'Kairouan', 'Kasserine', 'Sidi Bouzid',
  'Gabès', 'Médenine', 'Tataouine', 'Gafsa', 'Tozeur', 'Kébili',
];

/// Foot zones, as in `assets/models/foot_regions.json` and `findings.region`.
const footRegions = [
  'hallux', 'lesser_toes', 'interdigital', 'forefoot_plantar',
  'midfoot_plantar', 'heel_plantar', 'heel_posterior', 'dorsum',
  'medial_side', 'lateral_side', 'ankle',
];

/// Measurement keys of `scans.measurements` shown in the trends, with their
/// French label and unit.
const measurementLabels = <String, (String, String)>{
  'foot_length_mm': ('Longueur du pied', 'mm'),
  'forefoot_width_mm': ('Largeur de l\'avant-pied', 'mm'),
  'arch_height_mm': ('Hauteur de l\'arche', 'mm'),
  'instep_height_mm': ('Hauteur du cou-de-pied', 'mm'),
  'volume_to_8cm_ml': ('Volume jusqu\'à 8 cm', 'mL'),
};

class Patient {
  final String id;
  final String ref;
  final String? owner;
  final String displayName;
  final bool isDemo;
  final int? age;
  final String? sex; // F | M
  final String? diabetesType; // 1 | 2 | other
  final String? governorate;
  final int? iwgdfRisk; // 0..3
  final String? lastCheck; // green | amber | red
  final bool sharedWithDoctor;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  /// Next visit set by the clinician. Not a column of the contract yet: the
  /// demo keeps it in memory, a server implementation may leave it null.
  final DateTime? nextVisit;

  const Patient({
    required this.id,
    required this.ref,
    this.owner,
    required this.displayName,
    this.isDemo = false,
    this.age,
    this.sex,
    this.diabetesType,
    this.governorate,
    this.iwgdfRisk,
    this.lastCheck,
    this.sharedWithDoctor = false,
    required this.createdAt,
    required this.lastActiveAt,
    this.nextVisit,
  });

  factory Patient.fromMap(Map<String, dynamic> m) => Patient(
        id: '${m['id']}',
        ref: '${m['ref']}',
        owner: m['owner'] as String?,
        displayName: '${m['display_name']}',
        isDemo: m['is_demo'] == true,
        age: (m['age'] as num?)?.toInt(),
        sex: m['sex'] as String?,
        diabetesType: m['diabetes_type'] as String?,
        governorate: m['governorate'] as String?,
        iwgdfRisk: (m['iwgdf_risk'] as num?)?.toInt(),
        lastCheck: m['last_check'] as String?,
        sharedWithDoctor: m['shared_with_doctor'] == true,
        createdAt: _date(m['created_at']),
        lastActiveAt: _date(m['last_active_at']),
        nextVisit: _dateOrNull(m['next_visit']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'ref': ref,
        'owner': owner,
        'display_name': displayName,
        'is_demo': isDemo,
        'age': age,
        'sex': sex,
        'diabetes_type': diabetesType,
        'governorate': governorate,
        'iwgdf_risk': iwgdfRisk,
        'last_check': lastCheck,
        'shared_with_doctor': sharedWithDoctor,
        'created_at': createdAt.toIso8601String(),
        'last_active_at': lastActiveAt.toIso8601String(),
      };

  Patient copyWith({DateTime? nextVisit, String? lastCheck, DateTime? lastActiveAt}) => Patient(
        id: id,
        ref: ref,
        owner: owner,
        displayName: displayName,
        isDemo: isDemo,
        age: age,
        sex: sex,
        diabetesType: diabetesType,
        governorate: governorate,
        iwgdfRisk: iwgdfRisk,
        lastCheck: lastCheck ?? this.lastCheck,
        sharedWithDoctor: sharedWithDoctor,
        createdAt: createdAt,
        lastActiveAt: lastActiveAt ?? this.lastActiveAt,
        nextVisit: nextVisit ?? this.nextVisit,
      );
}

class Scan {
  final String id;
  final String patientId;
  final String side; // L | R
  final DateTime createdAt;
  /// foot_length_mm ... volume_to_8cm_ml; null = not measured.
  final Map<String, double?> measurements;
  final Map<String, dynamic> quality;
  final String glbPath;
  final String? solePhotoPath;
  final bool soleTextured;

  const Scan({
    required this.id,
    required this.patientId,
    required this.side,
    required this.createdAt,
    required this.measurements,
    this.quality = const {},
    required this.glbPath,
    this.solePhotoPath,
    this.soleTextured = false,
  });

  factory Scan.fromMap(Map<String, dynamic> m) => Scan(
        id: '${m['id']}',
        patientId: '${m['patient_id']}',
        side: '${m['side']}',
        createdAt: _date(m['created_at']),
        measurements: {
          for (final e in _json(m['measurements']).entries) e.key: (e.value as num?)?.toDouble(),
        },
        quality: _json(m['quality']),
        glbPath: '${m['glb_path']}',
        solePhotoPath: m['sole_photo_path'] as String?,
        soleTextured: m['sole_textured'] == true,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'patient_id': patientId,
        'side': side,
        'created_at': createdAt.toIso8601String(),
        'measurements': measurements,
        'quality': quality,
        'glb_path': glbPath,
        'sole_photo_path': solePhotoPath,
        'sole_textured': soleTextured,
      };
}

class Finding {
  final String id;
  final String patientId;
  final String side; // L | R
  final DateTime day;
  final String kind;
  final String region;
  final int vertex;
  final double? areaMm2;
  final String level; // none | soon | urgent
  final String status; // new, worse, no_improvement, still_there, healed, reported_healed, not_seen
  final String source; // photo, sole_photo, twin_tap, clinician
  final String reporter;
  final String? photoPath;
  final String note;
  final String? reviewedBy;
  final DateTime createdAt;

  const Finding({
    required this.id,
    required this.patientId,
    required this.side,
    required this.day,
    required this.kind,
    required this.region,
    required this.vertex,
    this.areaMm2,
    required this.level,
    this.status = 'new',
    this.source = 'photo',
    this.reporter = 'patient',
    this.photoPath,
    this.note = '',
    this.reviewedBy,
    required this.createdAt,
  });

  bool get isActive => status != 'healed' && status != 'reported_healed';

  factory Finding.fromMap(Map<String, dynamic> m) => Finding(
        id: '${m['id']}',
        patientId: '${m['patient_id']}',
        side: '${m['side']}',
        day: _date(m['day']),
        kind: '${m['kind']}',
        region: '${m['region']}',
        vertex: (m['vertex'] as num?)?.toInt() ?? 0,
        areaMm2: (m['area_mm2'] as num?)?.toDouble(),
        level: '${m['level']}',
        status: '${m['status'] ?? 'new'}',
        source: '${m['source'] ?? 'photo'}',
        reporter: '${m['reporter'] ?? 'patient'}',
        photoPath: m['photo_path'] as String?,
        note: '${m['note'] ?? ''}',
        reviewedBy: m['reviewed_by'] as String?,
        createdAt: _date(m['created_at']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'patient_id': patientId,
        'side': side,
        'day': _day(day),
        'kind': kind,
        'region': region,
        'vertex': vertex,
        'area_mm2': areaMm2,
        'level': level,
        'status': status,
        'source': source,
        'reporter': reporter,
        'photo_path': photoPath,
        'note': note,
        'reviewed_by': reviewedBy,
        'created_at': createdAt.toIso8601String(),
      };

  Finding copyWith({String? status, String? reviewedBy}) => Finding(
        id: id,
        patientId: patientId,
        side: side,
        day: day,
        kind: kind,
        region: region,
        vertex: vertex,
        areaMm2: areaMm2,
        level: level,
        status: status ?? this.status,
        source: source,
        reporter: reporter,
        photoPath: photoPath,
        note: note,
        reviewedBy: reviewedBy ?? this.reviewedBy,
        createdAt: createdAt,
      );
}

class Check {
  final String id;
  final String patientId;
  final DateTime day;
  final String result; // green | amber | red
  final Map<String, dynamic> answers;
  final DateTime createdAt;

  const Check({
    required this.id,
    required this.patientId,
    required this.day,
    required this.result,
    this.answers = const {},
    required this.createdAt,
  });

  factory Check.fromMap(Map<String, dynamic> m) => Check(
        id: '${m['id']}',
        patientId: '${m['patient_id']}',
        day: _date(m['day']),
        result: '${m['result']}',
        answers: _json(m['answers']),
        createdAt: _date(m['created_at']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'patient_id': patientId,
        'day': _day(day),
        'result': result,
        'answers': answers,
        'created_at': createdAt.toIso8601String(),
      };
}

class Alert {
  final String id;
  final String patientId;
  final String level; // info | soon | urgent
  final String source; // voice | finding | check | scan | share
  final String title;
  final String body;
  final String? acknowledgedBy;
  final DateTime createdAt;

  const Alert({
    required this.id,
    required this.patientId,
    required this.level,
    required this.source,
    required this.title,
    this.body = '',
    this.acknowledgedBy,
    required this.createdAt,
  });

  bool get acknowledged => acknowledgedBy != null;
  bool get urgent => level == 'urgent';

  factory Alert.fromMap(Map<String, dynamic> m) => Alert(
        id: '${m['id']}',
        patientId: '${m['patient_id']}',
        level: '${m['level']}',
        source: '${m['source']}',
        title: '${m['title']}',
        body: '${m['body'] ?? ''}',
        acknowledgedBy: m['acknowledged_by'] as String?,
        createdAt: _date(m['created_at']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'patient_id': patientId,
        'level': level,
        'source': source,
        'title': title,
        'body': body,
        'acknowledged_by': acknowledgedBy,
        'created_at': createdAt.toIso8601String(),
      };

  Alert acknowledge(String by) => Alert(
        id: id,
        patientId: patientId,
        level: level,
        source: source,
        title: title,
        body: body,
        acknowledgedBy: by,
        createdAt: createdAt,
      );
}

class Message {
  final String id;
  final String patientId;
  final String sender; // doctor | patient
  final String body;
  final DateTime? readAt;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.patientId,
    required this.sender,
    required this.body,
    this.readAt,
    required this.createdAt,
  });

  bool get fromDoctor => sender == 'doctor';

  factory Message.fromMap(Map<String, dynamic> m) => Message(
        id: '${m['id']}',
        patientId: '${m['patient_id']}',
        sender: '${m['sender']}',
        body: '${m['body']}',
        readAt: _dateOrNull(m['read_at']),
        createdAt: _date(m['created_at']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'patient_id': patientId,
        'sender': sender,
        'body': body,
        'read_at': readAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}

class Share {
  final String id;
  final String patientId;
  final Map<String, dynamic> fhir;
  final String? gazelleReport;
  final DateTime createdAt;

  const Share({
    required this.id,
    required this.patientId,
    required this.fhir,
    this.gazelleReport,
    required this.createdAt,
  });

  factory Share.fromMap(Map<String, dynamic> m) => Share(
        id: '${m['id']}',
        patientId: '${m['patient_id']}',
        fhir: _json(m['fhir']),
        gazelleReport: m['gazelle_report'] as String?,
        createdAt: _date(m['created_at']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'patient_id': patientId,
        'fhir': fhir,
        'gazelle_report': gazelleReport,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Aggregates for the public health view. Computed by the repository so a
/// server implementation can do it in SQL.
class PopulationStats {
  final int patients;
  /// Active findings per foot region (both feet together).
  final Map<String, int> findingsByRegion;
  /// Patients per IWGDF risk category 0..3.
  final Map<int, int> patientsByRisk;
  /// Alerts per week, oldest first; the key is the Monday of the week.
  final Map<DateTime, int> alertsByWeek;
  /// Patients per governorate.
  final Map<String, int> patientsByGovernorate;
  /// Urgent alerts per governorate.
  final Map<String, int> urgentByGovernorate;

  const PopulationStats({
    required this.patients,
    required this.findingsByRegion,
    required this.patientsByRisk,
    required this.alertsByWeek,
    required this.patientsByGovernorate,
    required this.urgentByGovernorate,
  });
}
