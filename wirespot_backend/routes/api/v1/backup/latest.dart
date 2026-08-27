import 'package:dart_frog/dart_frog.dart';
import 'package:wirespot_backend/auth.dart';
import 'package:wirespot_backend/backend_store.dart';

Response onRequest(RequestContext context) {
  if (!isAuthenticated(context)) return unauthorized();
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }
  return Response.json(
    body: {
      'status': 'success',
      'backup': BackendStore.latestBackup,
      'uploadedAt': BackendStore.latestBackupAt?.toIso8601String(),
    },
  );
}
