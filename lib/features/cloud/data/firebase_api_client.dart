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
        data: {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
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
        data: {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      );
      final data = response.data ?? {};
      final idToken = data['idToken'] as String? ?? '';
      final localId = data['localId'] as String? ?? '';
      final orgId = 'org_${localId.substring(0, 8)}';

      return {
        'status': 'success',
        'accessToken': idToken,
        'user': {
          'email': email,
          'localId': localId,
          'organizationId': orgId,
        },
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
        if (value is String) {
          formattedFields[key] = {'stringValue': value};
        } else if (value is int) {
          formattedFields[key] = {'integerValue': value.toString()};
        } else if (value is double) {
          formattedFields[key] = {'doubleValue': value};
        } else if (value is bool) {
          formattedFields[key] = {'booleanValue': value};
        }
      });

      final response = await _dio.patch<Map<String, dynamic>>(
        '$_firestoreBaseUrl/$documentPath',
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
        data: {'fields': formattedFields},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
