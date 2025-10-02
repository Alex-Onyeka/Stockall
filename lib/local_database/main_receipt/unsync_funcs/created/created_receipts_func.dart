import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_main_receipt/unsynced/created_receipts/created_receipts.dart';

class CreatedReceiptsFunc {
  static final CreatedReceiptsFunc instance =
      CreatedReceiptsFunc._internal();
  factory CreatedReceiptsFunc() => instance;
  CreatedReceiptsFunc._internal();

  Box<CreatedReceipts>? _createdReceiptsBox;
  final String createdReceiptsBoxName =
      'createdReceiptsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedReceiptsAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedReceiptsAdapter());
      print('Created Receipts Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdReceiptsBoxName)) {
      _createdReceiptsBox =
          await Hive.openBox<CreatedReceipts>(
            createdReceiptsBoxName,
          );
      print('Created Receipts Box opened ✅');
    } else {
      _createdReceiptsBox = Hive.box<CreatedReceipts>(
        createdReceiptsBoxName,
      );
      print('Created Receipts Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<CreatedReceipts> get createdReceiptsBox {
    if (_createdReceiptsBox == null) {
      throw Exception(
        "Created Receipts Func not initialized. Call await CreatedReceiptsFunc.instance.init() first.",
      );
    }
    return _createdReceiptsBox!;
  }

  List<CreatedReceipts> getReceipts() {
    List<CreatedReceipts> receipts =
        createdReceiptsBox.values.toList();
    receipts.sort(
      (a, b) => a.receipt.createdAt.compareTo(
        b.receipt.createdAt,
      ),
    );
    return receipts;
  }

  Future<int> insertAllReceipts(
    List<CreatedReceipts> createdReceipts,
  ) async {
    try {
      for (var receipts in createdReceipts) {
        await createdReceiptsBox.put(
          receipts.receipt.uuid,
          receipts,
        );
      }
      print("Offline Created Receipts inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Created Receipts insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createReceipts(
    CreatedReceipts createdReceipts,
  ) async {
    try {
      await createdReceiptsBox.put(
        createdReceipts.receipt.uuid,
        createdReceipts,
      );
      print(
        'Offline Created Receipts inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Created Receipts insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteReceipt(String uuid) async {
    try {
      print(
        createdReceiptsBox.containsKey(uuid).toString(),
      );
      await createdReceiptsBox.delete(uuid);
      print('Created eceipts Deleted');
      return 1;
    } catch (e) {
      print(
        'Created Receipts Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearReceipts() async {
    try {
      await createdReceiptsBox.clear();
      print('All Created Receipts cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Created Receipts ❌: $e');
      return 0;
    }
  }
}
