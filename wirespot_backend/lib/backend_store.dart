/// Process-local state used by the lightweight backend.
///
/// This provides a working API for local/Koyeb testing. Replace this store
/// with Firestore persistence before running multiple backend instances.
class BackendStore {
  BackendStore._();

  static final vouchers = <Map<String, dynamic>>[];
  static Map<String, dynamic>? latestBackup;
  static DateTime? latestBackupAt;
  static int telemetryEvents = 0;
}
