import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/settings/domain/entities/backup_payload.dart';

void main() {
  test('backup payload serializes to json map', () {
    final payload = BackupPayload(
      version: 1,
      exportedAt: DateTime(2026),
      settings: const {'theme_mode': 'dark'},
      printers: const [
        {'id': 'printer-1', 'name': 'Front desk'},
      ],
    );

    final json = payload.toJson();

    expect(json['version'], 1);
    expect(json['settings'], {'theme_mode': 'dark'});
    expect(json['printers'], isA<List<Map<String, Object?>>>());
  });
}
