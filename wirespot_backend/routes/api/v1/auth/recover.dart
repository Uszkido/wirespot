import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:wirespot_backend/auth.dart';

/// Starts account recovery without disclosing whether an email is registered.
/// A hosted identity provider must be configured to send the actual reset link.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  try {
    final body =
        jsonDecode(await context.request.body()) as Map<String, dynamic>;
    final email = (body['email'] as String? ?? '').trim();
    if (email.isEmpty || !email.contains('@')) {
      return Response.json(
          statusCode: 400, body: {'error': 'A valid email is required.'});
    }
    if (productionMode) {
      return Response.json(
        statusCode: 501,
        body: {
          'error':
              'Configure a hosted identity provider to send recovery emails.'
        },
      );
    }
    return Response.json(body: {
      'status': 'accepted',
      'message':
          'Recovery request accepted. Configure an identity provider to deliver the reset email.',
    });
  } catch (_) {
    return Response.json(
        statusCode: 400, body: {'error': 'Invalid recovery request.'});
  }
}
