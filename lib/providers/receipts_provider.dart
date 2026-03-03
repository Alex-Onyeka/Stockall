import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_main_receipt/unsynced/created_receipts/created_receipts.dart';
import 'package:stockall/classes/temp_main_receipt/unsynced/deleted_customers/deleted_receipts.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_product_slaes_record/unsynced/created_records/created_records.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/main_receipt/main_receipt_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/created/created_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/deleted/deleted_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/updated/updated_receipts_func.dart';
import 'package:stockall/local_database/product_record_func.dart/product_record_func.dart';
import 'package:stockall/local_database/product_record_func.dart/unsync_funcs/created/created_records_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// // //

// // // //

// I WANT TO START WORKING ON THE INVOICE

// ///////

class ReceiptsProvider extends ChangeNotifier {
  static final ReceiptsProvider _instance =
      ReceiptsProvider._internal();
  factory ReceiptsProvider() => _instance;
  ReceiptsProvider._internal();
  bool isLoading = false;
  void toggleIsLoading(bool value) {
    isLoading = value;
    print(
      'Receipt is ${value ? 'Loading on' : 'Loading Off'}',
    );
    notifyListeners();
  }
  //
  //
  //

  final SupabaseClient supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();
  // final ShopProvider shopProvider = ShopProvider();

  List<TempMainReceipt> _receipts = [];
  List<TempMainReceipt> get receipts => _receipts;

  void clearReceipts() {
    _receipts.clear();
    clearRecords();
    print('Receipts Cleared');
    notifyListeners();
  }

  void clearRecords() {
    produtRecordSalesMain.clear();
    // notifyListeners();
  }

  bool isLoaded = false;
  void load(bool value) {
    isLoaded = value;
    print(
      value == true
          ? 'Receipts Loaded is now true'
          : 'Receipts Loaded is now false',
    );
    notifyListeners();
  }

