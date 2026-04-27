import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_suppliers/unsynced/updated/updated_suppliers.dart';

class UpdatedSupplierFunc {
  static final UpdatedSupplierFunc instance =
      UpdatedSupplierFunc._internal();
  factory UpdatedSupplierFunc() => instance;
  UpdatedSupplierFunc._internal();

  Box<UpdatedSuppliers>? _updatedSuppliersBox;
  final String updatedSuppliersBoxName =
      'updatedSuppliersBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      UpdatedSuppliersAdapter().typeId,
    )) {
      Hive.registerAdapter(UpdatedSuppliersAdapter());
      print('Updated Suppliers Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(updatedSuppliersBoxName)) {
      _updatedSuppliersBox =
          await Hive.openBox<UpdatedSuppliers>(
            updatedSuppliersBoxName,
          );
      print('Updated Suppliers Box opened ✅');
    } else {
      _updatedSuppliersBox = Hive.box<UpdatedSuppliers>(
        updatedSuppliersBoxName,
      );
      print('Updated Suppliers Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<UpdatedSuppliers> get updatedSuppliersBox {
    if (_updatedSuppliersBox == null) {
      throw Exception(
        "Updated Suppliers Func not initialized. Call await updated Suppliers Func.instance.init() first.",
      );
    }
    return _updatedSuppliersBox!;
  }

  List<UpdatedSuppliers> getSuppliers() {
    return updatedSuppliersBox.values.toList();
  }

  Future<int> createUpdatedSupplier(
    UpdatedSuppliers updatedSupplier,
  ) async {
    try {
      updatedSupplier.suppliers.updatedAt = DateTime.now()
          .toUtc()
          .add(const Duration(hours: 1));
      await updatedSuppliersBox.put(
        updatedSupplier.suppliers.uuid,
        updatedSupplier,
      );
      print(
        'Offline updated Supplier inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline updated Supplier insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedSupplier(String uuid) async {
    try {
      print(
        updatedSuppliersBox.containsKey(uuid).toString(),
      );
      await updatedSuppliersBox.delete(uuid);
      print('Updated Supplier Deleted');
      return 1;
    } catch (e) {
      print('Supplier Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearUpdatedSuppliers() async {
    try {
      await updatedSuppliersBox.clear();
      print('All updated Suppliers cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing updated Suppliers ❌: $e');
      return 0;
    }
  }
}
