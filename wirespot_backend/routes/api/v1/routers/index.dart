import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:wirespot_backend/auth.dart';
import 'package:wirespot_backend/backend_store.dart';

Future<Response> onRequest(RequestContext context) async {
  if (!isAuthenticated(context)) return unauthorized();
  if (context.request.method == HttpMethod.get) {
    return Response.json(
      body: {'status': 'success', 'routers': BackendStore.routers},
    );
  }

  if (context.request.method == HttpMethod.post) {
    try {
      final payload = jsonDecode(await context.request.body());
      if (payload is! Map || payload['routers'] is! List) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'Expected a routers list.'},
        );
      }
      final incoming = (payload['routers'] as List)
          .whereType<Map>()
          .map((router) => Map<String, dynamic>.from(router))
          .where(_isValidRouter)
          .toList();
      BackendStore.routers
        ..clear()
        ..addAll(incoming);
      return Response.json(
        body: {
          'status': 'success',
          'syncedCount': incoming.length,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (_) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Invalid router sync payload.'},
      );
    }
  }

  return Response(statusCode: 405, body: 'Method Not Allowed');
}

bool _isValidRouter(Map<String, dynamic> router) {
  final name = router['name'];
  final vendor = router['vendor'];
  final ip = router['ip'];
  final port = router['port'];
  return name is String &&
      name.trim().isNotEmpty &&
      vendor is String &&
      vendor.trim().isNotEmpty &&
      ip is String &&
      ip.trim().isNotEmpty &&
      (port is int || port is num);
}
