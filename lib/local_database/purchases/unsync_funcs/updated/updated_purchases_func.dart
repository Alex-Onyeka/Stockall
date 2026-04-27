import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_purchase/unsynced/updated/updated_purchases.dart';

class UpdatedPurchasesFunc {
  static final UpdatedPurchasesFunc instance =
      UpdatedPurchasesFunc._internal();
  factory UpdatedPurchasesFunc() => instance;
  UpdatedPurchasesFunc._internal();

  Box<UpdatedPurchases>? _updatedPurchasesBox;
  final String updatedPurchasesBoxName =
      'updatedPurchasesBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      UpdatedPurchasesAdapter().typeId,
    )) {
      Hive.registerAdapter(UpdatedPurchasesAdapter());
      print('Updated Purchases Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(updatedPurchasesBoxName)) {
      _updatedPurchasesBox =
          await Hive.openBox<UpdatedPurchases>(
            updatedPurchasesBoxName,
          );
      print('Updated Purchases Box opened ✅');
    } else {
      _updatedPurchasesBox = Hive.box<UpdatedPurchases>(
        updatedPurchasesBoxName,
      );
      print('Updated Purchases Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<UpdatedPurchases> get updatedPurchasesBox {
    if (_updatedPurchasesBox == null) {
      throw Exception(
        "Updated Purchases Func not initialized. Call await updated Purchases Func.instance.init() first.",
      );
    }
    return _updatedPurchasesBox!;
  }

  List<UpdatedPurchases> getPurchaseIds() {
    return updatedPurchasesBox.values.toList();
  }

  Future<int> createUpdatedPurchase(
    String purchaseUuid,
  ) async {
    try {
      updatedPurchasesBox.add(
        UpdatedPurchases(purchaseUuid: purchaseUuid),
      );
      print(
        'Offline Updated Purchase inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Updated Purchase insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedPurchase(String uuid) async {
    try {
      print(
        updatedPurchasesBox.containsKey(uuid).toString(),
      );
      await updatedPurchasesBox.delete(uuid);
      print('Updated Purchase Deleted');
      return 1;
    } catch (e) {
      print('Purchase Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearUpdatedPurchases() async {
    try {
      await updatedPurchasesBox.clear();
      print('All updated Purchases cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing updated Purchases ❌: $e');
      return 0;
    }
  }
}
