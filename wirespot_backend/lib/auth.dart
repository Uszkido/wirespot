import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

class AuthPrincipal {
  const AuthPrincipal({
    required this.token,
    required this.organizationId,
    required this.role,
  });

  final String token;
  final String organizationId;
  final String role;
}

bool get productionMode =>
    Platform.environment['WIRESPOT_PRODUCTION']?.toLowerCase() == 'true' ||
    Platform.environment['WIRESPOT_ENV']?.toLowerCase() == 'production';

AuthPrincipal? principal(RequestContext context) {
  final header = context.request.headers['authorization'];
  if (header == null || !header.startsWith('Bearer ')) return null;
  final token = header.substring('Bearer '.length).trim();
  if (token.isEmpty) return null;

  if (productionMode) {
    // Configure WIRESPOT_OPERATOR_TOKENS as comma-separated
    // `token|organizationId|role` entries. This keeps role and organization
    // claims server-controlled until a hosted identity provider is wired in.
    final configured = Platform.environment['WIRESPOT_OPERATOR_TOKENS'] ?? '';
    for (final entry in configured.split(',')) {
      final parts = entry.split('|');
      if (parts.length == 3 && parts[0] == token) {
        return AuthPrincipal(
          token: token,
          organizationId: parts[1],
          role: parts[2].toLowerCase(),
        );
      }
    }
    return null;
  }

  // Development compatibility only. Never enable this fallback in production.
  if (!token.startsWith('ws_')) return null;
  final role =
      context.request.headers['x-wirespot-role']?.toLowerCase() ?? 'owner';
  final organization = context.request.headers['x-wirespot-organization']
      ?.trim();
  return AuthPrincipal(
    token: token,
    organizationId: organization == null || organization.isEmpty
        ? 'org_default'
        : organization,
    role: role,
  );
}

bool isAuthenticated(RequestContext context) {
  return principal(context) != null;
}

String organizationId(RequestContext context) {
  return principal(context)?.organizationId ?? 'org_default';
}

/// Role-aware authorization for API mutations. Existing operator tokens that
/// do not send a role remain owner-compatible until role claims are available.
bool hasRole(RequestContext context, Set<String> allowed) {
  if (!isAuthenticated(context)) return false;
  return allowed.contains(principal(context)?.role);
}

Response unauthorized() => Response.json(
  statusCode: 401,
  body: {'error': 'A valid WireSpot session token is required.'},
);
