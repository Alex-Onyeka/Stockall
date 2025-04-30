class Product {
  final int productId;
  final int? shopId;
  final String sku;
  final String? barcode;
  final DateTime createdAt;
  final String name;
  final String? category;
  final String? brand;
  final int? costPrice;
  final int? sellingPrice;
  final bool inStock;
  final Map<String, dynamic>? unit;
  final String? color;
  final double? size;
  final Map<String, dynamic>? dimension;
  final double? quantity;
  final String? sizeType;
  final double? discount;
  final bool isRefundable;

  Product({
    required this.productId,
    this.shopId,
    required this.sku,
    this.barcode,
    required this.createdAt,
    required this.name,
    this.category,
    this.brand,
    this.costPrice,
    this.sellingPrice,
    required this.inStock,
    this.unit,
    this.color,
    this.size,
    this.dimension,
    this.quantity,
    this.sizeType,
    this.discount,
    required this.isRefundable,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'],
      shopId: json['shop_id'],
      sku: json['SKU'],
      barcode: json['barcode'],
      createdAt: DateTime.parse(json['created_at']),
      name: json['name'],
      category: json['category'],
      brand: json['brand'],
      costPrice: json['cost_price'],
      sellingPrice: json['selling_price'],
      inStock: json['in_stock'],
      unit:
          json['unit'] != null
              ? Map<String, dynamic>.from(json['unit'])
              : null,
      color: json['color'],
      size: (json['size'] as num?)?.toDouble(),
      dimension:
          json['dimension'] != null
              ? Map<String, dynamic>.from(json['dimension'])
              : null,
      quantity: (json['quantity'] as num?)?.toDouble(),
      sizeType: json['size_type'],
      discount: (json['discount'] as num?)?.toDouble(),
      isRefundable: json['is_refundable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'shop_id': shopId,
      'SKU': sku,
      'barcode': barcode,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'category': category,
      'brand': brand,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'in_stock': inStock,
      'unit': unit,
      'color': color,
      'size': size,
      'dimension': dimension,
      'quantity': quantity,
      'size_type': sizeType,
      'discount': discount,
      'is_refundable': isRefundable,
    };
  }
}
