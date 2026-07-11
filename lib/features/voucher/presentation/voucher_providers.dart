import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/di/providers.dart';
import '../domain/entities/voucher_entity.dart';

final selectedVoucherRouterIdProvider = StateProvider<String?>((ref) => null);

final voucherHistoryProvider = FutureProvider.autoDispose
    .family<List<VoucherEntity>, String>((ref, routerId) {
  return ref.watch(voucherRepositoryProvider).getVoucherHistory(
        routerId: routerId,
      );
});
