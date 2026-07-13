import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../di/providers.dart';
import '../router/app_routes.dart';
import 'entitlement_snapshot.dart';

class LicenseGate extends ConsumerWidget {
  const LicenseGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitlement = ref.watch(_entitlementGateProvider);
    return entitlement.when(
      data: (value) {
        if (value.hasAccess) {
          return child;
        }
        return Scaffold(
          appBar: AppBar(title: const Text('License required')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspace_premium_outlined,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'WireSpot trial has ended',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter a valid license to continue using the app.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => context.go(AppRoutes.settings),
                    icon: const Icon(Icons.key_outlined),
                    label: const Text('Open license settings'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('Could not load license: $error'))),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

final _entitlementGateProvider =
    FutureProvider.autoDispose<EntitlementSnapshot>((ref) {
      return ref.watch(entitlementServiceProvider).load();
    });
