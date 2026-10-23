import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/routeros_models.dart';
import '../../../core/branding/app_branding.dart';
import '../../../core/di/providers.dart';
import '../../../core/localization/app_text.dart';
import '../../../core/platform/external_action_service.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/byte_format.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/brand_logo.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../settings/presentation/settings_providers.dart';
import '../../routers/presentation/router_providers.dart';
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
    final languageCode =
        ref.watch(appSettingsProvider).asData?.value.languageCode ?? 'en';
    final text = AppText(languageCode);
    final routers = ref.watch(routersProvider).asData?.value ?? const [];
    final selectedRouterId = ref.watch(selectedRouterIdProvider);
    final storedActiveRouterId = ref
        .watch(storedActiveRouterIdProvider)
        .asData
        ?.value;
    final effectiveRouterId = selectedRouterId ?? storedActiveRouterId;

    final dashboardContent = snapshot.when(
      data: (value) {
        if (value == null && routers.isEmpty) {
          return EmptyState(
            icon: Icons.router_outlined,
            title: text.addRouter,
            message: text.addRouterMessage,
            action: FilledButton.icon(
              onPressed: () => context.push(AppRoutes.newRouter),
              icon: const Icon(Icons.add),
              label: Text(text.addRouter),
            ),
          );
        }
        if (value == null) {
          return EmptyState(
            icon: Icons.router_outlined,
            title: text.dashboardUnavailable,
            message: text.interfaceDataAfterConnection,
            action: FilledButton.icon(
              onPressed: () => context.push(AppRoutes.routers),
              icon: const Icon(Icons.router_outlined),
              label: Text(text.routers),
            ),
          );
        }
        return _DashboardContent(snapshot: value);
      },
      error: (error, stackTrace) => EmptyState(
        icon: Icons.error_outline,
        title: text.dashboardUnavailable,
        message: error.toString(),
        action: FilledButton.icon(
          onPressed: () => ref.invalidate(dashboardSnapshotProvider),
          icon: const Icon(Icons.refresh),
          label: Text(text.retry),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );

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
          titleSpacing: 12,
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandLogo(size: 28),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  AppBranding.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            if (routers.isNotEmpty)
              PopupMenuButton<String>(
                tooltip: 'Switch active router',
                icon: const Icon(Icons.swap_horiz_outlined),
                onSelected: (routerId) {
                  ref.read(selectedRouterIdProvider.notifier).state = routerId;
                  ref.read(activeRouterServiceProvider).selectRouter(routerId);
                  ref.invalidate(storedActiveRouterIdProvider);
                  ref.invalidate(dashboardSnapshotProvider);
                },
                itemBuilder: (context) => [
                  for (var index = 0; index < routers.length; index++)
                    CheckedPopupMenuItem(
                      value: routers[index].id,
                      checked:
                          routers[index].id == effectiveRouterId ||
                          (effectiveRouterId == null && index == 0),
                      child: Text(routers[index].name),
                    ),
                ],
              ),
            IconButton(
              tooltip: text.refresh,
              onPressed: () => ref.invalidate(dashboardSnapshotProvider),
              icon: const Icon(Icons.refresh),
            ),
            PopupMenuButton<String>(
              tooltip: text.dashboard,
              icon: const Icon(Icons.more_vert),
              onSelected: (route) => context.push(route),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: AppRoutes.help,
                  child: ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text('Help & setup guide'),
                  ),
                ),
                const PopupMenuItem(
                  value: AppRoutes.onboarding,
                  child: ListTile(
                    leading: Icon(Icons.auto_awesome_outlined),
                    title: Text('Setup walkthrough'),
                  ),
                ),
                PopupMenuItem(
                  value: AppRoutes.routers,
                  child: ListTile(
                    leading: const Icon(Icons.router_outlined),
                    title: Text(text.routers),
                  ),
                ),
                const PopupMenuItem(
                  value: AppRoutes.diagnostics,
                  child: ListTile(
                    leading: Icon(Icons.network_ping_outlined),
                    title: Text('Diagnostics'),
                  ),
                ),
                const PopupMenuItem(
                  value: AppRoutes.alerts,
                  child: ListTile(
                    leading: Icon(Icons.notifications_active_outlined),
                    title: Text('Alert Settings'),
                  ),
                ),
                PopupMenuItem(
                  value: AppRoutes.hotspot,
                  child: ListTile(
                    leading: const Icon(Icons.wifi_tethering),
                    title: Text(text.hotspot),
                  ),
                ),
                PopupMenuItem(
                  value: AppRoutes.vouchers,
                  child: ListTile(
                    leading: const Icon(Icons.confirmation_number_outlined),
                    title: Text(text.vouchers),
                  ),
                ),
                PopupMenuItem(
                  value: AppRoutes.reports,
                  child: ListTile(
                    leading: const Icon(Icons.bar_chart_outlined),
                    title: Text(text.reports),
                  ),
                ),
                PopupMenuItem(
                  value: AppRoutes.settings,
                  child: ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(text.settings),
                  ),
                ),
                const PopupMenuItem(
                  value: AppRoutes.about,
                  child: ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('About WireSpot'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 720) {
              return Row(
                children: [
                  _DashboardNavigation(rail: true),
                  const VerticalDivider(width: 1),
                  Expanded(child: dashboardContent),
                ],
              );
            }
            return dashboardContent;
          },
        ),
        bottomNavigationBar: MediaQuery.sizeOf(context).width < 720
            ? const _DashboardNavigation()
            : null,
      ),
    );
  }

  void _handleBackPressed() {
    final now = DateTime.now();
    final shouldExit =
        _lastBackPressedAt != null &&
        now.difference(_lastBackPressedAt!) < const Duration(seconds: 2);

    if (shouldExit) {
      SystemNavigator.pop();
      return;
    }

    _lastBackPressedAt = now;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppText(
            ref.read(appSettingsProvider).asData?.value.languageCode ?? 'en',
          ).pressBackAgain,
        ),
      ),
    );
  }
}

