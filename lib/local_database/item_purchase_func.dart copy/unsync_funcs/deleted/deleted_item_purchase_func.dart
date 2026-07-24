import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_item_purchase_record/unsynced/deleted_item_records/deleted_item_records.dart';
import 'package:stockall/main.dart';

class DeletedItemPurchaseFunc {
  static final DeletedItemPurchaseFunc instance =
      DeletedItemPurchaseFunc._internal();
  factory DeletedItemPurchaseFunc() => instance;
  DeletedItemPurchaseFunc._internal();

  Box<DeletedItemRecords>? _deletedItemPurchaseBox;
  final String deletedItemPurchaseBoxName =
      'deletedItemPurchaseBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedItemRecordsAdapter().typeId,
    )) {
      Hive.registerAdapter(DeletedItemRecordsAdapter());
      await mainLocalLog(
        'Deleted Item Purchase Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(deletedItemPurchaseBoxName)) {
      _deletedItemPurchaseBox =
          await Hive.openBox<DeletedItemRecords>(
            deletedItemPurchaseBoxName,
          );
      await mainLocalLog(
        'Deleted Item Purchase Box opened ✅',
      );
    } else {
      _deletedItemPurchaseBox =
          Hive.box<DeletedItemRecords>(
            deletedItemPurchaseBoxName,
          );
      await mainLocalLog(
        'Deleted Item Purchase Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<DeletedItemRecords> get deletedItemPurchaseBox {
    if (_deletedItemPurchaseBox == null) {
      throw Exception(
        "Deleted Item Purchase Func not initialized. Call await Deleted Item Purchase Func.instance.init() first.",
      );
    }
    return _deletedItemPurchaseBox!;
  }

  List<DeletedItemRecords> getItemPurchaseIds() {
    return deletedItemPurchaseBox.values.toList();
  }

  Future<int> insertAllDeletedItemRecords(
    List<DeletedItemRecords> deletedItemRecords,
  ) async {
    try {
      for (var purchase in deletedItemRecords) {
        await deletedItemPurchaseBox.add(purchase);
      }
      await mainLocalLog(
        "Offline Deleted Item Purchase inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Item Purchase insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedPurchase(
    DeletedItemRecords deletedPurchase,
  ) async {
    try {
      await deletedItemPurchaseBox.add(deletedPurchase);
      await mainLocalLog(
        'Offline Deleted Item Purchase Record inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Item Purchase Record insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deletedDeletedItemRecords(String uuid) async {
    try {
      await deletedItemPurchaseBox.delete(uuid);
      await mainLocalLog(
        'Delete Item Purchase Purchase cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while Deleting Deleted Item Purchase Record ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedItemRecords() async {
    try {
      await deletedItemPurchaseBox.clear();
      await mainLocalLog(
        'All Deleted Item Purchase cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Deleted Item Purchase ❌: $e',
      );
      return 0;
    }
  }
}
