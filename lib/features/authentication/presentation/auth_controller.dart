import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/di/providers.dart';

final authControllerProvider =
    ChangeNotifierProvider<AuthController>((ref) {
  return AuthController(ref)..bootstrap();
});

class AuthController extends ChangeNotifier {
  AuthController(this._ref);

  final Ref _ref;
  bool _isBootstrapped = false;
  bool _isAuthenticated = false;
  bool _hasPin = false;

  bool get isBootstrapped => _isBootstrapped;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasPin => _hasPin;

  Future<void> bootstrap() async {
    final service = _ref.read(authServiceProvider);
    _hasPin = await service.hasPin();
    _isAuthenticated = await service.currentSession() != null;
    _isBootstrapped = true;
    notifyListeners();
  }

  Future<bool> setupPin(String pin) async {
    await _ref.read(authServiceProvider).setupPin(pin);
    _hasPin = true;
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  Future<bool> signInWithPin(String pin) async {
    final ok = await _ref.read(authServiceProvider).verifyPin(pin);
    _isAuthenticated = ok;
    notifyListeners();
    return ok;
  }

  Future<bool> signInWithBiometrics() async {
    final ok = await _ref.read(authServiceProvider).authenticateWithBiometrics();
    _isAuthenticated = ok;
    notifyListeners();
    return ok;
  }

  Future<void> signOut() async {
    await _ref.read(authServiceProvider).signOut();
    _isAuthenticated = false;
    notifyListeners();
  }
}
