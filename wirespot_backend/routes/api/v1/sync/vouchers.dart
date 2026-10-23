import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:wirespot_backend/auth.dart';
import 'package:wirespot_backend/backend_store.dart';

Future<Response> onRequest(RequestContext context) async {
  if (!isAuthenticated(context)) return unauthorized();
  final orgId = organizationId(context);
  if (context.request.method == HttpMethod.get) {
    return Response.json(
      body: {
        'status': 'success',
        'organizationId': orgId,
        'vouchers': BackendStore.vouchersFor(orgId),
      },
    );
  }

  if (context.request.method == HttpMethod.post) {
    if (!hasRole(context, commandExecutionRoles)) {
      return forbidden('Voucher synchronization permission required.');
    }
    try {
      final bodyText = await context.request.body();
      final json = jsonDecode(bodyText) as Map<String, dynamic>;
      final vouchers = json['vouchers'] as List<dynamic>? ?? [];
      var syncedCount = 0;
      final stored = BackendStore.vouchersFor(orgId);
      for (final voucher in vouchers) {
        if (voucher is Map) {
          final normalized = Map<String, dynamic>.from(voucher);
          final key = _voucherKey(normalized);
          if (key == null) continue;
          final index = stored.indexWhere((item) => _voucherKey(item) == key);
          if (index >= 0) {
            stored[index] = normalized;
          } else {
            stored.add(normalized);
          }
          syncedCount++;
        }
      }
      BackendStore.persist();

      return Response.json(
        body: {
          'status': 'success',
          'syncedCount': syncedCount,
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

String? _voucherKey(Map<String, dynamic> voucher) {
  final value = voucher['id'] ?? voucher['code'] ?? voucher['voucherId'];
  if (value is! String || value.trim().isEmpty) return null;
  return value.trim().toLowerCase();
}
