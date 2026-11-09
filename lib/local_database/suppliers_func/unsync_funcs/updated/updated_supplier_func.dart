import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/classes/temp_suppliers/unsynced/updated/updated_suppliers.dart';
import 'package:stockall/main.dart';

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
      await mainLocalLog(
        'Updated Suppliers Adapter registered ✅',
      );
    }

_updatedSuppliersBox = await openBoxSafely<UpdatedSuppliers>(updatedSuppliersBoxName);
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
      await mainLocalLog(
        'Offline updated Supplier inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline updated Supplier insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedSupplier(String uuid) async {
    try {
      await mainLocalLog(
        updatedSuppliersBox.containsKey(uuid).toString(),
      );
      await updatedSuppliersBox.delete(uuid);
      await mainLocalLog('Updated Supplier Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Supplier Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearUpdatedSuppliers() async {
    try {
      await updatedSuppliersBox.clear();
      await mainLocalLog('All updated Suppliers cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing updated Suppliers ❌: $e',
      );
      return 0;
    }
  }
}
