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
//     await mainLocalLog('Purchase Payments Box Initialized');
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
//       await mainLocalLog('Offline Purchase Payments Success');
//       return 1;
//     } catch (e) {
//       await mainLocalLog(
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
//       await mainLocalLog('Offline Purchase Payment Created');
//       return 1;
//     } catch (e) {
//       await mainLocalLog(
//         'Offline Purchase Payment Failed: ${e.toString()}',
//       );
//       return 0;
//     }
//   }

//   Future<int> deletePurchasePayment(String uuid) async {
//     try {
//       await purchasePaymentsBox.delete(uuid);
//       await mainLocalLog('Offline Purchase Payment Deleted');
//       return 1;
//     } catch (e) {
//       await mainLocalLog(
//         'Offline Purchase Payment Delete Failed: ${e.toString()}',
//       );
//       return 0;
//     }
//   }

//   Future<int> clearPurchasePayments() async {
//     try {
//       await purchasePaymentsBox.clear();
//       await mainLocalLog('Offline Purchase Payments Cleared');
//       return 1;
//     } catch (e) {
//       await mainLocalLog(
//         'Offline Purchase Payments Clear Failed: ${e.toString()}',
//       );
//       return 0;
//     }
//   }
// }
