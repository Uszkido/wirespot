class SecureStorageKeys {
  const SecureStorageKeys._();

  static const operatorPinHash = 'operator.pin_hash';
  static const operatorPinSalt = 'operator.pin_salt';
  static const sessionToken = 'session.token';
  static const sessionCreatedAt = 'session.created_at';
  static const cloudConnectionSettings = 'cloud.connection_settings';
  static const cloudSession = 'cloud.session';

  static String routerCredentials(String routerId, {String? organizationId}) {
    final scope = (organizationId == null || organizationId.trim().isEmpty)
        ? 'default'
        : organizationId.trim().replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return 'router.$scope.$routerId.credentials';
  }

  static String voucherPassword(String voucherId) {
    return 'voucher.$voucherId.password';
  }

  static String wireGuardConfig(String tunnelName) {
    return 'wireguard.$tunnelName.config';
  }
}
