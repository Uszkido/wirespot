import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../../routers/domain/entities/router_entity.dart';
import '../../routers/presentation/router_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../domain/entities/hotspot_active_session_entity.dart';
import '../domain/entities/hotspot_cookie_entity.dart';
import '../domain/entities/hotspot_deployment_entity.dart';
import '../domain/entities/hotspot_ip_binding_entity.dart';
import '../domain/entities/hotspot_ip_binding_input.dart';
import '../domain/entities/hotspot_profile_input.dart';
import '../domain/entities/hotspot_queue_entity.dart';
import '../domain/entities/hotspot_setup_inspection.dart';
import '../domain/entities/hotspot_setup_input.dart';
import '../domain/entities/hotspot_setup_preset.dart';
import '../domain/entities/hotspot_user_entity.dart';
import '../domain/entities/hotspot_user_input.dart';
import '../domain/entities/hotspot_user_profile_entity.dart';
import 'hotspot_providers.dart';

class HotspotPage extends ConsumerWidget {
  const HotspotPage({this.initialTabIndex = 0, super.key});

  final int initialTabIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routers = ref.watch(routersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hotspot')),
      body: routers.when(
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.router_outlined,
              title: 'No router available',
              message: 'Add a router before managing hotspot users.',
              action: FilledButton.icon(
                onPressed: () => context.push(AppRoutes.newRouter),
                icon: const Icon(Icons.add),
                label: const Text('Add router'),
              ),
            );
          }

          final selectedId =
              ref.watch(selectedHotspotRouterIdProvider) ??
              ref.watch(selectedRouterIdProvider) ??
              ref.watch(storedActiveRouterIdProvider).asData?.value;
          final router = items.firstWhere(
            (item) => item.id == selectedId,
            orElse: () => items.first,
          );

          return _HotspotRouterScope(
            routers: items,
            router: router,
            initialTabIndex: initialTabIndex,
          );
        },
        error: (error, stackTrace) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load routers',
          message: error.toString(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _HotspotRouterScope extends ConsumerWidget {
  const _HotspotRouterScope({
    required this.routers,
    required this.router,
    required this.initialTabIndex,
  });

  final List<RouterEntity> routers;
  final RouterEntity router;
  final int initialTabIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!router.vendor.supports(RouterCapability.hotspotUsers)) {
      return _UnsupportedHotspotRouter(routers: routers, router: router);
    }
    return DefaultTabController(
      length: 7,
      initialIndex: initialTabIndex.clamp(0, 6).toInt(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: router.id,
                  decoration: const InputDecoration(
                    labelText: 'Router',
                    prefixIcon: Icon(Icons.router_outlined),
                  ),
                  items: [
                    for (final item in routers)
                      DropdownMenuItem(value: item.id, child: Text(item.name)),
                  ],
                  onChanged: (value) {
                    ref.read(selectedHotspotRouterIdProvider.notifier).state =
                        value;
                    if (value != null) {
                      ref.read(selectedRouterIdProvider.notifier).state = value;
                      ref.read(activeRouterServiceProvider).selectRouter(value);
                      ref.invalidate(storedActiveRouterIdProvider);
                    }
                  },
                ),
                const SizedBox(height: 8),
                _HotspotCapabilityBanner(router: router),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showSetupHotspotDialog(context, ref, router),
                    icon: const Icon(Icons.settings_input_antenna_outlined),
                    label: const Text('Setup hotspot'),
                  ),
                ),
              ],
            ),
          ),
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Profiles'),
              Tab(text: 'Sessions'),
              Tab(text: 'Cookies'),
              Tab(text: 'Bindings'),
              Tab(text: 'Queues'),
              Tab(text: 'Deployments'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _UsersTab(router: router),
                _ProfilesTab(router: router),
                _SessionsTab(router: router),
                _CookiesTab(router: router),
                _BindingsTab(router: router),
                _QueuesTab(router: router),
                _DeploymentsTab(router: router),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeploymentsTab extends ConsumerWidget {
  const _DeploymentsTab({required this.router});
  final RouterEntity router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(hotspotDeploymentHistoryProvider(router.id));
    return history.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Could not load deployments: $error')),
      data: (items) => items.isEmpty
          ? const EmptyState(
              icon: Icons.history_outlined,
              title: 'No deployment history',
              message:
                  'Completed and failed hotspot setup attempts appear here.',
            )
          : RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(hotspotDeploymentHistoryProvider(router.id)),
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final succeeded =
                      item.status == HotspotDeploymentStatus.succeeded;
                  return ListTile(
                    leading: Icon(
                      succeeded
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: succeeded
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                    ),
                    title: Text(item.preset),
                    subtitle: Text(
                      '${item.profileAction} • ${item.serverAction}\n${item.deployedAt.toLocal()}',
                    ),
                    isThreeLine: true,
                  );
                },
              ),
            ),
    );
  }
}

