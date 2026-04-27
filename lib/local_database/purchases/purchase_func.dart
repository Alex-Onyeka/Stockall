import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/created/created_purchases_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/deleted/deleted_purchases_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/updated/updated_purchases_func.dart';

class PurchaseFunc {
  static final PurchaseFunc instance =
      PurchaseFunc._internal();
  factory PurchaseFunc() => instance;
  PurchaseFunc._internal();
  late Box<TempPurchase> purchasesBox;
  final String purchasesBoxName = 'purchasesBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempPurchaseAdapter());
    purchasesBox = await Hive.openBox(purchasesBoxName);
    await CreatedPurchasesFunc().init();
    await DeletedPurchasesFunc().init();
    await UpdatedPurchasesFunc().init();
    print('Purchase Box Initialized');
  }

  List<TempPurchase> getPurchases() {
    List<TempPurchase> purchases =
        purchasesBox.values.toList();
    purchases.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );
    return purchases;
  }

  Future<int> insertAllPurchases(
    List<TempPurchase> purchases,
  ) async {
    await clearPurchases();
    try {
      for (var rec in purchases) {
        await purchasesBox.put(rec.uuid, rec);
      }
      print('Offline Purchase Success');
      return 1;
    } catch (e) {
      print('Offline Purchase Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> createPurchase(TempPurchase purchase) async {
    try {
      await purchasesBox.put(purchase.uuid, purchase);
      print('Offline Purchase Created');
      return 1;
    } catch (e) {
      print('Offline Purchase Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> deletePurchase(String uuid) async {
    try {
      await purchasesBox.delete(uuid);
      print('Offline Purchase Deleted');
      return 1;
    } catch (e) {
      print('Offline Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  // Future<int> payCredit(String uuid) async {
  //   try {
  //     var Purchase = purchasesBox.get(uuid);
  //     if (Purchase != null) {
  //       Purchase.isInvoice = false;
  //       Purchase.createdAt = DateTime.now();

  //       // Save back into Hive explicitly
  //       await purchasesBox.put(uuid, Purchase);

  //       print('Offline Purchase Sale Updated Successfully');
  //       return 1;
  //     } else {
  //       print('Purchase not found in box ❌');
  //       return 0;
  //     }
  //   } catch (e) {
  //     print(
  //       'Offline Purchase Sale Update Failed: ${e.toString()}',
  //     );
  //     return 0;
  //   }
  // }

  Future<int> clearPurchases() async {
    try {
      await purchasesBox.clear();
      print('Offline Purchases Cleared');
      return 1;
    } catch (e) {
      print(
        'Offline Purchase Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }
}
