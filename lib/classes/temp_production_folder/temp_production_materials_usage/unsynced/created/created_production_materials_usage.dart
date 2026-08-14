import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/production_materials_usage.dart';
part 'created_production_materials_usage.g.dart';

@HiveType(typeId: 122)
class CreatedProductionMaterialsUsage extends HiveObject {
  @HiveField(0)
  final ProductionMaterialsUsage
  createdProductionMaterialsUsage;

  CreatedProductionMaterialsUsage({
    required this.createdProductionMaterialsUsage,
  });
}
