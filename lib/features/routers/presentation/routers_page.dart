import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/localization/app_text.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../domain/entities/router_entity.dart';
import '../domain/entities/router_group_entity.dart';
import '../domain/entities/ruijie_cloud_device.dart';
import '../domain/services/router_fleet_connection_service.dart';
import 'router_providers.dart';

class RoutersPage extends ConsumerWidget {
  const RoutersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routers = ref.watch(routersProvider);
    final languageCode =
        ref.watch(appSettingsProvider).asData?.value.languageCode ?? 'en';
    final text = AppText(languageCode);
    final selectedRouterId = ref.watch(selectedRouterIdProvider);
    final storedActiveRouterId = ref
        .watch(storedActiveRouterIdProvider)
        .asData
        ?.value;
    final effectiveRouterId = selectedRouterId ?? storedActiveRouterId;
    final items = routers.asData?.value ?? const <RouterEntity>[];
    final connectionStates = ref.watch(routerConnectionStatesProvider);
    final groups = ref.watch(routerGroupsProvider).asData?.value ?? const [];
    final groupsById = {for (final group in groups) group.id: group};

    return Scaffold(
      appBar: AppBar(
        title: Text(text.routers),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: 'Test all router connections',
              onPressed: () => _testAllConnections(context, ref, items),
              icon: const Icon(Icons.network_check_outlined),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: text.addRouter,
        onPressed: () => context.push(AppRoutes.newRouter),
        child: const Icon(Icons.add),
      ),
      body: routers.when(
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.router_outlined,
              title: text.noRoutersYet,
              message: text.noRoutersMessage,
              action: FilledButton.icon(
                onPressed: () => context.push(AppRoutes.newRouter),
                icon: const Icon(Icons.add),
                label: Text(text.addRouter),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(routersProvider);
              ref.read(routerConnectionStatesProvider.notifier).state =
                  const {};
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _FleetStatusCard(
                    routerCount: items.length,
                    connectionStates: connectionStates,
                  );
                }
                final routerIndex = index - 1;
                return _RouterTile(
                  router: items[routerIndex],
                  isActive:
                      items[routerIndex].id == effectiveRouterId ||
                      (effectiveRouterId == null && routerIndex == 0),
                  isConnected: connectionStates[items[routerIndex].id],
                  group: groupsById[items[routerIndex].groupId],
                );
              },
            ),
          );
        },
        error: (error, stackTrace) => EmptyState(
          icon: Icons.error_outline,
          title: text.couldNotLoadRouters,
          message: error.toString(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _testAllConnections(
    BuildContext context,
    WidgetRef ref,
    List<RouterEntity> routers,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Testing ${routers.length} router connections...'),
      ),
    );
    final results = await ref
        .read(routerFleetConnectionServiceProvider)
        .testConnections(routers);
    ref.read(routerConnectionStatesProvider.notifier).state = {
      for (final result in results) result.router.id: result.isConnected,
    };
    if (!context.mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => _FleetConnectionResultsDialog(results: results),
    );
  }
}

class _FleetStatusCard extends StatelessWidget {
  const _FleetStatusCard({
    required this.routerCount,
    required this.connectionStates,
  });

  final int routerCount;
  final Map<String, bool> connectionStates;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final connected = connectionStates.values.where((value) => value).length;
    final unavailable = connectionStates.length - connected;
    final needsCheck = connectionStates.isEmpty;

