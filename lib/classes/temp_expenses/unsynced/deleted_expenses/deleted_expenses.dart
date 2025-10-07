import 'package:hive/hive.dart';
part 'deleted_expenses.g.dart';

@HiveType(typeId: 15)
class DeletedExpenses extends HiveObject {
  @HiveField(0)
  final String expensesUuid;

  @HiveField(1)
  final int shopId;

  DeletedExpenses({
    required this.expensesUuid,
    required this.shopId,
  });
}
