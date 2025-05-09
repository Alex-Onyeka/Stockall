class TempProductClass {
  int id;
  final String name;
  final String? desc;
  final String? brand;
  final String category;
  final String? barcode;
  final String unit;
  final bool isRefundable;
  final String? color;
  final String? sizeType;
  final String? size;
  final double costPrice;
  final double sellingPrice;
  final double? discount;
  final double quantity;

  TempProductClass({
    required this.id,
    required this.name,
    this.desc,
    this.brand,
    required this.category,
    this.barcode,
    required this.unit,
    required this.isRefundable,
    this.color,
    this.sizeType,
    this.size,
    required this.costPrice,
    required this.sellingPrice,
    this.discount,
    required this.quantity,
  });
}
