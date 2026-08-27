import 'package:dart_frog/dart_frog.dart';

bool isAuthenticated(RequestContext context) {
  final value = context.request.headers['authorization'];
  return value != null && value.startsWith('Bearer ws_');
}

/// Role-aware authorization for API mutations. Existing operator tokens that
/// do not send a role remain owner-compatible until role claims are available.
bool hasRole(RequestContext context, Set<String> allowed) {
  if (!isAuthenticated(context)) return false;
  final role =
      context.request.headers['x-wirespot-role']?.toLowerCase() ?? 'owner';
  return allowed.contains(role);
}

Response unauthorized() => Response.json(
  statusCode: 401,
  body: {'error': 'A valid WireSpot session token is required.'},
);
