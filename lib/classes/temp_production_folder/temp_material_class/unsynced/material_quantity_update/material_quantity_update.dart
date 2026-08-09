import 'package:hive/hive.dart';
part 'material_quantity_update.g.dart';

@HiveType(typeId: 107)
class MaterialQuantityUpdate extends HiveObject {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime? createdAt;

  @HiveField(2)
  double quantity;

  @HiveField(3)
  final String materialUuid;

  @HiveField(4)
  bool isIncrement;

  MaterialQuantityUpdate({
    this.uuid,
    this.createdAt,
    required this.quantity,
    required this.materialUuid,
    this.isIncrement = true,
  });
}
