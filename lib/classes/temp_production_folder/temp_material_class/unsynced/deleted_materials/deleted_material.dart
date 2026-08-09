import 'package:hive/hive.dart';
part 'deleted_material.g.dart';

@HiveType(typeId: 106)
class DeletedMaterial extends HiveObject {
  @HiveField(0)
  final String materialUuid;

  DeletedMaterial({required this.materialUuid});
}
