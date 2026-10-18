import 'package:wirespot_backend/auth.dart';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'status': 'ok',
      'timestamp': DateTime.now().toIso8601String(),
      'database': Platform.environment['WIRESPOT_STORE_PATH'] == null
          ? 'file-snapshot (default path)'
          : 'file-snapshot (configured path)',
      'productionReady': false,
      'authenticationMode':
          productionMode ? 'server-token-allowlist' : 'development-token',
    },
  );
}
