import 'package:hive/hive.dart';
part 'updated_purchases.g.dart';

@HiveType(typeId: 76)
class UpdatedPurchases extends HiveObject {
  @HiveField(0)
  String purchaseUuid;

  UpdatedPurchases({required this.purchaseUuid});
}
