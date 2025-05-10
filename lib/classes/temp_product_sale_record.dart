class TempProductSaleRecord {
  final int productRecordId;
  final DateTime createdAt;
  final int productId;
  final int shopId;
  final String staffId;
  final int? customerId;
  final String staffName;
  final int recepitId;
  final double quantity;
  final double revenue;

  TempProductSaleRecord({
    required this.productRecordId,
    required this.createdAt,
    required this.productId,
    required this.shopId,
    required this.staffId,
    this.customerId,
    required this.staffName,
    required this.recepitId,
    required this.quantity,
    required this.revenue,
  });
}
