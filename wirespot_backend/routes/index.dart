import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'service': 'WireSpot Cloud API Server',
      'version': '1.0.0',
      'status': 'healthy',
      'provider': 'Koyeb Free Tier / Firebase Firestore',
      'documentation': 'https://github.com/Uszkido/wirespot/wiki',
    },
  );
}
