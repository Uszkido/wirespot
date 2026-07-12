import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/vpn/vpn_statistics.dart';
import '../../../core/vpn/vpn_status.dart';
import '../domain/entities/wireguard_settings.dart';

final wireGuardSettingsProvider =
    FutureProvider.autoDispose<WireGuardSettings>((ref) {
      return ref.watch(wireGuardSettingsServiceProvider).load();
    });

final wireGuardStatusProvider = FutureProvider.autoDispose<VpnStatus>((ref) {
  return ref.watch(wireGuardVpnServiceProvider).currentStatus();
});

final wireGuardStatusStreamProvider = StreamProvider.autoDispose<VpnStatus>((
  ref,
) {
  return ref.watch(wireGuardVpnServiceProvider).watchStatus();
});

final wireGuardStatisticsProvider =
    FutureProvider.autoDispose<VpnStatistics>((ref) {
      return ref.watch(wireGuardVpnServiceProvider).statistics();
    });

final wireGuardLogsProvider = FutureProvider.autoDispose<List<String>>((ref) {
  return ref.watch(wireGuardVpnServiceProvider).logs();
});
