import 'package:dart_frog/dart_frog.dart';
import 'package:wirespot_backend/auth.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'service': 'WireSpot Cloud API Server',
      'version': '1.0.0',
      'status': 'healthy',
      'provider': 'Dart Frog process-local store',
      'productionReady': productionConfigurationReady,
      'productionConfigurationGaps': productionConfigurationGaps,
      'authenticationMode': authenticationModeLabel,
      'documentation': 'https://github.com/Uszkido/wirespot/wiki',
    },
  );
}
