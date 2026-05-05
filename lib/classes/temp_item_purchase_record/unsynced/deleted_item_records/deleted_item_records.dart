import 'package:hive/hive.dart';
part 'deleted_item_records.g.dart';

@HiveType(typeId: 84)
class DeletedItemRecords extends HiveObject {
  @HiveField(0)
  final String recordUuid;

  DeletedItemRecords({required this.recordUuid});
}
