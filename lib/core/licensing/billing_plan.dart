enum BillingPlan {
  trial(
    id: 'trial',
    title: '7-day trial',
    description: 'Full access for first-time devices.',
    monthlyPriceGuide: 'Free',
  ),
  smallMonthly(
    id: 'wirespot_small_monthly',
    title: 'Small monthly',
    description: 'Single-site operators, one primary router, core tools.',
    monthlyPriceGuide: 'NGN 5,000 / month',
  ),
  proMonthly(
    id: 'wirespot_pro_monthly',
    title: 'Pro monthly',
    description: 'Multi-router hotspot operations, VPN, printing, reports.',
    monthlyPriceGuide: 'NGN 10,000 / month',
  ),
  proYearly(
    id: 'wirespot_pro_yearly',
    title: 'Pro yearly',
    description: 'Best value for serious operators and small ISPs.',
    monthlyPriceGuide: 'NGN 100,000 / year',
  ),
  lifetimeDevice(
    id: 'wirespot_lifetime_device',
    title: 'Lifetime device',
    description: 'Offline device-bound license for direct installations.',
    monthlyPriceGuide: 'NGN 200,000 one-time',
  );

  const BillingPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.monthlyPriceGuide,
  });

  final String id;
  final String title;
  final String description;
  final String monthlyPriceGuide;

  static BillingPlan fromId(String? id) {
    return BillingPlan.values.firstWhere(
      (plan) => plan.id == id,
      orElse: () => BillingPlan.trial,
    );
  }
}

enum EntitlementSource {
  trial,
  deviceLicense,
  playBilling,
  serverLicense,
  development,
  none,
}

extension EntitlementSourceLabel on EntitlementSource {
  String get label {
    return switch (this) {
      EntitlementSource.trial => 'Trial',
      EntitlementSource.deviceLicense => 'Device license',
      EntitlementSource.playBilling => 'Google Play',
      EntitlementSource.serverLicense => 'Server license',
      EntitlementSource.development => 'Development',
      EntitlementSource.none => 'None',
    };
  }
}
