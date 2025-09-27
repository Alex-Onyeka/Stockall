import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
part 'created_customers.g.dart';

@HiveType(typeId: 17)
class CreatedCustomers extends HiveObject {
  @HiveField(0)
  final TempCustomersClass customer;

  CreatedCustomers({required this.customer});
}
