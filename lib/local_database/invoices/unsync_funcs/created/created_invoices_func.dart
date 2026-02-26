import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_invoices/unsynced/created_invoices/created_invoices.dart';

class CreatedInvoicesFunc {
  static final CreatedInvoicesFunc instance =
      CreatedInvoicesFunc._internal();
  factory CreatedInvoicesFunc() => instance;
  CreatedInvoicesFunc._internal();

  Box<CreatedInvoices>? _createdInvoicesBox;
  final String createdInvoicesBoxName =
      'createdInvoicesBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedInvoicesAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedInvoicesAdapter());
      print('Created Invoices Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdInvoicesBoxName)) {
      _createdInvoicesBox =
          await Hive.openBox<CreatedInvoices>(
            createdInvoicesBoxName,
          );
      print('Created Invoices Box opened ✅');
    } else {
      _createdInvoicesBox = Hive.box<CreatedInvoices>(
        createdInvoicesBoxName,
      );
      print('Created Invoices Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<CreatedInvoices> get createdInvoicesBox {
    if (_createdInvoicesBox == null) {
      throw Exception(
        "Created Invoices Func not initialized. Call await CreatedInvoicesFunc.instance.init() first.",
      );
    }
    return _createdInvoicesBox!;
  }

  List<CreatedInvoices> getInvoices() {
    List<CreatedInvoices> invoices =
        createdInvoicesBox.values.toList();
    invoices.sort(
      (a, b) => a.invoice.createdAt.compareTo(
        b.invoice.createdAt,
      ),
    );
    return invoices;
  }

  Future<int> insertAllInvoices(
    List<CreatedInvoices> createdInvoices,
  ) async {
    try {
      for (var invoice in createdInvoices) {
        await createdInvoicesBox.put(
          invoice.invoice.uuid,
          invoice,
        );
      }
      print("Offline Created Invoices inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Created Invoices insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createInvoice(
    CreatedInvoices createdInvoice,
  ) async {
    try {
      await createdInvoicesBox.put(
        createdInvoice.invoice.uuid,
        createdInvoice,
      );
      print(
        'Offline Created Invoice inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Created Invoice insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateCreatedInvoice(
    CreatedInvoices createdInvoice,
  ) async {
    try {
      await createdInvoicesBox.put(
        createdInvoice.invoice.uuid,
        createdInvoice,
      );
      print(
        'Offline Created Invoice Updated successfully ✅',
      );
      return 1;
    } catch (e) {
      print('Offline Created Invoice Update failed ❌: $e');
      return 0;
    }
  }

  Future<int> deleteInvoice(String uuid) async {
    try {
      print(
        createdInvoicesBox.containsKey(uuid).toString(),
      );
      await createdInvoicesBox.delete(uuid);
      print('Created Invoice Deleted');
      return 1;
    } catch (e) {
      print(
        'Created Invoice Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearInvoices() async {
    try {
      await createdInvoicesBox.clear();
      print('All Created Invoices cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Created Invoices ❌: $e');
      return 0;
    }
  }
}
