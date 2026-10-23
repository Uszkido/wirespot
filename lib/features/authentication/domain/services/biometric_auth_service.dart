import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? localAuthentication})
    : _localAuthentication = localAuthentication ?? LocalAuthentication();

  final LocalAuthentication _localAuthentication;

  /// Returns the biometric methods currently enrolled and available to the
  /// app (for example fingerprint, Face ID, iris, or Windows Hello).
  Future<List<BiometricType>> availableBiometrics() async {
    try {
      return await _localAuthentication.getAvailableBiometrics();
    } on Object {
      // Some desktop implementations do not expose an enrolled-biometric
      // list. The device-authentication fallback can still be available.
      return const <BiometricType>[];
    }
  }

  Future<bool> canAuthenticate() async {
    try {
      return await _localAuthentication.canCheckBiometrics ||
          await _localAuthentication.isDeviceSupported();
    } on Object {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _localAuthentication.authenticate(
        localizedReason:
            'Verify your identity to unlock WireSpot with biometrics or device security.',
        // Keep the platform PIN/passcode fallback enabled. This is important
        // on devices without a registered fingerprint or face profile.
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on Object {
      return false;
    }
  }

  static String describe(List<BiometricType> biometrics) {
    final labels = <String>[];
    for (final biometric in biometrics) {
      final label = switch (biometric) {
        BiometricType.face => 'Face ID / face unlock',
        BiometricType.fingerprint => 'fingerprint',
        BiometricType.iris => 'iris',
        BiometricType.strong => 'device biometrics',
        BiometricType.weak => 'device biometrics',
      };
      if (!labels.contains(label)) labels.add(label);
    }
    if (labels.isEmpty) return 'device security (PIN, pattern, or passcode)';
    if (labels.length == 1) return labels.single;
    if (labels.length == 2) return '${labels[0]} or ${labels[1]}';
    return '${labels.take(labels.length - 1).join(', ')}, or ${labels.last}';
  }
}
