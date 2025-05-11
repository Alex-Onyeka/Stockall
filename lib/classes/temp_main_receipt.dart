class TempMainReceipt {
  final int id;
  final String? barcode;
  final DateTime createdAt;
  final int? shopId;
  final String? staffId;
  final String? staffName;
  final int? customerId;

  TempMainReceipt({
    required this.id,
    this.barcode,
    required this.createdAt,
    this.shopId,
    this.staffId,
    this.staffName,
    this.customerId,
  });
}
