import 'package:dart_frog/dart_frog.dart';
import 'package:wirespot_backend/auth.dart';
import 'package:wirespot_backend/backend_store.dart';

Response onRequest(RequestContext context) {
  if (!isAuthenticated(context)) return unauthorized();
  final orgId = organizationId(context);
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }
  return Response.json(
    body: {
      'status': 'success',
      'organizationId': orgId,
      'backup': BackendStore.latestBackupFor(orgId),
      'uploadedAt': BackendStore.latestBackupAtFor(orgId)?.toIso8601String(),
    },
  );
}
