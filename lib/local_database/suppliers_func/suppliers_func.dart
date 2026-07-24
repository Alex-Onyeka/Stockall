import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/local_database/suppliers_func/unsync_funcs/created/created_supplier_func.dart';
import 'package:stockall/local_database/suppliers_func/unsync_funcs/deleted/deleted_supplier_func.dart';
import 'package:stockall/local_database/suppliers_func/unsync_funcs/updated/updated_supplier_func.dart';
import 'package:stockall/main.dart';

class SuppliersFunc {
  static final SuppliersFunc instance =
      SuppliersFunc._internal();
  factory SuppliersFunc() => instance;
  SuppliersFunc._internal();
  late Box<SuppliersClass> suppliersBox;
  final String suppliersBoxName = 'suppliersBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(SuppliersClassAdapter());
    suppliersBox = await Hive.openBox(suppliersBoxName);
    await CreatedSupplierFunc().init();
    await DeletedSupplierFunc().init();
    await UpdatedSupplierFunc().init();
    await mainLocalLog('Supplier Box Initialized');
  }

  List<SuppliersClass> getSuppliers() {
    List<SuppliersClass> suppliers =
        suppliersBox.values.toList();
    suppliers.sort(
      (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );
    // await mainLocalLog('Suppliers Gotten: ${suppliers.length}');

    return suppliers;
  }

  Future<int> insertAllSuppliers(
    List<SuppliersClass> suppliers,
  ) async {
    await clearSuppliers();
    try {
      for (var supplier in suppliers) {
        await suppliersBox.put(supplier.uuid, supplier);
      }
      await mainLocalLog(
        'Offline Suppliers Inserted Successfully',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Supplier insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createSupplier(
    SuppliersClass supplier,
  ) async {
    try {
      await suppliersBox.put(supplier.uuid, supplier);
      await mainLocalLog('Offline Supplier Inserted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Supplier Insert Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> updateSupplier(
    SuppliersClass supplier,
  ) async {
    try {
      supplier.updatedAt = DateTime.now();
      await suppliersBox.put(supplier.uuid, supplier);
      await mainLocalLog('Offline Supplier Updated');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Supplier Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteSupplier(String uuid) async {
    try {
      await suppliersBox.delete(uuid);
      await mainLocalLog('Offline Supplier Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Supplier Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearSuppliers() async {
    try {
      await suppliersBox.clear().timeout(
        Duration(seconds: 2),
      );
      await mainLocalLog('Offline Suppliers Cleared');
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Error Clearing Offline Suppliers: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedSupplierFunc().getSuppliers().isEmpty &&
        UpdatedSupplierFunc().getSuppliers().isEmpty &&
        DeletedSupplierFunc().getSupplierIds().isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
