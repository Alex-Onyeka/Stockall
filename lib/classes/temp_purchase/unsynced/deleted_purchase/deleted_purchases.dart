import 'package:hive/hive.dart';
part 'deleted_purchases.g.dart';

@HiveType(typeId: 75)
class DeletedPurchases extends HiveObject {
  @HiveField(0)
  final String purchaseUuid;

  DeletedPurchases({required this.purchaseUuid});
}
