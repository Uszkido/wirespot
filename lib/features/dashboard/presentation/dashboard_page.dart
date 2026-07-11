import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/routeros_models.dart';
import '../../../core/branding/app_branding.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/byte_format.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/brand_logo.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../domain/dashboard_snapshot.dart';
import 'dashboard_providers.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  DateTime? _lastBackPressedAt;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(dashboardSnapshotProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _handleBackPressed();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              BrandLogo(size: 36),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppBranding.appName),
                  Text(
                    AppBranding.companyName,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Routers',
              onPressed: () => context.go(AppRoutes.routers),
              icon: const Icon(Icons.router_outlined),
            ),
            IconButton(
              tooltip: 'Hotspot',
              onPressed: () => context.go(AppRoutes.hotspot),
              icon: const Icon(Icons.wifi_tethering),
            ),
            IconButton(
              tooltip: 'Vouchers',
              onPressed: () => context.go(AppRoutes.vouchers),
              icon: const Icon(Icons.confirmation_number_outlined),
            ),
            IconButton(
              tooltip: 'Reports',
              onPressed: () => context.go(AppRoutes.reports),
              icon: const Icon(Icons.bar_chart_outlined),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: () => ref.invalidate(dashboardSnapshotProvider),
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: 'Settings',
              onPressed: () => context.go(AppRoutes.settings),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: snapshot.when(
          data: (value) {
            if (value == null) {
              return EmptyState(
                icon: Icons.router_outlined,
                title: 'Add a router',
                message: 'Connect a MikroTik router before viewing dashboard data.',
                action: FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.newRouter),
                  icon: const Icon(Icons.add),
                  label: const Text('Add router'),
                ),
              );
            }
            return _DashboardContent(snapshot: value);
          },
          error: (error, stackTrace) => EmptyState(
            icon: Icons.error_outline,
            title: 'Dashboard unavailable',
            message: error.toString(),
            action: FilledButton.icon(
              onPressed: () => ref.invalidate(dashboardSnapshotProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  void _handleBackPressed() {
    final now = DateTime.now();
    final shouldExit = _lastBackPressedAt != null &&
        now.difference(_lastBackPressedAt!) < const Duration(seconds: 2);

    if (shouldExit) {
      SystemNavigator.pop();
      return;
    }

    _lastBackPressedAt = now;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Press back again to exit WireSpot.')),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final routerSnapshot = snapshot.routerSnapshot;
    final resource = routerSnapshot?.resource;
    final memoryPercent = _memoryPercent(resource);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(dashboardSnapshotProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _RouterHeader(snapshot: snapshot),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              MetricCard(
                icon: Icons.people_outline,
                label: 'Online users',
                value: snapshot.onlineUsers.toString(),
              ),
              MetricCard(
                icon: Icons.receipt_long_outlined,
                label: 'Today sales',
                value: 'NGN ${(snapshot.todaySalesMinor / 100).toStringAsFixed(0)}',
              ),
              MetricCard(
                icon: Icons.memory_outlined,
                label: 'CPU',
                value: resource == null ? '--' : '${resource.cpuLoad}%',
              ),
              MetricCard(
                icon: Icons.storage_outlined,
                label: 'Memory',
                value: memoryPercent == null ? '--' : '$memoryPercent%',
              ),
            ],
          ),
          const SizedBox(height: 28),
          const SectionHeader(title: 'Router Health'),
          const SizedBox(height: 12),
          _RouterHealthPanel(snapshot: routerSnapshot),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Interfaces'),
          const SizedBox(height: 12),
          if (routerSnapshot == null)
            _OfflinePanel(theme: theme)
          else
            _InterfacesPanel(interfaces: routerSnapshot.interfaces),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Support'),
          const SizedBox(height: 12),
          const _BrandingPanel(),
        ],
      ),
    );
  }

  int? _memoryPercent(RouterOsSystemResource? resource) {
    if (resource == null || resource.totalMemory <= 0) {
      return null;
    }
    final used = resource.totalMemory - resource.freeMemory;
    return ((used / resource.totalMemory) * 100).round();
  }
}

class _RouterHeader extends StatelessWidget {
  const _RouterHeader({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOnline = snapshot.routerSnapshot != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                isOnline ? colorScheme.primaryContainer : colorScheme.errorContainer,
            foregroundColor: isOnline
                ? colorScheme.onPrimaryContainer
                : colorScheme.onErrorContainer,
            child: Icon(isOnline ? Icons.router : Icons.router_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.routerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${snapshot.router.host}:${snapshot.router.apiPort}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Chip(
            avatar: Icon(
              isOnline ? Icons.check_circle : Icons.warning_amber,
              size: 18,
            ),
            label: Text(isOnline ? 'Online' : 'API offline'),
          ),
        ],
      ),
    );
  }
}

class _RouterHealthPanel extends StatelessWidget {
  const _RouterHealthPanel({required this.snapshot});

  final RouterOsRouterSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final resource = snapshot?.resource;
    if (resource == null) {
      return const _DashboardPanel(
        child: Text('Connect WireGuard and refresh to load RouterOS health.'),
      );
    }

    return _DashboardPanel(
      child: Column(
        children: [
          _HealthRow(label: 'Version', value: resource.version),
          _HealthRow(label: 'Board', value: resource.boardName),
          _HealthRow(label: 'Uptime', value: resource.uptime),
          _HealthRow(
            label: 'Free memory',
            value: ByteFormat.compact(resource.freeMemory),
          ),
          if (resource.temperature != null)
            _HealthRow(
              label: 'Temperature',
              value: '${resource.temperature} C',
            ),
        ],
      ),
    );
  }
}

class _InterfacesPanel extends StatelessWidget {
  const _InterfacesPanel({required this.interfaces});

  final List<RouterOsInterface> interfaces;

  @override
  Widget build(BuildContext context) {
    if (interfaces.isEmpty) {
      return const _DashboardPanel(child: Text('No interfaces reported.'));
    }

    return _DashboardPanel(
      child: Column(
        children: [
          for (final interface in interfaces.take(6))
            _InterfaceRow(interface: interface),
        ],
      ),
    );
  }
}

class _InterfaceRow extends StatelessWidget {
  const _InterfaceRow({required this.interface});

  final RouterOsInterface interface;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRunning = interface.running && !interface.disabled;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isRunning ? Icons.lan : Icons.lan_outlined,
        color: isRunning ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(interface.name),
      subtitle: Text(interface.type.isEmpty ? 'interface' : interface.type),
      trailing: Text(
        isRunning ? 'Running' : 'Down',
        style: TextStyle(
          color: isRunning ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value.isEmpty ? '--' : value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflinePanel extends StatelessWidget {
  const _OfflinePanel({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      child: Text(
        'Interface data appears after the VPN is connected and RouterOS API responds.',
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

class _BrandingPanel extends StatelessWidget {
  const _BrandingPanel();

  @override
  Widget build(BuildContext context) {
    return const _DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: BrandLogo(size: 72, borderRadius: 12)),
          SizedBox(height: 12),
          _HealthRow(label: 'Company', value: AppBranding.companyName),
          _HealthRow(label: 'Email', value: AppBranding.supportEmail),
          _HealthRow(label: 'Phone', value: AppBranding.supportPhone),
          _HealthRow(label: 'Website', value: AppBranding.website),
        ],
      ),
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}
