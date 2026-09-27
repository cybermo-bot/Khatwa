import 'models.dart';

/// Everything the doctor dashboard reads and does. Stream based: each stream
/// emits the current value as soon as it is listened to, then again on every
/// change, so the same screens work with the demo data and with Supabase
/// realtime.
abstract class DoctorRepository {
  /// Who acts: stored in `alerts.acknowledged_by` and `findings.reviewed_by`.
  String get doctorId;

  /// Patients shared with the doctor (or seeded demo patients).
  Stream<List<Patient>> patients();

  /// All alerts, newest first.
  Stream<List<Alert>> alerts();

  /// Messages of one patient, oldest first.
  Stream<List<Message>> messages(String patientId);

  /// Scans of one patient, oldest first.
  Stream<List<Scan>> scans(String patientId);

  /// Findings of one patient, or of every patient when [patientId] is null.
  Stream<List<Finding>> findings({String? patientId});

  /// Daily checks of one patient, or of every patient when [patientId] is
  /// null; newest first.
  Stream<List<Check>> checks({String? patientId});

  /// FHIR shares of one patient, newest first.
  Stream<List<Share>> shares(String patientId);

  /// Aggregates for the public health view.
  Stream<PopulationStats> populationStats();

  Future<void> acknowledgeAlert(String alertId);

  /// Clinician only: the finding was looked at.
  Future<void> markFindingReviewed(String findingId);

  /// Clinician only: the lesion has healed.
  Future<void> markFindingHealed(String findingId);

  Future<void> sendMessage(String patientId, String body);

  Future<void> setNextVisit(String patientId, DateTime when);

  /// A loadable URL for a scan's twin, or null to show the model foot.
  Future<String?> glbUrl(Scan scan);

  /// A loadable URL for a stored photo (sole or finding), or null.
  Future<String?> photoUrl(String path);

  void dispose();
}
