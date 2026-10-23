import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:wirespot_backend/auth.dart';
import 'package:wirespot_backend/backend_store.dart';

Future<Response> onRequest(RequestContext context) async {
  if (!isAuthenticated(context)) return unauthorized();
  final orgId = organizationId(context);
  if (!hasRole(context, cloudBackupRoles)) {
    return forbidden('Cloud backup management permission required.');
  }
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
    BackendStore.saveBackup(orgId, Map<String, dynamic>.from(payload));
    return Response.json(
      statusCode: 201,
      body: {
        'status': 'accepted',
        'organizationId': orgId,
        'uploadedAt': BackendStore.latestBackupAtFor(orgId)!.toIso8601String(),
      },
    );
  } catch (_) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid backup payload.'},
    );
  }
}
