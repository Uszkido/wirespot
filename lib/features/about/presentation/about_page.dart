import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/branding/app_branding.dart';
import '../../../core/platform/external_action_service.dart';
import '../../../shared/widgets/brand_logo.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About WireSpot')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const BrandLogo(size: 88, borderRadius: 20),
                  const SizedBox(height: 14),
                  Text(
                    AppBranding.appName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppBranding.tagline,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppBranding.aboutDescription,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Chip(
                    avatar: const Icon(Icons.info_outline, size: 18),
                    label: Text('Version ${AppBranding.version}'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vexel Innovations',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vexel Innovations builds practical software for connected businesses, network operators, and teams that need dependable tools for everyday work.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.handshake_outlined),
                      title: const Text('Collaboration partner'),
                      subtitle: Text(AppBranding.collaboratorName),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Support email',
                    value: AppBranding.supportEmail,
                    actionIcon: Icons.open_in_new,
                    onTap: () => _openContact(
                      context,
                      ExternalActionService.openEmail(AppBranding.supportEmail),
                      'email app',
                    ),
                  ),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Support phone',
                    value: AppBranding.supportPhone,
                    actionIcon: Icons.call_outlined,
                    onTap: () => _openContact(
                      context,
                      ExternalActionService.openPhone(AppBranding.supportPhone),
                      'phone app',
                    ),
                  ),
                  _InfoRow(
                    icon: Icons.language_outlined,
                    label: 'Website',
                    value: AppBranding.website,
                    actionIcon: Icons.open_in_browser_outlined,
                    onTap: () => _openContact(
                      context,
                      ExternalActionService.openWebsite(AppBranding.website),
                      'browser',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.security_outlined),
              title: const Text('Built for responsible operations'),
              subtitle: const Text(
                'Local PIN and biometrics, device-bound licensing, encrypted storage, and controlled router access.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openContact(
    BuildContext context,
    Future<bool> action,
    String target,
  ) async {
    final opened = await action;
    if (!context.mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No $target is available on this device.')),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.actionIcon,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final IconData actionIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
                  SelectableText(value),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Copy $label',
              icon: const Icon(Icons.copy_outlined),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: value));
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('$label copied.')));
                }
              },
            ),
            IconButton(
              tooltip: 'Open $label',
              icon: Icon(actionIcon),
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
