// import 'package:flutter/material.dart';
// import 'package:stockall/classes/temp_categories/category_class.dart';
// import 'package:stockall/classes/temp_main_cart/temp_main_cart.dart';
// import 'package:stockall/constants/functions.dart';
// import 'package:stockall/main.dart';

// class CartProvider extends ChangeNotifier {
//   static final CartProvider _instance =
//       CartProvider._internal();
//   factory CartProvider() => _instance;
//   CartProvider._internal();
//   void selectFistMainCart() {
//     selectMainCart(mainCartQueue.first.mainCartId!);
//     toggleSubStaffSelectionMobile(false);
//     notifyListeners();
//   }

//   String cartIdCache = '';
//   String mainCartIdCache = '';

//   TempMainCart currentMainCart() {
//     // try {
//     return mainCartQueue.firstWhere(
//       (cart) => cart.mainCartId == mainCartIdCache,
//     );
//     // } catch (e) {
//     //   await mainLocalLog('Error : ${e.toString()}');
//     //   return TempMainCart(
//     //     cartQueue: [],
//     //     mainCartId: 'mainCartId',
//     //   );
//     // }
//   }
//   List<TempMainCart> mainCartQueue = [];

//   String initCart() {
//     try {
//       var mainCartId = uuidGen();
//       await mainLocalLog('Main Cart Id: $mainCartId');
//       await mainLocalLog('Main Cart Length: ${mainCartQueue.length}');

//       mainCartQueue.add(
//         TempMainCart(cartQueue: [], mainCartId: mainCartId),
//       );
//       await mainLocalLog(
//         'First Main Cart Id: ${mainCartQueue.first.mainCartId}',
//       );
//       await mainLocalLog('Main Cart Length: ${mainCartQueue.length}');

//       mainCartIdCache = mainCartId;
//       await mainLocalLog('Main Cart Id Cached: $mainCartIdCache');

//       var cartId = uuidGen();
//       await mainLocalLog('Normal Cart Id: $cartId');
//       await mainLocalLog(
//         'Normal Cart Length: ${mainCartQueue.first.cartQueue.length}',
//       );
//       mainCartQueue.first.cartQueue.add(
//         TempCart(
//           departmentName:
//               returnDepartmentProvider()
//                   .currentDepartment()
//                   ?.name,
//           departmentUuid:
//               returnDepartmentProvider()
//                   .currentDepartment()
//                   ?.uuid,
//           staffId: currentUser().userId,
//           staffName:
//               "${currentUser().name} ${currentUser().lastName}",
//           cartItems: [],
//           isInvoice: false,
//           id: cartId,
//         ),
//       );
//       await mainLocalLog(
//         'First Normal Cart Id: ${mainCartQueue.first.cartQueue.first.id}',
//       );
//       await mainLocalLog(
//         'Normal Cart Length: ${mainCartQueue.first.cartQueue.length}',
//       );
//       cartIdCache = cartId;
//       await mainLocalLog('Normal Cart Id Cached: $cartIdCache');

//       notifyListeners();
//       return cartId;
//     } catch (e) {
//       await mainLocalLog('Error Initializing Cart: ${e.toString()}');
//       return '';
//     }
//   }
// }
