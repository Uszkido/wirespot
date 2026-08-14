import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/api/routeros_api_response.dart';
import 'package:wirespot/core/api/routeros_models.dart';
import 'package:wirespot/features/routers/domain/entities/router_entity.dart';
import 'package:wirespot/features/routers/domain/services/router_connection_service.dart';
import 'package:wirespot/features/routers/domain/services/router_fleet_connection_service.dart';

void main() {
  test('tests multiple router connections concurrently', () async {
    final firstStarted = Completer<void>();
    final releaseFirst = Completer<void>();
    final service = RouterFleetConnectionService(
      _RecordingConnectionService(
        onTest: (router) async {
          if (router.id == 'one') {
            firstStarted.complete();
            await releaseFirst.future;
            return true;
          }
          await firstStarted.future;
          return false;
        },
      ),
    );

    final pending = service.testConnections([_router('one'), _router('two')]);
    await firstStarted.future;
    releaseFirst.complete();
    final results = await pending;

    expect(results.map((result) => result.isConnected), [true, false]);
  });
}

RouterEntity _router(String id) =>
    RouterEntity(id: id, name: id, host: '10.0.0.1', username: 'operator');

class _RecordingConnectionService implements RouterConnectionService {
  _RecordingConnectionService({required this.onTest});

  final Future<bool> Function(RouterEntity router) onTest;

  @override
  Future<RouterOsApiResponse> execute(
    RouterEntity router,
    String command, {
    Map<String, String> attributes = const {},
    List<String> queries = const [],
  }) => throw UnimplementedError();

  @override
  Future<RouterOsRouterSnapshot> getSnapshot(RouterEntity router) =>
      throw UnimplementedError();

  @override
  Future<bool> testConnection(RouterEntity router) => onTest(router);

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
