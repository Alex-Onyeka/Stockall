import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_sub_staff/temp_sub_staff.dart';

class TempMainCart {
  List<TempCart> cartQueue;
  TempSubStaff? subStaff;
  // String? mainCartName;
  String? mainCartId;

  TempMainCart({
    required this.cartQueue,
    // this.mainCartName,
    required this.mainCartId,
    this.subStaff,
  });

  // String cartId() {
  //   var id = uuidGen();
  //   return id;
  // }

  String? cartName() {
    return subStaff?.staffName;
  }
}
