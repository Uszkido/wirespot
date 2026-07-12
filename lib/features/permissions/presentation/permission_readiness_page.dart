import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';

class PermissionReadinessPage extends ConsumerWidget {
  const PermissionReadinessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PermissionCard(
            icon: Icons.vpn_key_outlined,
            title: 'WireGuard VPN',
            message:
                'Android requires the user to approve VPN access at runtime. This cannot be granted silently during installation.',
            actionLabel: 'Request VPN access',
            onPressed: () async {
              await _requestVpn(context, ref);
            },
          ),
          const SizedBox(height: 16),
          _PermissionCard(
            icon: Icons.bluetooth_connected_outlined,
            title: 'Bluetooth printers',
            message:
                'Bluetooth permission is needed to find paired thermal printers and print receipts.',
            actionLabel: 'Request Bluetooth',
            onPressed: () async {
              await _requestBluetooth(context, ref);
            },
          ),
          const SizedBox(height: 16),
          const _InfoCard(
            icon: Icons.language_outlined,
            title: 'Network access',
            message:
                'Internet and network-state permissions are declared in AndroidManifest.xml and are available after install.',
          ),
        ],
      ),
    );
  }

  Future<void> _requestVpn(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(wireGuardVpnServiceProvider).requestPermission();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('VPN permission screen opened if Android requires it.'),
          ),
        );
      }
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not request VPN access: $error')),
        );
      }
    }
  }

  Future<void> _requestBluetooth(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(printerServiceProvider).pairedBluetoothPrinters();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bluetooth printer access checked.')),
        );
      }
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bluetooth permission request: $error')),
        );
      }
    }
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                await onPressed();
              },
              icon: const Icon(Icons.security_outlined),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(message),
      ),
    );
  }
}
