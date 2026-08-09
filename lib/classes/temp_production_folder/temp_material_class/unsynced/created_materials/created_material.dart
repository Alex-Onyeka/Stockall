import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
part 'created_material.g.dart';

@HiveType(typeId: 105)
class CreatedMaterial extends HiveObject {
  @HiveField(0)
  final MaterialClass material;

  @HiveField(1)
  final bool? includeQuantity;

  CreatedMaterial({
    required this.material,
    this.includeQuantity = false,
  });
}
