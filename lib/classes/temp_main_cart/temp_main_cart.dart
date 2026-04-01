import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_sub_staff/temp_sub_staff.dart';

part 'temp_main_cart.g.dart';

@HiveType(typeId: 70)
class TempMainCart extends HiveObject {
  @HiveField(0)
  List<TempCart> cartQueue;

  @HiveField(1)
  TempSubStaff? subStaff;

  @HiveField(2)
  String? mainCartId;

  TempMainCart({
    required this.cartQueue,
    required this.mainCartId,
    this.subStaff,
  });

  String? cartName() {
    return subStaff?.staffName;
  }
}
