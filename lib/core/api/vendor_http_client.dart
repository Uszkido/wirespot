import 'dart:async';
import 'package:dio/dio.dart';
import '../../features/routers/domain/entities/router_entity.dart';

/// Production HTTP Client Adapter for non-MikroTik router management APIs.
class VendorHttpClient {
  VendorHttpClient({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Executes an HTTP REST or JSON-RPC API call normalized for vendor connectors.
  Future<Map<String, dynamic>> sendRequest({
    required RouterEntity router,
    required String path,
    String method = 'GET',
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    String? token,
  }) async {
    final scheme = router.useSsl ? 'https' : 'http';
    final baseUrl = '$scheme://${router.host}:${router.apiPort}';
    final fullUrl = path.startsWith('http') ? path : '$baseUrl$path';

    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };

    if (token != null && token.isNotEmpty) {
      if (router.vendor == RouterVendor.ruijie) {
        requestHeaders['Authorization'] = 'Bearer $token';
      } else if (router.vendor == RouterVendor.ubiquitiUniFi) {
        requestHeaders['X-CSRF-Token'] = token;
        requestHeaders['Cookie'] = 'TOKEN=$token';
      } else if (router.vendor == RouterVendor.tpLinkOmada) {
        requestHeaders['Csrf-Token'] = token;
      }
    }

    try {
      final response = await _dio.request<dynamic>(
        fullUrl,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          headers: requestHeaders,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else if (response.data is List) {
        return {'items': response.data};
      }
      return {'status': 'success', 'raw': response.data};
    } on DioException catch (e) {
      return {
        'status': 'error',
        'code': e.response?.statusCode ?? 500,
        'message': e.message ?? 'HTTP communication failure',
      };
    } catch (e) {
      return {
        'status': 'error',
        'code': 500,
        'message': 'Unexpected error: $e',
      };
    }
  }
}
