import 'package:hive/hive.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
part 'shop_owner.g.dart';

@HiveType(typeId: 33)
class ShopOwner extends HiveObject {
  @HiveField(0)
  final TempUserClass? shopOwner;

  ShopOwner({required this.shopOwner});
}
