import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_purchase/unsynced/deleted_purchase/deleted_purchases.dart';

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
      print('Deleted Purchases Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(deletedPurchasesBoxName)) {
      _deletedPurchasesBox =
          await Hive.openBox<DeletedPurchases>(
            deletedPurchasesBoxName,
          );
      print('Deleted Purchases Box opened ✅');
    } else {
      _deletedPurchasesBox = Hive.box<DeletedPurchases>(
        deletedPurchasesBoxName,
      );
      print('Deleted Purchases Box already open, reused ✅');
    }
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
      print("Offline Deleted Purchases inserted ✅");
      return 1;
    } catch (e) {
      print(
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
      print(
        'Offline Deleted Purchase inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Purchase insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deletedDeletedPurchases(String uuid) async {
    try {
      await deletedPurchasesBox.delete(uuid);
      print('Delete Purchase cleared ✅');
      return 1;
    } catch (e) {
      print('Error while Deleting Deleted Purchase ❌: $e');
      return 0;
    }
  }

  Future<int> clearDeletedPurchases() async {
    try {
      await deletedPurchasesBox.clear();
      print('All Deleted Purchases cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Deleted Purchases ❌: $e');
      return 0;
    }
  }
}
