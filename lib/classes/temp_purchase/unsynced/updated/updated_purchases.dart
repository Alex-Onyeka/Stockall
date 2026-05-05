import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
part 'updated_purchases.g.dart';

@HiveType(typeId: 76)
class UpdatedPurchases extends HiveObject {
  @HiveField(0)
  final TempPurchase purchase;

  UpdatedPurchases({required this.purchase});
}