class _HotspotCapabilityBanner extends StatelessWidget {
  const _HotspotCapabilityBanner({required this.router});

  final RouterEntity router;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.wifi_tethering, color: colorScheme.onPrimaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${router.name}: live ${router.vendor.label} hotspot operations are enabled.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnsupportedHotspotRouter extends ConsumerWidget {
  const _UnsupportedHotspotRouter({
    required this.routers,
    required this.router,
  });

  final List<RouterEntity> routers;
  final RouterEntity router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: router.id,
          decoration: const InputDecoration(
            labelText: 'Router',
            prefixIcon: Icon(Icons.router_outlined),
          ),
          items: [
            for (final item in routers)
              DropdownMenuItem(value: item.id, child: Text(item.name)),
          ],
          onChanged: (value) {
            ref.read(selectedHotspotRouterIdProvider.notifier).state = value;
            if (value != null) {
              ref.read(selectedRouterIdProvider.notifier).state = value;
              ref.read(activeRouterServiceProvider).selectRouter(value);
              ref.invalidate(storedActiveRouterIdProvider);
            }
          },
        ),
        const SizedBox(height: 32),
        Icon(
          Icons.lock_outline,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        Text(
          'Hotspot controls are not available for ${router.vendor.label}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          router.vendor.hasLiveConnector
              ? 'This connection currently supports ${router.vendor.activeCapabilitySummary.toLowerCase()}. '
                    'Hotspot users, setup, and vouchers remain disabled until the vendor API is verified.'
              : 'This brand is saved for future connector support. Select a MikroTik router for live RouterOS hotspot operations.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _UsersTab extends ConsumerWidget {
  const _UsersTab({required this.router});

  final RouterEntity router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(hotspotUsersProvider(router));

    return _AsyncListScaffold<HotspotUserEntity>(
      value: users,
      emptyIcon: Icons.people_outline,
      emptyTitle: 'No hotspot users',
      emptyMessage: 'Create users or generate vouchers to populate this list.',
      onRefresh: () async => ref.invalidate(hotspotUsersProvider(router)),
      action: FloatingActionButton(
        tooltip: 'Add hotspot user',
        onPressed: () => _showCreateUserDialog(context, ref, router),
        child: const Icon(Icons.person_add_alt),
      ),
      itemBuilder: (context, user) => ListTile(
        leading: Icon(user.disabled ? Icons.person_off_outlined : Icons.person),
        title: Text(user.name),
        subtitle: Text(user.profile ?? 'default'),
        trailing: PopupMenuButton<_UserAction>(
          onSelected: (action) => _handleUserAction(context, ref, user, action),
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _UserAction.resetCounters,
              child: Text('Reset counters'),
            ),
            PopupMenuItem(value: _UserAction.delete, child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUserAction(
    BuildContext context,
    WidgetRef ref,
    HotspotUserEntity user,
    _UserAction action,
  ) async {
    final service = ref.read(hotspotServiceProvider);
    try {
      switch (action) {
        case _UserAction.resetCounters:
          await service.resetUserCounters(router, user.id);
          break;
        case _UserAction.delete:
          await service.deleteUser(router, user.id);
          break;
      }
      ref.invalidate(hotspotUsersProvider(router));
      if (context.mounted) {
        _showSnack(context, 'User action completed.');
      }
    } on Object catch (error) {
      if (context.mounted) {
        _showSnack(context, 'User action failed: $error');
      }
    }
  }
}

class _ProfilesTab extends ConsumerWidget {
  const _ProfilesTab({required this.router});

  final RouterEntity router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(hotspotProfilesProvider(router));

    return _AsyncListScaffold<HotspotUserProfileEntity>(
      value: profiles,
      emptyIcon: Icons.speed_outlined,
      emptyTitle: 'No profiles',
      emptyMessage: 'Create RouterOS hotspot user profiles for plan speeds.',
      onRefresh: () async => ref.invalidate(hotspotProfilesProvider(router)),
      action: FloatingActionButton(
        tooltip: 'Add profile',
        onPressed: () => _showCreateProfileDialog(context, ref, router),
        child: const Icon(Icons.add),
      ),
      itemBuilder: (context, profile) => ListTile(
        leading: const Icon(Icons.speed_outlined),
        title: Text(profile.name),
        subtitle: Text(profile.rateLimit ?? 'No rate limit'),
        trailing: IconButton(
          tooltip: 'Delete profile',
          onPressed: () => _deleteProfile(context, ref, router, profile),
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    );
  }
}

class _SessionsTab extends ConsumerWidget {
  const _SessionsTab({required this.router});

  final RouterEntity router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(hotspotActiveSessionsProvider(router));

    return _AsyncListScaffold<HotspotActiveSessionEntity>(
      value: sessions,
      emptyIcon: Icons.wifi_tethering_off,
      emptyTitle: 'No active sessions',
      emptyMessage: 'Online hotspot sessions will appear here.',
      onRefresh: () async =>
          ref.invalidate(hotspotActiveSessionsProvider(router)),
      itemBuilder: (context, session) => ListTile(
        leading: const Icon(Icons.wifi_tethering),
        title: Text(session.user),
        subtitle: Text(session.address ?? session.macAddress ?? 'active'),
        trailing: IconButton(
          tooltip: 'Disconnect',
          onPressed: () => _disconnectSession(context, ref, router, session),
          icon: const Icon(Icons.link_off),
        ),
      ),
    );
  }
}

class _CookiesTab extends ConsumerWidget {
  const _CookiesTab({required this.router});

  final RouterEntity router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cookies = ref.watch(hotspotCookiesProvider(router));

    return _AsyncListScaffold<HotspotCookieEntity>(
      value: cookies,
      emptyIcon: Icons.cookie_outlined,
      emptyTitle: 'No cookies',
      emptyMessage: 'MAC cookies reported by RouterOS will appear here.',
      onRefresh: () async => ref.invalidate(hotspotCookiesProvider(router)),
      itemBuilder: (context, cookie) => ListTile(
        leading: const Icon(Icons.cookie_outlined),
        title: Text(cookie.user),
        subtitle: Text(cookie.macAddress ?? cookie.expiresIn ?? 'cookie'),
        trailing: IconButton(
          tooltip: 'Delete cookie',
          onPressed: () => _deleteCookie(context, ref, router, cookie),
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    );
  }
}

class _BindingsTab extends ConsumerWidget {
  const _BindingsTab({required this.router});

  final RouterEntity router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bindings = ref.watch(hotspotIpBindingsProvider(router));

    return _AsyncListScaffold<HotspotIpBindingEntity>(
      value: bindings,
      emptyIcon: Icons.rule_folder_outlined,
      emptyTitle: 'No IP bindings',
      emptyMessage: 'Bypass, block, or regular bindings will appear here.',
      onRefresh: () async => ref.invalidate(hotspotIpBindingsProvider(router)),
      action: FloatingActionButton(
        tooltip: 'Add binding',
        onPressed: () => _showCreateBindingDialog(context, ref, router),
        child: const Icon(Icons.add_link),
      ),
      itemBuilder: (context, binding) => ListTile(
        leading: const Icon(Icons.rule_folder_outlined),
        title: Text(binding.macAddress ?? binding.address ?? binding.id),
        subtitle: Text(binding.type ?? 'binding'),
        trailing: IconButton(
          tooltip: 'Delete binding',
          onPressed: () => _deleteBinding(context, ref, router, binding),
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    );
  }
}

class _QueuesTab extends ConsumerWidget {
  const _QueuesTab({required this.router});

  final RouterEntity router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queues = ref.watch(hotspotQueuesProvider(router));

    return _AsyncListScaffold<HotspotQueueEntity>(
      value: queues,
      emptyIcon: Icons.account_tree_outlined,
      emptyTitle: 'No simple queues',
      emptyMessage: 'Simple queues from RouterOS will appear here.',
      onRefresh: () async => ref.invalidate(hotspotQueuesProvider(router)),
      itemBuilder: (context, queue) => ListTile(
        leading: const Icon(Icons.account_tree_outlined),
        title: Text(queue.name),
        subtitle: Text(queue.maxLimit ?? queue.target ?? 'queue'),
      ),
    );
  }
}

class _AsyncListScaffold<T> extends StatelessWidget {
  const _AsyncListScaffold({
    required this.value,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.onRefresh,
    required this.itemBuilder,
    this.action,
  });

  final AsyncValue<List<T>> value;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        value.when(
          data: (items) {
            if (items.isEmpty) {
              return EmptyState(
                icon: emptyIcon,
                title: emptyTitle,
                message: emptyMessage,
              );
            }

            return RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) =>
                    itemBuilder(context, items[index]),
              ),
            );
          },
          error: (error, stackTrace) => EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load data',
            message: error.toString(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
        if (action != null) Positioned(right: 16, bottom: 16, child: action!),
      ],
    );
  }
}

Future<void> _showSetupHotspotDialog(
  BuildContext context,
  WidgetRef ref,
  RouterEntity router,
) async {
  if (!router.supportsHotspotVouchers) {
    _showSnack(
      context,
      '${router.vendor.label} hotspot setup presets are planned, but not available yet.',
    );
    return;
  }

  final interfaceNamesFuture = _loadHotspotInterfaceNames(ref, router);
  var selectedPreset = HotspotSetupPreset.quickVoucher;
  final initialInput = selectedPreset.toInput();
  final serverNameController = TextEditingController(
    text: initialInput.serverName,
  );
  final interfaceController = TextEditingController(
    text: initialInput.interfaceName,
  );
  final serverProfileController = TextEditingController(
    text: initialInput.serverProfileName,
  );
  final hotspotAddressController = TextEditingController(
    text: initialInput.hotspotAddress,
  );
  final dnsNameController = TextEditingController(text: initialInput.dnsName);
  final addressPoolController = TextEditingController(
    text: initialInput.addressPool,
  );
  final ipAddressController = TextEditingController(
    text: initialInput.ipAddressWithPrefix,
  );
  final poolNameController = TextEditingController(text: initialInput.poolName);
  final poolRangesController = TextEditingController(
    text: initialInput.poolRanges,
  );
  final dhcpServerController = TextEditingController(
    text: initialInput.dhcpServerName,
  );
  final dhcpNetworkController = TextEditingController(
    text: initialInput.dhcpNetwork,
  );
  final dhcpGatewayController = TextEditingController(
    text: initialInput.dhcpGateway,
  );
  final dnsServersController = TextEditingController(
    text: initialInput.dnsServers,
  );
  final natSrcAddressController = TextEditingController(
    text: initialInput.natSrcAddress,
  );
  final natOutInterfaceController = TextEditingController();
  var provisionNetwork = initialInput.provisionNetwork;
  var enableNatMasquerade = initialInput.enableNatMasquerade;
  var loginByCookie = initialInput.loginByCookie;
  var loginByHttpPap = initialInput.loginByHttpPap;
  var loginByHttps = initialInput.loginByHttps;
  var useRadius = initialInput.useRadius;

  void applyPreset(HotspotSetupInput input) {
    serverNameController.text = input.serverName;
    interfaceController.text = input.interfaceName;
    serverProfileController.text = input.serverProfileName;
    hotspotAddressController.text = input.hotspotAddress ?? '';
    dnsNameController.text = input.dnsName ?? '';
    addressPoolController.text = input.addressPool ?? '';
    ipAddressController.text = input.ipAddressWithPrefix ?? '';
    poolNameController.text = input.poolName ?? '';
    poolRangesController.text = input.poolRanges ?? '';
    dhcpServerController.text = input.dhcpServerName ?? '';
    dhcpNetworkController.text = input.dhcpNetwork ?? '';
    dhcpGatewayController.text = input.dhcpGateway ?? '';
    dnsServersController.text = input.dnsServers ?? '';
    natSrcAddressController.text = input.natSrcAddress ?? '';
    natOutInterfaceController.text = input.natOutInterface ?? '';
    provisionNetwork = input.provisionNetwork;
    enableNatMasquerade = input.enableNatMasquerade;
    loginByCookie = input.loginByCookie;
    loginByHttpPap = input.loginByHttpPap;
    loginByHttps = input.loginByHttps;
    useRadius = input.useRadius;
  }

  HotspotSetupInput buildInput() {
    return HotspotSetupInput(
      serverName: serverNameController.text.trim(),
      interfaceName: interfaceController.text.trim(),
      serverProfileName: serverProfileController.text.trim(),
      hotspotAddress: hotspotAddressController.text.trim(),
      dnsName: dnsNameController.text.trim(),
      addressPool: addressPoolController.text.trim(),
      provisionNetwork: provisionNetwork,
      ipAddressWithPrefix: ipAddressController.text.trim(),
      poolName: poolNameController.text.trim(),
      poolRanges: poolRangesController.text.trim(),
      dhcpServerName: dhcpServerController.text.trim(),
      dhcpNetwork: dhcpNetworkController.text.trim(),
      dhcpGateway: dhcpGatewayController.text.trim(),
      dnsServers: dnsServersController.text.trim(),
      enableNatMasquerade: enableNatMasquerade,
      natSrcAddress: natSrcAddressController.text.trim(),
      natOutInterface: natOutInterfaceController.text.trim(),
      loginByCookie: loginByCookie,
      loginByHttpPap: loginByHttpPap,
      loginByHttps: loginByHttps,
      useRadius: useRadius,
    );
  }

  try {
    final input = await showDialog<HotspotSetupInput>(
      context: context,
      builder: (context) {
        String? validationError;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Setup hotspot'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<HotspotSetupPreset>(
                    initialValue: selectedPreset,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Business setup preset',
                      prefixIcon: Icon(Icons.tune_outlined),
                    ),
                    items: [
                      for (final preset in HotspotSetupPreset.values)
                        DropdownMenuItem(
                          value: preset,
                          child: Text(
                            preset.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (preset) {
                      if (preset == null) {
                        return;
                      }
                      setState(() {
                        selectedPreset = preset;
                        applyPreset(preset.toInput());
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      selectedPreset.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: serverNameController,
                    decoration: const InputDecoration(
                      labelText: 'Server name',
                      helperText: 'Example: hotspot1',
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<List<String>>(
                    future: interfaceNamesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return TextField(
                          controller: interfaceController,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Interface',
                            helperText: 'Loading interfaces from the router...',
                          ),
                        );
                      }

                      final interfaceNames = snapshot.data ?? const <String>[];
                      if (interfaceNames.isEmpty) {
                        return TextField(
                          controller: interfaceController,
                          decoration: InputDecoration(
                            labelText: 'Interface',
                            helperText: snapshot.hasError
                                ? 'Could not load interfaces. Enter a verified name.'
                                : 'No interfaces were reported. Enter a verified name.',
                          ),
                        );
                      }

                      final selectedInterface =
                          interfaceNames.contains(interfaceController.text)
                          ? interfaceController.text
                          : null;
                      return DropdownButtonFormField<String>(
                        key: ValueKey(selectedInterface),
                        initialValue: selectedInterface,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Hotspot interface',
                          helperText:
                              'Choose an interface reported by this router.',
                        ),
                        items: [
                          for (final interfaceName in interfaceNames)
                            DropdownMenuItem(
                              value: interfaceName,
                              child: Text(interfaceName),
                            ),
                        ],
                        onChanged: (interfaceName) {
                          if (interfaceName == null) {
                            return;
                          }
                          setState(
                            () => interfaceController.text = interfaceName,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: serverProfileController,
                    decoration: const InputDecoration(
                      labelText: 'Server profile',
                      helperText: 'Created if it does not already exist.',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: hotspotAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Hotspot address',
                      helperText: 'Optional, e.g. 10.5.50.1',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dnsNameController,
                    decoration: const InputDecoration(
                      labelText: 'DNS name',
                      helperText: 'Optional captive portal name.',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: addressPoolController,
                    decoration: const InputDecoration(
                      labelText: 'Address pool',
                      helperText: 'Existing or generated RouterOS pool.',
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: provisionNetwork,
                    onChanged: (value) =>
                        setState(() => provisionNetwork = value),
                    title: const Text('Provision LAN network'),
                    subtitle: const Text(
                      'Adds missing IP address, pool, DHCP, and optional NAT.',
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (provisionNetwork) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: ipAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Interface IP',
                        helperText: 'Example: 10.5.50.1/24',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: poolNameController,
                      decoration: const InputDecoration(labelText: 'Pool name'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: poolRangesController,
                      decoration: const InputDecoration(
                        labelText: 'Pool ranges',
                        helperText: 'Example: 10.5.50.10-10.5.50.254',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: dhcpServerController,
                      decoration: const InputDecoration(
                        labelText: 'DHCP server name',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: dhcpNetworkController,
                      decoration: const InputDecoration(
                        labelText: 'DHCP network',
                        helperText: 'Example: 10.5.50.0/24',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: dhcpGatewayController,
                      decoration: const InputDecoration(labelText: 'Gateway'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: dnsServersController,
                      decoration: const InputDecoration(
                        labelText: 'DNS servers',
                        helperText: 'Comma-separated RouterOS value.',
                      ),
                    ),
                    SwitchListTile(
                      value: enableNatMasquerade,
                      onChanged: (value) =>
                          setState(() => enableNatMasquerade = value),
                      title: const Text('Add NAT masquerade'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (enableNatMasquerade) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: natSrcAddressController,
                        decoration: const InputDecoration(
                          labelText: 'NAT source',
                          helperText: 'Example: 10.5.50.0/24',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: natOutInterfaceController,
                        decoration: const InputDecoration(
                          labelText: 'WAN interface',
                          helperText: 'Optional, e.g. ether1',
                        ),
                      ),
                    ],
                  ],
                  SwitchListTile(
                    value: loginByCookie,
                    onChanged: (value) => setState(() => loginByCookie = value),
                    title: const Text('Cookie login'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    value: loginByHttpPap,
                    onChanged: (value) =>
                        setState(() => loginByHttpPap = value),
                    title: const Text('HTTP PAP login'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    value: loginByHttps,
                    onChanged: (value) => setState(() => loginByHttps = value),
                    title: const Text('HTTPS login'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    value: useRadius,
                    onChanged: (value) => setState(() => useRadius = value),
                    title: const Text('Use RADIUS'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (validationError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      validationError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final input = buildInput();
                  final errors = input.validationErrors;
                  if (errors.isNotEmpty) {
                    setState(() => validationError = errors.first);
                    return;
                  }
                  Navigator.of(context).pop(input);
                },
                child: const Text('Create'),
              ),
            ],
          ),
        );
      },
    );

    if (input == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final validationErrors = input.validationErrors;
    if (validationErrors.isNotEmpty) {
      _showSnack(
        context,
        'Complete the setup before reviewing it: ${validationErrors.first}',
      );
      return;
    }
    final inspection = await ref
        .read(hotspotServiceProvider)
        .inspectSetup(router, input);
    if (!context.mounted) {
      return;
    }
    final confirmed = await _showSetupPlanDialog(
      context,
      router: router,
      preset: selectedPreset,
      input: input,
      inspection: inspection,
    );
    if (!confirmed) {
      return;
    }
    await ref
        .read(hotspotDeploymentServiceProvider)
        .deploy(
          router: router,
          preset: selectedPreset,
          input: input,
          inspection: inspection,
        );
    ref.invalidate(hotspotProfilesProvider(router));
    ref.invalidate(hotspotDeploymentHistoryProvider(router.id));
    if (context.mounted) {
      _showSnack(context, 'Hotspot server setup completed.');
    }
  } on Object catch (error) {
    if (context.mounted) {
      _showSnack(context, 'Could not setup hotspot: $error');
    }
  } finally {
    serverNameController.dispose();
    interfaceController.dispose();
    serverProfileController.dispose();
    hotspotAddressController.dispose();
    dnsNameController.dispose();
    addressPoolController.dispose();
    ipAddressController.dispose();
    poolNameController.dispose();
    poolRangesController.dispose();
    dhcpServerController.dispose();
    dhcpNetworkController.dispose();
    dhcpGatewayController.dispose();
    dnsServersController.dispose();
    natSrcAddressController.dispose();
    natOutInterfaceController.dispose();
  }
}

Future<List<String>> _loadHotspotInterfaceNames(
  WidgetRef ref,
  RouterEntity router,
) async {
  final response = await ref
      .read(routerConnectionServiceProvider)
      .execute(router, '/interface/print');
  final interfaceNames =
      response.records
          .map((record) => record['name']?.trim() ?? '')
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
  return interfaceNames;
}

Future<bool> _showSetupPlanDialog(
  BuildContext context, {
  required RouterEntity router,
  required HotspotSetupPreset preset,
  required HotspotSetupInput input,
  required HotspotSetupInspection inspection,
}) async {
  final plan = input.toPlan();
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Review and apply setup'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Target router: ${router.name}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text('${router.vendor.label} • ${preset.label}'),
              const SizedBox(height: 12),
              Text(
                '${inspection.profileAction} • ${inspection.serverAction}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'This can create network, DHCP, NAT, and hotspot records on the selected router. WireSpot checks for existing records before adding settings.',
              ),
              const SizedBox(height: 12),
              for (final step in plan.steps)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.command,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      for (final attribute in step.attributes.entries)
                        Text('${attribute.key}: ${attribute.value}'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Back'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Apply'),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<void> _showCreateUserDialog(
  BuildContext context,
  WidgetRef ref,
  RouterEntity router,
) async {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final profileController = TextEditingController();
  final limitUptimeController = TextEditingController();
  final priceController = TextEditingController();
  final dataLimitMbController = TextEditingController();
  final currencyCode =
      ref.read(appSettingsProvider).asData?.value.currencyCode ?? 'NGN';
  var userMode = 'usernamePassword';
  try {
    final input = await showDialog<HotspotUserInput>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add hotspot user'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: userMode,
                  decoration: const InputDecoration(labelText: 'Login mode'),
                  items: const [
                    DropdownMenuItem(
                      value: 'usernamePassword',
                      child: Text('Username + password'),
                    ),
                    DropdownMenuItem(
                      value: 'usernameOnly',
                      child: Text('Username only'),
                    ),
                    DropdownMenuItem(value: 'pinOnly', child: Text('PIN only')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => userMode = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: usernameController,
                  keyboardType: userMode == 'pinOnly'
                      ? TextInputType.number
                      : TextInputType.text,
                  decoration: InputDecoration(
                    labelText: userMode == 'pinOnly' ? 'PIN' : 'Username',
                  ),
                ),
                if (userMode == 'usernamePassword') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                ],
                const SizedBox(height: 8),
                TextField(
                  controller: profileController,
                  decoration: const InputDecoration(labelText: 'Profile'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: limitUptimeController,
                  decoration: const InputDecoration(
                    labelText: 'Time limit',
                    helperText: 'RouterOS format, for example 1h, 3h, 1d',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          prefixText: '$currencyCode ',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: dataLimitMbController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Data limit',
                          suffixText: 'MB',
                        ),
                      ),
                    ),
                  ],
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
              onPressed: () {
                final dataLimitMb = int.tryParse(
                  dataLimitMbController.text.trim(),
                );
                Navigator.of(context).pop(
                  HotspotUserInput(
                    username: usernameController.text.trim(),
                    password: userMode == 'usernamePassword'
                        ? passwordController.text.trim()
                        : '',
                    profile: profileController.text.trim(),
                    limitUptime: limitUptimeController.text.trim(),
                    limitBytesTotal: dataLimitMb == null
                        ? null
                        : dataLimitMb * 1024 * 1024,
                    comment: priceController.text.trim().isEmpty
                        ? null
                        : 'Price $currencyCode ${priceController.text.trim()}',
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (input == null) {
      return;
    }
    await ref.read(hotspotServiceProvider).createUser(router, input);
    ref.invalidate(hotspotUsersProvider(router));
    if (context.mounted) {
      _showSnack(context, 'Hotspot user created.');
    }
  } on Object catch (error) {
    if (context.mounted) {
      _showSnack(context, 'Could not create user: $error');
    }
  } finally {
    usernameController.dispose();
    passwordController.dispose();
    profileController.dispose();
    limitUptimeController.dispose();
    priceController.dispose();
    dataLimitMbController.dispose();
  }
}

Future<void> _showCreateProfileDialog(
  BuildContext context,
  WidgetRef ref,
  RouterEntity router,
) async {
  final nameController = TextEditingController();
  final rateLimitController = TextEditingController();
  final uploadController = TextEditingController();
  final downloadController = TextEditingController();
  final sessionTimeoutController = TextEditingController();
  final idleTimeoutController = TextEditingController();
  final keepaliveTimeoutController = TextEditingController();
  final sharedUsersController = TextEditingController(text: '1');
  final priceController = TextEditingController();
  final dataLimitMbController = TextEditingController();
  final currencyCode =
      ref.read(appSettingsProvider).asData?.value.currencyCode ?? 'NGN';
  try {
    final input = await showDialog<HotspotProfileInput>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add profile'),
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
                controller: rateLimitController,
                decoration: const InputDecoration(
                  labelText: 'Raw rate limit',
                  helperText: 'Optional RouterOS format, e.g. 2M/5M',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: uploadController,
                      decoration: const InputDecoration(labelText: 'Upload'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: downloadController,
                      decoration: const InputDecoration(labelText: 'Download'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        prefixText: '$currencyCode ',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: dataLimitMbController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Data',
                        suffixText: 'MB',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: sessionTimeoutController,
                decoration: const InputDecoration(labelText: 'Session timeout'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: idleTimeoutController,
                decoration: const InputDecoration(labelText: 'Idle timeout'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: keepaliveTimeoutController,
                decoration: const InputDecoration(
                  labelText: 'Keepalive timeout',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: sharedUsersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Shared users'),
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
            onPressed: () {
              final priceMajor = int.tryParse(priceController.text.trim());
              final dataLimitMb = int.tryParse(
                dataLimitMbController.text.trim(),
              );
              Navigator.of(context).pop(
                HotspotProfileInput(
                  name: nameController.text.trim(),
                  rateLimit: rateLimitController.text.trim(),
                  uploadLimit: uploadController.text.trim(),
                  downloadLimit: downloadController.text.trim(),
                  sessionTimeout: sessionTimeoutController.text.trim(),
                  idleTimeout: idleTimeoutController.text.trim(),
                  keepaliveTimeout: keepaliveTimeoutController.text.trim(),
                  sharedUsers: int.tryParse(sharedUsersController.text.trim()),
                  priceMinor: priceMajor == null ? null : priceMajor * 100,
                  dataLimitBytes: dataLimitMb == null
                      ? null
                      : dataLimitMb * 1024 * 1024,
                ),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (input == null) {
      return;
    }
    await ref.read(hotspotServiceProvider).createProfile(router, input);
    ref.invalidate(hotspotProfilesProvider(router));
    if (context.mounted) {
      _showSnack(context, 'Profile created.');
    }
  } on Object catch (error) {
    if (context.mounted) {
      _showSnack(context, 'Could not create profile: $error');
    }
  } finally {
    nameController.dispose();
    rateLimitController.dispose();
    uploadController.dispose();
    downloadController.dispose();
    sessionTimeoutController.dispose();
    idleTimeoutController.dispose();
    keepaliveTimeoutController.dispose();
    sharedUsersController.dispose();
    priceController.dispose();
    dataLimitMbController.dispose();
  }
}

Future<void> _showCreateBindingDialog(
  BuildContext context,
  WidgetRef ref,
  RouterEntity router,
) async {
  final addressController = TextEditingController();
  final macController = TextEditingController();
  final commentController = TextEditingController();
  var bindingType = 'bypassed';
  try {
    final input = await showDialog<HotspotIpBindingInput>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add IP binding'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: macController,
                decoration: const InputDecoration(labelText: 'MAC address'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: bindingType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'bypassed', child: Text('Bypassed')),
                  DropdownMenuItem(value: 'blocked', child: Text('Blocked')),
                  DropdownMenuItem(value: 'regular', child: Text('Regular')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => bindingType = value);
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(labelText: 'Comment'),
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
                HotspotIpBindingInput(
                  address: addressController.text.trim(),
                  macAddress: macController.text.trim(),
                  type: bindingType,
                  comment: commentController.text.trim(),
                ),
              ),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (input == null) {
      return;
    }
    await ref.read(hotspotServiceProvider).createIpBinding(router, input);
    ref.invalidate(hotspotIpBindingsProvider(router));
    if (context.mounted) {
      _showSnack(context, 'IP binding created.');
    }
  } on Object catch (error) {
    if (context.mounted) {
      _showSnack(context, 'Could not create binding: $error');
    }
  } finally {
    addressController.dispose();
    macController.dispose();
    commentController.dispose();
  }
}

Future<void> _deleteProfile(
  BuildContext context,
  WidgetRef ref,
  RouterEntity router,
  HotspotUserProfileEntity profile,
) async {
  try {
    await ref.read(hotspotServiceProvider).deleteProfile(router, profile.id);
    ref.invalidate(hotspotProfilesProvider(router));
    if (context.mounted) {
      _showSnack(context, 'Profile deleted.');
    }
  } on Object catch (error) {
    if (context.mounted) {
      _showSnack(context, 'Could not delete profile: $error');
    }
  }
}

Future<void> _disconnectSession(
  BuildContext context,
  WidgetRef ref,
  RouterEntity router,
  HotspotActiveSessionEntity session,
) async {
  try {
    await ref
        .read(hotspotServiceProvider)
        .disconnectSession(router, session.id);
    ref.invalidate(hotspotActiveSessionsProvider(router));
    if (context.mounted) {
      _showSnack(context, 'Session disconnected.');
    }
  } on Object catch (error) {
    if (context.mounted) {
      _showSnack(context, 'Could not disconnect session: $error');
    }
  }
}

Future<void> _deleteCookie(
  BuildContext context,
  WidgetRef ref,
  RouterEntity router,
  HotspotCookieEntity cookie,
) async {
  try {
    await ref.read(hotspotServiceProvider).deleteCookie(router, cookie.id);
    ref.invalidate(hotspotCookiesProvider(router));
    if (context.mounted) {
      _showSnack(context, 'Cookie deleted.');
    }
  } on Object catch (error) {
    if (context.mounted) {
      _showSnack(context, 'Could not delete cookie: $error');
    }
  }
}

Future<void> _deleteBinding(
  BuildContext context,
  WidgetRef ref,
  RouterEntity router,
  HotspotIpBindingEntity binding,
) async {
  try {
    await ref.read(hotspotServiceProvider).deleteIpBinding(router, binding.id);
    ref.invalidate(hotspotIpBindingsProvider(router));
    if (context.mounted) {
      _showSnack(context, 'IP binding deleted.');
    }
  } on Object catch (error) {
    if (context.mounted) {
      _showSnack(context, 'Could not delete binding: $error');
    }
  }
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

enum _UserAction { resetCounters, delete }
