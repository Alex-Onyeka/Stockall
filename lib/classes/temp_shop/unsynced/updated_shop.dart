import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
part 'updated_shop.g.dart';

@HiveType(typeId: 27)
class UpdatedShop extends HiveObject {
  @HiveField(0)
  TempShopClass shop;

  UpdatedShop({required this.shop});
}
