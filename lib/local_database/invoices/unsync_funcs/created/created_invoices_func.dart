import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_invoices/unsynced/created_invoices/created_invoices.dart';
import 'package:stockall/main.dart';

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
      await mainLocalLog(
        'Created Invoices Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdInvoicesBoxName)) {
      _createdInvoicesBox =
          await Hive.openBox<CreatedInvoices>(
            createdInvoicesBoxName,
          );
      await mainLocalLog('Created Invoices Box opened ✅');
    } else {
      _createdInvoicesBox = Hive.box<CreatedInvoices>(
        createdInvoicesBoxName,
      );
      await mainLocalLog(
        'Created Invoices Box already open, reused ✅',
      );
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
      await mainLocalLog(
        "Offline Created Invoices inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
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
      await mainLocalLog(
        'Offline Created Invoice inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
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
      await mainLocalLog(
        'Offline Created Invoice Updated successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Invoice Update failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteInvoice(String uuid) async {
    try {
      await mainLocalLog(
        createdInvoicesBox.containsKey(uuid).toString(),
      );
      await createdInvoicesBox.delete(uuid);
      await mainLocalLog('Created Invoice Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Created Invoice Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearInvoices() async {
    try {
      await createdInvoicesBox.clear();
      await mainLocalLog('All Created Invoices cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Invoices ❌: $e',
      );
      return 0;
    }
  }
}