class _DashboardNavigation extends StatelessWidget {
  const _DashboardNavigation({this.rail = false});

  final bool rail;

  static const _items = <(String, String, IconData, IconData)>[
    (
      'Dashboard',
      AppRoutes.dashboard,
      Icons.dashboard_outlined,
      Icons.dashboard,
    ),
    ('Routers', AppRoutes.routers, Icons.router_outlined, Icons.router),
    (
      'Hotspot',
      AppRoutes.hotspot,
      Icons.wifi_tethering_outlined,
      Icons.wifi_tethering,
    ),
    ('Reports', AppRoutes.reports, Icons.bar_chart_outlined, Icons.bar_chart),
    ('Settings', AppRoutes.settings, Icons.settings_outlined, Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = _items.indexWhere(
      (item) => item.$2 == GoRouterState.of(context).matchedLocation,
    );
    final index = selected < 0 ? 0 : selected;
    void navigate(int value) {
      if (value != index) context.push(_items[value].$2);
    }

    if (rail) {
      return NavigationRail(
        selectedIndex: index,
        onDestinationSelected: navigate,
        labelType: NavigationRailLabelType.all,
        destinations: [
          for (final item in _items)
            NavigationRailDestination(
              icon: Icon(item.$3),
              selectedIcon: Icon(item.$4),
              label: Text(item.$1),
            ),
        ],
      );
    }
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: navigate,
      destinations: [
        for (final item in _items)
          NavigationDestination(
            icon: Icon(item.$3),
            selectedIcon: Icon(item.$4),
            label: item.$1,
          ),
      ],
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
    final languageCode =
        ref.watch(appSettingsProvider).asData?.value.languageCode ?? 'en';
    final text = AppText(languageCode);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(dashboardSnapshotProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _RouterHeader(snapshot: snapshot),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 4 : 2;
              const gap = 12.0;
              final cardWidth =
                  (constraints.maxWidth - (gap * (columns - 1))) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  MetricCard(
                    width: cardWidth,
                    icon: Icons.people_outline,
                    label: text.onlineUsers,
                    value: snapshot.onlineUsers.toString(),
                    onTap: () => context.push(AppRoutes.hotspotSessions),
                  ),
                  MetricCard(
                    width: cardWidth,
                    icon: Icons.receipt_long_outlined,
                    label: text.todaySales,
                    value:
                        '${snapshot.todaySalesCurrency} '
                        '${(snapshot.todaySalesMinor / 100).toStringAsFixed(0)}',
                    onTap: () => _showTodaySales(context, snapshot),
                  ),
                  MetricCard(
                    width: cardWidth,
                    icon: Icons.memory_outlined,
                    label: 'CPU',
                    value: resource == null ? '--' : '${resource.cpuLoad}%',
                    onTap: () => _showCpuDetails(context, resource),
                  ),
                  MetricCard(
                    width: cardWidth,
                    icon: Icons.storage_outlined,
                    label: text.memory,
                    value: memoryPercent == null ? '--' : '$memoryPercent%',
                    onTap: () => _showMemoryDetails(context, resource),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          SectionHeader(title: text.routerHealth),
          const SizedBox(height: 12),
          _RouterHealthPanel(snapshot: routerSnapshot),
          const SizedBox(height: 20),
          SectionHeader(title: text.interfaces),
          const SizedBox(height: 12),
          if (routerSnapshot == null)
            _OfflinePanel(theme: theme, text: text)
          else
            _InterfacesPanel(interfaces: routerSnapshot.interfaces, text: text),
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

  void _showTodaySales(BuildContext context, DashboardSnapshot snapshot) {
    _showMetricSheet(
      context,
      title: 'Today’s sales',
      icon: Icons.receipt_long_outlined,
      rows: [
        _MetricDetail(
          label: 'Total',
          value:
              '${snapshot.todaySalesCurrency} '
              '${(snapshot.todaySalesMinor / 100).toStringAsFixed(2)}',
        ),
        const _MetricDetail(label: 'Period', value: 'Today'),
        _MetricDetail(label: 'Router', value: snapshot.routerName),
      ],
    );
  }

  void _showCpuDetails(BuildContext context, RouterOsSystemResource? resource) {
    _showMetricSheet(
      context,
      title: 'CPU usage',
      icon: Icons.memory_outlined,
      rows: [
        _MetricDetail(
          label: 'Current load',
          value: resource == null ? '--' : '${resource.cpuLoad}%',
        ),
        _MetricDetail(
          label: 'Temperature',
          value: resource?.temperature == null
              ? '--'
              : '${resource!.temperature} °C',
        ),
        _MetricDetail(
          label: 'Router version',
          value: resource?.version ?? '--',
        ),
      ],
    );
  }

  void _showMemoryDetails(
    BuildContext context,
    RouterOsSystemResource? resource,
  ) {
    final used = resource == null
        ? null
        : resource.totalMemory - resource.freeMemory;
    _showMetricSheet(
      context,
      title: 'Memory usage',
      icon: Icons.storage_outlined,
      rows: [
        _MetricDetail(
          label: 'Used',
          value: used == null ? '--' : ByteFormat.compact(used),
        ),
        _MetricDetail(
          label: 'Free',
          value: resource == null
              ? '--'
              : ByteFormat.compact(resource.freeMemory),
        ),
        _MetricDetail(
          label: 'Total',
          value: resource == null
              ? '--'
              : ByteFormat.compact(resource.totalMemory),
        ),
      ],
    );
  }

  void _showMetricSheet(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<_MetricDetail> rows,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 12),
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 16),
              for (final row in rows)
                _InterfaceDetailRow(label: row.label, value: row.value),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricDetail {
  const _MetricDetail({required this.label, required this.value});

  final String label;
  final String value;
}

class _RouterHeader extends ConsumerWidget {
  const _RouterHeader({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOnline = snapshot.routerSnapshot != null;
    final languageCode =
        ref.watch(appSettingsProvider).asData?.value.languageCode ?? 'en';
    final text = AppText(languageCode);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.surfaceContainerLow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isOnline
                ? colorScheme.primaryContainer
                : colorScheme.errorContainer,
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
            label: Text(isOnline ? text.online : text.apiOffline),
          ),
        ],
      ),
    );
  }
}

class _RouterHealthPanel extends ConsumerWidget {
  const _RouterHealthPanel({required this.snapshot});

