import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:wirespot_backend/auth.dart';
import 'package:wirespot_backend/backend_store.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }
  if (productionMode) {
    return Response.json(
      statusCode: 501,
      body: {
        'error':
            'Configure a hosted identity provider for production registration.',
      },
    );
  }

  try {
    final bodyText = await context.request.body();
    final json = jsonDecode(bodyText) as Map<String, dynamic>;
    final email = json['email'] as String? ?? '';
    final password = json['password'] as String? ?? '';
    final organizationName =
        json['organizationName'] as String? ?? 'Default Org';

    if (email.isEmpty || !email.contains('@') || password.length < 6) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Valid email and password (min 6 chars) are required.'},
      );
    }

    final orgId =
        'org_${organizationName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';
    final token =
        'ws_jwt_${DateTime.now().millisecondsSinceEpoch}_${email.hashCode.abs()}';

    BackendStore.saveAccount(email, {
      'organizationId': orgId,
      'organizationName': organizationName,
    });

    return Response.json(
      body: {
        'status': 'success',
        'message': 'Account registered successfully.',
        'user': {
          'email': email,
          'organizationName': organizationName,
          'organizationId': orgId,
          'createdAt': DateTime.now().toIso8601String(),
        },
        'accessToken': token,
        'expiresIn': 86400,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Failed to process registration: ${e.toString()}'},
    );
  }
}
