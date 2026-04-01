import 'package:hive/hive.dart';
part 'deleted_storage_product.g.dart';

@HiveType(typeId: 68)
class DeletedStorageProduct extends HiveObject {
  @HiveField(0)
  final String storageProducteUuid;

  DeletedStorageProduct({
    required this.storageProducteUuid,
  });
}