  // CREATE a new receipt
  Future<TempMainReceipt?> createReceipt(
    TempMainReceipt receipt,
  ) async {
    print('Inner Receipt Creation Started');
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      print('Inner Receipt Online Started');
      final res =
          await supabase
              .from('receipts')
              .upsert(
                receipt.toJson(),
                onConflict:
                    'uuid', // match existing row by uuid
              )
              .select()
              .single();

      print('Inner Receipt Online Finished');
      print('Casting Started');
      try {
        final newReceipt = TempMainReceipt.fromJson(res);
        notifyListeners();
        return newReceipt;
      } catch (e) {
        print('❌❌ Create Receipt Error: ${e.toString()}');
        return null;
      }
    } else {
      receipt.createdAt = DateTime.now();
      await MainReceiptFunc().createReceipt(receipt);
      await CreatedReceiptsFunc().createReceipts(
        CreatedReceipts(receipt: receipt),
      );
      notifyListeners();
      return receipt;
    }
  }

  // READ all receipts for a shop
  Future<List<TempMainReceipt>> loadReceipts(
    int shopId,
  ) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      await MainReceiptFunc().clearReceipts();
      try {
        final data = await supabase
            .from('receipts')
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false);
        if (data.isNotEmpty) {
          print('Receipts Gotten ${data.length}');
        }

        _receipts =
            (data as List)
                .map(
                  (json) => TempMainReceipt.fromJson(json),
                )
                .toList();

        await MainReceiptFunc().insertAllReceipts(
          _receipts,
        );
        print('Loaded');
        await returnInvoicesProvider().loadInvoices(shopId);
        await returnData().getProducts(
          returnShopProvider().userShop()!.shopId!,
        );
        await loadProductSalesRecord(
          returnShopProvider().userShop()!.shopId!,
        );
        notifyListeners();
      } catch (e) {
        print('Error Getting Receipts: ${e.toString()}');
        return [];
      }
    } else {
      _receipts = MainReceiptFunc().getReceipts();

      print('Offline Receipts Gotten');
      await returnInvoicesProvider().loadInvoices(
        returnShopProvider().userShop()!.shopId!,
      );
      await returnData().getProducts(
        returnShopProvider().userShop()!.shopId!,
      );
      await loadProductSalesRecord(
        returnShopProvider().userShop()!.shopId!,
      );
      notifyListeners();
    }
    notifyListeners();
    return _receipts;
  }

  DateTime? singleDay;
  DateTime? weekStartDate;

  bool setDate = false;
  bool isDateSet = false;
  String? dateSet;

  void openDatePicker() {
    setDate = true;
    notifyListeners();
  }

  void setReceiptDay(DateTime day) {
    singleDay = day;
    weekStartDate = null;
    isDateSet = true;
    setDate = false;
    dateSet = 'For ${formatDateTime(day)}';
    notifyListeners();
  }

  void setReceiptWeek(
    DateTime weekStart,
    DateTime endOfWeek,
  ) {
    weekStartDate = weekStart;
    singleDay = null;
    isDateSet = true;
    setDate = false;
    dateSet =
        '${formatDateWithoutYear(weekStart)} - ${formatDateWithoutYear(endOfWeek)}';
    notifyListeners();
  }

  void clearReceiptDate() {
    singleDay = null;
    weekStartDate = null;
    setDate = false;
    isDateSet = false;
    dateSet = null;
    notifyListeners();
  }

  // // UPDATE a receipt
  // Future<void> updateReceipt(
  //   TempMainReceipt updated,
  // ) async {
  //   // Use only the updatable fields
  //   final updateData = {
  //     'barcode': updated.barcode,
  //     'payment_method': updated.paymentMethod,
  //     'cash_alt': updated.cashAlt,
  //     'bank': updated.bank,
  //     'customer_id': updated.customerId,
  //     'customer_uuid': updated.customerUuid,
  //   };

  //   await supabase
  //       .from('receipts')
  //       .update(updateData)
  //       .eq('uuid', updated.uuid!);

  //   final index = _receipts.indexWhere(
  //     (r) => r.uuid == updated.uuid,
  //   );
  //   if (index != -1) {
  //     _receipts[index] = updated;
  //     notifyListeners();
  //   }
  // }

  // DELETE a receipt
  Future<void> deleteReceipt(
    TempMainReceipt receipt,
    List<String> productNames,
    // BuildContext context,
  ) async {
    print('Deleting Receipt');
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      print('Deleting Receipt Online');
      await supabase.rpc(
        'delete_receipt_and_update_inventory_new',
        params: {'target_receipt_uuid': receipt.uuid},
      );
      print('Finished Deleting Receipt Online');
      var containsUpdate = UpdatedReceiptsFunc()
          .getReceiptIds()
          .where((rec) => rec.receiptUuid == receipt.uuid);
      if (containsUpdate.isNotEmpty) {
        await UpdatedReceiptsFunc().deleteUpdatedReceipt(
          receipt.uuid!,
        );
      }
    } else {
      print('Deleting Receipt Offline');
      await MainReceiptFunc().deleteReceipt(receipt.uuid!);
      var containsCreated =
          CreatedReceiptsFunc()
              .getReceipts()
              .where(
                (rec) => rec.receipt.uuid == receipt.uuid,
              )
              .toList();
      var containsUpdate = UpdatedReceiptsFunc()
          .getReceiptIds()
          .where((rec) => rec.receiptUuid == receipt.uuid!);
      if (containsCreated.isNotEmpty) {
        await CreatedReceiptsFunc().deleteReceipt(
          receipt.uuid!,
        );
      } else {
        await DeletedReceiptsFunc().createDeletedReceipt(
          DeletedReceipts(receiptUuid: receipt.uuid!),
        );
      }
      if (containsUpdate.isNotEmpty) {
        await UpdatedReceiptsFunc().deleteUpdatedReceipt(
          receipt.uuid!,
        );
      }
      await ProductRecordFunc().deleteRecordsInReceipt(
        receipt.uuid!,
      );
    }
    if (productNames.isNotEmpty) {
      await returnEventsLogProvider().createLog(
        returnEventsLogProvider().receiptAdapter(
          receipt,
          productNames,
          3,
        ),
      );
    }

    print(
      '✅ Receipt and inventory successfully Delete and Updated.',
    );

    await loadReceipts(
      returnShopProvider().userShop()!.shopId!,
    );

    print('Totally Finished Deleting Receipt');
    notifyListeners();
  }

  // DELETE a receipt
  Future<void> deleteReceiptWithoutUpdatingInventory(
    String uuid,
    // BuildContext context,
  ) async {
    print('Deleting Receipt 2');
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      print('Deleting Receipt 2 Online');
      await supabase.rpc(
        'delete_receipt_without_updating_inventory',
        params: {'target_receipt_uuid': uuid},
      );
      print('Finished Deleting Receipt 2 Online');
      var containsUpdate = UpdatedReceiptsFunc()
          .getReceiptIds()
          .where((rec) => rec.receiptUuid == uuid);
      if (containsUpdate.isNotEmpty) {
        await UpdatedReceiptsFunc().deleteUpdatedReceipt(
          uuid,
        );
      }
    } else {
      print('Deleting Receipt Offline');
      await MainReceiptFunc().deleteReceipt(uuid);
      var containsCreated =
          CreatedReceiptsFunc()
              .getReceipts()
              .where((rec) => rec.receipt.uuid == uuid)
              .toList();
      var containsUpdate = UpdatedReceiptsFunc()
          .getReceiptIds()
          .where((rec) => rec.receiptUuid == uuid);
      if (containsCreated.isNotEmpty) {
        await CreatedReceiptsFunc().deleteReceipt(uuid);
      } else {
        await DeletedReceiptsFunc().createDeletedReceipt(
          DeletedReceipts(receiptUuid: uuid),
        );
      }
      if (containsUpdate.isNotEmpty) {
        await UpdatedReceiptsFunc().deleteUpdatedReceipt(
          uuid,
        );
      }
      await ProductRecordFunc()
          .deleteRecordsInReceiptWithoutUpdatingInventory(
            uuid,
          );
    }

    print(
      '✅ Receipt and inventory successfully Delete and Updated.',
    );

    await loadReceipts(
      returnShopProvider().userShop()!.shopId!,
    );

    print('Totally Finished Deleting Receipt');
    notifyListeners();
  }

  // UPDATE a receipt
  // Future<void> payCredit(String uuid) async {
  //   try {
  //     bool isOnline = await connectivity.isOnline();
  //     if (isOnline) {
  //       final updateData = {
  //         'is_invoice': false,
  //         'created_at':
  //             DateTime.now()
  //                 .subtract(Duration(hours: 1))
  //                 .toIso8601String(),
  //       };

  //       final response =
  //           await supabase
  //               .from('receipts')
  //               .update(updateData)
  //               .eq('uuid', uuid)
  //               .select();

  //       if (response.isEmpty) {
  //         print('❌ No matching receipt to update.');
  //         return;
  //       }
  //       await MainReceiptFunc().payCredit(uuid);
  //     } else {
  //       await MainReceiptFunc().payCredit(uuid);
  //       await UpdatedReceiptsFunc().createUpdatedReceipt(
  //         uuid,
  //       );
  //     }
  //     final rec = receipts.firstWhere(
  //       (recc) => recc.uuid! == uuid,
  //     );
  //     rec.isInvoice = false;
  //     print('✅ Receipt updated successfully.');
  //     notifyListeners();
  //   } catch (e) {
  //     print('❌ Error updating receipt: $e');
  //   }
  // }

  //
  //
  //
  //
  //

  Future<void> createReceiptsSync(
    BuildContext context,
  ) async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedReceiptsFunc().getReceipts().isNotEmpty &&
          isOnline) {
        final tempReceipts =
            CreatedReceiptsFunc().getReceipts().toList();
        var newReceipts = tempReceipts.map((rec) {
          rec.receipt.createdAt =
              rec.receipt.createdAt.toUtc();
          return rec;
        });
        final payload =
            newReceipts
                .map((p) => p.receipt.toJson())
                .toList();

        // Insert all at once
        final data =
            await supabase
                .from('receipts')
                .insert(payload)
                .select();

        print('${data.length} items added successfully ✅');
        await CreatedReceiptsFunc().clearReceipts();
        print('Unsynced Receipts Cleared');
        if (context.mounted) {
          print('Mounted, refreshing Receipts ✅');
          await loadReceipts(
            returnShopProvider().userShop()!.shopId!,
          );
        }
      }
    } catch (e) {
      print('Batch Receipts insert failed ❌: $e');
    }
  }

  //
  //
  //
  //
  //

  //
  //
  //
  //
  //

  Future<void> deleteReceiptsSync(
    BuildContext context,
  ) async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (DeletedReceiptsFunc()
              .getReceiptIds()
              .isNotEmpty &&
          isOnline) {
        final tempReceipts =
            DeletedReceiptsFunc().getReceiptIds().toList();

        for (var rec in tempReceipts) {
          await supabase.rpc(
            'delete_receipt_and_update_inventory_new',
            params: {
              'target_receipt_uuid': rec.receiptUuid,
            },
          );
          await DeletedReceiptsFunc()
              .deletedDeletedReceipts(rec.receiptUuid);
        }

        print(
          '${tempReceipts.length} Receipts Created successfully ✅',
        );
        await DeletedReceiptsFunc().clearDeletedReceipts();
        print('Unsynced Deleted Receipts Cleared');
        if (context.mounted) {
          print('Mounted, refreshing Receipts ✅');
          await loadReceipts(
            returnShopProvider().userShop()!.shopId!,
          );
        }
      }
    } catch (e) {
      print('Batch Receipts Deleted failed ❌: $e');
    }
  }
  //
  //
  //
  //
  //

  Future<void> updateReceiptsSync(
    BuildContext context,
  ) async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (UpdatedReceiptsFunc()
              .getReceiptIds()
              .isNotEmpty &&
          isOnline) {
        final tempReceipts =
            UpdatedReceiptsFunc().getReceiptIds().toList();
        for (var rec in tempReceipts) {
          final updateData = {'is_invoice': false};
          await supabase
              .from('receipts')
              .update(updateData)
              .eq('uuid', rec.receiptUuid);
          await UpdatedReceiptsFunc().deleteUpdatedReceipt(
            rec.receiptUuid,
          );
        }

        print(
          '${tempReceipts.length} items added successfully ✅',
        );
        await UpdatedReceiptsFunc().clearUpdatedReceipts();
        print('Unsynced Receipts Cleared');
        if (context.mounted) {
          print('Mounted, refreshing Receipts ✅');
          await loadReceipts(
            returnShopProvider().userShop()!.shopId!,
          );
        }
      }
    } catch (e) {
      print('Batch Receipts insert failed ❌: $e');
    }
  }

  //
  //
  //
  //
  //

  //
  //
  //
  //
  //

  List<TempProductSaleRecord> _sales = [];
  List<TempProductSaleRecord> get produtRecordSalesMain =>
      _sales;

  // CREATE a new product sale record
  Future<void> createProductSaleRecord(
    List<TempProductSaleRecord> records,
    // BuildContext context,
  ) async {
    bool isOnline = await connectivity.isOnline();
    print('About to Start Mapping');
    try {
      final dataToInsert =
          records.map((e) => e.toJson()).toList();
      print('Finished Mapping');

      if (isOnline) {
        print('About to Create Product Sales Online');
        await supabase
            .from('product_sales')
            .upsert(dataToInsert, onConflict: 'uuid');
        await ProductRecordFunc().insertSalesProductRecords(
          records,
        );
        print('Finished Creating Product Sales Online');
      } else {
        print('About to Create Product Sales Offline');
        var newRecords =
            records.map((rec) {
              rec.createdAt = DateTime.now();

              return rec;
            }).toList();
        await ProductRecordFunc().insertSalesProductRecords(
          newRecords,
        );
        List<CreatedRecords> cRecords =
            newRecords.map((r) {
              return CreatedRecords(record: r);
            }).toList();
        await CreatedRecordsFunc().insertAllRecords(
          cRecords,
        );
        print('Finished Creating Product Sales Offline');
      }
    } catch (e) {
      print('Error ${e.toString()}');
    }

    notifyListeners();
  }

  // READ sales for a shop
  Future<List<TempProductSaleRecord>>
  loadProductSalesRecord(int shopId) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      final data = await supabase
          .from('product_sales')
          .select()
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);

      print('Items Records gotten');
      _sales =
          (data as List)
              .map(
                (json) =>
                    TempProductSaleRecord.fromJson(json),
              )
              .toList();
      await ProductRecordFunc().insertAllProductRecords(
        _sales,
      );
    } else {
      _sales = ProductRecordFunc().getProductRecords();
    }

    notifyListeners();
    return _sales;
  }

  // UPDATE a sale record
  Future<void> updateProductSaleRecord(
    TempProductSaleRecord record,
    BuildContext context,
  ) async {
    // Use toJson but remove the ID because you don't update the primary key
    final updateData = record.toJson()..remove('uuid');

    await supabase
        .from('product_sales')
        .update(updateData)
        .eq('uuid', record.uuid!);

    // final index = _sales.indexWhere(
    //   (r) => r.productRecordId == record.productRecordId,
    // );
    // if (index != -1) {
    //   _sales[index] = record;
    if (context.mounted) {
      await loadProductSalesRecord(
        returnShopProvider().userShop()!.shopId!,
      );
    }
    notifyListeners();
    // }
  }

  // DELETE a sale record
  Future<void> deleteProductSaleRecord(
    String recordUuid,
    BuildContext context,
  ) async {
    await supabase
        .from('product_sales')
        .delete()
        .eq('uuid', recordUuid);
    // _sales.removeWhere(
    //   (r) => r.productRecordId == recordId,
    // );
    if (context.mounted) {
      loadProductSalesRecord(
        returnShopProvider().userShop()!.shopId!,
      );
    }
    notifyListeners();
  }

  //
  //
  //
  //
  //
  //

  //
  //
  //
  //
  //

  Future<void> createRecordsSync(
    BuildContext context,
  ) async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedRecordsFunc().getRecords().isNotEmpty &&
          isOnline) {
        final tempRecords =
            CreatedRecordsFunc().getRecords().toList();
        var newRecords = tempRecords.map((rec) {
          rec.record.createdAt =
              rec.record.createdAt.toUtc();
          return rec;
        });
        final payload =
            newRecords
                .map((p) => p.record.toJson())
                .toList();

        // Insert all at once
        final data =
            await supabase
                .from('product_sales')
                .insert(payload)
                .select();

        print('${data.length} items added successfully ✅');
        await CreatedRecordsFunc().clearRecords();
        print('Unsynced Records Cleared');
      }
    } catch (e) {
      print('Batch Records insert failed ❌: $e');
    }
  }

  //
  //
  //
  //
  //

  // bool returnInvoice = false;

  // void switchReturnInvoice(bool value) {
  //   returnInvoice = value;
  //   notifyListeners();
  // }

  List<TempMainReceipt> returnReceipts() {
    return returnOwnReceiptsByDayOrWeekInvoice(receipts);
  }

  List<TempMainReceipt> returnOwnReceiptsByDayOrWeek(
    // BuildContext context,
    List<TempMainReceipt> receiptss,
  ) {
    if (weekStartDate != null) {
      final weekStartLocal = weekStartDate!;
      final weekEndLocal = weekStartLocal.add(
        const Duration(days: 7),
      );

      if (authorization(
        authorized:
            Authorizations().viewAllTransactionRecords,
      )) {
        return receiptss.where((receipt) {
          final created =
              receipt.createdAt
                  .toLocal(); // convert UTC to local
          return !created.isBefore(weekStartLocal) &&
              created.isBefore(weekEndLocal);
        }).toList();
      } else {
        return receiptss.where((receipt) {
          final created =
              receipt.createdAt
                  .toLocal(); // convert UTC to local
          return !created.isBefore(weekStartLocal) &&
              created.isBefore(weekEndLocal) &&
              receipt.staffId == currentUser().userId;
        }).toList();
      }
    }

    // Force local date without UTC logic
    final localNow = DateTime.now();
    final localTarget = singleDay?.toLocal() ?? localNow;

    final startOfDay = DateTime(
      localTarget.year,
      localTarget.month,
      localTarget.day,
    );
    final endOfDay = startOfDay.add(
      const Duration(days: 1),
    );

    if (authorization(
      authorized:
          Authorizations().viewAllTransactionRecords,
    )) {
      return receiptss.where((receipt) {
        final created =
            receipt.createdAt
                .toLocal(); // ALWAYS convert to local
        final inRange =
            !created.isBefore(startOfDay) &&
            created.isBefore(endOfDay);

        return inRange;
      }).toList();
    } else {
      return receiptss.where((receipt) {
        final created =
            receipt.createdAt
                .toLocal(); // ALWAYS convert to local
        final inRange =
            !created.isBefore(startOfDay) &&
            created.isBefore(endOfDay) &&
            receipt.staffId == currentUser().userId;

        return inRange;
      }).toList();
    }
  }

  List<TempMainReceipt> returnOwnReceiptsByDayOrWeekAll(
    // BuildContext context,
    List<TempMainReceipt> receiptss,
  ) {
    if (weekStartDate != null) {
      final weekStartLocal = weekStartDate!;
      final weekEndLocal = weekStartLocal.add(
        const Duration(days: 7),
      );

      if (authorization(
        authorized:
            Authorizations().viewAllTransactionRecords,
      )) {
        return receiptss.where((receipt) {
          final created =
              receipt.createdAt
                  .toLocal(); // convert UTC to local
          return !created.isBefore(weekStartLocal) &&
              created.isBefore(weekEndLocal);
        }).toList();
      } else {
        return receiptss.where((receipt) {
          final created =
              receipt.createdAt
                  .toLocal(); // convert UTC to local
          return !created.isBefore(weekStartLocal) &&
              created.isBefore(weekEndLocal) &&
              receipt.staffId == currentUser().userId;
        }).toList();
      }
    }

    // Force local date without UTC logic
    final localNow = DateTime.now();
    final localTarget = singleDay?.toLocal() ?? localNow;

    final startOfDay = DateTime(
      localTarget.year,
      localTarget.month,
      localTarget.day,
    );
    final endOfDay = startOfDay.add(
      const Duration(days: 1),
    );

    if (authorization(
      authorized:
          Authorizations().viewAllTransactionRecords,
    )) {
      return receiptss.where((receipt) {
        final created =
            receipt.createdAt
                .toLocal(); // ALWAYS convert to local
        final inRange =
            !created.isBefore(startOfDay) &&
            created.isBefore(endOfDay);

        return inRange;
      }).toList();
    } else {
      return receiptss.where((receipt) {
        final created =
            receipt.createdAt
                .toLocal(); // ALWAYS convert to local
        final inRange =
            !created.isBefore(startOfDay) &&
            created.isBefore(endOfDay) &&
            receipt.staffId == currentUser().userId;

        return inRange;
      }).toList();
    }
  }

  List<TempMainReceipt> returnOwnReceiptsByDayOrWeekInvoice(
    // BuildContext context,
    List<TempMainReceipt> receiptss,
  ) {
    if (weekStartDate != null) {
      final weekStartLocal = weekStartDate!;
      final weekEndLocal = weekStartLocal.add(
        const Duration(days: 7),
      );

      if (authorization(
        authorized:
            Authorizations().viewAllTransactionRecords,
      )) {
        return receiptss.where((receipt) {
          final created =
              receipt.createdAt
                  .toLocal(); // convert UTC to local
          return !created.isBefore(weekStartLocal) &&
              created.isBefore(weekEndLocal);
        }).toList();
      } else {
        return receiptss.where((receipt) {
          final created =
              receipt.createdAt
                  .toLocal(); // convert UTC to local
          return !created.isBefore(weekStartLocal) &&
              created.isBefore(weekEndLocal) &&
              receipt.staffId == currentUser().userId;
        }).toList();
      }
    }

    // Force local date without UTC logic
    final localNow = DateTime.now();
    final localTarget = singleDay?.toLocal() ?? localNow;

    final startOfDay = DateTime(
      localTarget.year,
      localTarget.month,
      localTarget.day,
    );
    final endOfDay = startOfDay.add(
      const Duration(days: 1),
    );

    if (authorization(
      authorized:
          Authorizations().viewAllTransactionRecords,
    )) {
      return receiptss.where((receipt) {
        final created =
            receipt.createdAt
                .toLocal(); // ALWAYS convert to local
        final inRange =
            !created.isBefore(startOfDay) &&
            created.isBefore(endOfDay);

        return inRange;
      }).toList();
    } else {
      return receiptss.where((receipt) {
        final created =
            receipt.createdAt
                .toLocal(); // ALWAYS convert to local
        final inRange =
            !created.isBefore(startOfDay) &&
            created.isBefore(endOfDay) &&
            receipt.staffId == currentUser().userId;

        return inRange;
      }).toList();
    }
  }
  //
  //
  //
  //
  //
  //
  //

  //
  //

  List<TempProductSaleRecord>
  returnproductsRecordByDayOrWeek(
    List<TempProductSaleRecord> records,
  ) {
    List<TempProductSaleRecord> recordss = [];

    for (var rec in records) {
      TempMainReceipt? receipt;

      try {
        receipt = receipts.firstWhere(
          (recx) => recx.uuid == rec.receiptUuid,
        );
      } catch (e) {
        receipt = null; // receipt not found
      }

      if (receipt != null) {
        recordss.add(rec);
      }
    }

    if (weekStartDate != null) {
      final weekStartLocal = weekStartDate!;
      final weekEndLocal = weekStartLocal.add(
        const Duration(days: 7),
      );

      if (authorization(
        authorized:
            Authorizations().viewAllTransactionRecords,
      )) {
        return recordss.where((record) {
          final created = record.createdAt.toLocal();
          return !created.isBefore(weekStartLocal) &&
              created.isBefore(weekEndLocal);
        }).toList();
      } else {
        return recordss.where((record) {
          final created = record.createdAt.toLocal();
          return !created.isBefore(weekStartLocal) &&
              created.isBefore(weekEndLocal) &&
              record.staffId == currentUser().userId;
        }).toList();
      }
    }

    final localNow = DateTime.now();
    final localTarget = singleDay?.toLocal() ?? localNow;

    final startOfDay = DateTime(
      localTarget.year,
      localTarget.month,
      localTarget.day,
    );
    final endOfDay = startOfDay.add(
      const Duration(days: 1),
    );
    if (authorization(
      authorized:
          Authorizations().viewAllTransactionRecords,
    )) {
      return recordss.where((record) {
        final created = record.createdAt.toLocal();
        return !created.isBefore(startOfDay) &&
            created.isBefore(endOfDay);
      }).toList();
    } else {
      return recordss.where((record) {
        final created = record.createdAt.toLocal();
        return !created.isBefore(startOfDay) &&
            created.isBefore(endOfDay) &&
            record.staffId == currentUser().userId;
      }).toList();
    }
  }

  //
  //
  //

  double getTotalRevenueForSelectedDay(
    List<TempMainReceipt> receiptss,
  ) {
    double tempTotalRevenue = 0;

    for (var receipt in returnOwnReceiptsByDayOrWeek(
      // context,
      receiptss,
    )) {
      tempTotalRevenue += getTotalMainRevenueReceipt(
        receipt,
      );
    }

    return tempTotalRevenue;
  }

  double getTotalRevenueForSelectedDayAll({
    String? staffId,
    String? customerId,
    String? subStaffId,
  }) {
    double tempTotalRevenue = 0;

    for (var receipt
        in (staffId != null
            ? returnReceipts().where(
              (rec) => rec.staffId == staffId,
            )
            : subStaffId != null
            ? returnReceipts().where(
              (rec) => rec.subStaffUuid == subStaffId,
            )
            : customerId != null
            ? returnReceipts().where(
              (rec) => rec.customerUuid == customerId,
            )
            : returnReceipts())) {
      tempTotalRevenue += getTotalMainRevenueReceipt(
        receipt,
      );
    }

    return tempTotalRevenue;
  }
  //
  //
  //
  //

  double getTotalCostPriceForSelectedDay(
    BuildContext context,
    List<TempMainReceipt> receiptss,
    List<TempProductSaleRecord> productSalesRecords,
  ) {
    double tempTotalCostPrice = 0;

    for (var receipt in returnOwnReceiptsByDayOrWeek(
      // context,
      receiptss,
    )) {
      var productRecords =
          productSalesRecords
              .where(
                (record) =>
                    record.receiptUuid == receipt.uuid,
              )
              .toList();

      for (var record in productRecords) {
        tempTotalCostPrice += record.costPrice ?? 0;
      }
    }

    return tempTotalCostPrice;
  }

  double getTotalCostPriceForSelectedDayAll(
    BuildContext context,
    List<TempMainReceipt> receiptss,
    List<TempProductSaleRecord> productSalesRecords,
  ) {
    double tempTotalCostPrice = 0;

    for (var receipt in returnOwnReceiptsByDayOrWeekAll(
      // context,
      receiptss,
    )) {
      var productRecords =
          productSalesRecords
              .where(
                (record) =>
                    record.receiptUuid == receipt.uuid,
              )
              .toList();

      for (var record in productRecords) {
        tempTotalCostPrice += record.costPrice ?? 0;
      }
    }

    return tempTotalCostPrice;
  }

  double getVATForReceipt(TempMainReceipt receipt) {
    var vat =
        ((receipt.originalCost ?? 0) *
            ((receipt.vat ?? 0) / 100));
    return vat;
  }

  double getDiscountAmountForReceipt(
    TempMainReceipt receipt,
  ) {
    if (receipt.fixedDiscount != null) {
      return (receipt.fixedDiscount ?? 0);
    } else if (receipt.generalDiscount != null) {
      return (getOriginalCostReceipt(receipt) *
          ((receipt.generalDiscount ?? 0) / 100));
    } else {
      return 0;
    }
  }

  double getOriginalCostReceipt(TempMainReceipt receipt) {
    return receipt.originalCost ?? 0;
  }

  double getTotalMainRevenueReceipt(
    TempMainReceipt receipt,
  ) {
    var total = ((receipt.bank + receipt.cashAlt));

    return total;
  }
}
