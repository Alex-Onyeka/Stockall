import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
part 'created_storage_products.g.dart';

@HiveType(typeId: 67)
class CreatedStorageProducts extends HiveObject {
  @HiveField(0)
  final TempStorageProducts storageProduct;

  CreatedStorageProducts({required this.storageProduct});
}
