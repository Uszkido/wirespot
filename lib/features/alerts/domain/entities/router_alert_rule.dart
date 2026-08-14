/// The type of metric monitored by an alert rule.
enum AlertMetricType {
  cpuLoad('CPU Load %'),
  memoryUsage('Memory Usage %'),
  interfaceDown('Interface Down');

  const AlertMetricType(this.label);
  final String label;
}

/// A user-configured alert rule for a specific router.
class RouterAlertRule {
  const RouterAlertRule({
    required this.id,
    required this.routerId,
    required this.metric,
    required this.threshold,
    this.enabled = true,
  });

  final String id;
  final String routerId;
  final AlertMetricType metric;

  /// CPU/memory: the percentage threshold above which to alert.
  /// interfaceDown: unused (any down interface triggers).
  final int threshold;
  final bool enabled;

  RouterAlertRule copyWith({bool? enabled, int? threshold}) {
    return RouterAlertRule(
      id: id,
      routerId: routerId,
      metric: metric,
      threshold: threshold ?? this.threshold,
      enabled: enabled ?? this.enabled,
    );
  }
}
