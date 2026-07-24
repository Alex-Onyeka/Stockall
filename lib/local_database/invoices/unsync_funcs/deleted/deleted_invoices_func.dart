import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_invoices/unsynced/deleted_invoices/deleted_invoices.dart';
import 'package:stockall/main.dart';

class DeletedInvoicesFunc {
  static final DeletedInvoicesFunc instance =
      DeletedInvoicesFunc._internal();
  factory DeletedInvoicesFunc() => instance;
  DeletedInvoicesFunc._internal();

  Box<DeletedInvoices>? _deletedInvoicesBox;
  final String deletedInvoicesBoxName =
      'deletedInvoicesBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedInvoicesAdapter().typeId,
    )) {
      Hive.registerAdapter(DeletedInvoicesAdapter());
      await mainLocalLog(
        'Deleted Invoices Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(deletedInvoicesBoxName)) {
      _deletedInvoicesBox =
          await Hive.openBox<DeletedInvoices>(
            deletedInvoicesBoxName,
          );
      await mainLocalLog('Deleted Invoices Box opened ✅');
    } else {
      _deletedInvoicesBox = Hive.box<DeletedInvoices>(
        deletedInvoicesBoxName,
      );
      await mainLocalLog(
        'Deleted Invoices Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<DeletedInvoices> get deletedInvoicesBox {
    if (_deletedInvoicesBox == null) {
      throw Exception(
        "Deleted Invoices Func not initialized. Call await Deleted Invoices Func.instance.init() first.",
      );
    }
    return _deletedInvoicesBox!;
  }

  List<DeletedInvoices> getInvoiceIds() {
    return deletedInvoicesBox.values.toList();
  }

  Future<int> insertAllDeletedInvoices(
    List<DeletedInvoices> deletedInvoices,
  ) async {
    try {
      for (var invoice in deletedInvoices) {
        await deletedInvoicesBox.add(invoice);
      }
      await mainLocalLog(
        "Offline Deleted Invoices inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Invoices insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedInvoice(
    DeletedInvoices deletedInvoice,
  ) async {
    try {
      await deletedInvoicesBox.add(deletedInvoice);
      await mainLocalLog(
        'Offline Deleted Invoice inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Invoice insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deletedDeletedInvoices(String uuid) async {
    try {
      await deletedInvoicesBox.delete(uuid);
      await mainLocalLog('Delete Invoice cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while Deleting Deleted Invoice ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedInvoices() async {
    try {
      await deletedInvoicesBox.clear();
      await mainLocalLog('All Deleted Invoices cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Deleted Invoices ❌: $e',
      );
      return 0;
    }
  }
}
