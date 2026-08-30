import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
part 'created_orders.g.dart';

@HiveType(typeId: 135)
class CreatedOrders extends HiveObject {
  @HiveField(0)
  final Orders order;

  CreatedOrders({required this.order});
}
