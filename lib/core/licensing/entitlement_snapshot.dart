import 'premium_feature.dart';

class EntitlementSnapshot {
  const EntitlementSnapshot({required this.isPremium, this.licenseKey});

  final bool isPremium;
  final String? licenseKey;

  bool allows(PremiumFeature feature) => isPremium;
}
