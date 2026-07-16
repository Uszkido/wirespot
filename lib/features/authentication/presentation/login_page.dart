import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/branding/app_branding.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/brand_logo.dart';
import 'auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _obscurePin = true;
  bool _isBusy = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSetup = auth.isBootstrapped && !auth.hasPin;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: BrandLogo(size: 88, borderRadius: 18)),
                    const SizedBox(height: 20),
                    Text(
                      isSetup ? 'Secure WireSpot' : 'Welcome back',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSetup
                          ? 'Create a local operator PIN for ${AppBranding.appName}.'
                          : 'Sign in with your local operator PIN.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _pinController,
                      obscureText: _obscurePin,
                      keyboardType: TextInputType.number,
                      textInputAction: isSetup
                          ? TextInputAction.next
                          : TextInputAction.done,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _validatePin,
                      onFieldSubmitted: (_) {
                        if (!isSetup) {
                          _submit(isSetup: isSetup);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'PIN',
                        prefixIcon: const Icon(Icons.pin_outlined),
                        suffixIcon: IconButton(
                          tooltip: _obscurePin ? 'Show PIN' : 'Hide PIN',
                          onPressed: () {
                            setState(() => _obscurePin = !_obscurePin);
                          },
                          icon: Icon(
                            _obscurePin
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    if (isSetup) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPinController,
                        obscureText: _obscurePin,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value != _pinController.text) {
                            return 'PINs do not match';
                          }
                          return _validatePin(value);
                        },
                        onFieldSubmitted: (_) => _submit(isSetup: isSetup),
                        decoration: const InputDecoration(
                          labelText: 'Confirm PIN',
                          prefixIcon: Icon(Icons.password_outlined),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _isBusy
                          ? null
                          : () => _submit(isSetup: isSetup),
                      icon: _isBusy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(isSetup ? Icons.lock_outline : Icons.login),
                      label: Text(isSetup ? 'Create PIN' : 'Sign in'),
                    ),
                    if (!isSetup) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _isBusy ? null : _biometricLogin,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Use biometrics'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit({required bool isSetup}) async {
    if (_isBusy || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isBusy = true);
    try {
      final auth = ref.read(authControllerProvider);
      final ok = isSetup
          ? await auth.setupPin(_pinController.text)
          : await auth.signInWithPin(_pinController.text);
      if (!mounted) {
        return;
      }
      if (ok) {
        context.go(AppRoutes.dashboard);
      } else {
        _showMessage('Invalid PIN.');
      }
    } on Object catch (error) {
      if (mounted) {
        _showMessage('Authentication failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _biometricLogin() async {
    setState(() => _isBusy = true);
    try {
      final ok = await ref.read(authControllerProvider).signInWithBiometrics();
      if (!mounted) {
        return;
      }
      if (ok) {
        context.go(AppRoutes.dashboard);
      } else {
        _showMessage('Biometric authentication was not completed.');
      }
    } on Object catch (error) {
      if (mounted) {
        _showMessage('Biometric authentication failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  String? _validatePin(String? value) {
    final pin = value ?? '';
    if (pin.length < 4 || pin.length > 12) {
      return 'PIN must be 4 to 12 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return 'PIN must contain digits only';
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
