class ProductSuggestion {
  final int? id;
  final DateTime createdAt;
  final String? name;
  final double? costPrice;
  final int shopId;

  ProductSuggestion({
    this.id,
    required this.createdAt,
    this.name,
    this.costPrice,
    required this.shopId,
  });

  factory ProductSuggestion.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductSuggestion(
      id: json['id'] as int?,
      createdAt: DateTime.parse(json['created_at']),
      name: json['name'],
      costPrice: (json['cost_price'] as num?)?.toDouble(),
      shopId: json['shop_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'cost_price': costPrice,
      'shop_id': shopId,
    };
  }
}
