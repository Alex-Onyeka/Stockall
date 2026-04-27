import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_suppliers/unsynced/deleted_suppliers/deleted_supplier.dart';

class DeletedSupplierFunc {
  static final DeletedSupplierFunc instance =
      DeletedSupplierFunc._internal();
  factory DeletedSupplierFunc() => instance;
  DeletedSupplierFunc._internal();

  Box<DeletedSupplier>? _deletedSuppliersBox;
  final String deletedSuppliersBoxName =
      'deletedSuppliersBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedSupplierAdapter().typeId,
    )) {
      Hive.registerAdapter(DeletedSupplierAdapter());
      print('Deleted Suppliers Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(deletedSuppliersBoxName)) {
      _deletedSuppliersBox =
          await Hive.openBox<DeletedSupplier>(
            deletedSuppliersBoxName,
          );
      print('Deleted Suppliers Box opened ✅');
    } else {
      _deletedSuppliersBox = Hive.box<DeletedSupplier>(
        deletedSuppliersBoxName,
      );
      print('Deleted Suppliers Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<DeletedSupplier> get deletedSuppliersBox {
    if (_deletedSuppliersBox == null) {
      throw Exception(
        "Deleted Suppliers Func not initialized. Call await Deleted Suppliers Func.instance.init() first.",
      );
    }
    return _deletedSuppliersBox!;
  }

  List<DeletedSupplier> getSupplierIds() {
    return deletedSuppliersBox.values.toList();
  }

  Future<int> insertAllDeletedSupplier(
    List<DeletedSupplier> deletedSupplier,
  ) async {
    try {
      for (var supplier in deletedSupplier) {
        await deletedSuppliersBox.add(supplier);
      }
      print("Offline Deleted Suppliers inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Suppliers insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedSupplier(
    DeletedSupplier deletedSupplier,
  ) async {
    try {
      await deletedSuppliersBox.add(deletedSupplier);
      print(
        'Offline Deleted Supplier inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Supplier insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedSupplier() async {
    try {
      await deletedSuppliersBox.clear();
      print('All Deleted Suppliers cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Deleted Suppliers ❌: $e');
      return 0;
    }
  }
}
