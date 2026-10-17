import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

const _defaultOrigins = <String>{
  'https://wirespot.web.app',
  'https://wirespot-app.web.app',
  'http://127.0.0.1:4173',
  'http://localhost:4173',
};

Set<String> _allowedOrigins() {
  final configured = Platform.environment['WIRESPOT_CORS_ORIGINS'];
  if (configured == null || configured.trim().isEmpty) {
    return _defaultOrigins;
  }
  return configured
      .split(',')
      .map((origin) => origin.trim())
      .where((origin) => origin.isNotEmpty)
      .toSet();
}

Map<String, Object> _corsHeaders(String? origin) {
  final allowed = _allowedOrigins();
  final validOrigin =
      origin != null && allowed.contains(origin) ? origin : null;
  return {
    if (validOrigin != null) 'Access-Control-Allow-Origin': validOrigin,
    'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
    'Access-Control-Allow-Headers':
        'Authorization, Content-Type, X-WireSpot-Organization, X-WireSpot-Role',
    'Access-Control-Max-Age': '600',
    'Vary': 'Origin',
  };
}

Handler middleware(Handler handler) {
  return (context) async {
    final origin = context.request.headers['origin'];
    final headers = _corsHeaders(origin);

    if (context.request.method == HttpMethod.options) {
      return Response(statusCode: 204, headers: headers);
    }

    final response = await handler(context);
    return response.copyWith(headers: {...response.headers, ...headers});
  };
}
