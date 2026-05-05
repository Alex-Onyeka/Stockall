// import 'package:hive/hive.dart';
// import 'package:stockall/classes/purchase_payments/purchase_payments.dart';
// import 'package:stockall/local_database/purchase_payments/unsync_funcs/created/created_purchase_payments_func.dart';
// import 'package:stockall/local_database/purchase_payments/unsync_funcs/deleted/deleted_purchase_payments_func.dart';

// class PurchasePaymentsFunc {
//   static final PurchasePaymentsFunc instance =
//       PurchasePaymentsFunc._internal();
//   factory PurchasePaymentsFunc() => instance;
//   PurchasePaymentsFunc._internal();
//   late Box<PurchasePayments> purchasePaymentsBox;
//   final String purchasePaymentsBoxName =
//       'purchasePaymentsBoxStockall';

//   Future<void> init() async {
//     Hive.registerAdapter(PurchasePaymentsAdapter());
//     purchasePaymentsBox = await Hive.openBox(
//       purchasePaymentsBoxName,
//     );
//     await CreatedPurchasePaymentsFunc().init();
//     await DeletedPurchasePaymentsFunc().init();
//     print('Purchase Payments Box Initialized');
//   }

//   List<PurchasePayments> getPurchasePayments() {
//     List<PurchasePayments> purchasePayments =
//         purchasePaymentsBox.values.toList();
//     purchasePayments.sort(
//       (a, b) => b.createdAt.compareTo(a.createdAt),
//     );
//     return purchasePayments;
//   }

//   Future<int> insertAllPurchasePayments(
//     List<PurchasePayments> purchasePayments,
//   ) async {
//     await clearPurchasePayments();
//     try {
//       for (var rec in purchasePayments) {
//         await purchasePaymentsBox.put(rec.uuid, rec);
//       }
//       print('Offline Purchase Payments Success');
//       return 1;
//     } catch (e) {
//       print(
//         'Offline Purchase Payments Failed: ${e.toString()}',
//       );
//       return 0;
//     }
//   }

//   Future<int> createPurchasePayment(
//     PurchasePayments purchasePayment,
//   ) async {
//     try {
//       await purchasePaymentsBox.put(
//         purchasePayment.uuid,
//         purchasePayment,
//       );
//       print('Offline Purchase Payment Created');
//       return 1;
//     } catch (e) {
//       print(
//         'Offline Purchase Payment Failed: ${e.toString()}',
//       );
//       return 0;
//     }
//   }

//   Future<int> deletePurchasePayment(String uuid) async {
//     try {
//       await purchasePaymentsBox.delete(uuid);
//       print('Offline Purchase Payment Deleted');
//       return 1;
//     } catch (e) {
//       print(
//         'Offline Purchase Payment Delete Failed: ${e.toString()}',
//       );
//       return 0;
//     }
//   }

//   Future<int> clearPurchasePayments() async {
//     try {
//       await purchasePaymentsBox.clear();
//       print('Offline Purchase Payments Cleared');
//       return 1;
//     } catch (e) {
//       print(
//         'Offline Purchase Payments Clear Failed: ${e.toString()}',
//       );
//       return 0;
//     }
//   }
// }
