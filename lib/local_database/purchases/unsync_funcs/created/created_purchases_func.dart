import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_purchase/unsynced/created_purchases/created_purchases.dart';

class CreatedPurchasesFunc {
  static final CreatedPurchasesFunc instance =
      CreatedPurchasesFunc._internal();
  factory CreatedPurchasesFunc() => instance;
  CreatedPurchasesFunc._internal();

  Box<CreatedPurchases>? _createdPurchasesBox;
  final String createdPurchasesBoxName =
      'createdPurchasesBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedPurchasesAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedPurchasesAdapter());
      print('Created Purchases Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdPurchasesBoxName)) {
      _createdPurchasesBox =
          await Hive.openBox<CreatedPurchases>(
            createdPurchasesBoxName,
          );
      print('Created Purchases Box opened ✅');
    } else {
      _createdPurchasesBox = Hive.box<CreatedPurchases>(
        createdPurchasesBoxName,
      );
      print('Created Purchases Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<CreatedPurchases> get createdPurchasesBox {
    if (_createdPurchasesBox == null) {
      throw Exception(
        "Created Purchases Func not initialized. Call await CreatedPurchasesFunc.instance.init() first.",
      );
    }
    return _createdPurchasesBox!;
  }

  List<CreatedPurchases> getPurchases() {
    List<CreatedPurchases> purchases =
        createdPurchasesBox.values.toList();
    purchases.sort(
      (a, b) => a.purchase.createdAt.compareTo(
        b.purchase.createdAt,
      ),
    );
    return purchases;
  }

  Future<int> insertAllPurchases(
    List<CreatedPurchases> createdPurchases,
  ) async {
    try {
      for (var purchases in createdPurchases) {
        await createdPurchasesBox.put(
          purchases.purchase.uuid,
          purchases,
        );
      }
      print("Offline Created Purchases inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Created Purchases insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createPurchases(
    CreatedPurchases createdPurchases,
  ) async {
    try {
      await createdPurchasesBox.put(
        createdPurchases.purchase.uuid,
        createdPurchases,
      );
      print(
        'Offline Created Purchases inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Created Purchases insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deletePurchase(String uuid) async {
    try {
      print(
        createdPurchasesBox.containsKey(uuid).toString(),
      );
      await createdPurchasesBox.delete(uuid);
      print('Created Purchase Deleted');
      return 1;
    } catch (e) {
      print(
        'Created Purchase Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearPurchases() async {
    try {
      await createdPurchasesBox.clear();
      print('All Created Purchases cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Created Purchases ❌: $e');
      return 0;
    }
  }
}
