import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/production_materials_usage.dart';
part 'updated_production_materials_usage.g.dart';

@HiveType(typeId: 124)
class UpdatedProductionMaterialsUsage extends HiveObject {
  @HiveField(0)
  final ProductionMaterialsUsage
  updatedProductionMaterialsUsage;

  UpdatedProductionMaterialsUsage({
    required this.updatedProductionMaterialsUsage,
  });
}
