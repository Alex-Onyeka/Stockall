import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
part 'updated_orders.g.dart';

@HiveType(typeId: 137)
class UpdatedOrders extends HiveObject {
  @HiveField(0)
  final Orders order;

  UpdatedOrders({required this.order});
}
