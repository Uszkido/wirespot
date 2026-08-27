import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_text.dart';
import '../../settings/presentation/settings_providers.dart';
import '../domain/entities/cloud_connection_settings.dart';
import '../domain/entities/cloud_sync_operation.dart';
import 'cloud_controller.dart';
import 'cloud_providers.dart';

class CloudSettingsPage extends ConsumerStatefulWidget {
  const CloudSettingsPage({super.key});

  @override
  ConsumerState<CloudSettingsPage> createState() => _CloudSettingsPageState();
}

class _CloudSettingsPageState extends ConsumerState<CloudSettingsPage> {
  final _urlController = TextEditingController();
  final _orgController = TextEditingController();
  final _tokenController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _regOrgController = TextEditingController();
  bool _allowInsecure = false;
  int _authTabIndex = 0; // 0: Sign In, 1: Sign Up, 2: Token

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(cloudControllerProvider);
      if (state.connection != null) {
        _urlController.text = state.connection!.apiBaseUrl;
        _orgController.text = state.connection!.organizationId ?? '';
        setState(() {
          _allowInsecure = state.connection!.allowInsecureDevelopment;
        });
      }
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _orgController.dispose();
    _tokenController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _regOrgController.dispose();
    super.dispose();
  }

  CloudConnectionSettings _settingsFromForm() {
    final settings = CloudConnectionSettings(
      apiBaseUrl: _urlController.text.trim(),
      organizationId: _orgController.text.trim().isEmpty
          ? null
          : _orgController.text.trim(),
      allowInsecureDevelopment: _allowInsecure,
    );
    settings.apiBaseUri; // Validate before persisting or testing.
    return settings;
  }

  Future<void> _saveAndTest(
    BuildContext context,
    CloudController controller,
  ) async {
    try {
      final saved = await controller.saveConnection(_settingsFromForm());
      if (saved && context.mounted) await controller.testConnection();
    } on ArgumentError catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message?.toString() ?? 'Invalid cloud URL.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider).asData?.value;
    final text = AppText(settings?.languageCode ?? 'en');
    final state = ref.watch(cloudControllerProvider);
    final controller = ref.read(cloudControllerProvider.notifier);

    ref.listen<CloudState>(cloudControllerProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      if (next.successMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.successMessage!)));
      }
      if (previous?.connection != next.connection && next.connection != null) {
        _urlController.text = next.connection!.apiBaseUrl;
        _orgController.text = next.connection!.organizationId ?? '';
        setState(() {
          _allowInsecure = next.connection!.allowInsecureDevelopment;
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(text.cloudSync),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading ? null : () => controller.load(),
            tooltip: text.refresh,
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildConnectionCard(context, text, state, controller),
                const SizedBox(height: 16),
                _buildSessionCard(context, text, state, controller),
                const SizedBox(height: 16),
                _buildSyncDashboardCard(context, text, state, controller),
              ],
            ),
    );
  }

  Widget _buildConnectionCard(
    BuildContext context,
    AppText text,
    CloudState state,
    CloudController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_outlined, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text.cloudConnection,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: text.apiBaseUrl,
                hintText: 'https://cloud.wirespot.app/api',
                prefixIcon: const Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _orgController,
              decoration: InputDecoration(
                labelText: text.organizationId,
                hintText: 'org_12345',
                prefixIcon: const Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: Text(text.allowInsecureDev),
              value: _allowInsecure,
              onChanged: (val) => setState(() => _allowInsecure = val),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () => _saveAndTest(context, controller),
                    icon: const Icon(Icons.save),
                    label: Text(text.save),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: state.isLoading || state.isTestingConnection
                      ? null
                      : () => _saveAndTest(context, controller),
                  icon: state.isTestingConnection
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.network_check),
                  label: Text(text.testConnection),
                ),
              ],
            ),
            if (state.connectionHealthy != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: state.connectionHealthy!
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: state.connectionHealthy!
                        ? Colors.green.withValues(alpha: 0.5)
                        : Colors.red.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.connectionHealthy!
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: state.connectionHealthy!
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.connectionHealthy!
                            ? 'Cloud Connection Verified & Reachable'
                            : 'Cloud Connection Failed or Unreachable',
                        style: TextStyle(
                          color: state.connectionHealthy!
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    AppText text,
    CloudState state,
    CloudController controller,
  ) {
    final session = state.session;
    final hasSession = session != null && !session.isExpired;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  hasSession ? Icons.key : Icons.key_off,
                  size: 28,
                  color: hasSession ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text.cloudSessionText,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        hasSession
                            ? 'Session Active (Expires: ${_formatDate(session.expiresAt)})'
                            : 'No Active Session',
                        style: TextStyle(
                          fontSize: 12,
                          color: hasSession ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasSession)
                  OutlinedButton(
                    onPressed: () => controller.clearSession(),
                    child: const Text('Disconnect'),
                  ),
              ],
            ),
            if (hasSession) ...[
              const SizedBox(height: 12),
              _CredentialRow(
                label: 'API Base URL',
                value: state.connection?.apiBaseUrl ?? 'Not configured',
              ),
              _CredentialRow(
                label: 'Organization ID',
                value: state.connection?.organizationId ?? 'Not assigned',
              ),
              _CredentialRow(
                label: 'Mobile access code',
                value: session.accessToken,
                obscured: true,
              ),
            ],
            const SizedBox(height: 16),
            if (!hasSession) ...[
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('Sign In'),
                    icon: Icon(Icons.login),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('Sign Up'),
                    icon: Icon(Icons.person_add),
                  ),
                  ButtonSegment(
                    value: 2,
                    label: Text('Token'),
                    icon: Icon(Icons.key),
                  ),
                ],
                selected: {_authTabIndex},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _authTabIndex = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_authTabIndex == 0) ...[
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Operator Email',
                    hintText: 'admin@wirespot.app',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          final email = _emailController.text.trim();
                          final pass = _passwordController.text.trim();
                          if (email.isNotEmpty && pass.isNotEmpty) {
                            controller.signIn(email, pass);
                          }
                        },
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In to WireSpot Cloud'),
                ),
              ] else if (_authTabIndex == 1) ...[
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Operator Email',
                    hintText: 'admin@wirespot.app',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password (min 6 chars)',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _regOrgController,
                  decoration: const InputDecoration(
                    labelText: 'Organization / Business Name',
                    hintText: 'StarCoffee Wifi',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          final email = _emailController.text.trim();
                          final pass = _passwordController.text.trim();
                          final org = _regOrgController.text.trim();
                          if (email.isNotEmpty && pass.isNotEmpty) {
                            controller.signUp(
                              email: email,
                              password: pass,
                              organizationName: org.isEmpty
                                  ? 'Default Org'
                                  : org,
                            );
                          }
                        },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Create Operator Account'),
                ),
              ] else ...[
                TextField(
                  controller: _tokenController,
                  decoration: InputDecoration(
                    labelText: text.cloudAccessToken,
                    hintText: 'ws_session_...',
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    if (_tokenController.text.trim().isNotEmpty) {
                      controller.saveSession(
                        _tokenController.text.trim(),
                        1440,
                      );
                      _tokenController.clear();
                    }
                  },
                  icon: const Icon(Icons.key),
                  label: const Text('Save Access Token'),
                ),
              ],
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.4),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Authenticated & Ready for Cloud Sync!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _CredentialRow({
    required String label,
    required String value,
    bool obscured = false,
  }) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(width: 132, child: Text(label)),
            Expanded(
              child: SelectableText(
                obscured && value.length > 8
                    ? '${value.substring(0, 4)}••••${value.substring(value.length - 4)}'
                    : value,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              ),
            ),
            IconButton(
              tooltip: 'Copy $label',
              icon: const Icon(Icons.copy_outlined, size: 18),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: value));
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('$label copied.')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncDashboardCard(
    BuildContext context,
    AppText text,
    CloudState state,
    CloudController controller,
  ) {
    final ops = state.pendingOperations;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.sync, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text.pendingOperations,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${ops.length} operation(s) in queue',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: state.isSyncing
                      ? null
                      : () => controller.syncPending(),
                  icon: state.isSyncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.sync),
                  label: Text(text.syncNow),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => controller.retryFailed(),
                  icon: const Icon(Icons.replay, size: 16),
                  label: Text(text.retryFailed),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => controller.clearCompleted(),
                  icon: const Icon(Icons.cleaning_services, size: 16),
                  label: Text(text.clearCompleted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (ops.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No pending sync operations. Everything is up to date!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ops.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final op = ops[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Chip(
                      label: Text(
                        op.operation.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text('${op.resourceType} #${op.resourceId}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Attempts: ${op.attemptCount}'),
                        if (op.lastError != null)
                          Text(
                            'Error: ${op.lastError}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                    trailing: _buildStatusChip(op.status),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(CloudSyncStatus status) {
    final color = switch (status) {
      CloudSyncStatus.pending => Colors.orange,
      CloudSyncStatus.syncing => Colors.blue,
      CloudSyncStatus.completed => Colors.green,
      CloudSyncStatus.failed => Colors.red,
    };

    return Chip(
      label: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.5)),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${_two(dt.month)}-${_two(dt.day)} ${_two(dt.hour)}:${_two(dt.minute)}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}
