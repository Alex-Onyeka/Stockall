class TempProductClass {
  int id;
  final String name;
  final int shopId;
  String? desc;
  String? brand;
  String category;
  final String? barcode;
  String unit;
  bool isRefundable;
  String? color;
  String? sizeType;
  String? size;
  double costPrice;
  double sellingPrice;
  double? discount;
  double quantity;

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
    required this.shopId,
  });
}
