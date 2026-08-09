import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
part 'updated_production_item.g.dart';

@HiveType(typeId: 112)
class UpdatedProductionItem extends HiveObject {
  @HiveField(0)
  final ProductionItem productionItem;

  @HiveField(1)
  final bool includeQuantity;

  UpdatedProductionItem({
    required this.productionItem,
    this.includeQuantity = false,
  });
}
