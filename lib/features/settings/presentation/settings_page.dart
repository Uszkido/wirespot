import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/branding/app_branding.dart';
import '../../../core/di/providers.dart';
import '../../../core/licensing/billing_plan.dart';
import '../../../core/licensing/entitlement_snapshot.dart';
import '../../../core/licensing/premium_feature.dart';
import '../../../core/localization/app_text.dart';
import '../../../core/platform/external_action_service.dart';
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
import '../domain/entities/backup_payload.dart';
import '../domain/entities/printer_config_entity.dart';
import 'settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final text = AppText(settings.asData?.value.languageCode ?? 'en');
    final printers = ref.watch(printerConfigsProvider);
    final entitlement = ref.watch(entitlementSnapshotProvider);
    final encoding = ref.watch(voucherEncodingSettingsProvider);
    final selectedTemplate = ref.watch(selectedTicketTemplateProvider);
    final schedulerTasks = ref.watch(schedulerTasksProvider);

    return Scaffold(
      appBar: AppBar(title: Text(text.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _BrandCard(),
          const SizedBox(height: 16),
          settings.when(
            data: (value) => _CoBrandingCard(
              settings: value,
              entitlement: entitlement.asData?.value,
            ),
            error: (error, stackTrace) =>
                Text('Could not load business branding: $error'),
            loading: () => const LinearProgressIndicator(),
          ),
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
                subtitle: Text(
                  'Every ${task.intervalMinutes} minutes\n'
                  'Last run: ${_lastRunText(task)}',
                ),
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }

  String _lastRunText(ScheduledTask task) {
    final ranAt = task.lastRunAt;
    if (ranAt == null) {
      return task.lastRunStatus;
    }
    return '${ranAt.year}-${_two(ranAt.month)}-${_two(ranAt.day)} '
        '${_two(ranAt.hour)}:${_two(ranAt.minute)} - '
        '${task.lastRunStatus}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}

class _TicketTemplateCard extends ConsumerWidget {
  const _TicketTemplateCard({
    required this.selected,
    required this.entitlement,
  });

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
      await ref
          .read(ticketTemplateSettingsServiceProvider)
          .saveCustom(template);
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
    final settings = ref.watch(appSettingsProvider).asData?.value;
    final text = AppText(settings?.languageCode ?? 'en');
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
                    text.premiumLicense,
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
              entitlement.isPremium
                  ? 'This device has active WireSpot access. Trial limits no longer apply.'
                  : entitlement.isTrialActive
                  ? 'WireSpot includes a 7-day trial. Add a license anytime to keep access after the trial.'
                  : 'Trial ended. Enter a valid device license to continue using WireSpot.',
            ),
            const SizedBox(height: 12),
            _LicenseStatusRow(
              label: text.activePlan,
              value: entitlement.planLabel,
            ),
            _LicenseStatusRow(
              label: text.trialStatus,
              value: entitlement.isTrialActive
                  ? '${entitlement.trialDaysRemaining} days left'
                  : 'Ended',
            ),
            _LicenseStatusRow(
              label: text.licenseSource,
              value: entitlement.source.label,
            ),
            if (entitlement.entitlementEndsAt != null)
              _LicenseStatusRow(
                label: 'Renewal/expiry',
                value: _date(entitlement.entitlementEndsAt!),
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
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('License saved. Status will refresh now.'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.workspace_premium_outlined),
              label: const Text('Apply license'),
            ),
            const SizedBox(height: 16),
            Text(
              'Subscription plans',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final plan in BillingPlan.values.where(
              (plan) => plan != BillingPlan.trial,
            ))
              _BillingPlanTile(plan: plan),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () async {
                try {
                  await const MethodChannel(
                    'com.wirespot.app/play_store',
                  ).invokeMethod<bool>('openSubscriptions');
                } on PlatformException catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          error.message ??
                              'Could not open Google Play subscriptions.',
                        ),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.shop_outlined),
              label: const Text('Google Play subscription'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                final request = [
                  'WireSpot license request',
                  'Device ID: ${entitlement.deviceId}',
                  'Plan: ${BillingPlan.proMonthly.title}',
                  'Contact: ${AppBranding.supportEmail}',
                ].join('\n');
                Clipboard.setData(ClipboardData(text: request));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('License request copied.')),
                );
              },
              icon: const Icon(Icons.content_copy_outlined),
              label: const Text('Copy license request'),
            ),
          ],
        ),
      ),
    );
  }

  String _date(DateTime value) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}

