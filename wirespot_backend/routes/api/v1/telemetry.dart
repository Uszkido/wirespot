import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:wirespot_backend/auth.dart';
import 'package:wirespot_backend/backend_store.dart';

Future<Response> onRequest(RequestContext context) async {
  if (!isAuthenticated(context)) return unauthorized();
  final orgId = organizationId(context);
  if (context.request.method == HttpMethod.get) {
    final limit = (int.tryParse(
              context.request.uri.queryParameters['limit'] ?? '',
            ) ??
            120)
        .clamp(1, 240)
        .toInt();
    return Response.json(
      body: {
        'status': 'success',
        'organizationId': orgId,
        'telemetry': BackendStore.telemetryFor(orgId, limit: limit),
      },
    );
  }
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }
  try {
    final payload = await context.request.body().then(jsonDecode);
    final rawFrames = payload is Map && payload['frames'] is List
        ? payload['frames'] as List
        : [payload];
    final frames = rawFrames
        .whereType<Map>()
        .map((frame) => _normaliseFrame(Map<String, dynamic>.from(frame)))
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
    if (frames.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Telemetry must include at least one routerId.'},
      );
    }
    BackendStore.saveTelemetry(orgId, frames);
    return Response.json(
      statusCode: 201,
      body: {
        'status': 'accepted',
        'organizationId': orgId,
        'received': frames.length,
        'telemetry': BackendStore.telemetryFor(orgId, limit: 1),
      },
    );
  } catch (_) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid telemetry payload.'},
    );
  }
}

Map<String, dynamic>? _normaliseFrame(Map<String, dynamic> frame) {
  final routerId = frame['routerId']?.toString().trim();
  if (routerId == null || routerId.isEmpty) return null;
  final timestamp = DateTime.tryParse(frame['timestamp']?.toString() ?? '') ??
      DateTime.now().toUtc();
  num number(String key) => frame[key] is num
      ? frame[key] as num
      : num.tryParse(frame[key]?.toString() ?? '') ?? 0;
  int integer(String key) =>
      number(key).toInt().clamp(0, 2147483647).toInt();
  return {
    'routerId': routerId,
    'cpuLoad': number('cpuLoad').clamp(0, 100),
    'freeMemoryMb': number('freeMemoryMb').clamp(0, double.maxFinite),
    'totalMemoryMb': number('totalMemoryMb').clamp(0, double.maxFinite),
    'uptimeSeconds': integer('uptimeSeconds'),
    'activeHotspotUsersCount': integer('activeHotspotUsersCount'),
    'timestamp': timestamp.toIso8601String(),
  };
}
