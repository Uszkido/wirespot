import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/settings/domain/entities/backup_payload.dart';

void main() {
  test('backup payload serializes to json map with full entity scope', () {
    final payload = BackupPayload(
      version: 1,
      exportedAt: DateTime(2026),
      settings: const {'theme_mode': 'dark'},
      printers: const [
        {'id': 'printer-1', 'name': 'Front desk'},
      ],
      routers: const [
        {
          'id': 'r1',
          'name': 'MikroTik Core',
          'host': '192.168.88.1',
          'vendor': 'routeros',
        },
      ],
      hotspotProfiles: const [
        {'id': 'p1', 'name': '1-Hour Pass', 'price': 5.0},
      ],
      routerGroups: const [
        {'id': 'g1', 'name': 'Branch 1', 'description': 'Main Store'},
      ],
      wireGuardConfigs: const [
        {'name': 'hq_vpn', 'config': '[Interface]\nPrivateKey=abc='},
      ],
    );

    final json = payload.toJson();

    expect(json['version'], 1);
    expect(json['settings'], {'theme_mode': 'dark'});
    expect(json['printers'], isA<List<Map<String, Object?>>>());
    expect(json['routers'], isA<List<Map<String, Object?>>>());
    expect((json['routers'] as List).single['name'], 'MikroTik Core');
    expect((json['hotspotProfiles'] as List).single['price'], 5.0);
    expect((json['wireGuardConfigs'] as List).single['name'], 'hq_vpn');
  });

  test('backup payload restores from json map with full entity scope', () {
    final payload = BackupPayload.fromJson({
      'version': 1,
      'exportedAt': DateTime(2026).toIso8601String(),
      'settings': {'theme_mode': 'dark'},
      'printers': [
        {'id': 'printer-1', 'name': 'Front desk', 'paperWidthMm': 80},
      ],
      'routers': [
        {
          'id': 'r1',
          'name': 'Ruijie Gateway',
          'host': '10.0.0.1',
          'vendor': 'ruijie',
        },
      ],
      'hotspotProfiles': [
        {'id': 'p1', 'name': 'Daily Unlimited', 'price': 10.0},
      ],
      'wireGuardConfigs': [
        {'name': 'branch_tunnel', 'config': '[Interface]\nPrivateKey=xyz='},
      ],
    });

    expect(payload.version, 1);
    expect(payload.settings['theme_mode'], 'dark');
    expect(payload.printers.single['paperWidthMm'], 80);
    expect(payload.routers.single['name'], 'Ruijie Gateway');
    expect(payload.hotspotProfiles.single['name'], 'Daily Unlimited');
    expect(payload.wireGuardConfigs.single['name'], 'branch_tunnel');
  });
}