class _LicenseStatusRow extends StatelessWidget {
  const _LicenseStatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _BillingPlanTile extends StatelessWidget {
  const _BillingPlanTile({required this.plan});

  final BillingPlan plan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          dense: true,
          leading: const Icon(Icons.workspace_premium_outlined),
          title: Text(plan.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plan.description),
              const SizedBox(height: 4),
              Text(
                plan.monthlyPriceGuide,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
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
    final settings = ref.watch(appSettingsProvider).asData?.value;
    final text = AppText(settings?.languageCode ?? 'en');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              text.security,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const BrandLogo(size: 56, borderRadius: 12),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppBranding.appName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        AppBranding.partnershipLine,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              AppBranding.tagline,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SupportLine(
                      icon: Icons.handshake_outlined,
                      label: 'Partner',
                      value: AppBranding.collaboratorName,
                      action: SupportContactAction.copy,
                    ),
                    SizedBox(height: 8),
                    _SupportLine(
                      icon: Icons.mail_outline,
                      label: 'Email',
                      value: AppBranding.supportEmail,
                      action: SupportContactAction.email,
                    ),
                    SizedBox(height: 8),
                    _SupportLine(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: AppBranding.supportPhone,
                      action: SupportContactAction.phone,
                    ),
                    SizedBox(height: 8),
                    _SupportLine(
                      icon: Icons.language_outlined,
                      label: 'Website',
                      value: AppBranding.website,
                      action: SupportContactAction.website,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum SupportContactAction { copy, email, phone, website }

class _SupportLine extends StatelessWidget {
  const _SupportLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.action,
  });

  final IconData icon;
  final String label;
  final String value;
  final SupportContactAction action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _open(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 10),
            SizedBox(
              width: 58,
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: SelectableText(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            IconButton(
              tooltip: _actionTooltip,
              onPressed: () => _open(context),
              icon: Icon(_actionIcon, size: 18),
            ),
            IconButton(
              tooltip: 'Copy $label',
              onPressed: () => _copy(context),
              icon: const Icon(Icons.copy, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _actionIcon {
    return switch (action) {
      SupportContactAction.email => Icons.outgoing_mail,
      SupportContactAction.phone => Icons.call_outlined,
      SupportContactAction.website => Icons.open_in_browser_outlined,
      SupportContactAction.copy => Icons.info_outline,
    };
  }

  String get _actionTooltip {
    return switch (action) {
      SupportContactAction.email => 'Email support',
      SupportContactAction.phone => 'Call support',
      SupportContactAction.website => 'Open website',
      SupportContactAction.copy => 'View $label',
    };
  }

  Future<void> _open(BuildContext context) async {
    if (action == SupportContactAction.copy) {
      _copy(context);
      return;
    }
    final opened = await (switch (action) {
      SupportContactAction.email => ExternalActionService.openEmail(value),
      SupportContactAction.phone => ExternalActionService.openPhone(value),
      SupportContactAction.website => ExternalActionService.openWebsite(value),
      SupportContactAction.copy => Future.value(false),
    });
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $label.')));
    }
  }

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label copied.')));
  }
}

class _PreferencesCard extends ConsumerWidget {
  const _PreferencesCard({required this.settings});

  final AppSettingsSnapshot settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText(settings.languageCode);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text.preferences,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AppThemePreference>(
              initialValue: settings.themePreference,
              decoration: InputDecoration(labelText: text.theme),
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
              decoration: InputDecoration(labelText: text.language),
              items: [
                for (final language in AppSettingsOptions.languages)
                  DropdownMenuItem(
                    value: language.code,
                    child: Text('${language.name} - ${language.nativeName}'),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  _save(ref, settings.copyWith(languageCode: value));
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: settings.currencyCode,
              isExpanded: true,
              decoration: InputDecoration(labelText: text.defaultCurrency),
              items: [
                for (final currency in AppSettingsOptions.currencies)
                  DropdownMenuItem(
                    value: currency.code,
                    child: Text(
                      currency.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  _save(ref, settings.copyWith(currencyCode: value));
                }
              },
            ),
            SwitchListTile(
              value: settings.notificationsEnabled,
              onChanged: (value) {
                _save(ref, settings.copyWith(notificationsEnabled: value));
              },
              title: Text(text.notifications),
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

class _CoBrandingCard extends ConsumerWidget {
  const _CoBrandingCard({required this.settings, required this.entitlement});

  final AppSettingsSnapshot settings;
  final EntitlementSnapshot? entitlement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = entitlement?.allows(PremiumFeature.coBranding) ?? false;
    var businessName = settings.businessName;
    var businessEmail = settings.businessEmail;
    var businessPhone = settings.businessPhone;
    var businessWebsite = settings.businessWebsite;
    var businessLogoPath = settings.businessLogoPath;

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
                    'Business branding',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!isPremium) const Chip(label: Text('Premium')),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Select the operator logo from the phone gallery and enter the '
              'identity used on receipts and reports.',
            ),
            const SizedBox(height: 12),
            _BusinessLogoPreview(path: businessLogoPath),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: isPremium
                  ? () async {
                      final selectedPath = await _pickBusinessLogo(
                        context,
                        ref,
                        settings,
                      );
                      if (selectedPath != null) {
                        businessLogoPath = selectedPath;
                      }
                    }
                  : null,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Upload logo from gallery'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              enabled: isPremium,
              initialValue: businessLogoPath,
              onChanged: (value) => businessLogoPath = value,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Selected business logo',
                helperText: 'Choose a PNG or JPG from your phone gallery.',
                prefixIcon: Icon(Icons.image_outlined),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: isPremium
                      ? () async {
                          final clipboard = await Clipboard.getData(
                            Clipboard.kTextPlain,
                          );
                          businessLogoPath = clipboard?.text?.trim() ?? '';
                          await ref
                              .read(appSettingsServiceProvider)
                              .save(
                                settings.copyWith(
                                  businessLogoPath: businessLogoPath,
                                ),
                              );
                          ref.invalidate(appSettingsProvider);
                        }
                      : null,
                  icon: const Icon(Icons.content_paste_outlined),
                  label: const Text('Paste logo path'),
                ),
                OutlinedButton.icon(
                  onPressed: isPremium
                      ? () async {
                          businessLogoPath = '';
                          await ref
                              .read(appSettingsServiceProvider)
                              .save(settings.copyWith(businessLogoPath: ''));
                          ref.invalidate(appSettingsProvider);
                        }
                      : null,
                  icon: const Icon(Icons.clear_outlined),
                  label: const Text('Clear logo'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              enabled: isPremium,
              initialValue: businessName,
              onChanged: (value) => businessName = value,
              decoration: const InputDecoration(
                labelText: 'Business name',
                prefixIcon: Icon(Icons.storefront_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              enabled: isPremium,
              initialValue: businessEmail,
              onChanged: (value) => businessEmail = value,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Business email',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              enabled: isPremium,
              initialValue: businessPhone,
              onChanged: (value) => businessPhone = value,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Business phone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              enabled: isPremium,
              initialValue: businessWebsite,
              onChanged: (value) => businessWebsite = value,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Business website',
                prefixIcon: Icon(Icons.language_outlined),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: isPremium
                  ? () async {
                      await ref
                          .read(appSettingsServiceProvider)
                          .save(
                            settings.copyWith(
                              businessName: businessName.trim(),
                              businessEmail: businessEmail.trim(),
                              businessPhone: businessPhone.trim(),
                              businessWebsite: businessWebsite.trim(),
                              businessLogoPath: businessLogoPath.trim(),
                            ),
                          );
                      ref.invalidate(appSettingsProvider);
                    }
                  : null,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save co-branding'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _pickBusinessLogo(
    BuildContext context,
    WidgetRef ref,
    AppSettingsSnapshot settings,
  ) async {
    final settingsService = ref.read(appSettingsServiceProvider);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );
      if (pickedImage == null) {
        return null;
      }

      final documents = await getApplicationDocumentsDirectory();
      final brandingDirectory = Directory(
        p.join(documents.path, 'branding'),
      );
      if (!brandingDirectory.existsSync()) {
        await brandingDirectory.create(recursive: true);
      }

      final extension = _safeLogoExtension(pickedImage.path);
      final logoFile = File(
        p.join(brandingDirectory.path, 'business_logo$extension'),
      );
      await File(pickedImage.path).copy(logoFile.path);
      await settingsService.save(
        settings.copyWith(businessLogoPath: logoFile.path),
      );
      ref.invalidate(appSettingsProvider);

      messenger.showSnackBar(
        const SnackBar(content: Text('Business logo selected.')),
      );
      return logoFile.path;
    } on Object catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not select logo: $error')),
      );
      return null;
    }
  }

  String _safeLogoExtension(String sourcePath) {
    final extension = p.extension(sourcePath).toLowerCase();
    return switch (extension) {
      '.jpg' || '.jpeg' || '.png' || '.webp' => extension,
      _ => '.png',
    };
  }
}

class _BusinessLogoPreview extends StatelessWidget {
  const _BusinessLogoPreview({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final trimmed = path.trim();
    final exists = trimmed.isNotEmpty && File(trimmed).existsSync();

    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: exists
          ? Image.file(File(trimmed), fit: BoxFit.contain)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  trimmed.isEmpty
                      ? 'No business logo selected'
                      : 'Logo file not found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
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
              onPressed: () => _restoreBackup(context, ref),
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

  Future<void> _restoreBackup(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    try {
      String? errorText;
      final payload = await showDialog<BackupPayload>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Restore backup'),
              content: TextField(
                controller: controller,
                minLines: 8,
                maxLines: 12,
                decoration: InputDecoration(
                  labelText: 'Backup JSON',
                  alignLabelWithHint: true,
                  errorText: errorText,
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
                      final decoded = jsonDecode(controller.text);
                      if (decoded is! Map) {
                        throw const FormatException(
                          'Backup JSON must be an object.',
                        );
                      }
                      Navigator.of(context).pop(
                        BackupPayload.fromJson({
                          for (final entry in decoded.entries)
                            entry.key.toString(): entry.value,
                        }),
                      );
                    } on Object catch (error) {
                      setState(() => errorText = error.toString());
                    }
                  },
                  icon: const Icon(Icons.restore_outlined),
                  label: const Text('Restore'),
                ),
              ],
            );
          },
        ),
      );
      if (payload == null) {
        return;
      }
      await ref.read(backupServiceProvider).restoreBackup(payload);
      ref
        ..invalidate(appSettingsProvider)
        ..invalidate(printerConfigsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Backup restored.')));
      }
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not restore backup: $error')),
        );
      }
    } finally {
      controller.dispose();
    }
  }
}