    return Card(
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              needsCheck ? Icons.network_check_outlined : Icons.hub_outlined,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                needsCheck
                    ? '$routerCount routers saved • run Test all to check connectivity'
                    : '$connected of $routerCount routers online'
                          '${unavailable == 0 ? '' : ' • $unavailable unavailable'}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouterTile extends ConsumerWidget {
  const _RouterTile({
    required this.router,
    required this.isActive,
    required this.isConnected,
    this.group,
  });

  final RouterEntity router;
  final bool isActive;
  final bool? isConnected;
  final RouterGroupEntity? group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final languageCode =
        ref.watch(appSettingsProvider).asData?.value.languageCode ?? 'en';
    final text = AppText(languageCode);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isConnected == true
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          foregroundColor: isConnected == true
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
          child: const Icon(Icons.router_outlined),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                router.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isActive)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle, size: 18),
              ),
            if (isConnected != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  isConnected! ? Icons.wifi : Icons.wifi_off,
                  size: 18,
                  color: isConnected! ? colorScheme.primary : colorScheme.error,
                ),
              ),
          ],
        ),
        subtitle: Text(
          [
            router.vendor.label,
            if (group != null) group!.name,
            '${router.host}:${router.apiPort}',
            if (router.useSsl) 'SSL',
            router.remoteAccessMode.label,
            if (!router.vendor.hasLiveConnector) 'planned',
            if (router.vendor.hasLiveConnector &&
                !router.vendor.supportsHotspotVouchers)
              'limited',
          ].join(' - '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<_RouterAction>(
          tooltip: text.routerActions,
          onSelected: (action) => _handleAction(context, ref, action),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _RouterAction.test,
              child: ListTile(
                leading: const Icon(Icons.network_check),
                title: Text(text.testConnection),
              ),
            ),
            PopupMenuItem(
              value: _RouterAction.useRouter,
              child: ListTile(
                leading: Icon(
                  isActive
                      ? Icons.check_circle_outline
                      : Icons.swap_horiz_outlined,
                ),
                title: Text(isActive ? 'Current router' : 'Use this router'),
              ),
            ),
            if (router.vendor == RouterVendor.ruijie)
              const PopupMenuItem(
                value: _RouterAction.discoverDevices,
                child: ListTile(
                  leading: Icon(Icons.devices_other_outlined),
                  title: Text('Discover cloud devices'),
                ),
              ),
            if (router.requiresPrivateTunnel)
              PopupMenuItem(
                value: _RouterAction.wireGuard,
                child: ListTile(
                  leading: const Icon(Icons.vpn_key_outlined),
                  title: Text(text.remoteTunnel),
                ),
              ),
            PopupMenuItem(
              value: _RouterAction.edit,
              child: ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(text.edit),
              ),
            ),
            PopupMenuItem(
              value: _RouterAction.delete,
              child: ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(text.delete),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _RouterAction action,
  ) async {
    switch (action) {
      case _RouterAction.test:
        await _testConnection(context, ref);
        break;
      case _RouterAction.useRouter:
        ref.read(selectedRouterIdProvider.notifier).state = router.id;
        await ref.read(activeRouterServiceProvider).selectRouter(router.id);
        if (!context.mounted) {
          return;
        }
        ref.invalidate(storedActiveRouterIdProvider);
        ref.invalidate(dashboardSnapshotProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${router.name} is now the active router.')),
        );
        break;
      case _RouterAction.discoverDevices:
        await _discoverDevices(context, ref);
        break;
      case _RouterAction.edit:
        context.push(AppRoutes.editRouter(router.id));
        break;
      case _RouterAction.wireGuard:
        context.push(AppRoutes.wireGuardTunnel(router.name));
        break;
      case _RouterAction.delete:
        await _deleteRouter(context, ref);
        break;
    }
  }

  Future<void> _discoverDevices(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Discovering Ruijie Cloud devices...')),
    );

    try {
      final devices = await ref
          .read(ruijieCloudConnectionServiceProvider)
          .discoverDevices(router);
      if (!context.mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (context) => _RuijieDevicesDialog(devices: devices),
      );
    } on Object catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not discover Ruijie Cloud devices: $error'),
        ),
      );
    }
  }

  Future<void> _testConnection(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final text = AppText(
      ref.read(appSettingsProvider).asData?.value.languageCode ?? 'en',
    );
    messenger.showSnackBar(
      SnackBar(content: Text(text.testingRouterConnection)),
    );

    try {
      final isOnline = await ref
          .read(routerConnectionServiceProvider)
          .testConnection(router);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isOnline
                ? text.routerConnectionSuccessful
                : text.routerConnectionFailed,
          ),
        ),
      );
    } on Object catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(text.connectionTestFailed(error))),
      );
    }
  }

  Future<void> _deleteRouter(BuildContext context, WidgetRef ref) async {
    final text = AppText(
      ref.read(appSettingsProvider).asData?.value.languageCode ?? 'en',
    );
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(text.deleteRouterQuestion),
        content: Text(text.removeRouterMessage(router.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(text.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(text.delete),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    final activeRouterService = ref.read(activeRouterServiceProvider);
    final storedActiveRouterId = await activeRouterService
        .loadSelectedRouterId();
    await ref.read(routerRepositoryProvider).deleteRouter(router.id);
    if (storedActiveRouterId == router.id) {
      await activeRouterService.clearSelectedRouter();
      ref.read(selectedRouterIdProvider.notifier).state = null;
      ref.invalidate(storedActiveRouterIdProvider);
      ref.invalidate(dashboardSnapshotProvider);
    }
    if (!context.mounted) {
      return;
    }
    ref.invalidate(routersProvider);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text.routerDeleted)));
  }
}

enum _RouterAction { test, useRouter, discoverDevices, wireGuard, edit, delete }

class _RuijieDevicesDialog extends StatelessWidget {
  const _RuijieDevicesDialog({required this.devices});

  final List<RuijieCloudDevice> devices;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ruijie Cloud devices'),
      content: SizedBox(
        width: double.maxFinite,
        child: devices.isEmpty
            ? const Text('No devices were returned for this cloud connection.')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: devices.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final device = devices[index];
                  final details = [
                    if (device.model != null) device.model!,
                    if (device.status != null) device.status!,
                    if (device.siteName != null) device.siteName!,
                  ];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.router_outlined),
                    title: Text(device.name.isEmpty ? device.id : device.name),
                    subtitle: Text(
                      [
                        if (device.id.isNotEmpty) device.id,
                        ...details,
                      ].join(' • '),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _FleetConnectionResultsDialog extends StatelessWidget {
  const _FleetConnectionResultsDialog({required this.results});

  final List<RouterConnectionResult> results;

  @override
  Widget build(BuildContext context) {
    final connected = results.where((result) => result.isConnected).length;
    return AlertDialog(
      title: Text('$connected of ${results.length} routers connected'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: results.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final result = results[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                result.isConnected
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                color: result.isConnected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
              title: Text(result.router.name),
              subtitle: Text(result.router.vendor.label),
              trailing: Text(result.isConnected ? 'Connected' : 'Unavailable'),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
