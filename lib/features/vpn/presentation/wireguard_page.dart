import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/utils/byte_format.dart';
import '../../../core/vpn/vpn_statistics.dart';
import '../../../core/vpn/vpn_status.dart';
import '../../../core/vpn/wireguard_config.dart';
import '../domain/entities/wireguard_settings.dart';
import 'wireguard_qr_scan_page.dart';
import 'wireguard_providers.dart';

class WireGuardPage extends ConsumerStatefulWidget {
  const WireGuardPage({super.key, this.initialTunnelName});

  final String? initialTunnelName;

  @override
  ConsumerState<WireGuardPage> createState() => _WireGuardPageState();
}

class _WireGuardPageState extends ConsumerState<WireGuardPage> {
  late final TextEditingController _tunnelNameController;
  bool _didHydrateSettings = false;

  @override
  void initState() {
    super.initState();
    _tunnelNameController = TextEditingController(
      text: widget.initialTunnelName ?? 'wirespot',
    );
  }

  @override
  void dispose() {
    _tunnelNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(wireGuardStatusStreamProvider).asData?.value;
    final statusFallback = ref.watch(wireGuardStatusProvider);
    final statistics = ref.watch(wireGuardStatisticsProvider);
    final logs = ref.watch(wireGuardLogsProvider);
    final settings = ref.watch(wireGuardSettingsProvider);
    final resolvedStatus = status ?? statusFallback.asData?.value;
    final settingsValue = settings.asData?.value;
    if (!_didHydrateSettings && settingsValue != null) {
      _didHydrateSettings = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        if (widget.initialTunnelName == null) {
          _tunnelNameController.text = settingsValue.selectedTunnelName;
        }
        if (settingsValue.autoReconnectEnabled) {
          ref
              .read(wireGuardAutoReconnectServiceProvider)
              .start(tunnelName: settingsValue.selectedTunnelName);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('WireGuard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _VpnPermissionCard(onRequestPermission: _requestVpnPermission),
            const SizedBox(height: 16),
            _TunnelCard(
              controller: _tunnelNameController,
              status: resolvedStatus,
              settings: settingsValue,
              onImport: _showImportDialog,
              onScanQr: _scanQrConfig,
              onConnect: _connect,
              onDisconnect: _disconnect,
              onAutoReconnectChanged: (value) {
                _setAutoReconnect(value);
              },
            ),
            const SizedBox(height: 16),
            statistics.when(
              data: (value) => _StatisticsCard(statistics: value),
              error: (error, stackTrace) =>
                  _ErrorCard(message: 'Could not load statistics: $error'),
              loading: () => const LinearProgressIndicator(),
            ),
            const SizedBox(height: 16),
            logs.when(
              data: (items) => _LogsCard(logs: items),
              error: (error, stackTrace) =>
                  _ErrorCard(message: 'Could not load logs: $error'),
              loading: () => const LinearProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }

  void _refresh() {
    ref
      ..invalidate(wireGuardStatusProvider)
      ..invalidate(wireGuardStatisticsProvider)
      ..invalidate(wireGuardLogsProvider);
  }

  Future<void> _connect() async {
    final name = _tunnelNameController.text.trim();
    if (name.isEmpty) {
      _showSnack('Tunnel name is required.');
      return;
    }
    try {
      final autoReconnectEnabled =
          ref.read(wireGuardSettingsProvider).asData?.value
              .autoReconnectEnabled ??
          false;
      await ref.read(wireGuardVpnServiceProvider).connect(name);
      await _saveSettings(selectedTunnelName: name);
      if (autoReconnectEnabled) {
        ref
            .read(wireGuardAutoReconnectServiceProvider)
            .start(tunnelName: name);
      }
      _refresh();
      _showSnack('WireGuard connect requested.');
    } on Object catch (error) {
      _showSnack('Could not connect WireGuard: $error');
    }
  }

  Future<void> _disconnect() async {
    try {
      await ref.read(wireGuardVpnServiceProvider).disconnect();
      await ref.read(wireGuardAutoReconnectServiceProvider).stop();
      _refresh();
      _showSnack('WireGuard disconnect requested.');
    } on Object catch (error) {
      _showSnack('Could not disconnect WireGuard: $error');
    }
  }

  Future<void> _requestVpnPermission() async {
    try {
      await ref.read(wireGuardVpnServiceProvider).requestPermission();
      _refresh();
      _showSnack('VPN permission screen opened if Android requires it.');
    } on Object catch (error) {
      _showSnack('Could not request VPN permission: $error');
    }
  }

  Future<void> _showImportDialog() async {
    final nameController = TextEditingController(
      text: _tunnelNameController.text.trim().isEmpty
          ? 'wirespot'
          : _tunnelNameController.text.trim(),
    );
    final configController = TextEditingController();
    try {
      final config = await showDialog<WireGuardConfig>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import tunnel'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tunnel name',
                      prefixIcon: Icon(Icons.vpn_key_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: configController,
                    minLines: 8,
                    maxLines: 16,
                    decoration: const InputDecoration(
                      labelText: 'WireGuard config',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                try {
                  Navigator.of(context).pop(
                    WireGuardConfig.parse(
                      name: nameController.text,
                      config: configController.text,
                    ),
                  );
                } on FormatException catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error.message)),
                  );
                }
              },
              icon: const Icon(Icons.file_upload_outlined),
              label: const Text('Import'),
            ),
          ],
        ),
      );

      if (config == null) {
        return;
      }
      await ref.read(wireGuardVpnServiceProvider).importConfig(config);
      _tunnelNameController.text = config.name;
      await _saveSettings(selectedTunnelName: config.name);
      _refresh();
      _showSnack('WireGuard tunnel imported.');
    } on Object catch (error) {
      _showSnack('Could not import tunnel: $error');
    } finally {
      nameController.dispose();
      configController.dispose();
    }
  }

  Future<void> _scanQrConfig() async {
    final qrText = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const WireGuardQrScanPage()),
    );
    if (!mounted) {
      return;
    }
    if (qrText == null || qrText.trim().isEmpty) {
      return;
    }
    final name = _tunnelNameController.text.trim().isEmpty
        ? 'wirespot'
        : _tunnelNameController.text.trim();
    try {
      final config = WireGuardConfig.parse(name: name, config: qrText);
      await ref.read(wireGuardVpnServiceProvider).importConfig(config);
      _tunnelNameController.text = config.name;
      await _saveSettings(selectedTunnelName: config.name);
      _refresh();
      _showSnack('WireGuard QR config imported.');
    } on Object catch (error) {
      _showSnack('Could not import WireGuard QR: $error');
    }
  }

  Future<void> _setAutoReconnect(bool enabled) async {
    final tunnelName = _tunnelNameController.text.trim().isEmpty
        ? 'wirespot'
        : _tunnelNameController.text.trim();
    await _saveSettings(
      selectedTunnelName: tunnelName,
      autoReconnectEnabled: enabled,
    );
    if (enabled) {
      ref
          .read(wireGuardAutoReconnectServiceProvider)
          .start(tunnelName: tunnelName);
    } else {
      await ref.read(wireGuardAutoReconnectServiceProvider).stop();
    }
    ref.invalidate(wireGuardSettingsProvider);
  }

  Future<void> _saveSettings({
    String? selectedTunnelName,
    bool? autoReconnectEnabled,
  }) async {
    final current =
        ref.read(wireGuardSettingsProvider).asData?.value ??
        const WireGuardSettings();
    await ref
        .read(wireGuardSettingsServiceProvider)
        .save(
          current.copyWith(
            selectedTunnelName: selectedTunnelName,
            autoReconnectEnabled: autoReconnectEnabled,
          ),
        );
    ref.invalidate(wireGuardSettingsProvider);
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _VpnPermissionCard extends StatelessWidget {
  const _VpnPermissionCard({required this.onRequestPermission});

  final Future<void> Function() onRequestPermission;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.verified_user_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Android requires VPN consent at runtime. This cannot be granted silently during installation.',
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await onRequestPermission();
                    },
                    icon: const Icon(Icons.security_outlined),
                    label: const Text('Grant VPN access'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TunnelCard extends StatelessWidget {
  const _TunnelCard({
    required this.controller,
    required this.status,
    required this.settings,
    required this.onImport,
    required this.onScanQr,
    required this.onConnect,
    required this.onDisconnect,
    required this.onAutoReconnectChanged,
  });

  final TextEditingController controller;
  final VpnStatus? status;
  final WireGuardSettings? settings;
  final Future<void> Function() onImport;
  final Future<void> Function() onScanQr;
  final Future<void> Function() onConnect;
  final Future<void> Function() onDisconnect;
  final ValueChanged<bool> onAutoReconnectChanged;

  @override
  Widget build(BuildContext context) {
    final connected = status?.isConnected ?? false;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  connected ? Icons.vpn_lock : Icons.vpn_lock_outlined,
                  color: connected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _statusLabel(status),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (status?.message != null) ...[
              const SizedBox(height: 8),
              Text(status!.message!),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Tunnel name',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: settings?.autoReconnectEnabled ?? false,
              onChanged: onAutoReconnectChanged,
              title: const Text('Auto reconnect'),
              subtitle: const Text('Reconnect this tunnel after VPN errors.'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    onImport();
                  },
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Import'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    await onScanQr();
                  },
                  icon: const Icon(Icons.qr_code_scanner_outlined),
                  label: const Text('Scan QR'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    if (connected) {
                      onDisconnect();
                    } else {
                      onConnect();
                    }
                  },
                  icon: Icon(connected ? Icons.link_off : Icons.play_arrow),
                  label: Text(connected ? 'Disconnect' : 'Connect'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(VpnStatus? status) {
    final name = status?.tunnelName;
    final suffix = name == null || name.isEmpty ? '' : ' - $name';
    return switch (status?.state) {
      VpnConnectionState.connecting => 'Connecting$suffix',
      VpnConnectionState.connected => 'Connected$suffix',
      VpnConnectionState.disconnecting => 'Disconnecting$suffix',
      VpnConnectionState.error => 'Error$suffix',
      _ => 'Disconnected$suffix',
    };
  }
}

class _StatisticsCard extends StatelessWidget {
  const _StatisticsCard({required this.statistics});

  final VpnStatistics statistics;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Statistics',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Received',
                    value: ByteFormat.compact(statistics.rxBytes),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: 'Sent',
                    value: ByteFormat.compact(statistics.txBytes),
                  ),
                ),
              ],
            ),
            if (statistics.latestHandshakeAt != null) ...[
              const SizedBox(height: 12),
              Text('Latest handshake: ${statistics.latestHandshakeAt}'),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogsCard extends StatelessWidget {
  const _LogsCard({required this.logs});

  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Logs',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (logs.isEmpty)
              const Text('No WireGuard logs yet.')
            else
              SelectableText(logs.take(40).join('\n')),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message),
      ),
    );
  }
}
