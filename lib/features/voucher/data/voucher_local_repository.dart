import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/storage/voucher_secret_store.dart';
import '../domain/entities/hotspot_profile_entity.dart';
import '../domain/entities/voucher_entity.dart';
import '../domain/repositories/voucher_repository.dart';

class VoucherLocalRepository implements VoucherRepository {
  const VoucherLocalRepository(this._database, this._secretStore);

  final AppDatabase _database;
  final VoucherSecretStore _secretStore;

  @override
  Future<void> saveVoucher(VoucherEntity voucher) async {
    await _database
        .into(_database.voucherHistory)
        .insertOnConflictUpdate(
          VoucherHistoryCompanion.insert(
            id: voucher.id,
            routerId: voucher.routerId,
            username: voucher.username,
            priceMinor: Value(voucher.priceMinor),
            currency: Value(voucher.currency),
            profileId: Value(voucher.profileId),
            hasPassword: Value(voucher.password != null),
            validityMinutes: Value(voucher.validityMinutes),
            generatedAt: Value(voucher.generatedAt),
            printedAt: Value(voucher.printedAt),
            soldAt: Value(voucher.soldAt),
            note: Value(voucher.note),
          ),
        );

    if (voucher.password != null) {
      await _secretStore.writePassword(voucher.id, voucher.password!);
      return;
    }

    await _secretStore.deletePassword(voucher.id);
  }

  @override
  Future<List<VoucherEntity>> getVoucherHistory({
    String? routerId,
    DateTime? from,
    DateTime? to,
  }) async {
    final query = _database.select(_database.voucherHistory)
      ..orderBy([(table) => OrderingTerm.desc(table.generatedAt)]);

    if (routerId != null) {
      query.where((table) => table.routerId.equals(routerId));
    }

    final records = await query.get();
    final filtered = records
        .where((record) => from == null || !record.generatedAt.isBefore(from))
        .where((record) => to == null || !record.generatedAt.isAfter(to))
        .toList();

    return Future.wait(filtered.map(_mapVoucher));
  }

  @override
  Future<void> saveProfile(HotspotProfileEntity profile) {
    final now = DateTime.now();
    return _database
        .into(_database.hotspotProfiles)
        .insertOnConflictUpdate(
          HotspotProfilesCompanion.insert(
            id: profile.id,
            routerId: profile.routerId,
            name: profile.name,
            rateLimit: Value(profile.rateLimit),
            validityMinutes: Value(profile.validityMinutes),
            priceMinor: Value(profile.priceMinor),
            currency: Value(profile.currency),
            updatedAt: Value(now),
          ),
        );
  }

  @override
  Future<List<HotspotProfileEntity>> getProfiles(String routerId) async {
    final records =
        await (_database.select(_database.hotspotProfiles)
              ..where((table) => table.routerId.equals(routerId))
              ..orderBy([(table) => OrderingTerm.asc(table.name)]))
            .get();
    return records.map(_mapProfile).toList();
  }

  Future<VoucherEntity> _mapVoucher(VoucherRecord record) async {
    return VoucherEntity(
      id: record.id,
      routerId: record.routerId,
      profileId: record.profileId,
      username: record.username,
      password: record.hasPassword
          ? await _secretStore.readPassword(record.id)
          : null,
      priceMinor: record.priceMinor,
      currency: record.currency,
      validityMinutes: record.validityMinutes,
      generatedAt: record.generatedAt,
      printedAt: record.printedAt,
      soldAt: record.soldAt,
      note: record.note,
    );
  }
}

HotspotProfileEntity _mapProfile(HotspotProfileRecord record) {
  return HotspotProfileEntity(
    id: record.id,
    routerId: record.routerId,
    name: record.name,
    rateLimit: record.rateLimit,
    validityMinutes: record.validityMinutes,
    priceMinor: record.priceMinor,
    currency: record.currency,
  );
}
