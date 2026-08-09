import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
part 'updated_material.g.dart';

@HiveType(typeId: 108)
class UpdatedMaterial extends HiveObject {
  @HiveField(0)
  final MaterialClass material;

  @HiveField(1)
  final bool includeQuantity;

  UpdatedMaterial({
    required this.material,
    this.includeQuantity = false,
  });
}
