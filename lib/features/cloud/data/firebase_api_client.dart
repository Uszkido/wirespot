import 'package:dio/dio.dart';

/// Direct Firebase REST API Client for WireSpot (100% Free, Zero Credit Card required).
/// Uses Firebase Identity Toolkit REST API for Auth and Firestore REST API for Database.
class FirebaseApiClient {
  FirebaseApiClient({
    this.apiKey = 'AIzaSyBpbSdludqgorj9_DKIAhUwUIVZN1bzONc',
    this.projectId = 'wirespot-app',
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final String apiKey;
  final String projectId;
  final Dio _dio;

  String get _authBaseUrl => 'https://identitytoolkit.googleapis.com/v1';
  String get _firestoreBaseUrl =>
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  /// Sign up a new operator using Firebase Auth REST API.
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String organizationName,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_authBaseUrl/accounts:signUp?key=$apiKey',
        data: {'email': email, 'password': password, 'returnSecureToken': true},
      );
      final data = response.data ?? {};
      final idToken = data['idToken'] as String? ?? '';
      final localId = data['localId'] as String? ?? '';
      final orgId = 'org_${localId.substring(0, 8)}';

      if (idToken.isNotEmpty) {
        // Initialize organization document in Firestore
        await setFirestoreDocument(
          idToken: idToken,
          documentPath: 'organizations/$orgId',
          fields: {
            'organizationName': organizationName,
            'ownerEmail': email,
            'ownerId': localId,
            'createdAt': DateTime.now().toIso8601String(),
          },
        );
      }

      return {
        'status': 'success',
        'accessToken': idToken,
        'user': {
          'email': email,
          'localId': localId,
          'organizationId': orgId,
          'organizationName': organizationName,
        },
      };
    } on DioException catch (e) {
      final errorData = e.response?.data as Map<String, dynamic>?;
      final errorMsg = errorData?['error']?['message'] as String? ?? e.message;
      throw Exception('Firebase Sign Up Error: $errorMsg');
    }
  }

  /// Sign in an existing operator using Firebase Auth REST API.
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_authBaseUrl/accounts:signInWithPassword?key=$apiKey',
        data: {'email': email, 'password': password, 'returnSecureToken': true},
      );
      final data = response.data ?? {};
      final idToken = data['idToken'] as String? ?? '';
      final localId = data['localId'] as String? ?? '';
      final orgId = 'org_${localId.substring(0, 8)}';

      return {
        'status': 'success',
        'accessToken': idToken,
        'user': {'email': email, 'localId': localId, 'organizationId': orgId},
      };
    } on DioException catch (e) {
      final errorData = e.response?.data as Map<String, dynamic>?;
      final errorMsg = errorData?['error']?['message'] as String? ?? e.message;
      throw Exception('Firebase Sign In Error: $errorMsg');
    }
  }

  /// Write a document to Firestore using REST API.
  Future<bool> setFirestoreDocument({
    required String idToken,
    required String documentPath,
    required Map<String, dynamic> fields,
  }) async {
    try {
      final formattedFields = <String, dynamic>{};
      fields.forEach((key, value) {
        formattedFields[key] = _toFirestoreValue(value);
      });

      final response = await _dio.patch<Map<String, dynamic>>(
        '$_firestoreBaseUrl/$documentPath',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
        data: {'fields': formattedFields},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getFirestoreDocument({
    required String idToken,
    required String documentPath,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_firestoreBaseUrl/$documentPath',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );
      final fields = response.data?['fields'];
      if (fields is! Map) return {};
      return Map<String, dynamic>.from(
        fields.map(
          (key, value) => MapEntry(key.toString(), _fromFirestoreValue(value)),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteFirestoreDocument({
    required String idToken,
    required String documentPath,
  }) async {
    try {
      final response = await _dio.delete<void>(
        '$_firestoreBaseUrl/$documentPath',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

Map<String, dynamic> _toFirestoreValue(Object? value) {
  if (value == null) return {'nullValue': null};
  if (value is bool) return {'booleanValue': value};
  if (value is int) return {'integerValue': value.toString()};
  if (value is num) return {'doubleValue': value.toDouble()};
  if (value is String) return {'stringValue': value};
  if (value is DateTime) {
    return {'timestampValue': value.toUtc().toIso8601String()};
  }
  if (value is List) {
    return {
      'arrayValue': {'values': value.map(_toFirestoreValue).toList()},
    };
  }
  if (value is Map) {
    return {
      'mapValue': {
        'fields': value.map(
          (key, nested) => MapEntry(key.toString(), _toFirestoreValue(nested)),
        ),
      },
    };
  }
  return {'stringValue': value.toString()};
}

dynamic _fromFirestoreValue(Object? value) {
  if (value is! Map) return null;
  if (value.containsKey('nullValue')) return null;
  if (value.containsKey('stringValue')) return value['stringValue'];
  if (value.containsKey('booleanValue')) return value['booleanValue'];
  if (value.containsKey('integerValue')) {
    return int.tryParse('${value['integerValue']}') ?? 0;
  }
  if (value.containsKey('doubleValue')) return value['doubleValue'];
  if (value.containsKey('timestampValue')) return value['timestampValue'];
  final array = value['arrayValue'];
  if (array is Map && array['values'] is List) {
    return (array['values'] as List).map(_fromFirestoreValue).toList();
  }
  final map = value['mapValue'];
  if (map is Map && map['fields'] is Map) {
    final fields = map['fields'] as Map;
    return fields.map(
      (key, nested) => MapEntry(key.toString(), _fromFirestoreValue(nested)),
    );
  }
  return null;
}
