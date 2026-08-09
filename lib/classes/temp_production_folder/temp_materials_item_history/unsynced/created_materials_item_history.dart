import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';

part 'created_materials_item_history.g.dart';

@HiveType(typeId: 116)
class CreatedMaterialsItemHistory {
  @HiveField(0)
  final MaterialsItemHistory createdMaterialsItemHistory;
  CreatedMaterialsItemHistory({
    required this.createdMaterialsItemHistory,
  });
}
