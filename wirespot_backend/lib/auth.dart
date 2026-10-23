import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:wirespot_backend/backend_store.dart';

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

/// Shared role groups used by API routes. Keep these names aligned with the
/// operator permission matrix in the Flutter client.
const routerManagementRoles = {'owner', 'admin', 'manager'};
const commandExecutionRoles = {'owner', 'admin', 'manager', 'operator'};
const cloudBackupRoles = {'owner', 'admin'};

bool get productionMode =>
    Platform.environment['WIRESPOT_PRODUCTION']?.toLowerCase() == 'true' ||
    Platform.environment['WIRESPOT_ENV']?.toLowerCase() == 'production';

/// Enables the built-in account endpoints for a single-instance pilot.
///
/// Public multi-tenant deployments should leave this disabled and put a
/// hosted identity provider in front of the API. It is opt-in in production
/// so a forgotten Render variable cannot accidentally expose local account
/// registration.
bool get localAuthEnabled =>
    !productionMode ||
    Platform.environment['WIRESPOT_ENABLE_LOCAL_AUTH']?.toLowerCase() == 'true';

String get authenticationModeLabel {
  if (!productionMode) return 'development-token';
  return localAuthEnabled ? 'local-pilot-auth' : 'server-token-allowlist';
}

bool localAuthEnabledFor(Map<String, String> environment) {
  final mode = environment['WIRESPOT_ENV']?.toLowerCase() == 'production' ||
      environment['WIRESPOT_PRODUCTION']?.toLowerCase() == 'true';
  return !mode ||
      environment['WIRESPOT_ENABLE_LOCAL_AUTH']?.toLowerCase() == 'true';
}

/// Indicates whether the backend has the minimum server-side controls needed
/// to run outside development mode. Hosted identity integration is still
/// recommended for public multi-tenant deployments.
bool get productionConfigurationReady =>
    productionMode && productionConfigurationGaps.isEmpty;

List<String> get productionConfigurationGaps {
  final gaps = <String>[];
  if (!productionMode) gaps.add('WIRESPOT_ENV=production');
  final operatorTokens =
      (Platform.environment['WIRESPOT_OPERATOR_TOKENS'] ?? '').trim();
  if (operatorTokens.isEmpty && !localAuthEnabled) {
    gaps.add('WIRESPOT_OPERATOR_TOKENS or WIRESPOT_ENABLE_LOCAL_AUTH=true');
  }
  if ((Platform.environment['WIRESPOT_STORE_PATH'] ?? '').trim().isEmpty) {
    gaps.add('WIRESPOT_STORE_PATH');
  }
  return gaps;
}

List<String> productionConfigurationGapsFor(
  Map<String, String> environment,
) {
  final gaps = <String>[];
  final mode = environment['WIRESPOT_ENV']?.toLowerCase() == 'production' ||
      environment['WIRESPOT_PRODUCTION']?.toLowerCase() == 'true';
  if (!mode) gaps.add('WIRESPOT_ENV=production');
  final tokens = (environment['WIRESPOT_OPERATOR_TOKENS'] ?? '').trim();
  if (tokens.isEmpty && !localAuthEnabledFor(environment)) {
    gaps.add('WIRESPOT_OPERATOR_TOKENS or WIRESPOT_ENABLE_LOCAL_AUTH=true');
  }
  if ((environment['WIRESPOT_STORE_PATH'] ?? '').trim().isEmpty) {
    gaps.add('WIRESPOT_STORE_PATH');
  }
  return gaps;
}

AuthPrincipal? principal(RequestContext context) {
  final header = context.request.headers['authorization'];
  if (header == null || !header.startsWith('Bearer ')) return null;
  final token = header.substring('Bearer '.length).trim();
  if (token.isEmpty) return null;

  final session = BackendStore.sessionFor(token);
  if (session != null) {
    final organizationId = session['organizationId']?.toString();
    final role = session['role']?.toString().toLowerCase();
    if (organizationId != null &&
        organizationId.isNotEmpty &&
        role != null &&
        role.isNotEmpty) {
      return AuthPrincipal(
        token: token,
        organizationId: organizationId,
        role: role,
      );
    }
  }

  if (productionMode) {
    // Configure WIRESPOT_OPERATOR_TOKENS as comma-separated
    // `token|organizationId|role` entries. This keeps role and organization
    // claims server-controlled until a hosted identity provider is wired in.
    final configured = Platform.environment['WIRESPOT_OPERATOR_TOKENS'] ?? '';
    for (final entry in configured.split(',')) {
      final parts = entry.split('|');
      if (parts.length == 3 && parts[0] == token) {
        final organizationId = parts[1].trim();
        final role = parts[2].trim().toLowerCase();
        if (organizationId.isEmpty || role.isEmpty) continue;
        return AuthPrincipal(
          token: token,
          organizationId: organizationId,
          role: role,
        );
      }
    }
    return null;
  }

  // Development compatibility only. Never enable this fallback in production.
  if (!token.startsWith('ws_')) return null;
  final role =
      context.request.headers['x-wirespot-role']?.trim().toLowerCase() ??
          'owner';
  final organization =
      context.request.headers['x-wirespot-organization']?.trim();
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

Response forbidden(String message) => Response.json(
      statusCode: 403,
      body: {'error': message},
    );

Response unauthorized() => Response.json(
      statusCode: 401,
      body: {'error': 'A valid WireSpot session token is required.'},
    );
