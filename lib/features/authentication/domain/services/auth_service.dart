import '../../../../core/storage/secure_storage_keys.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../entities/auth_session.dart';
import 'biometric_auth_service.dart';
import 'pin_hash_service.dart';

class AuthService {
  const AuthService({
    required SecureStorageService secureStorage,
    required PinHashService pinHashService,
    required BiometricAuthService biometricAuthService,
  }) : _secureStorage = secureStorage,
       _pinHashService = pinHashService,
       _biometricAuthService = biometricAuthService;

  final SecureStorageService _secureStorage;
  final PinHashService _pinHashService;
  final BiometricAuthService _biometricAuthService;

  Future<bool> hasPin() async {
    final hash = await _secureStorage.read(SecureStorageKeys.operatorPinHash);
    final salt = await _secureStorage.read(SecureStorageKeys.operatorPinSalt);
    return hash != null && salt != null;
  }

  Future<void> setupPin(String pin) async {
    _validatePin(pin);
    final salt = _pinHashService.generateSalt();
    final hash = _pinHashService.hashPin(pin: pin, salt: salt);
    await _secureStorage.write(SecureStorageKeys.operatorPinSalt, salt);
    await _secureStorage.write(SecureStorageKeys.operatorPinHash, hash);
    await createSession();
  }

  Future<bool> verifyPin(String pin) async {
    final hash = await _secureStorage.read(SecureStorageKeys.operatorPinHash);
    final salt = await _secureStorage.read(SecureStorageKeys.operatorPinSalt);
    if (hash == null || salt == null) {
      return false;
    }
    final isValid = _pinHashService.verify(
      pin: pin,
      salt: salt,
      expectedHash: hash,
    );
    if (isValid) {
      await createSession();
    }
    return isValid;
  }

  Future<bool> authenticateWithBiometrics() async {
    final hasExistingPin = await hasPin();
    if (!hasExistingPin || !await _biometricAuthService.canAuthenticate()) {
      return false;
    }
    final authenticated = await _biometricAuthService.authenticate();
    if (authenticated) {
      await createSession();
    }
    return authenticated;
  }

  Future<AuthSession> createSession() async {
    final createdAt = DateTime.now();
    final token = _pinHashService.hashPin(
      pin: createdAt.microsecondsSinceEpoch.toString(),
      salt: _pinHashService.generateSalt(),
    );
    await _secureStorage.write(SecureStorageKeys.sessionToken, token);
    await _secureStorage.write(
      SecureStorageKeys.sessionCreatedAt,
      createdAt.toIso8601String(),
    );
    return AuthSession(token: token, createdAt: createdAt);
  }

  Future<AuthSession?> currentSession() async {
    final token = await _secureStorage.read(SecureStorageKeys.sessionToken);
    final createdAtText = await _secureStorage.read(
      SecureStorageKeys.sessionCreatedAt,
    );
    final createdAt = createdAtText == null
        ? null
        : DateTime.tryParse(createdAtText);
    if (token == null || createdAt == null) {
      return null;
    }
    return AuthSession(token: token, createdAt: createdAt);
  }

  Future<void> signOut() async {
    await _secureStorage.delete(SecureStorageKeys.sessionToken);
    await _secureStorage.delete(SecureStorageKeys.sessionCreatedAt);
  }

  void _validatePin(String pin) {
    if (pin.length < 4 || pin.length > 12) {
      throw ArgumentError.value(pin, 'pin', 'PIN must be 4 to 12 digits');
    }
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      throw ArgumentError.value(pin, 'pin', 'PIN must contain digits only');
    }
  }
}
