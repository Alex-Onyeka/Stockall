import 'package:hive/hive.dart';
part 'deleted_waybills.g.dart';

@HiveType(typeId: 88)
class DeletedWaybills extends HiveObject {
  @HiveField(0)
  final String waybillUuid;

  DeletedWaybills({required this.waybillUuid});
}
