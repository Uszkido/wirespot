import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/branding/app_branding.dart';
import '../../../core/di/providers.dart';
import '../../../core/licensing/entitlement_snapshot.dart';
import '../../../core/licensing/premium_feature.dart';
import '../../../core/printer/printer_models.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/id_generator.dart';
import '../../../shared/widgets/brand_logo.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../scheduler/domain/entities/scheduled_task.dart';
import '../../voucher/domain/entities/ticket_template.dart';
import '../../voucher/domain/entities/voucher_encoding_settings.dart';
import '../../voucher/presentation/voucher_providers.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/printer_config_entity.dart';
import 'settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final printers = ref.watch(printerConfigsProvider);
    final entitlement = ref.watch(entitlementSnapshotProvider);
    final encoding = ref.watch(voucherEncodingSettingsProvider);
    final selectedTemplate = ref.watch(selectedTicketTemplateProvider);
    final schedulerTasks = ref.watch(schedulerTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _BrandCard(),
          const SizedBox(height: 16),
          const _SecurityCard(),
          const SizedBox(height: 16),
          const _PermissionSettingsCard(),
          const SizedBox(height: 16),
          const _WireGuardSettingsCard(),
          const SizedBox(height: 16),
          entitlement.when(
            data: (value) => _PremiumLicenseCard(entitlement: value),
            error: (error, stackTrace) =>
                Text('Could not load license: $error'),
            loading: () => const LinearProgressIndicator(),
          ),
          const SizedBox(height: 16),
          settings.when(
            data: (value) => _PreferencesCard(settings: value),
            error: (error, stackTrace) =>
                Text('Could not load settings: $error'),
            loading: () => const LinearProgressIndicator(),
          ),
          const SizedBox(height: 16),
          encoding.when(
            data: (value) => _VoucherEncodingCard(settings: value),
            error: (error, stackTrace) =>
                Text('Could not load voucher encoding: $error'),
            loading: () => const LinearProgressIndicator(),
          ),
          const SizedBox(height: 16),
          selectedTemplate.when(
            data: (value) => _TicketTemplateCard(
              selected: value,
              entitlement: entitlement.asData?.value,
            ),
            error: (error, stackTrace) =>
                Text('Could not load ticket templates: $error'),
            loading: () => const LinearProgressIndicator(),
          ),
          const SizedBox(height: 16),
          schedulerTasks.when(
            data: (tasks) => _SchedulerCard(
              tasks: tasks,
              entitlement: entitlement.asData?.value,
            ),
            error: (error, stackTrace) =>
                Text('Could not load scheduler: $error'),
            loading: () => const LinearProgressIndicator(),
          ),
          const SizedBox(height: 16),
          printers.when(
            data: (items) => _PrinterCard(printers: items),
            error: (error, stackTrace) =>
                Text('Could not load printers: $error'),
            loading: () => const LinearProgressIndicator(),
          ),
          const SizedBox(height: 16),
          const _BackupCard(),
        ],
      ),
    );
  }
}

class _PermissionSettingsCard extends StatelessWidget {
  const _PermissionSettingsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.admin_panel_settings_outlined),
        title: const Text('Permission readiness'),
        subtitle: const Text('Request VPN consent and Bluetooth access.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(AppRoutes.permissions),
      ),
    );
  }
}

class _WireGuardSettingsCard extends StatelessWidget {
  const _WireGuardSettingsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.vpn_key_outlined),
        title: const Text('WireGuard VPN'),
        subtitle: const Text('Import tunnels, connect, view status, and logs.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(AppRoutes.wireGuard),
      ),
    );
  }
}

class _SchedulerCard extends ConsumerWidget {
  const _SchedulerCard({required this.tasks, required this.entitlement});

  final List<ScheduledTask> tasks;
  final EntitlementSnapshot? entitlement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = entitlement?.allows(PremiumFeature.scheduler) ?? false;
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
                    'Scheduler',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!isPremium) const Chip(label: Text('Premium')),
              ],
            ),
            const SizedBox(height: 8),
            for (final task in tasks)
              SwitchListTile(
                value: isPremium && task.enabled,
                onChanged: isPremium
                    ? (value) async {
                        await ref
                            .read(schedulerSettingsServiceProvider)
                            .save(task.copyWith(enabled: value));
                        ref.invalidate(schedulerTasksProvider);
                      }
                    : null,
                title: Text(task.label),
                subtitle: Text('Every ${task.intervalMinutes} minutes'),
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }
}

