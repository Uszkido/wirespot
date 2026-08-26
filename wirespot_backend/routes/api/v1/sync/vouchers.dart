import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    return Response.json(
      body: {
        'status': 'success',
        'vouchers': [
          {
            'code': 'WS-8A2F',
            'profile': '1Hour-5MBPS',
            'price': 2.50,
            'status': 'active',
            'createdAt': DateTime.now().toIso8601String(),
          },
          {
            'code': 'WS-3K90',
            'profile': '1Day-10MBPS',
            'price': 5.00,
            'status': 'unused',
            'createdAt': DateTime.now().toIso8601String(),
          },
        ],
      },
    );
  }

  if (context.request.method == HttpMethod.post) {
    try {
      final bodyText = await context.request.body();
      final json = jsonDecode(bodyText) as Map<String, dynamic>;
      final vouchers = json['vouchers'] as List<dynamic>? ?? [];

      return Response.json(
        body: {
          'status': 'success',
          'syncedCount': vouchers.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Failed to parse sync payload: ${e.toString()}'},
      );
    }
  }

  return Response(statusCode: 405, body: 'Method Not Allowed');
}
