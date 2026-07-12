import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/entities/sale_entity.dart';
import '../domain/repositories/report_repository.dart';

class ReportLocalRepository implements ReportRepository {
  const ReportLocalRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> recordSale(SaleEntity sale) {
    return _database
        .into(_database.sales)
        .insertOnConflictUpdate(
          SalesCompanion.insert(
            id: sale.id,
            routerId: sale.routerId,
            amountMinor: sale.amountMinor,
            currency: Value(sale.currency),
            voucherId: Value(sale.voucherId),
            paymentMethod: Value(sale.paymentMethod),
            soldAt: Value(sale.soldAt),
            note: Value(sale.note),
          ),
        );
  }

  @override
  Future<List<SaleEntity>> getSales({
    String? routerId,
    DateTime? from,
    DateTime? to,
  }) async {
    final query = _database.select(_database.sales)
      ..orderBy([(table) => OrderingTerm.desc(table.soldAt)]);

    if (routerId != null) {
      query.where((table) => table.routerId.equals(routerId));
    }

    final records = await query.get();
    return records
        .where((record) => from == null || !record.soldAt.isBefore(from))
        .where((record) => to == null || !record.soldAt.isAfter(to))
        .map(_mapSale)
        .toList();
  }
}

SaleEntity _mapSale(SaleRecord record) {
  return SaleEntity(
    id: record.id,
    voucherId: record.voucherId,
    routerId: record.routerId,
    amountMinor: record.amountMinor,
    currency: record.currency,
    paymentMethod: record.paymentMethod,
    soldAt: record.soldAt,
    note: record.note,
  );
}
