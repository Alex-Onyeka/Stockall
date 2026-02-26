import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_invoices/unsynced/deleted_invoices/deleted_invoices.dart';

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
      print('Deleted Invoices Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(deletedInvoicesBoxName)) {
      _deletedInvoicesBox =
          await Hive.openBox<DeletedInvoices>(
            deletedInvoicesBoxName,
          );
      print('Deleted Invoices Box opened ✅');
    } else {
      _deletedInvoicesBox = Hive.box<DeletedInvoices>(
        deletedInvoicesBoxName,
      );
      print('Deleted Invoices Box already open, reused ✅');
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
      print("Offline Deleted Invoices inserted ✅");
      return 1;
    } catch (e) {
      print(
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
      print(
        'Offline Deleted Invoice inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Invoice insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deletedDeletedInvoices(String uuid) async {
    try {
      await deletedInvoicesBox.delete(uuid);
      print('Delete Invoice cleared ✅');
      return 1;
    } catch (e) {
      print('Error while Deleting Deleted Invoice ❌: $e');
      return 0;
    }
  }

  Future<int> clearDeletedInvoices() async {
    try {
      await deletedInvoicesBox.clear();
      print('All Deleted Invoices cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Deleted Invoices ❌: $e');
      return 0;
    }
  }
}
