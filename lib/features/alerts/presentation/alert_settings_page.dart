import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../routers/presentation/router_providers.dart';
import '../domain/entities/router_alert_rule.dart';

class AlertSettingsPage extends ConsumerStatefulWidget {
  const AlertSettingsPage({super.key});

  @override
  ConsumerState<AlertSettingsPage> createState() => _AlertSettingsPageState();
}

class _AlertSettingsPageState extends ConsumerState<AlertSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final alertService = ref.watch(routerAlertServiceProvider);
    final routers = ref.watch(routersProvider).asData?.value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Router Alert Settings'),
        actions: [
          Switch(
            value: alertService.isRunning,
            onChanged: (value) {
              setState(() {
                if (value) {
                  alertService.setRouters(routers);
                  alertService.start();
                } else {
                  alertService.stop();
                }
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRuleDialog(context),
        child: const Icon(Icons.add_alert),
      ),
      body: alertService.rules.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No alert rules configured',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a threshold alert for CPU, memory, or interface status.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: alertService.rules.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final rule = alertService.rules[index];
                final router = routers
                    .where((r) => r.id == rule.routerId)
                    .map((r) => r.name)
                    .firstOrNull;
                return ListTile(
                  leading: Icon(_iconForMetric(rule.metric)),
                  title: Text(rule.metric.label),
                  subtitle: Text(
                    '${router ?? rule.routerId} • Threshold: ${rule.threshold}%',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: rule.enabled,
                        onChanged: (v) {
                          setState(() {
                            alertService.toggleRule(rule.id, v);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() {
                            alertService.removeRule(rule.id);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  IconData _iconForMetric(AlertMetricType type) {
    return switch (type) {
      AlertMetricType.cpuLoad => Icons.memory,
      AlertMetricType.memoryUsage => Icons.storage,
      AlertMetricType.interfaceDown => Icons.link_off,
    };
  }

  Future<void> _showAddRuleDialog(BuildContext context) async {
    final routers = ref.read(routersProvider).asData?.value ?? [];
    if (routers.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No routers available.')));
      return;
    }

    String? selectedRouterId = routers.first.id;
    AlertMetricType selectedMetric = AlertMetricType.cpuLoad;
    final thresholdController = TextEditingController(text: '80');

    final result = await showDialog<RouterAlertRule>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Add Alert Rule'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedRouterId,
                  decoration: const InputDecoration(
                    labelText: 'Router',
                    prefixIcon: Icon(Icons.router_outlined),
                  ),
                  items: [
                    for (final r in routers)
                      DropdownMenuItem(value: r.id, child: Text(r.name)),
                  ],
                  onChanged: (v) => setDialogState(() => selectedRouterId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AlertMetricType>(
                  initialValue: selectedMetric,
                  decoration: const InputDecoration(
                    labelText: 'Metric',
                    prefixIcon: Icon(Icons.speed),
                  ),
                  items: [
                    for (final m in AlertMetricType.values)
                      DropdownMenuItem(value: m, child: Text(m.label)),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedMetric = v);
                  },
                ),
                const SizedBox(height: 12),
                if (selectedMetric != AlertMetricType.interfaceDown)
                  TextField(
                    controller: thresholdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Threshold %',
                      prefixIcon: Icon(Icons.tune),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    RouterAlertRule(
                      id: const Uuid().v4(),
                      routerId: selectedRouterId!,
                      metric: selectedMetric,
                      threshold: int.tryParse(thresholdController.text) ?? 80,
                    ),
                  );
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        ref.read(routerAlertServiceProvider).addRule(result);
      });
    }
  }
}
