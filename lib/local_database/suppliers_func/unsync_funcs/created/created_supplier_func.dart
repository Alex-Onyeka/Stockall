import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_suppliers/unsynced/created_suppliers/created_suppliers.dart';

class CreatedSupplierFunc {
  static final CreatedSupplierFunc instance =
      CreatedSupplierFunc._internal();
  factory CreatedSupplierFunc() => instance;
  CreatedSupplierFunc._internal();

  Box<CreatedSuppliers>? _createdSuppliersBox;
  final String createdSuppliersBoxName =
      'createdSuppliersBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedSuppliersAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedSuppliersAdapter());
      print('Created Suppliers Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdSuppliersBoxName)) {
      _createdSuppliersBox =
          await Hive.openBox<CreatedSuppliers>(
            createdSuppliersBoxName,
          );
      print('Created Suppliers Box opened ✅');
    } else {
      _createdSuppliersBox = Hive.box<CreatedSuppliers>(
        createdSuppliersBoxName,
      );
      print('Created Suppliers Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<CreatedSuppliers> get createdSuppliersBox {
    if (_createdSuppliersBox == null) {
      throw Exception(
        "Created Suppliers Func not initialized. Call await CreatedSupplierFunc.instance.init() first.",
      );
    }
    return _createdSuppliersBox!;
  }

  List<CreatedSuppliers> getSuppliers() {
    List<CreatedSuppliers> suppliers =
        createdSuppliersBox.values.toList();
    suppliers.sort(
      (a, b) => a.supplier.name.compareTo(b.supplier.name),
    );
    return suppliers;
  }

  Future<int> insertAllSuppliers(
    List<CreatedSuppliers> createdSuppliers,
  ) async {
    try {
      for (var suppliers in createdSuppliers) {
        await createdSuppliersBox.put(
          suppliers.supplier.uuid,
          suppliers,
        );
      }
      print("Offline Created Suppliers inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Created Suppliers insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createSuppliers(
    CreatedSuppliers createdSuppliers,
  ) async {
    try {
      await createdSuppliersBox.put(
        createdSuppliers.supplier.uuid,
        createdSuppliers,
      );
      print(
        'Offline Created Suppliers inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Created Suppliers insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateSuppliers(
    CreatedSuppliers createdSuppliers,
  ) async {
    try {
      await createdSuppliersBox.put(
        createdSuppliers.supplier.uuid,
        createdSuppliers,
      );
      print(
        'Offline Created Suppliers inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Created Suppliers insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteSupplier(String uuid) async {
    try {
      print(
        createdSuppliersBox.containsKey(uuid).toString(),
      );
      await createdSuppliersBox.delete(uuid);
      print('Suppliers Deleted');
      return 1;
    } catch (e) {
      print('Suppliers Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearSuppliers() async {
    try {
      await createdSuppliersBox.clear();
      print('All Created Suppliers cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Created Suppliers ❌: $e');
      return 0;
    }
  }
}
