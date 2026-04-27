import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
part 'created_purchases.g.dart';

@HiveType(typeId: 74)
class CreatedPurchases extends HiveObject {
  @HiveField(0)
  final TempPurchase purchase;

  CreatedPurchases({required this.purchase});
}
