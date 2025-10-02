import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_main_receipt/unsynced/created_receipts/created_receipts.dart';
import 'package:stockall/classes/temp_main_receipt/unsynced/deleted_customers/deleted_receipts.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_product_slaes_record/unsynced/created_records/created_records.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/main_receipt/main_receipt_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/created/created_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/deleted/deleted_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/updated/updated_receipts_func.dart';
import 'package:stockall/local_database/product_record_func.dart/product_record_func.dart';
import 'package:stockall/local_database/product_record_func.dart/unsync_funcs/created/created_records_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReceiptsProvider extends ChangeNotifier {
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
    print('Receipts Cleared');
    notifyListeners();
  }

  void clearRecords() {
    produtRecordSalesMain.clear();
    notifyListeners();
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
  Future<TempMainReceipt> createReceipt(
    TempMainReceipt receipt,
    BuildContext context,
  ) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      final res =
          await supabase
              .from('receipts')
              .insert(receipt.toJson())
              .select()
              .single();

      final newReceipt = TempMainReceipt.fromJson(res);

      // _receipts.add(newReceipt);
      notifyListeners();
      return newReceipt;
    } else {
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
    BuildContext context,
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
          print('Receipts Gotten');
        }

        _receipts =
            (data as List)
                .map(
                  (json) => TempMainReceipt.fromJson(json),
                )
                .toList();
        notifyListeners();
        await MainReceiptFunc().insertAllReceipts(
          _receipts,
        );
        if (context.mounted) {
          print('Loaded');
          await returnData(
            context,
            listen: false,
          ).getProducts(
            returnShopProvider(
              context,
              listen: false,
            ).userShop!.shopId!,
          );
          if (context.mounted) {
            await loadProductSalesRecord(
              returnShopProvider(
                context,
                listen: false,
              ).userShop!.shopId!,
            );
          }
        }
      } catch (e) {
        return [];
      }
    } else {
      _receipts = MainReceiptFunc().getReceipts();
      notifyListeners();
      if (context.mounted) {
        print('Offline Receipts Gotten');
        await returnData(
          context,
          listen: false,
        ).getProducts(
          returnShopProvider(
            context,
            listen: false,
          ).userShop!.shopId!,
        );
        if (context.mounted) {
          await loadProductSalesRecord(
            returnShopProvider(
              context,
              listen: false,
            ).userShop!.shopId!,
          );
        }
      }
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

  // UPDATE a receipt
  Future<void> updateReceipt(
    TempMainReceipt updated,
  ) async {
    // Use only the updatable fields
    final updateData = {
      'barcode': updated.barcode,
      'payment_method': updated.paymentMethod,
      'cash_alt': updated.cashAlt,
      'bank': updated.bank,
      'customer_id': updated.customerId,
      'customer_uuid': updated.customerUuid,
    };

    await supabase
        .from('receipts')
        .update(updateData)
        .eq('uuid', updated.uuid!);

    final index = _receipts.indexWhere(
      (r) => r.uuid == updated.uuid,
    );
    if (index != -1) {
      _receipts[index] = updated;
      notifyListeners();
    }
  }

  // DELETE a receipt
  Future<void> deleteReceipt(
    String uuid,
    BuildContext context,
  ) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      await supabase.rpc(
        'delete_receipt_and_update_inventory_new',
        params: {'target_receipt_uuid': uuid},
      );
      var containsUpdate = UpdatedReceiptsFunc()
          .getReceiptIds()
          .where((rec) => rec.receiptUuid == uuid);
      if (containsUpdate.isNotEmpty) {
        await UpdatedReceiptsFunc().deleteUpdatedReceipt(
          uuid,
        );
      }
    } else {
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
      await ProductRecordFunc().deleteRecordsInReceipt(
        uuid,
      );
    }

    print('✅ Receipt and inventory successfully updated.');

    if (context.mounted) {
      await loadReceipts(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
        context,
      );
    }
    notifyListeners();
  }

  // UPDATE a receipt
  Future<void> payCredit(String uuid) async {
    try {
      bool isOnline = await connectivity.isOnline();
      if (isOnline) {
        final updateData = {
          'is_invoice': false,
          'created_at':
              DateTime.now().toLocal().toIso8601String(),
        };

        final response =
            await supabase
                .from('receipts')
                .update(updateData)
                .eq('uuid', uuid)
                .select();

        if (response.isEmpty) {
          print('❌ No matching receipt to update.');
          return;
        }
        await MainReceiptFunc().payCredit(uuid);
      } else {
        await MainReceiptFunc().payCredit(uuid);
        await UpdatedReceiptsFunc().createUpdatedReceipt(
          uuid,
        );
      }
      final rec = receipts.firstWhere(
        (recc) => recc.uuid! == uuid,
      );
      rec.isInvoice = false;
      print('✅ Receipt updated successfully.');
      notifyListeners();
    } catch (e) {
      print('❌ Error updating receipt: $e');
    }
  }

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
        final payload =
            tempReceipts
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
            returnShopProvider(
              context,
              listen: false,
            ).userShop!.shopId!,
            context,
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
            returnShopProvider(
              context,
              listen: false,
            ).userShop!.shopId!,
            context,
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
            returnShopProvider(
              context,
              listen: false,
            ).userShop!.shopId!,
            context,
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
    BuildContext context,
  ) async {
    bool isOnline = await connectivity.isOnline();
    final dataToInsert =
        records.map((e) => e.toJson()).toList();

    if (isOnline) {
      await supabase
          .from('product_sales')
          .insert(dataToInsert);
      await ProductRecordFunc().insertSalesProductRecords(
        records,
      );
    } else {
      await ProductRecordFunc().insertSalesProductRecords(
        records,
      );
      List<CreatedRecords> cRecords =
          records.map((r) {
            return CreatedRecords(record: r);
          }).toList();
      await CreatedRecordsFunc().insertAllRecords(cRecords);
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
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
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
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
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
        final payload =
            tempRecords
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

  // List<TempProductSaleRecord> productSaleRecords = [
  //   TempProductSaleRecord(
  //     customPriceSet: false,
  //     discount: 10,
  //     discountedAmount: 3000,
  //     originalCost: 5000,
  //     productRecordId: 1,
  //     createdAt: DateTime(2025, 5, 1, 10, 30),
  //     productId: 1,
  //     productName: '',
  //     shopId: 1,
  //     staffId: 'staff001',
  //     customerId: 1,
  //     staffName: 'Alice Johnson',
  //     recepitId: 2,
  //     quantity: 3,
  //     revenue: 4500.0,
  //     isProductManaged: true,
  //   ),
  //   TempProductSaleRecord(
  //     customPriceSet: false,
  //     discount: 10,
  //     discountedAmount: 2100,
  //     originalCost: 4000,
  //     productRecordId: 2,
  //     createdAt: DateTime(2025, 5, 3, 14, 15),
  //     productId: 2,
  //     productName: '',
  //     shopId: 1,
  //     staffId: 'staff002',
  //     customerId: 1,
  //     staffName: 'Bob Smith',
  //     recepitId: 1,
  //     quantity: 2,
  //     revenue: 3000.0,
  //     isProductManaged: true,
  //   ),
  //   TempProductSaleRecord(
  //     customPriceSet: false,
  //     discount: 10,
  //     discountedAmount: 5000,
  //     originalCost: 2500,
  //     productRecordId: 3,
  //     createdAt: DateTime(2025, 5, 5, 9, 0),
  //     productId: 3,
  //     productName: '',
  //     shopId: 2,
  //     staffId: 'staff003',
  //     customerId: 2,
  //     staffName: 'Chinwe Okafor',
  //     recepitId: 3,
  //     quantity: 5,
  //     revenue: 7500.0,
  //     isProductManaged: true,
  //   ),
  // ];

  // List<TempProductSaleRecord> getOwnProductSalesRecord(
  //   BuildContext context,
  // ) {
  //   return returnProductSalesRecordsByDate(context)
  //       .where(
  //         (record) =>
  //             record.shopId ==
  //             returnShopProvider(
  //               context,
  //               listen: false,
  //             ).returnShop(userId()).shopId,
  //       )
  //       .toList();
  // }

  // List<TempProductSaleRecord>
  // returnProductSalesRecordsByDate(BuildContext context) {
  //   final sortedList =
  //       productSaleRecords.toList()..sort(
  //         (a, b) => b.createdAt.compareTo(a.createdAt),
  //       );
  //   return sortedList;
  // }

  // List<TempProductSaleRecord> getProductRecordsByReceiptId(
  //   int receiptId,
  //   BuildContext context,
  // ) {
  //   return getOwnProductSalesRecord(context)
  //       .where((product) => product.recepitId == receiptId)
  //       .toList();
  // }

  // void createProductSalesRecord(
  //   BuildContext context,
  //   int newReceiptId,
  //   String newReceiptUuid,
  //   String? customerUuid,
  // ) {
  //   for (var item
  //       in returnSalesProvider(
  //         context,
  //         listen: false,
  //       ).cartItems) {
  //     productSaleRecords.add(
  //       TempProductSaleRecord(
  //         customPriceSet: item.item.setCustomPrice,
  //         productName: '',
  //         discount: item.discount,
  //         originalCost: item.totalCost(),
  //         customerUuid: customerUuid,
  //         discountedAmount: item.discountCost(),
  //         productRecordId: productSaleRecords.length + 1,
  //         createdAt: DateTime.now(),
  //         productId: item.item.id!,
  //         productUuid: item.item.uuid!,
  //         receiptUuid: newReceiptUuid,
  //         shopId: item.item.shopId,
  //         staffId: 'staffId',
  //         staffName: 'staffName',
  //         recepitId: newReceiptId,
  //         quantity: item.quantity,
  //         revenue: item.revenue(),
  //         isProductManaged: true,
  //       ),
  //     );
  //   }

  //   notifyListeners();
  // }

  bool returnInvoice = false;

  void switchReturnInvoice(bool value) {
    returnInvoice = value;
    notifyListeners();
  }

  List<TempMainReceipt> returnReceipts(
    BuildContext context,
  ) {
    if (!returnInvoice) {
      return returnOwnReceiptsByDayOrWeekInvoice(
            context,
            receipts,
          )
          .where((receipt) => receipt.isInvoice == false)
          .toList();
    } else {
      return receipts
          .where((receipt) => receipt.isInvoice == true)
          .toList();
    }
  }

  List<TempMainReceipt> returnOwnReceiptsByDayOrWeek(
    BuildContext context,
    List<TempMainReceipt> receipts,
  ) {
    if (weekStartDate != null) {
      final weekStartLocal = weekStartDate!;
      final weekEndLocal = weekStartLocal.add(
        const Duration(days: 7),
      );

      return receipts.where((receipt) {
        final created =
            receipt.createdAt
                .toLocal(); // convert UTC to local
        return !created.isBefore(weekStartLocal) &&
            created.isBefore(weekEndLocal);
      }).toList();
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

    return receipts
        .where((receipt) {
          final created =
              receipt.createdAt
                  .toLocal(); // ALWAYS convert to local
          final inRange =
              !created.isBefore(startOfDay) &&
              created.isBefore(endOfDay);

          return inRange;
        })
        .toList()
        .where((receipt) => receipt.isInvoice == false)
        .toList();
  }

  List<TempMainReceipt> returnOwnReceiptsByDayOrWeekAll(
    BuildContext context,
    List<TempMainReceipt> receipts,
  ) {
    if (weekStartDate != null) {
      final weekStartLocal = weekStartDate!;
      final weekEndLocal = weekStartLocal.add(
        const Duration(days: 7),
      );

      return receipts.where((receipt) {
        final created =
            receipt.createdAt
                .toLocal(); // convert UTC to local
        return !created.isBefore(weekStartLocal) &&
            created.isBefore(weekEndLocal);
      }).toList();
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

    return receipts.where((receipt) {
      final created =
          receipt.createdAt
              .toLocal(); // ALWAYS convert to local
      final inRange =
          !created.isBefore(startOfDay) &&
          created.isBefore(endOfDay);

      return inRange;
    }).toList();
  }

  List<TempMainReceipt> returnOwnReceiptsByDayOrWeekInvoice(
    BuildContext context,
    List<TempMainReceipt> receipts,
  ) {
    if (weekStartDate != null) {
      final weekStartLocal = weekStartDate!;
      final weekEndLocal = weekStartLocal.add(
        const Duration(days: 7),
      );

      return receipts.where((receipt) {
        final created =
            receipt.createdAt
                .toLocal(); // convert UTC to local
        return !created.isBefore(weekStartLocal) &&
            created.isBefore(weekEndLocal);
      }).toList();
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

    return receipts.where((receipt) {
      final created =
          receipt.createdAt
              .toLocal(); // ALWAYS convert to local
      final inRange =
          !created.isBefore(startOfDay) &&
          created.isBefore(endOfDay);

      return inRange;
    }).toList();
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
    BuildContext context,
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

      if (receipt != null && !receipt.isInvoice) {
        recordss.add(rec);
      }
    }

    if (weekStartDate != null) {
      final weekStartLocal = weekStartDate!;
      final weekEndLocal = weekStartLocal.add(
        const Duration(days: 7),
      );

      return recordss.where((record) {
        final created = record.createdAt.toLocal();
        return !created.isBefore(weekStartLocal) &&
            created.isBefore(weekEndLocal);
      }).toList();
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

    return recordss.where((record) {
      final created = record.createdAt.toLocal();
      return !created.isBefore(startOfDay) &&
          created.isBefore(endOfDay);
    }).toList();
  }

  //
  //
  //

  double getTotalRevenueForSelectedDay(
    BuildContext context,
    List<TempMainReceipt> receiptss,
    List<TempProductSaleRecord> productSalesRecords,
  ) {
    double tempTotalRevenue = 0;

    for (var receipt in returnOwnReceiptsByDayOrWeek(
      context,
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
        tempTotalRevenue += record.revenue;
      }
    }

    return tempTotalRevenue;
  }

  double getTotalRevenueForSelectedDayAll(
    BuildContext context,
    List<TempMainReceipt> receiptss,
    List<TempProductSaleRecord> productSalesRecords,
  ) {
    double tempTotalRevenue = 0;

    for (var receipt in returnReceipts(context)) {
      var productRecords =
          productSalesRecords
              .where(
                (record) =>
                    record.receiptUuid == receipt.uuid,
              )
              .toList();

      for (var record in productRecords) {
        tempTotalRevenue += record.revenue;
      }
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
      context,
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
      context,
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

  double getSubTotalRevenueForReceipt(
    BuildContext context,
    List<TempProductSaleRecord> records,
  ) {
    double tempRev = 0;

    for (var bean in records) {
      tempRev += bean.originalCost!;
    }
    return tempRev;
  }

  double getTotalMainRevenueReceipt(
    List<TempProductSaleRecord> records,
    BuildContext context,
  ) {
    double tempTotal = 0;

    for (var productRecord in records) {
      tempTotal += productRecord.revenue;
    }

    return tempTotal;
  }
}
