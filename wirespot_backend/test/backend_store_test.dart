import 'package:test/test.dart';
import 'package:wirespot_backend/backend_store.dart';

void main() {
  test('router and backup records are isolated by organization', () {
    BackendStore.routersFor('org-a').add({
      'id': 'router-a',
      'name': 'A',
      'vendor': 'mikrotik',
      'ip': '192.0.2.1',
      'port': 8728,
    });
    BackendStore.routersFor('org-b').add({
      'id': 'router-b',
      'name': 'B',
      'vendor': 'mikrotik',
      'ip': '192.0.2.2',
      'port': 8728,
    });

    expect(BackendStore.routersFor('org-a').map((r) => r['id']), ['router-a']);
    expect(BackendStore.routersFor('org-b').map((r) => r['id']), ['router-b']);

    BackendStore.saveBackup('org-a', {'routers': ['router-a']});
    expect(BackendStore.latestBackupFor('org-a'), {'routers': ['router-a']});
    expect(BackendStore.latestBackupFor('org-b'), isNull);
  });

  test('commands cannot cross organization boundaries', () {
    BackendStore.enqueueCommand('org-a', {
      'id': 'cmd-a',
      'organizationId': 'org-a',
      'status': 'pending',
    });

    expect(BackendStore.commandFor('org-a', 'cmd-a'), isNotNull);
    expect(BackendStore.commandFor('org-b', 'cmd-a'), isNull);
  });

  test('router inventory merges devices without erasing another device', () {
    BackendStore.mergeRouters('org-merge', [
      {
        'id': 'phone-router',
        'name': 'Phone router',
        'vendor': 'mikrotik',
        'ip': '192.0.2.10',
        'port': 8728,
      },
    ]);
    BackendStore.mergeRouters('org-merge', [
      {
        'id': 'desktop-router',
        'name': 'Desktop router',
        'vendor': 'mikrotik',
        'ip': '192.0.2.11',
        'port': 8728,
      },
    ]);

    expect(
      BackendStore.routersFor('org-merge').map((router) => router['id']),
      containsAll(<String>['phone-router', 'desktop-router']),
    );
  });

  test('paired sessions retain organization and role until expiry', () {
    final token = BackendStore.createSession(
      'org-session-test',
      role: 'operator',
      lifetime: const Duration(minutes: 5),
    );

    expect(BackendStore.sessionFor(token), {
      'organizationId': 'org-session-test',
      'role': 'operator',
      'expiresAt': isA<String>(),
    });

    final expired = BackendStore.createSession(
      'org-expired-test',
      lifetime: const Duration(seconds: -1),
    );
    expect(BackendStore.sessionFor(expired), isNull);
  });

  test('telemetry frames are retained and isolated by organization', () {
    BackendStore.saveTelemetry('org-telemetry-a', [
      {
        'routerId': 'router-a',
        'cpuLoad': 24.5,
        'freeMemoryMb': 128,
        'timestamp': '2026-10-23T10:00:00Z',
      },
    ]);
    BackendStore.saveTelemetry('org-telemetry-b', [
      {'routerId': 'router-b', 'cpuLoad': 61},
    ]);

    expect(BackendStore.telemetryFor('org-telemetry-a'), hasLength(1));
    expect(BackendStore.telemetryFor('org-telemetry-a').single['routerId'],
        'router-a');
    expect(BackendStore.telemetryFor('org-telemetry-b').single['routerId'],
        'router-b');
    expect(BackendStore.telemetryFor('org-telemetry-a', limit: 0), hasLength(1));
  });
}
