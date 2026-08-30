import 'package:hive/hive.dart';
part 'deleted_orders.g.dart';

@HiveType(typeId: 136)
class DeletedOrders extends HiveObject {
  @HiveField(0)
  final String orderUuid;

  DeletedOrders({required this.orderUuid});
}
