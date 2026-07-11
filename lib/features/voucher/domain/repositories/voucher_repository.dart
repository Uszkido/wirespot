import '../entities/hotspot_profile_entity.dart';
import '../entities/voucher_entity.dart';

abstract interface class VoucherRepository {
  Future<void> saveVoucher(VoucherEntity voucher);

  Future<List<VoucherEntity>> getVoucherHistory({
    String? routerId,
    DateTime? from,
    DateTime? to,
  });

  Future<void> saveProfile(HotspotProfileEntity profile);

  Future<List<HotspotProfileEntity>> getProfiles(String routerId);
}
