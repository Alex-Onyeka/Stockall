// import 'package:hive/hive.dart';
// import 'package:stockall/classes/purchase_payments/unsynced/created_purchase_payments/created_purchase_payments.dart';

// class CreatedPurchasePaymentsFunc {
//   static final CreatedPurchasePaymentsFunc instance =
//       CreatedPurchasePaymentsFunc._internal();
//   factory CreatedPurchasePaymentsFunc() => instance;
//   CreatedPurchasePaymentsFunc._internal();

//   Box<CreatedPurchasePayments>? _createdPurchasePaymentsBox;
//   final String createdPurchasePaymentsBoxName =
//       'createdPurchasePaymentsBoxStockall';

//   /// Initialize Hive box + adapter safely
//   Future<void> init() async {
//     // Check if adapter is already registered
//     if (!Hive.isAdapterRegistered(
//       CreatedPurchasePaymentsAdapter().typeId,
//     )) {
//       Hive.registerAdapter(
//         CreatedPurchasePaymentsAdapter(),
//       );
//       print(
//         'Created Purchase Payments Adapter registered ✅',
//       );
//     }

//     // Open the box only if it isn’t already open
//     if (!Hive.isBoxOpen(createdPurchasePaymentsBoxName)) {
//       _createdPurchasePaymentsBox =
//           await Hive.openBox<CreatedPurchasePayments>(
//             createdPurchasePaymentsBoxName,
//           );
//       print('Created Purchase Payments Box opened ✅');
//     } else {
//       _createdPurchasePaymentsBox =
//           Hive.box<CreatedPurchasePayments>(
//             createdPurchasePaymentsBoxName,
//           );
//       print(
//         'Created Purchase Payments Box already open, reused ✅',
//       );
//     }
//   }

//   /// Safe getter for the box
//   Box<CreatedPurchasePayments>
//   get createdPurchasePaymentsBox {
//     if (_createdPurchasePaymentsBox == null) {
//       throw Exception(
//         "Created Purchase Payments Func not initialized. Call await CreatedPurchasePaymentsFunc.instance.init() first.",
//       );
//     }
//     return _createdPurchasePaymentsBox!;
//   }

//   List<CreatedPurchasePayments> getPurchasePayments() {
//     List<CreatedPurchasePayments> purchasePayments =
//         createdPurchasePaymentsBox.values.toList();
//     purchasePayments.sort(
//       (a, b) => a.purchasPayments.createdAt.compareTo(
//         b.purchasPayments.createdAt,
//       ),
//     );
//     return purchasePayments;
//   }

//   Future<int> insertAllPurchasePayments(
//     List<CreatedPurchasePayments> createdPurchasePayments,
//   ) async {
//     try {
//       for (var purchasePayments
//           in createdPurchasePayments) {
//         await createdPurchasePaymentsBox.put(
//           purchasePayments.purchasPayments.uuid,
//           purchasePayments,
//         );
//       }
//       print("Offline Created Purchase Payments inserted ✅");
//       return 1;
//     } catch (e) {
//       print(
//         'Offline Created Purchase Payments insertion failed ❌: $e',
//       );
//       return 0;
//     }
//   }

//   Future<int> createPurchasePayments(
//     CreatedPurchasePayments createdPurchasePayments,
//   ) async {
//     try {
//       await createdPurchasePaymentsBox.put(
//         createdPurchasePayments.purchasPayments.uuid,
//         createdPurchasePayments,
//       );
//       print(
//         'Offline Created Purchase Payments inserted successfully ✅',
//       );
//       return 1;
//     } catch (e) {
//       print(
//         'Offline Created Purchase Payments insertion failed ❌: $e',
//       );
//       return 0;
//     }
//   }

//   Future<int> deletePurchasePayments(String uuid) async {
//     try {
//       print(
//         createdPurchasePaymentsBox
//             .containsKey(uuid)
//             .toString(),
//       );
//       await createdPurchasePaymentsBox.delete(uuid);
//       print('Created Purchase Deleted');
//       return 1;
//     } catch (e) {
//       print(
//         'Created Purchase Delete Failed: ${e.toString()}',
//       );
//       return 0;
//     }
//   }

//   Future<int> clearPurchasePayments() async {
//     try {
//       await createdPurchasePaymentsBox.clear();
//       print('All Created Purchase Payments cleared ✅');
//       return 1;
//     } catch (e) {
//       print(
//         'Error while clearing Created Purchase Payments ❌: $e',
//       );
//       return 0;
//     }
//   }
// }
