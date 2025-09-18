import 'package:hive/hive.dart';
part 'sales_products.g.dart';

@HiveType(typeId: 12)
class SalesProducts extends HiveObject {
  @HiveField(0)
  final String productUuid;
  int? quantity;

  // @HiveField(1)
  // final DateTime date;

  SalesProducts({required this.productUuid, this.quantity});
}