class _TicketTemplateCard extends ConsumerWidget {
  const _TicketTemplateCard({required this.selected, required this.entitlement});

  final TicketTemplate selected;
  final EntitlementSnapshot? entitlement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium =
        entitlement?.allows(PremiumFeature.ticketTemplates) ?? false;
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
                    'Ticket templates',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!isPremium) const Chip(label: Text('Premium')),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TicketTemplate>(
              initialValue: selected,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Receipt layout',
                prefixIcon: Icon(Icons.confirmation_number_outlined),
              ),
              items: [
                for (final template in TicketTemplate.defaults)
                  DropdownMenuItem(
                    value: template,
                    child: Text(
                      '${template.name} - ${template.paperWidthMm}mm',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: isPremium
                  ? (template) async {
                      if (template == null) {
                        return;
                      }
                      await ref
                          .read(ticketTemplateSettingsServiceProvider)
                          .saveSelected(template);
                      ref.invalidate(selectedTicketTemplateProvider);
                    }
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              selected.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: isPremium
                      ? () => _showTemplateEditor(context, ref, selected)
                      : null,
                  icon: const Icon(Icons.tune_outlined),
                  label: const Text('Edit layout'),
                ),
                Chip(label: Text('${selected.paperWidthMm}mm')),
                if (selected.showLogo) const Chip(label: Text('Logo')),
                if (selected.showQrCode) const Chip(label: Text('QR')),
                if (selected.showPrice) const Chip(label: Text('Price')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTemplateEditor(
    BuildContext context,
    WidgetRef ref,
    TicketTemplate selected,
  ) async {
    final nameController = TextEditingController(text: selected.name);
    final footerController = TextEditingController(text: selected.footer);
    var paperWidthMm = selected.paperWidthMm;
    var showLogo = selected.showLogo;
    var showQrCode = selected.showQrCode;
    var showPrice = selected.showPrice;

    try {
      final template = await showDialog<TicketTemplate>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Edit ticket layout'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Template name',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 58,
                        label: Text('58mm'),
                        icon: Icon(Icons.receipt_long_outlined),
                      ),
                      ButtonSegment(
                        value: 80,
                        label: Text('80mm'),
                        icon: Icon(Icons.table_rows_outlined),
                      ),
                    ],
                    selected: {paperWidthMm},
                    onSelectionChanged: (value) {
                      setState(() => paperWidthMm = value.first);
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: showLogo,
                    onChanged: (value) => setState(() => showLogo = value),
                    title: const Text('Show logo marker'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    value: showQrCode,
                    onChanged: (value) => setState(() => showQrCode = value),
                    title: const Text('Show QR code'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    value: showPrice,
                    onChanged: (value) => setState(() => showPrice = value),
                    title: const Text('Show price'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: footerController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Footer',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(
                    selected.copyWith(
                      name: nameController.text.trim().isEmpty
                          ? selected.name
                          : nameController.text.trim(),
                      paperWidthMm: paperWidthMm,
                      showLogo: showLogo,
                      showQrCode: showQrCode,
                      showPrice: showPrice,
                      footer: footerController.text.trim().isEmpty
                          ? selected.footer
                          : footerController.text.trim(),
                    ),
                  );
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save'),
              ),
            ],
          ),
        ),
      );

      if (template == null) {
        return;
      }
      await ref.read(ticketTemplateSettingsServiceProvider).saveCustom(template);
      if (!context.mounted) {
        return;
      }
      ref
        ..invalidate(selectedTicketTemplateProvider)
        ..invalidate(voucherTicketTemplateProvider);
    } finally {
      nameController.dispose();
      footerController.dispose();
    }
  }
}

class _PremiumLicenseCard extends ConsumerWidget {
  const _PremiumLicenseCard({required this.entitlement});

