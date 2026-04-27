import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
part 'updated_suppliers.g.dart';

@HiveType(typeId: 82)
class UpdatedSuppliers extends HiveObject {
  @HiveField(0)
  SuppliersClass suppliers;

  UpdatedSuppliers({required this.suppliers});
}
