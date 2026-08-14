import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_usage_cart/temp_materials_usage_cart_item/materials_usage_cart_item.dart';

part 'materials_usage_cart.g.dart';

@HiveType(typeId: 125)
class MaterialsUsageCart extends HiveObject {
  @HiveField(0)
  List<MaterialsUsageCartItem> cartItems;

  @HiveField(1)
  bool isEdit;

  @HiveField(2)
  String uuid;

  MaterialsUsageCart({
    required this.cartItems,
    required this.uuid,
    this.isEdit = false,
  });
}
