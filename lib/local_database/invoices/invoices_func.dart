import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/local_database/invoices/unsync_funcs/created/created_invoices_func.dart';
import 'package:stockall/local_database/invoices/unsync_funcs/deleted/deleted_invoices_func.dart';
import 'package:stockall/local_database/invoices/unsync_funcs/updated/updated_invoices_func.dart';

class InvoicesFunc {
  static final InvoicesFunc instance =
      InvoicesFunc._internal();
  factory InvoicesFunc() => instance;
  InvoicesFunc._internal();
  late Box<TempInvoice> invoicesBox;
  final String invoicesBoxName = 'TempInvoiceBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempInvoiceAdapter());
    invoicesBox = await Hive.openBox(invoicesBoxName);
    await CreatedInvoicesFunc().init();
    await DeletedInvoicesFunc().init();
    await UpdatedInvoicesFunc().init();
    print('Invoices Box Initialized');
  }

  List<TempInvoice> getInvoices() {
    List<TempInvoice> invoicess =
        invoicesBox.values.toList();
    invoicess.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );
    return invoicess;
  }

  Future<int> insertAllInvoices(
    List<TempInvoice> invoices,
  ) async {
    await clearInvoices();
    try {
      for (var rec in invoices) {
        await invoicesBox.put(rec.uuid, rec);
      }
      print('Offline Invoices Success');
      return 1;
    } catch (e) {
      print('Offline Invoices Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> createInvoices(TempInvoice invoice) async {
    try {
      await invoicesBox.put(invoice.uuid, invoice);
      print('Offline Invoices Created');
      return 1;
    } catch (e) {
      print('Offline Invoices Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> updateInvoice(TempInvoice invoice) async {
    try {
      await invoicesBox.put(invoice.uuid, invoice);
      print('Offline Invoices Updated');
      return 1;
    } catch (e) {
      print(
        'Offline Invoices Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteInvoices(String uuid) async {
    try {
      await invoicesBox.delete(uuid);
      print('Offline Invoice Deleted');
      return 1;
    } catch (e) {
      print('Offline Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  // Future<int> payCredit(String uuid) async {
  //   try {
  //     var invoice = invoicesBox.get(uuid);
  //     if (invoice != null) {
  //       invoice.isInvoice = false;
  //       invoice.createdAt = DateTime.now();

  //       // Save back into Hive explicitly
  //       await invoicesBox.put(uuid, invoice);

  //       print('Offline Invoices Sale Updated Successfully');
  //       return 1;
  //     } else {
  //       print('Invoices not found in box ❌');
  //       return 0;
  //     }
  //   } catch (e) {
  //     print(
  //       'Offline Invoices Sale Update Failed: ${e.toString()}',
  //     );
  //     return 0;
  //   }
  // }

  Future<int> clearInvoices() async {
    try {
      await invoicesBox.clear();
      print('Offline Invoicess Cleared');
      return 1;
    } catch (e) {
      print(
        'Offline Invoices Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }
}
