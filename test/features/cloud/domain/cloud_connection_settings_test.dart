import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/cloud/domain/entities/cloud_connection_settings.dart';
import 'package:wirespot/features/cloud/domain/entities/cloud_session.dart';

void main() {
  test('cloud connection normalizes a secure API base URL', () {
    const settings = CloudConnectionSettings(
      apiBaseUrl: 'https://cloud.wirespot.example/api',
      organizationId: 'org-1',
    );

    expect(
      settings.apiBaseUri.toString(),
      'https://cloud.wirespot.example/api/',
    );
    expect(
      CloudConnectionSettings.fromJson(settings.toJson()).organizationId,
      'org-1',
    );
  });

  test('cloud connection rejects insecure production URLs', () {
    const settings = CloudConnectionSettings(
      apiBaseUrl: 'http://cloud.example/api',
    );

    expect(() => settings.apiBaseUri, throwsArgumentError);
  });

  test('cloud session identifies expired access tokens', () {
    final session = CloudSession(
      accessToken: 'token',
      expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
    );

    expect(session.isExpired, isTrue);
  });
}
