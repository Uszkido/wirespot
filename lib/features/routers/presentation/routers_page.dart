import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../domain/entities/router_entity.dart';
import 'router_providers.dart';

class RoutersPage extends ConsumerWidget {
  const RoutersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routers = ref.watch(routersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Routers')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add router',
        onPressed: () => context.push(AppRoutes.newRouter),
        child: const Icon(Icons.add),
      ),
      body: routers.when(
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.router_outlined,
              title: 'No routers yet',
              message:
                  'Add your first MikroTik router to manage hotspot users.',
              action: FilledButton.icon(
                onPressed: () => context.push(AppRoutes.newRouter),
                icon: const Icon(Icons.add),
                label: const Text('Add router'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(routersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _RouterTile(router: items[index]);
              },
            ),
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

class _RouterTile extends ConsumerWidget {
  const _RouterTile({required this.router});

  final RouterEntity router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          child: const Icon(Icons.router_outlined),
        ),
        title: Text(router.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [
            '${router.host}:${router.apiPort}',
            if (router.useSsl) 'SSL',
            router.remoteAccessMode.label,
          ].join(' - '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<_RouterAction>(
          tooltip: 'Router actions',
          onSelected: (action) => _handleAction(context, ref, action),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: _RouterAction.test,
              child: ListTile(
                leading: Icon(Icons.network_check),
                title: Text('Test connection'),
              ),
            ),
            if (router.requiresPrivateTunnel)
              const PopupMenuItem(
                value: _RouterAction.wireGuard,
                child: ListTile(
                  leading: Icon(Icons.vpn_key_outlined),
                  title: Text('Remote tunnel'),
                ),
              ),
            const PopupMenuItem(
              value: _RouterAction.edit,
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit'),
              ),
            ),
            const PopupMenuItem(
              value: _RouterAction.delete,
              child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Delete'),
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

  Future<void> _testConnection(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Testing router connection...')),
    );

    try {
      final isOnline = await ref
          .read(routerConnectionServiceProvider)
          .testConnection(router);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isOnline
                ? 'Router connection successful.'
                : 'Router connection failed.',
          ),
        ),
      );
    } on Object catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Connection test failed: $error')),
      );
    }
  }

  Future<void> _deleteRouter(BuildContext context, WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete router?'),
        content: Text('Remove ${router.name} and its saved credentials.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    await ref.read(routerRepositoryProvider).deleteRouter(router.id);
    ref.invalidate(routersProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Router deleted.')));
    }
  }
}

enum _RouterAction { test, wireGuard, edit, delete }
