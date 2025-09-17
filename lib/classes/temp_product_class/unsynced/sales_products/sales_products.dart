import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
part 'sales_products.g.dart';

@HiveType(typeId: 12)
class SalesProducts extends HiveObject {
  @HiveField(0)
  final TempProductClass product;

  @HiveField(1)
  final DateTime date;

  SalesProducts({
    required this.product,
    required this.date,
  });
}
