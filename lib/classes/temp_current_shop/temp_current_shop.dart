import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';

part 'temp_current_shop.g.dart';

@HiveType(typeId: 30)
class TempCurrentShop {
  @HiveField(0)
  final TempShopClass currentShop;

  TempCurrentShop({required this.currentShop});
}
