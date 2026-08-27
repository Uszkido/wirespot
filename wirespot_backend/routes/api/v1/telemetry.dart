import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:wirespot_backend/backend_store.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }
  try {
    await context.request.body().then(jsonDecode);
    BackendStore.telemetryEvents++;
    return Response.json(statusCode: 201, body: {'status': 'accepted'});
  } catch (_) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid telemetry payload.'},
    );
  }
}
