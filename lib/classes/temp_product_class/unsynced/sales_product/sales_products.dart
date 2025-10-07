import 'package:hive/hive.dart';
part 'sales_products.g.dart';

@HiveType(typeId: 28)
class SalesProducts extends HiveObject {
  @HiveField(0)
  double quantity;
  @HiveField(1)
  final String productUuid;

  SalesProducts({
    required this.quantity,
    required this.productUuid,
  });
}
