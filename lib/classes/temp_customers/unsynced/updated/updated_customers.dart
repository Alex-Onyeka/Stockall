import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
part 'updated_customers.g.dart';

@HiveType(typeId: 19)
class UpdatedCustomers extends HiveObject {
  @HiveField(0)
  TempCustomersClass customer;

  UpdatedCustomers({required this.customer});
}
