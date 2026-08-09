import 'package:hive/hive.dart';
part 'production_item_quantity_update.g.dart';

@HiveType(typeId: 113)
class ProductionItemQuantityUpdate extends HiveObject {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime? createdAt;

  @HiveField(2)
  double quantity;

  @HiveField(3)
  final String productionItemUuid;

  @HiveField(4)
  bool isIncrement;

  ProductionItemQuantityUpdate({
    this.uuid,
    this.createdAt,
    required this.quantity,
    required this.productionItemUuid,
    this.isIncrement = true,
  });
}
