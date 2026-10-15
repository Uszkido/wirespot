import 'dart:io';

import 'package:wirespot/core/licensing/billing_plan.dart';
import 'package:wirespot/core/licensing/entitlement_service.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    stdout.writeln(
      'Usage: dart run tools/license_generator.dart DEVICE_ID [--plan lifetime|monthly|yearly] [--expires YYYY-MM-DD]',
    );
    return;
  }

  final planIndex = args.indexOf('--plan');
  final planName = planIndex >= 0 && planIndex + 1 < args.length
      ? args[planIndex + 1]
      : 'lifetime';
  final expiryIndex = args.indexOf('--expires');
  final expiry = expiryIndex >= 0 && expiryIndex + 1 < args.length
      ? DateTime.tryParse('${args[expiryIndex + 1]}T23:59:59Z')
      : null;
  final deviceIds = args.where(
    (arg) =>
        !arg.startsWith('--') &&
        (planIndex < 0 || arg != args[planIndex + 1]) &&
        (expiryIndex < 0 || arg != args[expiryIndex + 1]),
  );
  for (final deviceId in deviceIds) {
    final normalized = deviceId.trim().toUpperCase();
    if (normalized.length < 8) {
      stdout.writeln('$deviceId: invalid device ID');
      continue;
    }
    final license = planName == 'lifetime'
        ? EntitlementService.generateDeviceLicense(normalized)
        : EntitlementService.generateTimedDeviceLicense(
            deviceId: normalized,
            plan: planName == 'yearly'
                ? BillingPlan.proYearly
                : BillingPlan.proMonthly,
            endsAt:
                expiry ??
                DateTime.now().toUtc().add(
                  Duration(days: planName == 'yearly' ? 365 : 30),
                ),
          );
    stdout.writeln('$normalized => $license');
  }
}
