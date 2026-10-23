import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:wirespot_backend/auth.dart';
import 'package:wirespot_backend/backend_store.dart';

Future<Response> onRequest(RequestContext context) async {
  if (!isAuthenticated(context)) return unauthorized();
  if (context.request.method == HttpMethod.post) {
    if (!hasRole(context, commandExecutionRoles)) {
      return forbidden('Command execution permission required.');
    }
    try {
      final payload = jsonDecode(await context.request.body());
      if (payload is! Map ||
          payload['targetResourceId'] is! String ||
          payload['type'] is! String ||
          (payload['type'] as String).trim().isEmpty) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'targetResourceId and type are required.'},
        );
      }
      final type = (payload['type'] as String).trim();
      if (!{'remote_reboot', 'router_command'}.contains(type)) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'Unsupported command type.'},
        );
      }
      if (type == 'router_command' &&
          (payload['params'] is! Map ||
              payload['params']['command'] is! String ||
              (payload['params']['command'] as String).trim().isEmpty ||
              (payload['params']['command'] as String).length > 512)) {
        return Response.json(
          statusCode: 400,
          body: {
            'error': 'router_command requires a command up to 512 characters.',
          },
        );
      }
      final id = 'cmd_${DateTime.now().microsecondsSinceEpoch}';
      final command = <String, dynamic>{
        'id': id,
        'organizationId': organizationId(context),
        'targetResourceId': payload['targetResourceId'],
        'type': type,
        'params': payload['params'] is Map ? payload['params'] : const {},
        'status': 'pending',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      };
      BackendStore.enqueueCommand(organizationId(context), command);
      return Response.json(
        statusCode: 202,
        body: {'status': 'queued', ...command},
      );
    } catch (_) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Invalid command payload.'},
      );
    }
  }
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }
  return Response.json(
    body: {
      'status': 'success',
      'commands': BackendStore.commandsFor(organizationId(context)),
    },
  );
}