  final RouterOsRouterSnapshot? snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resource = snapshot?.resource;
    final languageCode =
        ref.watch(appSettingsProvider).asData?.value.languageCode ?? 'en';
    final text = AppText(languageCode);
    if (resource == null) {
      return _DashboardPanel(child: Text(text.connectVpnForHealth));
    }

    return _DashboardPanel(
      child: Column(
        children: [
          _HealthRow(label: text.version, value: resource.version),
          _HealthRow(label: text.board, value: resource.boardName),
          _HealthRow(label: text.uptime, value: resource.uptime),
          _HealthRow(
            label: text.freeMemory,
            value: ByteFormat.compact(resource.freeMemory),
          ),
          if (resource.temperature != null)
            _HealthRow(
              label: text.temperature,
              value: '${resource.temperature} C',
            ),
        ],
      ),
    );
  }
}

class _InterfacesPanel extends StatefulWidget {
  const _InterfacesPanel({required this.interfaces, required this.text});

  final List<RouterOsInterface> interfaces;
  final AppText text;

  @override
  State<_InterfacesPanel> createState() => _InterfacesPanelState();
}

class _InterfacesPanelState extends State<_InterfacesPanel> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final interfaces = widget.interfaces;
    final text = widget.text;
    if (interfaces.isEmpty) {
      return _DashboardPanel(child: Text(text.noInterfaces));
    }

    final active = interfaces
        .where((item) => item.running && !item.disabled)
        .toList(growable: false);
    final visible = _showAll ? interfaces : active;

    return _DashboardPanel(
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _showAll
                    ? '${interfaces.length} interfaces'
                    : '${active.length} active interfaces',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _showAll = !_showAll),
                icon: Icon(
                  _showAll ? Icons.visibility_off_outlined : Icons.visibility,
                  size: 18,
                ),
                label: Text(_showAll ? 'Show active only' : 'Show all'),
              ),
            ],
          ),
          const Divider(height: 20),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'No active interfaces. Tap “Show all” to inspect every port.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            for (final interface in visible)
              _InterfaceRow(interface: interface, text: text),
        ],
      ),
    );
  }
}

