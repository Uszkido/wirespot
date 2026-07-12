import 'premium_feature.dart';

class EntitlementSnapshot {
  const EntitlementSnapshot({
    required this.isPremium,
    required this.trialStartedAt,
    required this.trialEndsAt,
    required this.now,
    required this.deviceId,
    this.licenseKey,
  });

  final bool isPremium;
  final DateTime trialStartedAt;
  final DateTime trialEndsAt;
  final DateTime now;
  final String deviceId;
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
      return 'Licensed';
    }
    if (isTrialActive) {
      return 'Trial: $trialDaysRemaining days left';
    }
    return 'License required';
  }

  bool allows(PremiumFeature feature) => hasAccess;
}
