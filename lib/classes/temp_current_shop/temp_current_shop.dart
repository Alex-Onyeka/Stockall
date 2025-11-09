import 'package:hive/hive.dart';

part 'temp_current_shop.g.dart';

@HiveType(typeId: 30)
class TempCurrentShop {
  @HiveField(0)
  final int currentShopId;

  TempCurrentShop({required this.currentShopId});
}
