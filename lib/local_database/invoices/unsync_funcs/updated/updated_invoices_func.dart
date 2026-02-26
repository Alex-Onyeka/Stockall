import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_invoices/unsynced/updated/updated_invoices.dart';

class UpdatedInvoicesFunc {
  static final UpdatedInvoicesFunc instance =
      UpdatedInvoicesFunc._internal();
  factory UpdatedInvoicesFunc() => instance;
  UpdatedInvoicesFunc._internal();

  Box<UpdatedInvoices>? _updatedInvoicesBox;
  final String updatedInvoicesBoxName =
      'updatedInvoicesBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      UpdatedInvoicesAdapter().typeId,
    )) {
      Hive.registerAdapter(UpdatedInvoicesAdapter());
      print('Updated Invoices Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(updatedInvoicesBoxName)) {
      _updatedInvoicesBox =
          await Hive.openBox<UpdatedInvoices>(
            updatedInvoicesBoxName,
          );
      print('Updated Invoices Box opened ✅');
    } else {
      _updatedInvoicesBox = Hive.box<UpdatedInvoices>(
        updatedInvoicesBoxName,
      );
      print('Updated Invoices Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<UpdatedInvoices> get updatedInvoicesBox {
    if (_updatedInvoicesBox == null) {
      throw Exception(
        "Updated Invoices Func not initialized. Call await updated Invoices Func.instance.init() first.",
      );
    }
    return _updatedInvoicesBox!;
  }

  List<UpdatedInvoices> getInvoiceIds() {
    return updatedInvoicesBox.values.toList();
  }

  Future<int> createUpdatedInvoice(
    UpdatedInvoices updatedInvoice,
  ) async {
    try {
      updatedInvoice
          .updatedInvoice
          .updatedAt = DateTime.now().toUtc().add(
        const Duration(hours: 1),
      );
      await updatedInvoicesBox.put(
        updatedInvoice.updatedInvoice.uuid,
        updatedInvoice,
      );
      print(
        'Offline updated Invoice inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline updated Invoice insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateUpdatedInvoice(
    UpdatedInvoices updatedInvoice,
  ) async {
    try {
      updatedInvoice
          .updatedInvoice
          .updatedAt = DateTime.now().toUtc().add(
        const Duration(hours: 1),
      );
      await updatedInvoicesBox.put(
        updatedInvoice.updatedInvoice.uuid,
        updatedInvoice,
      );
      print(
        'Offline updated Invoice inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline updated Invoice insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedInvoice(String uuid) async {
    try {
      print(
        updatedInvoicesBox.containsKey(uuid).toString(),
      );
      await updatedInvoicesBox.delete(uuid);
      print('Updated Invoice Deleted');
      return 1;
    } catch (e) {
      print('Invoice Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearupdatedInvoiceUpdatedInvoices() async {
    try {
      await updatedInvoicesBox.clear();
      print('All updated InvoiceUpdatedInvoices cleared ✅');
      return 1;
    } catch (e) {
      print(
        'Error while clearing updated InvoiceUpdatedInvoices ❌: $e',
      );
      return 0;
    }
  }
}
