import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  try {
    final bodyText = await context.request.body();
    final json = jsonDecode(bodyText) as Map<String, dynamic>;
    final pairingKey = json['pairingKey'] as String? ?? '';

    if (pairingKey.isEmpty || !pairingKey.startsWith('WS-')) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Invalid pairing key. Format must be WS-XXXX-SYNC.'},
      );
    }

    final token =
        'ws_session_${DateTime.now().millisecondsSinceEpoch}_${pairingKey.replaceAll('-', '_')}';

    return Response.json(
      body: {
        'status': 'success',
        'pairingKey': pairingKey,
        'accessToken': token,
        'organizationId': 'org_wirespot_default',
        'expiresIn': 86400,
        'pairedAt': DateTime.now().toIso8601String(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Failed to process pairing request: ${e.toString()}'},
    );
  }
}
