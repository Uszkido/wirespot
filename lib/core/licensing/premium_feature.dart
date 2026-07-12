enum PremiumFeature {
  multipleRouters,
  wireGuardRemote,
  batchVouchers,
  ticketTemplates,
  bluetoothPrinting,
  reportsExport,
  scheduler,
  advancedProfiles,
  advancedVoucherEncoding,
}

extension PremiumFeatureLabel on PremiumFeature {
  String get label {
    return switch (this) {
      PremiumFeature.multipleRouters => 'Multiple routers',
      PremiumFeature.wireGuardRemote => 'WireGuard remote management',
      PremiumFeature.batchVouchers => 'Batch vouchers',
      PremiumFeature.ticketTemplates => 'Ticket templates',
      PremiumFeature.bluetoothPrinting => 'Bluetooth printing',
      PremiumFeature.reportsExport => 'Report export',
      PremiumFeature.scheduler => 'Scheduler',
      PremiumFeature.advancedProfiles => 'Advanced profiles',
      PremiumFeature.advancedVoucherEncoding => 'Advanced voucher encoding',
    };
  }
}
