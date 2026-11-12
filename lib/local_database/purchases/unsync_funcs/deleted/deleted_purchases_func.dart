import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/classes/temp_purchase/unsynced/deleted_purchase/deleted_purchases.dart';
import 'package:stockall/main.dart';

class DeletedPurchasesFunc {
  static final DeletedPurchasesFunc instance =
      DeletedPurchasesFunc._internal();
  factory DeletedPurchasesFunc() => instance;
  DeletedPurchasesFunc._internal();

  Box<DeletedPurchases>? _deletedPurchasesBox;
  final String deletedPurchasesBoxName =
      'deletedPurchasesBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedPurchasesAdapter().typeId,
    )) {
      Hive.registerAdapter(DeletedPurchasesAdapter());
      await mainLocalLog(
        'Deleted Purchases Adapter registered ✅',
      );
    }

    _deletedPurchasesBox =
        await openBoxSafely<DeletedPurchases>(
          deletedPurchasesBoxName,
        );
  }

  /// Safe getter for the box
  Box<DeletedPurchases> get deletedPurchasesBox {
    if (_deletedPurchasesBox == null) {
      throw Exception(
        "Deleted Purchases Func not initialized. Call await Deleted Purchases Func.instance.init() first.",
      );
    }
    return _deletedPurchasesBox!;
  }

  List<DeletedPurchases> getPurchaseIds() {
    return deletedPurchasesBox.values.toList();
  }

  Future<int> insertAllDeletedPurchases(
    List<DeletedPurchases> deletedPurchases,
  ) async {
    try {
      for (var purchase in deletedPurchases) {
        await deletedPurchasesBox.add(purchase);
      }
      await mainLocalLog(
        "Offline Deleted Purchases inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Purchases insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedPurchase(
    DeletedPurchases deletedPurchase,
  ) async {
    try {
      await deletedPurchasesBox.add(deletedPurchase);
      await mainLocalLog(
        'Offline Deleted Purchase inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Purchase insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deletedDeletedPurchases(String uuid) async {
    try {
      final toDelete =
          deletedPurchasesBox.values
              .where((e) => e.purchaseUuid == uuid)
              .toList();
      for (var item in toDelete) {
        await item.delete();
      }
      if (deletedPurchasesBox.containsKey(uuid)) {
        await deletedPurchasesBox.delete(uuid);
      }
      await mainLocalLog('Delete Purchase cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while Deleting Deleted Purchase ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedPurchases() async {
    try {
      await deletedPurchasesBox.clear();
      await mainLocalLog('All Deleted Purchases cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Deleted Purchases ❌: $e',
      );
      return 0;
    }
  }
}
