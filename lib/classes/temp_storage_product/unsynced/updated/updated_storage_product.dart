import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
part 'updated_storage_product.g.dart';

@HiveType(typeId: 69)
class UpdatedStorageProduct extends HiveObject {
  @HiveField(0)
  TempStorageProducts updatedStorageProduct;

  UpdatedStorageProduct({
    required this.updatedStorageProduct,
  });
}