class _InterfaceRow extends StatelessWidget {
  const _InterfaceRow({required this.interface, required this.text});

  final RouterOsInterface interface;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRunning = interface.running && !interface.disabled;
    final physicalName = interface.defaultName?.trim();
    final speed = interface.speed?.trim();
    final connectionDetails = [
      if (physicalName != null &&
          physicalName.isNotEmpty &&
          physicalName != interface.name)
        physicalName,
      if (speed != null && speed.isNotEmpty) speed,
    ].join(' • ');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isRunning ? Icons.lan : Icons.lan_outlined,
        color: isRunning ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(interface.name),
      subtitle: Text(
        [
          if (interface.type.isNotEmpty) interface.type else 'interface',
          if (connectionDetails.isNotEmpty) connectionDetails,
        ].join(' • '),
      ),
      trailing: Text(
        isRunning ? text.running : text.down,
        style: TextStyle(
          color: isRunning ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: () => _showInterfaceDetails(context),
    );
  }

  void _showInterfaceDetails(BuildContext context) {
    final status = interface.disabled
        ? 'Disabled'
        : interface.running
        ? 'Running'
        : 'Down';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                interface.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Interface details',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _InterfaceDetailRow(label: 'Type', value: _value(interface.type)),
              _InterfaceDetailRow(
                label: 'Connected port',
                value: _value(interface.defaultName ?? interface.name),
              ),
              _InterfaceDetailRow(label: 'Status', value: status),
              _InterfaceDetailRow(
                label: 'Link speed',
                value: _value(interface.speed),
              ),
              _InterfaceDetailRow(
                label: 'Duplex',
                value: interface.fullDuplex == null
                    ? '--'
                    : interface.fullDuplex!
                    ? 'Full duplex'
                    : 'Half duplex',
              ),
              _InterfaceDetailRow(
                label: 'Link downs',
                value: interface.linkDowns?.toString() ?? '--',
              ),
              _InterfaceDetailRow(
                label: 'Last link up',
                value: _value(interface.lastLinkUpTime),
              ),
              _InterfaceDetailRow(
                label: 'MAC address',
                value: _value(interface.macAddress),
              ),
              _InterfaceDetailRow(
                label: 'Received',
                value: interface.rxByte == null
                    ? '--'
                    : ByteFormat.compact(interface.rxByte!),
              ),
              _InterfaceDetailRow(
                label: 'Transmitted',
                value: interface.txByte == null
                    ? '--'
                    : ByteFormat.compact(interface.txByte!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _value(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? '--' : trimmed;
  }
}

class _InterfaceDetailRow extends StatelessWidget {
  const _InterfaceDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 16),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
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
  const _OfflinePanel({required this.theme, required this.text});

  final ThemeData theme;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      child: Text(
        text.interfaceDataAfterConnection,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

// Kept as a reusable support panel for a future dedicated support surface.
// ignore: unused_element
class _BrandingPanel extends StatelessWidget {
  const _BrandingPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BrandLogo(size: 52, borderRadius: 10),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppBranding.appName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      AppBranding.partnershipLine,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppBranding.tagline,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _SupportAction(
                icon: Icons.mail_outline,
                label: 'Email',
                value: AppBranding.supportEmail,
                action: _SupportContactAction.email,
              ),
              _SupportAction(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: AppBranding.supportPhone,
                action: _SupportContactAction.phone,
              ),
              _SupportAction(
                icon: Icons.language_outlined,
                label: 'Website',
                value: AppBranding.website,
                action: _SupportContactAction.website,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _SupportContactAction { email, phone, website }

class _SupportAction extends StatelessWidget {
  const _SupportAction({
    required this.icon,
    required this.label,
    required this.value,
    required this.action,
  });

  final IconData icon;
  final String label;
  final String value;
  final _SupportContactAction action;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () => _open(context),
    );
  }

  Future<void> _open(BuildContext context) async {
    final opened = await (switch (action) {
      _SupportContactAction.email => ExternalActionService.openEmail(value),
      _SupportContactAction.phone => ExternalActionService.openPhone(value),
      _SupportContactAction.website => ExternalActionService.openWebsite(value),
    });
    if (!opened && context.mounted) {
      Clipboard.setData(ClipboardData(text: value));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $label. $label copied.')),
      );
    }
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
