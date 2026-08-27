import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  try {
    final bodyText = await context.request.body();
    final json = jsonDecode(bodyText) as Map<String, dynamic>;
    final email = json['email'] as String? ?? '';
    final password = json['password'] as String? ?? '';

    if (email.isEmpty || password.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Email and password are required.'},
      );
    }

    final token =
        'ws_jwt_${DateTime.now().millisecondsSinceEpoch}_${email.hashCode.abs()}';
    final orgId = 'org_${email.split('@').first}';

    return Response.json(
      body: {
        'status': 'success',
        'message': 'Signed in successfully.',
        'user': {
          'email': email,
          'organizationId': orgId,
          'lastLogin': DateTime.now().toIso8601String(),
        },
        'accessToken': token,
        'expiresIn': 86400,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Failed to process login: ${e.toString()}'},
    );
  }
}
