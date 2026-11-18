import 'package:hive/hive.dart';

part 'deleted_expense_category.g.dart';

@HiveType(typeId: 157)
class DeletedExpenseCategory extends HiveObject {
  @HiveField(0)
  final String categoryUuid;

  @HiveField(1)
  final int shopId;

  DeletedExpenseCategory({
    required this.categoryUuid,
    required this.shopId,
  });
}
