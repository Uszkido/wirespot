import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/branding/app_branding.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/printer/printer_models.dart';
import '../../../shared/widgets/brand_logo.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../../core/di/providers.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/printer_config_entity.dart';
import 'settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final printers = ref.watch(printerConfigsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _BrandCard(),
          const SizedBox(height: 16),
          const _SecurityCard(),
          const SizedBox(height: 16),
          settings.when(
            data: (value) => _PreferencesCard(settings: value),
            error: (error, stackTrace) => Text('Could not load settings: $error'),
            loading: () => const LinearProgressIndicator(),
          ),
          const SizedBox(height: 16),
          printers.when(
            data: (items) => _PrinterCard(printers: items),
            error: (error, stackTrace) => Text('Could not load printers: $error'),
            loading: () => const LinearProgressIndicator(),
          ),
          const SizedBox(height: 16),
          const _BackupCard(),
        ],
      ),
    );
  }
}

class _SecurityCard extends ConsumerWidget {
  const _SecurityCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Security',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            const Text('Local PIN and biometric unlock protect this device.'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authControllerProvider).signOut();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            BrandLogo(size: 64, borderRadius: 12),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppBranding.appName),
                  Text(AppBranding.companyName),
                  Text(AppBranding.supportEmail),
                  Text(AppBranding.supportPhone),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferencesCard extends ConsumerWidget {
  const _PreferencesCard({required this.settings});

  final AppSettingsSnapshot settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AppThemePreference>(
              initialValue: settings.themePreference,
              decoration: const InputDecoration(labelText: 'Theme'),
              items: const [
                DropdownMenuItem(
                  value: AppThemePreference.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(
                  value: AppThemePreference.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: AppThemePreference.dark,
                  child: Text('Dark'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  _save(ref, settings.copyWith(themePreference: value));
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: settings.languageCode,
              decoration: const InputDecoration(labelText: 'Language'),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'fr', child: Text('French')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _save(ref, settings.copyWith(languageCode: value));
                }
              },
            ),
            SwitchListTile(
              value: settings.notificationsEnabled,
              onChanged: (value) {
                _save(ref, settings.copyWith(notificationsEnabled: value));
              },
              title: const Text('Notifications'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(WidgetRef ref, AppSettingsSnapshot next) async {
    await ref.read(appSettingsServiceProvider).save(next);
    ref.invalidate(appSettingsProvider);
  }
}

class _PrinterCard extends ConsumerWidget {
  const _PrinterCard({required this.printers});

  final List<PrinterConfigEntity> printers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Printers',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: 'Add printer',
                  onPressed: () => _showPrinterDialog(context, ref),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (printers.isEmpty)
              const Text('No printer configured.')
            else
              for (final printer in printers)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.print_outlined),
                  title: Text(printer.name),
                  subtitle: Text('${printer.address} - ${printer.paperWidthMm}mm'),
                  trailing: IconButton(
                    tooltip: 'Delete printer',
                    onPressed: () async {
                      await ref
                          .read(settingsRepositoryProvider)
                          .deletePrinter(printer.id);
                      ref.invalidate(printerConfigsProvider);
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPrinterDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    var width = 58;
    var pairedPrinters = <BluetoothPrinterDevice>[];
    var isLoadingPrinters = false;
    String? printerLoadError;
    try {
      final printer = await showDialog<PrinterConfigEntity>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Add printer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Bluetooth address'),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: isLoadingPrinters
                        ? null
                        : () async {
                            setState(() {
                              isLoadingPrinters = true;
                              printerLoadError = null;
                            });
                            try {
                              final devices = await ref
                                  .read(printerServiceProvider)
                                  .pairedBluetoothPrinters();
                              setState(() {
                                pairedPrinters = devices;
                              });
                            } on Object catch (error) {
                              setState(() {
                                printerLoadError = error.toString();
                              });
                            } finally {
                              setState(() => isLoadingPrinters = false);
                            }
                          },
                    icon: isLoadingPrinters
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.bluetooth_searching),
                    label: Text(
                      isLoadingPrinters ? 'Loading printers...' : 'Load paired printers',
                    ),
                  ),
                ),
                if (printerLoadError != null)
                  Text(
                    printerLoadError!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                if (pairedPrinters.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<BluetoothPrinterDevice>(
                    decoration: const InputDecoration(
                      labelText: 'Paired printer',
                      prefixIcon: Icon(Icons.print_outlined),
                    ),
                    items: [
                      for (final printer in pairedPrinters)
                        DropdownMenuItem(
                          value: printer,
                          child: Text(
                            '${printer.name} (${printer.address})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (printer) {
                      if (printer == null) {
                        return;
                      }
                      nameController.text = printer.name;
                      addressController.text = printer.address;
                    },
                  ),
                ],
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 58, label: Text('58mm')),
                    ButtonSegment(value: 80, label: Text('80mm')),
                  ],
                  selected: {width},
                  onSelectionChanged: (value) => setState(() => width = value.first),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(
                  PrinterConfigEntity(
                    id: IdGenerator.timestampId('printer'),
                    name: nameController.text.trim(),
                    address: addressController.text.trim(),
                    paperWidthMm: width,
                    isDefault: printers.isEmpty,
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      );
      if (printer == null) {
        return;
      }
      await ref.read(settingsRepositoryProvider).savePrinter(printer);
      ref.invalidate(printerConfigsProvider);
    } finally {
      nameController.dispose();
      addressController.dispose();
    }
  }
}

class _BackupCard extends ConsumerWidget {
  const _BackupCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Backup and Restore',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            const Text('Create a JSON backup of settings and printer profiles.'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _showBackup(context, ref),
              icon: const Icon(Icons.backup_outlined),
              label: const Text('Preview backup'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.restore_outlined),
              label: const Text('Restore backup'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBackup(BuildContext context, WidgetRef ref) async {
    final payload = await ref.read(backupServiceProvider).buildBackup();
    if (!context.mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup preview'),
        content: SingleChildScrollView(
          child: SelectableText(
            const JsonEncoder.withIndent('  ').convert(payload.toJson()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
