import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_main_receipt/unsynced/created_receipts/created_receipts.dart';
import 'package:stockall/classes/temp_main_receipt/unsynced/deleted_customers/deleted_receipts.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
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
import 'package:stockall/pages/report/general_report/class/general_report_class.dart';
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
    // bool isOnline = await connectivity.isOnline();
    // if (isOnline) {
    //   print('Inner Receipt Online Started');
    //   final res =
    //       await supabase
    //           .from('receipts')
    //           .upsert(
    //             receipt.toJson(),
    //             onConflict:
    //                 'uuid', // match existing row by uuid
    //           )
    //           .select()
    //           .single();

    //   print('Inner Receipt Online Finished');
    //   print('Casting Started');
    //   try {
    //     final newReceipt = TempMainReceipt.fromJson(res);
    //     notifyListeners();
    //     return newReceipt;
    //   } catch (e) {
    //     print('❌❌ Create Receipt Error: ${e.toString()}');
    //     return null;
    //   }
    // } else {
    // receipt.createdAt = DateTime.now();
    await MainReceiptFunc().createReceipt(receipt);
    await CreatedReceiptsFunc().createReceipts(
      CreatedReceipts(receipt: receipt),
    );
    notifyListeners();
    return receipt;
    // }
  }

  // READ all receipts for a shop
  Future<List<TempMainReceipt>> loadReceipts(
    int shopId,
  ) async {
    bool isOnline = await connectivity.isOnline();
    List<Map<String, dynamic>> tempList = [];
    if (isOnline && returnData().isSynced() == 1) {
      await MainReceiptFunc().clearReceipts();
      try {
        final data = await supabase
            .from('receipts')
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false)
            .range(0, 1000);
        tempList.addAll(data);
        print('Receipts Gotten ${tempList.length}');

        if (data.length >= 1000) {
          final data2 = await supabase
              .from('receipts')
              .select()
              .eq('shop_id', shopId)
              .order('created_at', ascending: false)
              .range(1001, 2000);
          tempList.addAll(data2);
          print(
            'Receipts Gotten Second ${tempList.length}',
          );
        }

        _receipts =
            (tempList as List)
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

  Future<List<TempMainReceipt>> loadReceiptsOffline(
    int shopId,
  ) async {
    _receipts = MainReceiptFunc().getReceipts();
    print('Offline Receipts Gotten');
    await returnInvoicesProvider().loadInvoicesOffline(
      returnShopProvider().userShop()!.shopId!,
    );
    await returnData().getProductsOffline(
      returnShopProvider().userShop()!.shopId!,
    );
    await loadProductSalesRecordOffline(
      returnShopProvider().userShop()!.shopId!,
    );
    notifyListeners();

    notifyListeners();
    return _receipts;
  }

  DateTime? dateSet;

  void clearDate() {
    dateSet = null;
    rangeStartDate = null;
    rangeEndDate = null;
    notifyListeners();
  }

  void setDate(DateTime date) {
    if (dateSet == null) {
      dateSet = date;
      rangeStartDate = null;
      rangeEndDate = null;
      print('Date set: $date');
    } else {
      dateSet = null;
      print('Date Cleared');
    }
    notifyListeners();
  }

  DateTime? rangeStartDate;
  DateTime? rangeEndDate;

  void setRange(DateTime rangeStart, DateTime endOfrange) {
    rangeStartDate = rangeStart;
    rangeEndDate = endOfrange;
    print(
      'Date Range set: Start: $rangeStart End: $endOfrange ',
    );
    dateSet = null;
    notifyListeners();
  }

  // DELETE a receipt
  Future<int> deleteReceipt(
    TempMainReceipt receipt,
    List<String> productNames,
    // BuildContext context,
  ) async {
    try {
      print('Deleting Receipt');
      // bool isOnline = await connectivity.isOnline();
      // if (isOnline) {
      //   print('Deleting Receipt Online');
      //   await supabase.rpc(
      //     'delete_receipt_and_update_inventory_new',
      //     params: {'target_receipt_uuid': receipt.uuid},
      //   );
      //   print('Finished Deleting Receipt Online');
      //   var containsUpdate = UpdatedReceiptsFunc()
      //       .getReceiptIds()
      //       .where(
      //         (rec) => rec.receiptUuid == receipt.uuid,
      //       );
      //   if (containsUpdate.isNotEmpty) {
      //     await UpdatedReceiptsFunc().deleteUpdatedReceipt(
      //       receipt.uuid!,
      //     );
      //   }
      // } else {
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
      // }
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

      await loadReceiptsOffline(
        returnShopProvider().userShop()!.shopId!,
      );

      print('Totally Finished Deleting Receipt');
      notifyListeners();
      return 1;
    } catch (e) {
      print('Error Deleting Receipt: ${e.toString()}');
      return 0;
    }
  }

  // DELETE a receipt
  Future<void> deleteReceiptWithoutUpdatingInventory(
    String uuid,
    // BuildContext context,
  ) async {
    print('Deleting Receipt 2');
    // bool isOnline = await connectivity.isOnline();
    // if (isOnline) {
    //   print('Deleting Receipt 2 Online');
    //   await supabase.rpc(
    //     'delete_receipt_without_updating_inventory',
    //     params: {'target_receipt_uuid': uuid},
    //   );
    //   print('Finished Deleting Receipt 2 Online');
    //   var containsUpdate = UpdatedReceiptsFunc()
    //       .getReceiptIds()
    //       .where((rec) => rec.receiptUuid == uuid);
    //   if (containsUpdate.isNotEmpty) {
    //     await UpdatedReceiptsFunc().deleteUpdatedReceipt(
    //       uuid,
    //     );
    //   }
    // } else {
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
    // }

    print(
      '✅ Receipt and inventory successfully Delete and Updated.',
    );

    await loadReceiptsOffline(
      returnShopProvider().userShop()!.shopId!,
    );

    print('Totally Finished Deleting Receipt');
    notifyListeners();
  }

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

  List<TempProductSaleRecord> getProductRecordsNoVoid() {
    return _sales
        .where((item) => item.isVoid != true)
        .toList();
  }

  List<TempProductSaleRecord> getProductRecordsVoid() {
    return _sales
        .where((item) => item.isVoid == true)
        .toList();
  }

  // CREATE a new product sale record
  Future<void> createProductSaleRecord(
    List<TempProductSaleRecord> records,
    // BuildContext context,
  ) async {
    // bool isOnline = await connectivity.isOnline();
    print('About to Start Mapping');
    try {
      // final dataToInsert =
      //     records.map((e) => e.toJson()).toList();
      // print('Finished Mapping');

      // if (isOnline) {
      //   print('About to Create Product Sales Online');
      //   await supabase
      //       .from('product_sales')
      //       .upsert(dataToInsert, onConflict: 'uuid');
      //   await ProductRecordFunc().insertSalesProductRecords(
      //     records,
      //   );
      //   print('Finished Creating Product Sales Online');
      // } else {
      print('About to Create Product Sales Offline');
      var newRecords =
          records.map((rec) {
            // rec.createdAt = DateTime.now();

            return rec;
          }).toList();
      await ProductRecordFunc().insertSalesProductRecords(
        newRecords,
      );
      List<CreatedRecords> cRecords =
          newRecords.map((r) {
            return CreatedRecords(record: r);
          }).toList();
      await CreatedRecordsFunc().insertAllRecords(cRecords);
      print('Finished Creating Product Sales Offline');
      // }
    } catch (e) {
      print('Error ${e.toString()}');
    }

    notifyListeners();
  }

  // READ sales for a shop
  Future<List<TempProductSaleRecord>>
  loadProductSalesRecord(int shopId) async {
    bool isOnline = await connectivity.isOnline();
    List<Map<String, dynamic>> tempList = [];
    if (isOnline && returnData().isSynced() == 1) {
      final data = await supabase
          .from('product_sales')
          .select()
          .eq('shop_id', shopId)
          .order('created_at', ascending: false)
          .range(0, 1000);
      tempList.addAll(data);

      print(
        'Items Records gotten First: ${tempList.length}',
      );
      if (data.length >= 1000) {
        final data2 = await supabase
            .from('product_sales')
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false)
            .range(1001, 2000);
        tempList.addAll(data2);
        print(
          'Items Records gotten Second: ${tempList.length}',
        );
      }
      if (tempList.length >= 2000) {
        final data3 = await supabase
            .from('product_sales')
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false)
            .range(2001, 3000);
        tempList.addAll(data3);
        print(
          'Items Records gotten Third: ${tempList.length}',
        );
      }
      _sales =
          (tempList as List)
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

  Future<List<TempProductSaleRecord>>
  loadProductSalesRecordOffline(int shopId) async {
    _sales = ProductRecordFunc().getProductRecords();

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

  List<TempMainReceipt> departmentReceipts() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return receipts.where((cat) {
          return cat.departmentUuidNew ==
              returnDepartmentProvider()
                  .currentDepartment()
                  ?.uuid;
        }).toList();
      } else {
        if (returnDepartmentProvider()
                .currentDepartment()
                ?.uuid ==
            null) {
          return receipts;
        } else {
          return receipts.where((cat) {
            return cat.departmentUuidNew ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
            // }
          }).toList();
        }
      }
    } else {
      return receipts;
    }
  }

  int paymentMethod = 0;

  void selectPaymentMethod(int index) {
    paymentMethod = index;
    notifyListeners();
  }

  String paymentMethodText() {
    String tempMeth = 'All';
    switch (paymentMethod) {
      case 0:
        tempMeth = 'All';
        break;
      case 1:
        tempMeth = 'Cash';
        break;
      case 2:
        tempMeth = 'Bank';
        break;
      case 3:
        tempMeth = 'Split';
        break;
      default:
        tempMeth = 'All';
    }
    return tempMeth;
  }

  List<TempMainReceipt>
  returnReceiptsBasedOnPaymentMethod() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (rangeStartDate != null) {
        return departmentReceipts().where((receipt) {
          final created = receipt.createdAt.toLocal();
          return !created.isBefore(
                fourAm(rangeStartDate!),
              ) &&
              created.isBefore(
                fourAmNextDay(
                  rangeEndDate ??
                      resolveBusinessDate(DateTime.now()),
                ),
              );
        }).toList();
      } else {
        // final currentDate = dateSet ?? DateTime.now();
        final currentDate =
            dateSet ?? resolveBusinessDate(DateTime.now());

        return departmentReceipts()
            .where(
              (receipt) =>
                  !receipt.createdAt.isBefore(
                    fourAm(currentDate),
                  ) &&
                  receipt.createdAt.isBefore(
                    fourAmNextDay(currentDate),
                  ),
            )
            .toList();
      }
    } else {
      if (rangeStartDate != null) {
        if (authorization(
          authorized:
              Authorizations().viewAllTransactionRecords,
        )) {
          return receipts.where((receipt) {
            final created = receipt.createdAt.toLocal();
            return !created.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                created.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                );
          }).toList();
        } else {
          return receipts.where((receipt) {
            final created = receipt.createdAt.toLocal();
            return !created.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                created.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ) &&
                receipt.staffId == currentUser().userId;
          }).toList();
        }
      } else {
        final currentDate = dateSet ?? DateTime.now();

        if (authorization(
          authorized:
              Authorizations().viewAllTransactionRecords,
        )) {
          return receipts
              .where(
                (receipt) =>
                    !receipt.createdAt.isBefore(
                      fourAm(currentDate),
                    ) &&
                    !receipt.createdAt.isAfter(
                      fourAmNextDay(currentDate),
                    ),
              )
              .toList();
        } else {
          return receipts
              .where(
                (receipt) =>
                    !receipt.createdAt.isBefore(
                      fourAm(currentDate),
                    ) &&
                    !receipt.createdAt.isAfter(
                      fourAmNextDay(currentDate),
                    ) &&
                    receipt.staffId == currentUser().userId,
              )
              .toList();
        }
      }
    }
  }

  List<TempMainReceipt> returnOwnReceiptsByDayOrWeek() {
    if (paymentMethod == 3) {
      return returnReceiptsBasedOnPaymentMethod()
          .where((rec) => rec.paymentMethod == 'Split')
          .toList();
    } else if (paymentMethod == 1) {
      return returnReceiptsBasedOnPaymentMethod()
          .where((rec) => rec.paymentMethod == 'Cash')
          .toList();
    } else if (paymentMethod == 2) {
      return returnReceiptsBasedOnPaymentMethod()
          .where((rec) => rec.paymentMethod == 'Bank')
          .toList();
    } else {
      return returnReceiptsBasedOnPaymentMethod().toList();
    }
  }

  List<TempProductSaleRecord>
  returnProductsRecordByDayOrWeek() {
    if (rangeStartDate != null) {
      if (authorization(
        authorized:
            Authorizations().viewAllTransactionRecords,
      )) {
        return getProductRecordsNoVoid().where((record) {
          final created = record.createdAt.toLocal();
          return !created.isBefore(
                fourAm(rangeStartDate!),
              ) &&
              created.isBefore(
                fourAmNextDay(
                  rangeEndDate ??
                      resolveBusinessDate(DateTime.now()),
                ),
              );
        }).toList();
      } else {
        return getProductRecordsNoVoid().where((record) {
          final created = record.createdAt.toLocal();
          return !created.isBefore(
                fourAm(rangeStartDate!),
              ) &&
              created.isBefore(
                fourAmNextDay(
                  rangeEndDate ??
                      resolveBusinessDate(DateTime.now()),
                ),
              ) &&
              record.staffId == currentUser().userId;
        }).toList();
      }
    }

    var currentDate = dateSet ?? DateTime.now();
    if (authorization(
      authorized:
          Authorizations().viewAllTransactionRecords,
    )) {
      return getProductRecordsNoVoid()
          .where(
            (record) =>
                !record.createdAt.isBefore(
                  fourAm(currentDate),
                ) &&
                !record.createdAt.isAfter(
                  fourAmNextDay(currentDate),
                ),
          )
          .toList();
    } else {
      return getProductRecordsNoVoid()
          .where(
            (record) =>
                !record.createdAt.isBefore(
                  fourAm(currentDate),
                ) &&
                !record.createdAt.isAfter(
                  fourAmNextDay(currentDate),
                ) &&
                record.staffId == currentUser().userId,
          )
          .toList();
    }
  }

  List<TempProductSaleRecord>
  returnProductsRecordByDayOrWeekVoid() {
    if (rangeStartDate != null) {
      if (authorization(
        authorized:
            Authorizations().viewAllTransactionRecords,
      )) {
        return getProductRecordsVoid().where((record) {
          final created = record.createdAt.toLocal();
          return !created.isBefore(
                fourAm(rangeStartDate!),
              ) &&
              created.isBefore(
                fourAmNextDay(
                  rangeEndDate ??
                      resolveBusinessDate(DateTime.now()),
                ),
              );
        }).toList();
      } else {
        return getProductRecordsVoid().where((record) {
          final created = record.createdAt.toLocal();
          return !created.isBefore(
                fourAm(rangeStartDate!),
              ) &&
              created.isBefore(
                fourAmNextDay(
                  rangeEndDate ??
                      resolveBusinessDate(DateTime.now()),
                ),
              ) &&
              record.staffId == currentUser().userId;
        }).toList();
      }
    }

    var currentDate = dateSet ?? DateTime.now();
    if (authorization(
      authorized:
          Authorizations().viewAllTransactionRecords,
    )) {
      return getProductRecordsVoid()
          .where(
            (record) =>
                !record.createdAt.isBefore(
                  fourAm(currentDate),
                ) &&
                !record.createdAt.isAfter(
                  fourAmNextDay(currentDate),
                ),
          )
          .toList();
    } else {
      return getProductRecordsVoid()
          .where(
            (record) =>
                !record.createdAt.isBefore(
                  fourAm(currentDate),
                ) &&
                !record.createdAt.isAfter(
                  fourAmNextDay(currentDate),
                ) &&
                record.staffId == currentUser().userId,
          )
          .toList();
    }
  }

  //
  //
  //

  double getTotalRevenueForSelectedDay(
    // List<TempMainReceipt> receipts,
  ) {
    double tempTotalRevenue = 0;

    for (var receipt in returnOwnReceiptsByDayOrWeek(
      // context,
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
            ? returnOwnReceiptsByDayOrWeek().where(
              (rec) => rec.staffId == staffId,
            )
            : subStaffId != null
            ? returnOwnReceiptsByDayOrWeek().where(
              (rec) => rec.subStaffUuid == subStaffId,
            )
            : customerId != null
            ? returnOwnReceiptsByDayOrWeek().where(
              (rec) => rec.customerUuid == customerId,
            )
            : returnOwnReceiptsByDayOrWeek())) {
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
    List<TempMainReceipt> receipts,
    List<TempProductSaleRecord> productSalesRecords,
  ) {
    double tempTotalCostPrice = 0;

    for (var receipt in returnOwnReceiptsByDayOrWeek(
      // context,
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

  // String unitText({required TempProductSaleRecord record}){
  //   if (record.useGroupQuantity == true) {

  //   }
  // }

  //
  //
  //
  ////////////  GENERAL REPORT PRINTING  // // // /  /  // // //

  List<GeneralReportSalesSummaryItem>
  returnGeneralReportSalesSummary() {
    final List<TempProductSaleRecord> records =
        returnProductsRecordByDayOrWeek();

    Map<String, List<TempProductSaleRecord>> grouped = {};

    for (var item in records) {
      if (returnShopProvider()
              .userShop()
              ?.manageInventoryStorage ==
          true) {
        List<TempProductClass> productList =
            returnData().productListMain
                .where(
                  (pro) => pro.uuid == item.productUuid,
                )
                .toList();
        if (productList.isNotEmpty) {
          TempProductClass product = productList.first;
          if (product.storageUuid != null) {
            final uuid = product.storageUuid ?? '';
            // print(
            //   '✅ Product Storage Exist: ${product.name}',
            // );

            grouped.putIfAbsent(uuid, () => []);
            grouped[uuid]!.add(item);
          } else {
            // print(
            //   '🔥 Product Storage Uuid does not Exist: ${product.name}',
            // );
            final uuid = product.uuid ?? '';

            grouped.putIfAbsent(uuid, () => []);
            grouped[uuid]!.add(item);
          }
        } else {
          final uuid = item.productUuid ?? '';
          // print(
          //   '❌ Product Does Not Exist: ${item.productName}',
          // );

          grouped.putIfAbsent(uuid, () => []);
          grouped[uuid]!.add(item);
        }
      } else {
        final uuid = item.productUuid ?? '';

        grouped.putIfAbsent(uuid, () {
          return [];
        });
        grouped[uuid]!.add(item);
      }
    }

    List<GeneralReportSalesSummaryItem> result = [];

    grouped.forEach((uuid, items) {
      double totalQtty = items.fold(
        0,
        (sum, e) => sum + e.quantity,
      );

      double totalCost = items.fold(
        0,
        (sum, e) => sum + e.revenue,
      );

      double totalCostPrice = items.fold(
        0,
        (sum, e) => sum + (e.costPrice ?? 0),
      );

      String itemName() {
        List<TempProductClass> products =
            returnData().productListMain
                .where(
                  (pro) =>
                      pro.uuid == items.first.productUuid,
                )
                .toList();
        if (products.isNotEmpty) {
          TempProductClass product = products.first;
          if (returnShopProvider()
                  .userShop()
                  ?.manageInventoryStorage ==
              true) {
            var storageItems =
                returnStorageProductProvider()
                    .storageProductListMain
                    .where(
                      (item) =>
                          item.uuid == product.storageUuid,
                    )
                    .toList();
            if (storageItems.isNotEmpty) {
              return storageItems.first.name;
            } else {
              return product.name;
            }
          } else {
            return product.name;
          }
        } else {
          return items.first.productName;
        }
      }

      result.add(
        GeneralReportSalesSummaryItem(
          costPrice: totalCostPrice,
          itemName: itemName(),
          itemUuid: uuid,
          quantity: totalQtty,
          totalCost: totalCost,
          departmentName:
              items.first.departmentName ??
              'Departmant Not Set',
          departmentUuid:
              items.first.departmentUuid ??
              'Department Not Set',
          staffName: items.first.staffName,
          staffUuid: items.first.staffId,
        ),
      );
    });
    result.sort((a, b) => b.quantity.compareTo(a.quantity));
    return result;
  }

  //
  //
  //
  //
  List<GeneralReportSalesSummaryItem>
  returnGeneralReportSalesSummaryVoid() {
    final List<TempProductSaleRecord> records =
        returnProductsRecordByDayOrWeekVoid();

    Map<String, List<TempProductSaleRecord>> grouped = {};

    for (var item in records) {
      if (returnShopProvider()
              .userShop()
              ?.manageInventoryStorage ==
          true) {
        List<TempProductClass> productList =
            returnData().productListMain
                .where(
                  (pro) => pro.uuid == item.productUuid,
                )
                .toList();
        if (productList.isNotEmpty) {
          TempProductClass product = productList.first;
          if (product.storageUuid != null) {
            final uuid = product.storageUuid ?? '';
            // print(
            //   '✅ Product Storage Exist: ${product.name}',
            // );

            grouped.putIfAbsent(uuid, () => []);
            grouped[uuid]!.add(item);
          } else {
            // print(
            //   '🔥 Product Storage Uuid does not Exist: ${product.name}',
            // );
            final uuid = product.uuid ?? '';

            grouped.putIfAbsent(uuid, () => []);
            grouped[uuid]!.add(item);
          }
        } else {
          final uuid = item.productUuid ?? '';
          // print(
          //   '❌ Product Does Not Exist: ${item.productName}',
          // );

          grouped.putIfAbsent(uuid, () => []);
          grouped[uuid]!.add(item);
        }
      } else {
        final uuid = item.productUuid ?? '';

        grouped.putIfAbsent(uuid, () {
          return [];
        });
        grouped[uuid]!.add(item);
      }
    }

    List<GeneralReportSalesSummaryItem> result = [];

    grouped.forEach((uuid, items) {
      double totalQtty = items.fold(
        0,
        (sum, e) => sum + e.quantity,
      );

      double totalCost = items.fold(
        0,
        (sum, e) => sum + e.revenue,
      );

      double totalCostPrice = items.fold(
        0,
        (sum, e) => sum + (e.originalCost ?? 0),
      );

      String itemName() {
        List<TempProductClass> products =
            returnData().productListMain
                .where(
                  (pro) =>
                      pro.uuid == items.first.productUuid,
                )
                .toList();
        if (products.isNotEmpty) {
          TempProductClass product = products.first;
          if (returnShopProvider()
                  .userShop()
                  ?.manageInventoryStorage ==
              true) {
            var storageItems =
                returnStorageProductProvider()
                    .storageProductListMain
                    .where(
                      (item) =>
                          item.uuid == product.storageUuid,
                    )
                    .toList();
            if (storageItems.isNotEmpty) {
              return storageItems.first.name;
            } else {
              return product.name;
            }
          } else {
            return product.name;
          }
        } else {
          return items.first.productName;
        }
      }

      result.add(
        GeneralReportSalesSummaryItem(
          costPrice: totalCostPrice,
          itemName: itemName(),
          itemUuid: uuid,
          quantity: totalQtty,
          totalCost: totalCost,
          departmentName:
              items.first.departmentName ??
              'Departmant Not Set',
          departmentUuid:
              items.first.departmentUuid ??
              'Department Not Set',
          staffName: items.first.staffName,
          staffUuid: items.first.staffId,
        ),
      );
    });
    result.sort((a, b) => b.quantity.compareTo(a.quantity));
    return result;
  }

  List<GeneralReportSalesSummaryItem>
  returnGeneralReportSalesSummaryNoDepartment() {
    final List<TempProductSaleRecord> records =
        returnProductsRecordByDayOrWeek()
            .where((item) => item.departmentUuid == null)
            .toList();

    Map<String, List<TempProductSaleRecord>> grouped = {};

    for (var item in records) {
      if (returnShopProvider()
              .userShop()
              ?.manageInventoryStorage ==
          true) {
        List<TempProductClass> productList =
            returnData().productListMain
                .where(
                  (pro) => pro.uuid == item.productUuid,
                )
                .toList();
        if (productList.isNotEmpty) {
          TempProductClass product = productList.first;
          if (product.storageUuid != null) {
            final uuid = product.storageUuid ?? '';
            // print(
            //   '✅ Product Storage Exist: ${product.name}',
            // );

            grouped.putIfAbsent(uuid, () => []);
            grouped[uuid]!.add(item);
          } else {
            // print(
            //   '🔥 Product Storage Uuid does not Exist: ${product.name}',
            // );
            final uuid = product.uuid ?? '';

            grouped.putIfAbsent(uuid, () => []);
            grouped[uuid]!.add(item);
          }
        } else {
          final uuid = item.productUuid ?? '';
          // print(
          //   '❌ Product Does Not Exist: ${item.productName}',
          // );

          grouped.putIfAbsent(uuid, () => []);
          grouped[uuid]!.add(item);
        }
      } else {
        final uuid = item.productUuid ?? '';

        grouped.putIfAbsent(uuid, () {
          return [];
        });
        grouped[uuid]!.add(item);
      }
    }

    List<GeneralReportSalesSummaryItem> result = [];

    grouped.forEach((uuid, items) {
      double totalQtty = items.fold(
        0,
        (sum, e) => sum + e.quantity,
      );

      double totalCost = items.fold(
        0,
        (sum, e) => sum + e.revenue,
      );

      double totalCostPrice = items.fold(
        0,
        (sum, e) => sum + (e.originalCost ?? 0),
      );

      String itemName() {
        List<TempProductClass> products =
            returnData().productListMain
                .where(
                  (pro) =>
                      pro.uuid == items.first.productUuid,
                )
                .toList();
        if (products.isNotEmpty) {
          TempProductClass product = products.first;
          if (returnShopProvider()
                  .userShop()
                  ?.manageInventoryStorage ==
              true) {
            var storageItems =
                returnStorageProductProvider()
                    .storageProductListMain
                    .where(
                      (item) =>
                          item.uuid == product.storageUuid,
                    )
                    .toList();
            if (storageItems.isNotEmpty) {
              return storageItems.first.name;
            } else {
              return product.name;
            }
          } else {
            return product.name;
          }
        } else {
          return items.first.productName;
        }
      }

      result.add(
        GeneralReportSalesSummaryItem(
          costPrice: totalCostPrice,
          itemName: itemName(),
          itemUuid: uuid,
          quantity: totalQtty,
          totalCost: totalCost,
          departmentName:
              items.first.departmentName ??
              'Departmant Not Set',
          departmentUuid:
              items.first.departmentUuid ??
              'Department Not Set',
          staffName: items.first.staffName,
          staffUuid: items.first.staffId,
        ),
      );
    });
    result.sort((a, b) => b.quantity.compareTo(a.quantity));
    return result;
  }

  //
  //
  //

  List<GeneralReportSalesSummaryItem>
  returnGeneralReportSalesSummaryByDepartment(
    String departmentUuid,
  ) {
    return returnGeneralReportSalesSummary()
        .where(
          (item) => item.departmentUuid == departmentUuid,
        )
        .toList();
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

  List<GeneralReportSalesSummaryItemStaff>
  returnGeneralReportSalesSummaryByStaff() {
    final List<TempProductSaleRecord> records =
        returnProductsRecordByDayOrWeek();

    Map<String, List<TempProductSaleRecord>> grouped = {};

    // STEP 1: Group by staff + product
    for (var item in records) {
      final staffId = item.staffId;
      final productId =
          item.productUuid ?? 'unknown_product';

      final key = '$staffId|$productId';

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }

    // STEP 2: Build result
    List<GeneralReportSalesSummaryItemStaff> result = [];

    grouped.forEach((key, items) {
      final first = items.first;

      double totalQuantity = items.fold(
        0,
        (sum, e) => sum + (e.quantity),
      );

      double totalCost = items.fold(
        0,
        (sum, e) => sum + (e.revenue),
      );

      result.add(
        GeneralReportSalesSummaryItemStaff(
          itemName: first.productName,
          itemUuid: first.productUuid ?? 'unknown_product',
          staffName: first.staffName,
          staffUuid: first.staffId,
          quantity: totalQuantity,
          totalCost: totalCost,
        ),
      );
    });
    result.sort((a, b) => b.quantity.compareTo(a.quantity));

    return result;
  }
}
