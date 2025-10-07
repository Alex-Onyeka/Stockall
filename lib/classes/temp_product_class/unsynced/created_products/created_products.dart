import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
part 'created_products.g.dart';

@HiveType(typeId: 9)
class CreatedProducts extends HiveObject {
  @HiveField(0)
  final TempProductClass product;

  CreatedProducts({required this.product});
}
