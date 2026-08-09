import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';

part 'created_production_item_history.g.dart';

@HiveType(typeId: 115)
class CreatedProductionItemHistory {
  @HiveField(0)
  final ProductionItemHistory productionItemHistory;
  CreatedProductionItemHistory({
    required this.productionItemHistory,
  });
}
