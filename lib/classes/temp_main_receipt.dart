class TempMainReceipt {
  final int id;
  final String? barcode;
  final DateTime createdAt;
  final int shopId;
  final String staffId;
  final String staffName;
  final int? customerId;
  final String paymentMethod;
  final double cashAlt;
  final double bank;

  TempMainReceipt({
    required this.id,
    this.barcode,
    required this.createdAt,
    required this.shopId,
    required this.staffId,
    required this.staffName,
    this.customerId,
    required this.paymentMethod,
    required this.bank,
    required this.cashAlt,
  });
}
