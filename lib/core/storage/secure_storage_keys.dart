class SecureStorageKeys {
  const SecureStorageKeys._();

  static const operatorPinHash = 'operator.pin_hash';
  static const operatorPinSalt = 'operator.pin_salt';
  static const sessionToken = 'session.token';
  static const sessionCreatedAt = 'session.created_at';

  static String routerCredentials(String routerId) {
    return 'router.$routerId.credentials';
  }

  static String voucherPassword(String voucherId) {
    return 'voucher.$voucherId.password';
  }

  static String wireGuardConfig(String tunnelName) {
    return 'wireguard.$tunnelName.config';
  }
}
