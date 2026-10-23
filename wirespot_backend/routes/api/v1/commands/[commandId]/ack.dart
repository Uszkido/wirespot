import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:wirespot_backend/auth.dart';
import 'package:wirespot_backend/backend_store.dart';

Future<Response> onRequest(RequestContext context, String commandId) async {
  if (!isAuthenticated(context)) return unauthorized();
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }
  if (!hasRole(context, commandExecutionRoles)) {
    return forbidden('Command acknowledgement permission required.');
  }
  final command = BackendStore.commandFor(organizationId(context), commandId);
  if (command == null) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Command not found.'},
    );
  }
  try {
    final payload = jsonDecode(await context.request.body());
    if (payload is! Map || payload['status'] is! String) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Command status is required.'},
      );
    }
    command['status'] = payload['status'];
    command['executedAt'] =
        payload['executedAt'] ?? DateTime.now().toUtc().toIso8601String();
    if (payload['resultPayload'] is Map)
      command['resultPayload'] = payload['resultPayload'];
    if (payload['errorMessage'] is String)
      command['errorMessage'] = payload['errorMessage'];
    BackendStore.persist();
    return Response.json(body: {'status': 'success', 'command': command});
  } catch (_) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid command acknowledgement.'},
    );
  }
}
