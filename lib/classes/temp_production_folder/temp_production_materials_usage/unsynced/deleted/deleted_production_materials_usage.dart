import 'package:hive/hive.dart';
part 'deleted_production_materials_usage.g.dart';

@HiveType(typeId: 123)
class DeletedProductionMaterialsUsage extends HiveObject {
  @HiveField(0)
  final String materialsUsageUuid;

  DeletedProductionMaterialsUsage({
    required this.materialsUsageUuid,
  });
}
