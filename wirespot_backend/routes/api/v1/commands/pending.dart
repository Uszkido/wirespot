import 'package:dart_frog/dart_frog.dart';
import 'package:wirespot_backend/auth.dart';

Response onRequest(RequestContext context) {
  if (!isAuthenticated(context)) return unauthorized();
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }
  return Response.json(body: {'status': 'success', 'commands': const []});
}
