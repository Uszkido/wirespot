import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? localAuthentication})
    : _localAuthentication = localAuthentication ?? LocalAuthentication();

  final LocalAuthentication _localAuthentication;

  Future<bool> canAuthenticate() async {
    return await _localAuthentication.canCheckBiometrics ||
        await _localAuthentication.isDeviceSupported();
  }

  Future<bool> authenticate() {
    return _localAuthentication.authenticate(
      localizedReason: 'Unlock WireSpot',
      options: const AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
      ),
    );
  }
}