  final EntitlementSnapshot entitlement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: entitlement.licenseKey ?? '',
    );
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
                    'Premium license',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Chip(label: Text(entitlement.statusLabel)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entitlement.hasAccess
                  ? 'WireSpot includes a 7-day trial. After that, this device needs a license key.'
                  : 'Trial ended. Enter a valid device license to continue using WireSpot.',
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.fingerprint),
              title: const Text('Device license ID'),
              subtitle: SelectableText(entitlement.deviceId),
              trailing: IconButton(
                tooltip: 'Copy device ID',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: entitlement.deviceId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Device ID copied.')),
                  );
                },
                icon: const Icon(Icons.copy),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'License key',
                helperText:
                    'Device-bound license key or temporary dev license.',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                await ref
                    .read(entitlementServiceProvider)
                    .saveDevLicense(controller.text);
                ref.invalidate(entitlementSnapshotProvider);
              },
              icon: const Icon(Icons.workspace_premium_outlined),
              label: const Text('Apply license'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherEncodingCard extends ConsumerWidget {
  const _VoucherEncodingCard({required this.settings});

  final VoucherEncodingSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefixController = TextEditingController(
      text: settings.defaultPrefix,
    );
    final usernameMinController = TextEditingController(
      text: '${settings.usernameMinLength}',
    );
    final usernameMaxController = TextEditingController(
      text: '${settings.usernameMaxLength}',
    );
    final passwordMinController = TextEditingController(
      text: '${settings.passwordMinLength}',
    );
    final passwordMaxController = TextEditingController(
      text: '${settings.passwordMaxLength}',
    );
    var mode = settings.mode;
    var characterSet = settings.characterSet;
    var excludeConfusing = settings.excludeConfusingCharacters;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Voucher encoding',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<VoucherCodeMode>(
                initialValue: mode,
                decoration: const InputDecoration(
                  labelText: 'Default code mode',
                ),
                items: const [
                  DropdownMenuItem(
                    value: VoucherCodeMode.usernamePassword,
                    child: Text('Username + password'),
                  ),
                  DropdownMenuItem(
                    value: VoucherCodeMode.usernameOnly,
                    child: Text('Username only'),
                  ),
                  DropdownMenuItem(
                    value: VoucherCodeMode.pinOnly,
                    child: Text('Username as PIN only'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => mode = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<VoucherCharacterSet>(
                initialValue: characterSet,
                decoration: const InputDecoration(labelText: 'Characters'),
                items: const [
                  DropdownMenuItem(
                    value: VoucherCharacterSet.numeric,
                    child: Text('Numeric'),
                  ),
                  DropdownMenuItem(
                    value: VoucherCharacterSet.alphabetic,
                    child: Text('Alphabetic'),
                  ),
                  DropdownMenuItem(
                    value: VoucherCharacterSet.alphanumeric,
                    child: Text('Alphanumeric'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => characterSet = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: prefixController,
                decoration: const InputDecoration(labelText: 'Default prefix'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: usernameMinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'User min'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: usernameMaxController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'User max'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: passwordMinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Pass min'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: passwordMaxController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Pass max'),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                value: excludeConfusing,
                onChanged: (value) => setState(() => excludeConfusing = value),
                title: const Text('Avoid confusing characters'),
                subtitle: const Text(
                  'Skips values like 0/O and 1/I where possible.',
                ),
                contentPadding: EdgeInsets.zero,
              ),
              FilledButton.icon(
                onPressed: () async {
                  await ref
                      .read(voucherEncodingSettingsServiceProvider)
                      .save(
                        VoucherEncodingSettings(
                          mode: mode,
                          characterSet: characterSet,
                          defaultPrefix: prefixController.text.trim(),
                          usernameMinLength:
                              int.tryParse(usernameMinController.text) ?? 4,
                          usernameMaxLength:
                              int.tryParse(usernameMaxController.text) ?? 10,
                          passwordMinLength:
                              int.tryParse(passwordMinController.text) ?? 4,
                          passwordMaxLength:
                              int.tryParse(passwordMaxController.text) ?? 10,
                          excludeConfusingCharacters: excludeConfusing,
                        ),
                      );
                  ref.invalidate(voucherEncodingSettingsProvider);
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save encoding'),
              ),
            ],
          ),
        ),
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
                  subtitle: Text(
                    '${printer.address} - ${printer.paperWidthMm}mm',
                  ),
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
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Bluetooth address',
                    ),
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
                        isLoadingPrinters
                            ? 'Loading printers...'
                            : 'Load paired printers',
                      ),
                    ),
                  ),
                  if (printerLoadError != null)
                    Text(
                      printerLoadError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  if (pairedPrinters.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<BluetoothPrinterDevice>(
                      isExpanded: true,
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
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 58, label: Text('58mm')),
                      ButtonSegment(value: 80, label: Text('80mm')),
                    ],
                    selected: {width},
                    onSelectionChanged: (value) =>
                        setState(() => width = value.first),
                  ),
                ],
              ),
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a JSON backup of settings and printer profiles.',
            ),
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
