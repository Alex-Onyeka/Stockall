import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_invoices/unsynced/updated/updated_invoices.dart';
import 'package:stockall/main.dart';

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
      await mainLocalLog(
        '😍😍😍😍😍Updated Invoices Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(updatedInvoicesBoxName)) {
      _updatedInvoicesBox =
          await Hive.openBox<UpdatedInvoices>(
            updatedInvoicesBoxName,
          );
      await mainLocalLog(
        '😍😍😍😍😍Updated Invoices Box opened ✅',
      );
    } else {
      _updatedInvoicesBox = Hive.box<UpdatedInvoices>(
        updatedInvoicesBoxName,
      );
      await mainLocalLog(
        '😍😍😍😍😍Updated Invoices Box already open, reused ✅',
      );
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
      await mainLocalLog(
        'Offline updated Invoice inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
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
      await mainLocalLog(
        'Offline updated Invoice inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline updated Invoice insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedInvoice(String uuid) async {
    try {
      await mainLocalLog(
        updatedInvoicesBox.containsKey(uuid).toString(),
      );
      await updatedInvoicesBox.delete(uuid);
      await mainLocalLog('Updated Invoice Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Invoice Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearupdatedInvoiceUpdatedInvoices() async {
    try {
      await updatedInvoicesBox.clear();
      await mainLocalLog(
        'All updated InvoiceUpdatedInvoices cleared ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing updated InvoiceUpdatedInvoices ❌: $e',
      );
      return 0;
    }
  }
}
