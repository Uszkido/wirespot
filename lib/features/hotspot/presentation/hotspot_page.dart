import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../routers/domain/entities/router_entity.dart';
import '../../routers/presentation/router_providers.dart';
import '../domain/entities/hotspot_active_session_entity.dart';
import '../domain/entities/hotspot_cookie_entity.dart';
import '../domain/entities/hotspot_ip_binding_entity.dart';
import '../domain/entities/hotspot_ip_binding_input.dart';
import '../domain/entities/hotspot_profile_input.dart';
import '../domain/entities/hotspot_queue_entity.dart';
import '../domain/entities/hotspot_setup_input.dart';
import '../domain/entities/hotspot_user_entity.dart';
import '../domain/entities/hotspot_user_input.dart';
import '../domain/entities/hotspot_user_profile_entity.dart';
import 'hotspot_providers.dart';

class HotspotPage extends ConsumerWidget {
  const HotspotPage({super.key});

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

          final selectedId = ref.watch(selectedHotspotRouterIdProvider);
          final router = items.firstWhere(
            (item) => item.id == selectedId,
            orElse: () => items.first,
          );

          return _HotspotRouterScope(routers: items, router: router);
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
  const _HotspotRouterScope({required this.routers, required this.router});

  final List<RouterEntity> routers;
  final RouterEntity router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 6,
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
                  },
                ),
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
              ],
            ),
          ),
        ],
      ),
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
  final serverNameController = TextEditingController(text: 'hotspot1');
  final interfaceController = TextEditingController(text: 'bridge');
  final serverProfileController = TextEditingController(text: 'hsprof1');
  final hotspotAddressController = TextEditingController();
  final dnsNameController = TextEditingController(text: 'hotspot.local');
  final addressPoolController = TextEditingController();
  var loginByCookie = true;
  var loginByHttpPap = true;
  var loginByHttps = false;
  var useRadius = false;

  try {
    final input = await showDialog<HotspotSetupInput>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Setup hotspot'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: serverNameController,
                  decoration: const InputDecoration(
                    labelText: 'Server name',
                    helperText: 'Example: hotspot1',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: interfaceController,
                  decoration: const InputDecoration(
                    labelText: 'Interface',
                    helperText: 'Example: bridge, wlan1, ether2',
                  ),
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
                    helperText: 'Optional existing RouterOS pool.',
                  ),
                ),
                SwitchListTile(
                  value: loginByCookie,
                  onChanged: (value) => setState(() => loginByCookie = value),
                  title: const Text('Cookie login'),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  value: loginByHttpPap,
                  onChanged: (value) => setState(() => loginByHttpPap = value),
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
                HotspotSetupInput(
                  serverName: serverNameController.text.trim(),
                  interfaceName: interfaceController.text.trim(),
                  serverProfileName: serverProfileController.text.trim(),
                  hotspotAddress: hotspotAddressController.text.trim(),
                  dnsName: dnsNameController.text.trim(),
                  addressPool: addressPoolController.text.trim(),
                  loginByCookie: loginByCookie,
                  loginByHttpPap: loginByHttpPap,
                  loginByHttps: loginByHttps,
                  useRadius: useRadius,
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
    await ref.read(hotspotServiceProvider).setupHotspot(router, input);
    ref.invalidate(hotspotProfilesProvider(router));
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
  }
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
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          prefixText: 'NGN ',
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
                        : 'Price NGN ${priceController.text.trim()}',
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
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixText: 'NGN ',
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
