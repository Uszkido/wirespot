import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:wirespot_backend/auth.dart';
import 'package:wirespot_backend/backend_store.dart';

/// Reads a verified entitlement, or issues one through a server-only secret.
Future<Response> onRequest(RequestContext context) async {
  if (!isAuthenticated(context)) return unauthorized();
  final orgId = organizationId(context);

  if (context.request.method == HttpMethod.get) {
    return Response.json(
      body: {
        'status': 'success',
        'organizationId': orgId,
        'entitlement': BackendStore.entitlementFor(orgId),
      },
    );
  }
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }
  if (!hasRole(context, {'owner', 'admin'})) {
    return Response.json(
      statusCode: 403,
      body: {'error': 'Only organization owners or admins may issue licenses.'},
    );
  }
  final issuerSecret = Platform.environment['WIRESPOT_ENTITLEMENT_ADMIN_TOKEN'];
  if (issuerSecret == null || issuerSecret.isEmpty) {
    return Response.json(
      statusCode: 503,
      body: {'error': 'Server entitlement issuance is not configured.'},
    );
  }
  if (context.request.headers['x-wirespot-entitlement-token'] != issuerSecret) {
    return Response.json(
      statusCode: 403,
      body: {'error': 'Invalid entitlement issuer token.'},
    );
  }

  try {
    final payload = jsonDecode(await context.request.body());
    if (payload is! Map) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Invalid entitlement payload.'},
      );
    }
    final plan = payload['plan'] as String?;
    final deviceId = payload['deviceId'] as String?;
    final scope = (payload['scope'] as String?)?.trim().toLowerCase();
    final endsAt = payload['endsAt'] as String?;
    if (plan == null ||
        (deviceId == null && scope != 'workspace') ||
        endsAt == null ||
        (deviceId != null && deviceId.trim().length < 8) ||
        DateTime.tryParse(endsAt) == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'plan, deviceId, and a valid endsAt are required.'},
      );
    }
    final entitlement = <String, dynamic>{
      'plan': plan,
      if (deviceId != null && deviceId.trim().isNotEmpty)
        'deviceId': deviceId.trim().toUpperCase(),
      'scope': scope == 'workspace' ? 'workspace' : 'device',
      'startsAt': (payload['startsAt'] as String?) ??
          DateTime.now().toUtc().toIso8601String(),
      'endsAt': endsAt,
      'verified': true,
      'revoked': false,
      'issuedAt': DateTime.now().toUtc().toIso8601String(),
    };
    BackendStore.saveEntitlement(orgId, entitlement);
    return Response.json(
      body: {'status': 'success', 'entitlement': entitlement},
    );
  } catch (_) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid entitlement payload.'},
    );
  }
}
