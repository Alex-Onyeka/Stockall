import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/local_database/suppliers_func/unsync_funcs/created/created_supplier_func.dart';
import 'package:stockall/local_database/suppliers_func/unsync_funcs/deleted/deleted_supplier_func.dart';
import 'package:stockall/local_database/suppliers_func/unsync_funcs/updated/updated_supplier_func.dart';

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
    print('Supplier Box Initialized');
  }

  List<SuppliersClass> getSuppliers() {
    List<SuppliersClass> suppliers =
        suppliersBox.values.toList();
    suppliers.sort(
      (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );
    print('Suppliers Gotten: ${suppliers.length}');

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
      print('Offline Suppliers Inserted Successfully');
      return 1;
    } catch (e) {
      print(
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
      print('Offline Supplier Inserted');
      return 1;
    } catch (e) {
      print('Supplier Insert Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> updateSupplier(
    SuppliersClass supplier,
  ) async {
    try {
      supplier.updatedAt = DateTime.now();
      await suppliersBox.put(supplier.uuid, supplier);
      print('Offline Supplier Updated');
      return 1;
    } catch (e) {
      print('Supplier Update Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> deleteSupplier(String uuid) async {
    try {
      await suppliersBox.delete(uuid);
      print('Offline Supplier Deleted');
      return 1;
    } catch (e) {
      print('Supplier Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearSuppliers() async {
    try {
      await suppliersBox.clear().timeout(
        Duration(seconds: 2),
      );
      print('Offline Suppliers Cleared');
      return 1;
    } catch (e) {
      print(
        '❌❌ Error Clearing Offline Suppliers: ${e.toString()}',
      );
      return 0;
    }
  }
}
