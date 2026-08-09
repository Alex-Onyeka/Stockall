import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record.dart';
part 'updated_production_record.g.dart';

@HiveType(typeId: 103)
class UpdatedProductionRecord extends HiveObject {
  @HiveField(0)
  final ProductionRecord updatedProductionRecord;

  UpdatedProductionRecord({
    required this.updatedProductionRecord,
  });
}
