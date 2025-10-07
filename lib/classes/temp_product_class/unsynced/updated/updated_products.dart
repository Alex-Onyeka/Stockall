import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
part 'updated_products.g.dart';

@HiveType(typeId: 11)
class UpdatedProducts extends HiveObject {
  @HiveField(0)
  TempProductClass product;

  UpdatedProducts({required this.product});
}
