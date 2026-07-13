import 'premium_feature.dart';
import 'billing_plan.dart';

class EntitlementSnapshot {
  const EntitlementSnapshot({
    required this.isPremium,
    required this.trialStartedAt,
    required this.trialEndsAt,
    required this.now,
    required this.deviceId,
    this.source = EntitlementSource.none,
    this.plan = BillingPlan.trial,
    this.entitlementEndsAt,
    this.licenseKey,
  });

  final bool isPremium;
  final DateTime trialStartedAt;
  final DateTime trialEndsAt;
  final DateTime now;
  final String deviceId;
  final EntitlementSource source;
  final BillingPlan plan;
  final DateTime? entitlementEndsAt;
  final String? licenseKey;

  bool get isTrialActive => now.isBefore(trialEndsAt);

  bool get hasAccess => isPremium || isTrialActive;

  bool get requiresLicense => !hasAccess;

  int get trialDaysRemaining {
    if (!isTrialActive) {
      return 0;
    }
    final remaining = trialEndsAt.difference(now);
    return (remaining.inHours / 24).ceil().clamp(1, 7).toInt();
  }

  String get statusLabel {
    if (isPremium) {
      return entitlementEndsAt == null
          ? 'Licensed'
          : 'Licensed until ${_date(entitlementEndsAt!)}';
    }
    if (isTrialActive) {
      return 'Trial: $trialDaysRemaining days left';
    }
    return 'License required';
  }

  String get planLabel {
    if (isPremium) {
      return '${plan.title} - ${source.label}';
    }
    if (isTrialActive) {
      return BillingPlan.trial.title;
    }
    return 'No active plan';
  }

  bool allows(PremiumFeature feature) => hasAccess;

  String _date(DateTime value) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}
