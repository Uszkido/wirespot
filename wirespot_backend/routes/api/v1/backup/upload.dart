import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:wirespot_backend/auth.dart';
import 'package:wirespot_backend/backend_store.dart';

Future<Response> onRequest(RequestContext context) async {
  if (!isAuthenticated(context)) return unauthorized();
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }
  try {
    final payload = await context.request.body().then(jsonDecode);
    if (payload is! Map) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Backup must be a JSON object.'},
      );
    }
    BackendStore.latestBackup = Map<String, dynamic>.from(payload);
    BackendStore.latestBackupAt = DateTime.now().toUtc();
    return Response.json(
      statusCode: 201,
      body: {
        'status': 'accepted',
        'uploadedAt': BackendStore.latestBackupAt!.toIso8601String(),
      },
    );
  } catch (_) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid backup payload.'},
    );
  }
}
