import '../entities/sale_entity.dart';

abstract interface class ReportRepository {
  Future<void> recordSale(SaleEntity sale);

  Future<List<SaleEntity>> getSales({
    String? routerId,
    DateTime? from,
    DateTime? to,
  });
}
