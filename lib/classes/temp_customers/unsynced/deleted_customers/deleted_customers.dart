import 'package:hive/hive.dart';
part 'deleted_customers.g.dart';

@HiveType(typeId: 18)
class DeletedCustomers extends HiveObject {
  @HiveField(0)
  final String customerUuid;

  @HiveField(1)
  final int shopId;

  DeletedCustomers({
    required this.customerUuid,
    required this.shopId,
  });
}
