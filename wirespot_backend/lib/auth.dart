import 'package:dart_frog/dart_frog.dart';

bool isAuthenticated(RequestContext context) {
  final value = context.request.headers['authorization'];
  return value != null && value.startsWith('Bearer ws_');
}

Response unauthorized() => Response.json(
  statusCode: 401,
  body: {'error': 'A valid WireSpot session token is required.'},
);
