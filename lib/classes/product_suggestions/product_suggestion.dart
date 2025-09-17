import 'package:hive/hive.dart';

part 'product_suggestion.g.dart';

@HiveType(typeId: 8)
class ProductSuggestion {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  final String? name;

  @HiveField(3)
  final double? costPrice;

  @HiveField(4)
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
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
      name: json['name'] as String?,
      costPrice: (json['cost_price'] as num?)?.toDouble(),
      shopId: json['shop_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'cost_price': costPrice,
      'shop_id': shopId,
    };
  }
}
