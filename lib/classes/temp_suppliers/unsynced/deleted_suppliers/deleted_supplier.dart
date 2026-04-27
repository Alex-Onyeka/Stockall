import 'package:hive/hive.dart';
part 'deleted_supplier.g.dart';

@HiveType(typeId: 81)
class DeletedSupplier extends HiveObject {
  @HiveField(0)
  final String supplierUuid;

  DeletedSupplier({required this.supplierUuid});
}
