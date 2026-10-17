import 'package:dart_frog/dart_frog.dart';
import 'package:wirespot_backend/auth.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'status': 'ok',
      'timestamp': DateTime.now().toIso8601String(),
      'database': 'process-local (Firestore adapter required)',
      'productionReady': false,
      'authenticationMode': productionMode
          ? 'server-token-allowlist'
          : 'development-token',
    },
  );
}
