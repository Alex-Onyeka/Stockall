import 'package:hive/hive.dart';
part 'deleted_products.g.dart';

@HiveType(typeId: 10)
class DeletedProducts extends HiveObject {
  @HiveField(0)
  final int productid;

  @HiveField(1)
  final DateTime date;

  DeletedProducts({
    required this.productid,
    required this.date,
  });
}
