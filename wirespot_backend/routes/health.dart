import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'status': 'ok',
      'timestamp': DateTime.now().toIso8601String(),
      'database': 'Firebase Firestore (Free Spark Plan)',
    },
  );
}
