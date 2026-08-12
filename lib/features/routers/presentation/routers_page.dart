import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/localization/app_text.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../settings/presentation/settings_providers.dart';
import '../domain/entities/router_entity.dart';
import 'router_providers.dart';

class RoutersPage extends ConsumerWidget {
  const RoutersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routers = ref.watch(routersProvider);
    final languageCode =
        ref.watch(appSettingsProvider).asData?.value.languageCode ?? 'en';
    final text = AppText(languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(text.routers)),
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
          title: text.couldNotLoadRouters,
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
    final languageCode =
        ref.watch(appSettingsProvider).asData?.value.languageCode ?? 'en';
    final text = AppText(languageCode);

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

    await ref.read(routerRepositoryProvider).deleteRouter(router.id);
    ref.invalidate(routersProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(text.routerDeleted)));
    }
  }
}

enum _RouterAction { test, wireGuard, edit, delete }
