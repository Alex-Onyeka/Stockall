import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
part 'created_production_item.g.dart';

@HiveType(typeId: 110)
class CreatedProductionItem extends HiveObject {
  @HiveField(0)
  final ProductionItem productionItem;

  @HiveField(1)
  final bool? includeQuantity;

  CreatedProductionItem({
    required this.productionItem,
    this.includeQuantity = false,
  });
}
