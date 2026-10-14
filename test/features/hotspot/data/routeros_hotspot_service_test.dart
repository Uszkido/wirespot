import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/api/routeros_api_response.dart';
import 'package:wirespot/core/api/routeros_models.dart';
import 'package:wirespot/features/hotspot/data/routeros_hotspot_service.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_setup_input.dart';
import 'package:wirespot/features/hotspot/domain/entities/radius_server_settings.dart';
import 'package:wirespot/features/routers/domain/entities/router_entity.dart';
import 'package:wirespot/features/routers/domain/services/router_connection_service.dart';

void main() {
  test(
    'inspects whether the hotspot server and profile already exist',
    () async {
      final connection = _RecordingConnectionService(
        profileRecords: [
          {'.id': '*1', 'name': 'guest-profile'},
        ],
        serverRecords: [
          {'.id': '*2', 'name': 'guest-hotspot'},
        ],
      );
      final service = RouterOsHotspotService(connection);
      const router = RouterEntity(
        id: 'router-1',
        name: 'Guest router',
        host: '10.0.0.1',
        username: 'operator',
      );
      const input = HotspotSetupInput(
        serverName: 'guest-hotspot',
        interfaceName: 'bridge',
        serverProfileName: 'guest-profile',
        addressPool: 'guest-pool',
      );

      final inspection = await service.inspectSetup(router, input);

      expect(inspection.serverExists, isTrue);
      expect(inspection.profileExists, isTrue);
      expect(inspection.serverAction, 'Update existing server');
      expect(inspection.profileAction, 'Reuse existing profile');
      expect(connection.queries, contains('=name=guest-hotspot'));
      expect(connection.queries, contains('=name=guest-profile'));
    },
  );

  test('configures the RADIUS server during hotspot setup', () async {
    final connection = _RecordingConnectionService(
      profileRecords: const [],
      serverRecords: const [],
    );
    final service = RouterOsHotspotService(connection);
    const router = RouterEntity(
      id: 'router-1',
      name: 'Guest router',
      host: '10.0.0.1',
      username: 'operator',
    );
    const input = HotspotSetupInput(
      serverName: 'guest-hotspot',
      interfaceName: 'bridge',
      serverProfileName: 'guest-profile',
      addressPool: 'guest-pool',
      useRadius: true,
      radiusSettings: RadiusServerSettings(
        address: '10.0.0.10',
        secret: 'shared-secret',
      ),
    );

    await service.setupHotspot(router, input);

    expect(connection.commands, contains('/radius/add'));
    expect(
      connection.recordedAttributes['/radius/add'],
      containsPair('secret', 'shared-secret'),
    );
  });

  test('updates an existing hotspot profile when enabling RADIUS', () async {
    final connection = _RecordingConnectionService(
      profileRecords: [
        {'.id': '*1', 'name': 'guest-profile'},
      ],
      serverRecords: const [],
    );
    final service = RouterOsHotspotService(connection);
    const router = RouterEntity(
      id: 'router-1',
      name: 'Guest router',
      host: '10.0.0.1',
      username: 'operator',
    );
    const input = HotspotSetupInput(
      serverName: 'guest-hotspot',
      interfaceName: 'bridge',
      serverProfileName: 'guest-profile',
      addressPool: 'guest-pool',
      useRadius: true,
      radiusSettings: RadiusServerSettings(
        address: '10.0.0.10',
        secret: 'shared-secret',
      ),
    );

    await service.setupHotspot(router, input);

    expect(connection.commands, contains('/ip/hotspot/profile/set'));
    expect(
      connection.recordedAttributes['/ip/hotspot/profile/set'],
      containsPair('use-radius', 'yes'),
    );
  });
}

class _RecordingConnectionService implements RouterConnectionService {
  _RecordingConnectionService({
    required this.profileRecords,
    required this.serverRecords,
  });

  final List<Map<String, String>> profileRecords;
  final List<Map<String, String>> serverRecords;
  final queries = <String>[];
  final commands = <String>[];
  final recordedAttributes = <String, Map<String, String>>{};

  @override
  Future<RouterOsApiResponse> execute(
    RouterEntity router,
    String command, {
    Map<String, String> attributes = const {},
    List<String> queries = const [],
  }) async {
    commands.add(command);
    recordedAttributes[command] = attributes;
    this.queries.addAll(queries);
    return RouterOsApiResponse(
      records: switch (command) {
        '/ip/hotspot/profile/print' => profileRecords,
        '/ip/hotspot/print' => serverRecords,
        _ => const [],
      },
    );
  }

  @override
  Future<RouterOsRouterSnapshot> getSnapshot(RouterEntity router) {
    throw UnimplementedError();
  }

  @override
  Future<bool> testConnection(RouterEntity router) async => true;

  @override
  Stream<Map<String, String>> stream(
    RouterEntity router,
    String command, {
    Map<String, String> attributes = const {},
    List<String> queries = const [],
  }) {
    throw UnimplementedError();
  }
}
