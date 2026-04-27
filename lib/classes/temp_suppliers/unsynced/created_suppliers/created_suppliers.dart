import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
part 'created_suppliers.g.dart';

@HiveType(typeId: 80)
class CreatedSuppliers extends HiveObject {
  @HiveField(0)
  final SuppliersClass supplier;

  CreatedSuppliers({required this.supplier});
}
