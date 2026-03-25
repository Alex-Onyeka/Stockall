import 'package:hive/hive.dart';
part 'deleted_category.g.dart';

@HiveType(typeId: 63)
class DeletedCategory extends HiveObject {
  @HiveField(0)
  final String categoryUuid;

  @HiveField(1)
  final int shopId;

  DeletedCategory({
    required this.categoryUuid,
    required this.shopId,
  });
}
