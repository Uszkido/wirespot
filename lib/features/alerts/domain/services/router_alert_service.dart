import 'dart:async';

import '../../../../core/api/routeros_models.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../routers/domain/entities/router_entity.dart';
import '../../../routers/domain/services/router_connection_service.dart';
import '../entities/router_alert_rule.dart';

/// Periodically polls routers and fires local notifications when thresholds
/// are breached.
class RouterAlertService {
  RouterAlertService({
    required RouterConnectionService connectionService,
    required NotificationService notificationService,
  })  : _connectionService = connectionService,
        _notificationService = notificationService;

  final RouterConnectionService _connectionService;
  final NotificationService _notificationService;

  Timer? _timer;

  /// The rules configured by the user. Managed externally (UI / provider).
  final List<RouterAlertRule> _rules = [];
  List<RouterAlertRule> get rules => List.unmodifiable(_rules);

  /// Keeps track of alert IDs already fired so we don't spam.
  final Set<String> _firedAlertIds = {};

  /// Routers currently being monitored.
  final List<RouterEntity> _routers = [];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  void addRule(RouterAlertRule rule) {
    _rules.add(rule);
  }

  void removeRule(String ruleId) {
    _rules.removeWhere((r) => r.id == ruleId);
    _firedAlertIds.remove(ruleId);
  }

  void toggleRule(String ruleId, bool enabled) {
    final index = _rules.indexWhere((r) => r.id == ruleId);
    if (index == -1) return;
    _rules[index] = _rules[index].copyWith(enabled: enabled);
    if (!enabled) _firedAlertIds.remove(ruleId);
  }

  void setRouters(List<RouterEntity> routers) {
    _routers
      ..clear()
      ..addAll(routers);
  }

  /// Start polling. [interval] defaults to 5 minutes.
  void start({Duration interval = const Duration(minutes: 5)}) {
    stop();
    _timer = Timer.periodic(interval, (_) => _poll());
    // Also poll immediately on start.
    _poll();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  bool get isRunning => _timer != null && _timer!.isActive;

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  Future<void> _poll() async {
    for (final router in _routers) {
      final rulesForRouter =
          _rules.where((r) => r.routerId == router.id && r.enabled);
      if (rulesForRouter.isEmpty) continue;

      try {
        final snapshot = await _connectionService.getSnapshot(router);
        for (final rule in rulesForRouter) {
          _evaluate(rule, router.name, snapshot);
        }
      } on Object catch (_) {
        // Connection failure — optionally notify.
      }
    }
  }

  void _evaluate(
    RouterAlertRule rule,
    String routerName,
    RouterOsRouterSnapshot snapshot,
  ) {
    bool breached = false;
    String message = '';

    switch (rule.metric) {
      case AlertMetricType.cpuLoad:
        final cpu = snapshot.resource.cpuLoad;
        if (cpu >= rule.threshold) {
          breached = true;
          message = '$routerName CPU at $cpu% (threshold ${rule.threshold}%)';
        }
      case AlertMetricType.memoryUsage:
        final total = snapshot.resource.totalMemory;
        final free = snapshot.resource.freeMemory;
        if (total > 0) {
          final usedPercent = ((total - free) / total * 100).round();
          if (usedPercent >= rule.threshold) {
            breached = true;
            message =
                '$routerName memory at $usedPercent% (threshold ${rule.threshold}%)';
          }
        }
      case AlertMetricType.interfaceDown:
        final downInterfaces = snapshot.interfaces
            .where((i) => !i.running && !i.disabled)
            .map((i) => i.name)
            .toList();
        if (downInterfaces.isNotEmpty) {
          breached = true;
          message =
              '$routerName interface(s) down: ${downInterfaces.join(', ')}';
        }
    }

    if (breached && !_firedAlertIds.contains(rule.id)) {
      _firedAlertIds.add(rule.id);
      _notificationService.show(
        id: rule.id.hashCode,
        title: 'Router Alert: ${rule.metric.label}',
        body: message,
      );
    } else if (!breached) {
      // Clear so it can fire again if the condition resurfaces.
      _firedAlertIds.remove(rule.id);
    }
  }
}
