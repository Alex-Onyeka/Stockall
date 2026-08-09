import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record.dart';
part 'created_production_record.g.dart';

@HiveType(typeId: 101)
class CreatedProductionRecord extends HiveObject {
  @HiveField(0)
  final ProductionRecord createdProductionRecord;

  CreatedProductionRecord({
    required this.createdProductionRecord,
  });
}
