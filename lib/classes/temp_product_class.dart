class TempProductClass {
  int? id;
  String name;
  final int shopId;
  String? brand;
  DateTime? createdAt;
  String? category;
  String? barcode;
  String unit;
  bool isRefundable;
  String? color;
  String? sizeType;
  String? size;
  double costPrice;
  double sellingPrice;
  double? discount;
  DateTime? startDate;
  DateTime? endDate;
  double quantity;

  TempProductClass({
    this.id,
    required this.name,
    this.brand,
    this.category,
    this.barcode,
    required this.unit,
    required this.isRefundable,
    this.color,
    this.sizeType,
    this.size,
    required this.costPrice,
    required this.sellingPrice,
    this.discount,
    this.startDate,
    this.endDate,
    required this.quantity,
    required this.shopId,
    this.createdAt,
  });

  factory TempProductClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempProductClass(
      id: json['id'],
      name: json['name'],
      shopId: json['shop_id'],
      brand: json['brand'],
      category: json['category'],
      barcode: json['barcode'],
      unit: json['unit'],
      isRefundable: json['is_refundable'],
      color: json['color'],
      sizeType: json['size_type'],
      size: json['size'],
      costPrice: (json['cost_price'] as num).toDouble(),
      sellingPrice:
          (json['selling_price'] as num).toDouble(),
      discount:
          json['discount'] != null
              ? (json['discount'] as num).toDouble()
              : null,
      startDate:
          json['starting_date'] != null
              ? DateTime.parse(json['starting_date'])
              : null,

      endDate:
          json['ending_date'] != null
              ? DateTime.parse(json['ending_date'])
              : null,
      quantity: (json['quantity'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'shop_id': shopId,
      'brand': brand,
      'category': category,
      'barcode': barcode,
      'unit': unit,
      'is_refundable': isRefundable,
      'color': color,
      'size_type': sizeType,
      'size': size,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'discount': discount,
      'starting_date':
          startDate?.toIso8601String().split('T').first,
      'ending_date':
          endDate?.toIso8601String().split('T').first,

      'quantity': quantity,
    };
  }
}
