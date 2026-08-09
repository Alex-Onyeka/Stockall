import 'package:hive/hive.dart';
part 'deleted_production_record.g.dart';

@HiveType(typeId: 102)
class DeletedProductionRecord extends HiveObject {
  @HiveField(0)
  final String productionRecordUuid;

  DeletedProductionRecord({
    required this.productionRecordUuid,
  });
}
