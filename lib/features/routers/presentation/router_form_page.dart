import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/storage/router_credentials.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/validators.dart';
import '../domain/entities/router_entity.dart';
import 'router_providers.dart';

class RouterFormPage extends ConsumerStatefulWidget {
  const RouterFormPage({this.routerId, super.key});

  final String? routerId;

  @override
  ConsumerState<RouterFormPage> createState() => _RouterFormPageState();
}

class _RouterFormPageState extends ConsumerState<RouterFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '8728');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _useSsl = false;
  bool _requireVpn = true;
  RouterRemoteAccessMode _remoteAccessMode = RouterRemoteAccessMode.wireGuard;
  bool _isSaving = false;
  bool _didHydrate = false;

  bool get _isEditing => widget.routerId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.routerId == null) {
      return _buildScaffold(null);
    }

    final router = ref.watch(routerByIdProvider(widget.routerId!));
    return router.when(
      data: _buildScaffold,
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Edit router')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load router: $error'),
          ),
        ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Edit router')),
        body: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildScaffold(RouterEntity? existingRouter) {
    if (_isEditing && existingRouter == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit router')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.router_outlined, size: 48),
                const SizedBox(height: 16),
                const Text('Router not found'),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _returnToRouters(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to routers'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit router' : 'Add router')),
      body: Builder(
        builder: (context) {
          _hydrate(existingRouter);
          return _RouterFormBody(
            formKey: _formKey,
            nameController: _nameController,
            hostController: _hostController,
            portController: _portController,
            usernameController: _usernameController,
            passwordController: _passwordController,
            useSsl: _useSsl,
            requireVpn: _requireVpn,
            remoteAccessMode: _remoteAccessMode,
            isEditing: _isEditing,
            isSaving: _isSaving,
            onUseSslChanged: (value) => setState(() => _useSsl = value),
            onRemoteAccessModeChanged: _setRemoteAccessMode,
            onSave: () => _save(existingRouter),
            onCancel: _returnToRouters,
          );
        },
      ),
    );
  }

  void _hydrate(RouterEntity? router) {
    if (_didHydrate || router == null) {
      return;
    }

    _nameController.text = router.name;
    _hostController.text = router.host;
    _portController.text = router.apiPort.toString();
    _usernameController.text = router.username;
    _useSsl = router.useSsl;
    _requireVpn = router.requireVpn;
    _remoteAccessMode = router.remoteAccessMode;
    _didHydrate = true;
  }

  void _setRemoteAccessMode(RouterRemoteAccessMode mode) {
    setState(() {
      _remoteAccessMode = mode;
      _requireVpn = mode.requiresPrivateTunnel;
      if (mode.recommendedSsl) {
        _useSsl = true;
      }
      final port = _portController.text.trim();
      if (port.isEmpty || port == '8728' || port == '8729' || port == '443') {
        _portController.text = mode.recommendedPort.toString();
      }
    });
  }

  Future<void> _save(RouterEntity? existingRouter) async {
    if (_isSaving) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final password = _passwordController.text.trim();
    if (!_isEditing && password.isEmpty) {
      _showMessage('Password is required for a new router.');
      return;
    }
    if (_isEditing &&
        existingRouter != null &&
        existingRouter.username != _usernameController.text.trim() &&
        password.isEmpty) {
      _showMessage('Enter the router password after changing username.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      final router = RouterEntity(
        id: existingRouter?.id ?? IdGenerator.timestampId('router'),
        groupId: existingRouter?.groupId,
        name: _nameController.text.trim(),
        host: _hostController.text.trim(),
        apiPort: int.parse(_portController.text.trim()),
        useSsl: _useSsl,
        requireVpn: _requireVpn,
        remoteAccessMode: _remoteAccessMode,
        username: _usernameController.text.trim(),
        identity: existingRouter?.identity,
        version: existingRouter?.version,
        boardName: existingRouter?.boardName,
        isEnabled: existingRouter?.isEnabled ?? true,
        lastConnectedAt: existingRouter?.lastConnectedAt,
        createdAt: existingRouter?.createdAt ?? now,
        updatedAt: now,
      );

      await ref
          .read(routerRepositoryProvider)
          .saveRouter(
            router,
            credentials: password.isEmpty
                ? null
                : RouterCredentials(
                    username: router.username,
                    password: password,
                  ),
          );
      ref.invalidate(routersProvider);

      if (!mounted) {
        return;
      }
      _showMessage(_isEditing ? 'Router updated.' : 'Router added.');
      _returnToRouters();
    } on Object catch (error) {
      if (mounted) {
        _showMessage('Could not save router: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _returnToRouters() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.routers);
  }
}

class _RemoteAccessModeHint extends StatelessWidget {
  const _RemoteAccessModeHint({required this.mode});

  final RouterRemoteAccessMode mode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          mode.description,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _RouterFormBody extends StatelessWidget {
  const _RouterFormBody({
    required this.formKey,
    required this.nameController,
    required this.hostController,
    required this.portController,
    required this.usernameController,
    required this.passwordController,
    required this.useSsl,
    required this.requireVpn,
    required this.remoteAccessMode,
    required this.isEditing,
    required this.isSaving,
    required this.onUseSslChanged,
    required this.onRemoteAccessModeChanged,
    required this.onSave,
    required this.onCancel,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController hostController;
  final TextEditingController portController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool useSsl;
  final bool requireVpn;
  final RouterRemoteAccessMode remoteAccessMode;
  final bool isEditing;
  final bool isSaving;
  final ValueChanged<bool> onUseSslChanged;
  final ValueChanged<RouterRemoteAccessMode> onRemoteAccessModeChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sslIsRequired = remoteAccessMode.recommendedSsl;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      Validators.requiredText(value, label: 'Router name'),
                  decoration: const InputDecoration(
                    labelText: 'Router name',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: hostController,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      Validators.requiredText(value, label: 'Host'),
                  decoration: const InputDecoration(
                    labelText: 'Router IP or host',
                    helperText:
                        'Use the VPN IP for remote routers or LAN IP on-site.',
                    prefixIcon: Icon(Icons.dns_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: portController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _validatePort,
                  decoration: const InputDecoration(
                    labelText: 'API port',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<RouterRemoteAccessMode>(
                  initialValue: remoteAccessMode,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Remote access method',
                    prefixIcon: Icon(Icons.hub_outlined),
                  ),
                  items: [
                    for (final mode in RouterRemoteAccessMode.values)
                      DropdownMenuItem(
                        value: mode,
                        child: Text(
                          mode.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      onRemoteAccessModeChanged(mode);
                    }
                  },
                ),
                const SizedBox(height: 8),
                _RemoteAccessModeHint(mode: remoteAccessMode),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: useSsl,
                  onChanged: sslIsRequired ? null : onUseSslChanged,
                  title: const Text('Use SSL'),
                  subtitle: Text(
                    sslIsRequired
                        ? 'Required for this remote access method.'
                        : 'Enable for RouterOS API SSL, usually port 8729.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  secondary: const Icon(Icons.enhanced_encryption_outlined),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    requireVpn ? Icons.vpn_lock_outlined : Icons.lan_outlined,
                  ),
                  title: Text(
                    requireVpn
                        ? 'Private tunnel required'
                        : 'Direct connection allowed',
                  ),
                  subtitle: Text(
                    requireVpn
                        ? 'Connect WireGuard, Back To Home, or ZeroTier before RouterOS API communication.'
                        : 'Only use direct modes on trusted LAN or tightly firewalled API-SSL endpoints.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: usernameController,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      Validators.requiredText(value, label: 'Username'),
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => onSave(),
                  decoration: InputDecoration(
                    labelText: isEditing ? 'Password' : 'Password required',
                    helperText: isEditing
                        ? 'Leave blank to keep current password.'
                        : null,
                    prefixIcon: const Icon(Icons.password_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: isSaving ? null : onSave,
                  icon: isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(isSaving ? 'Saving...' : 'Save router'),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: isSaving ? null : onCancel,
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _validatePort(String? value) {
    final required = Validators.requiredText(value, label: 'API port');
    if (required != null) {
      return required;
    }

    final port = int.tryParse(value!.trim());
    if (port == null || port < 1 || port > 65535) {
      return 'Enter a valid port from 1 to 65535';
    }
    return null;
  }
}
