import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_customer_account_receipts/customer_account_receipts.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_main_receipt/unsynced/created_receipts/created_receipts.dart';
import 'package:stockall/classes/temp_main_receipt/unsynced/deleted_customers/deleted_receipts.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/local_database/customer_account_receipts/customer_account_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/main_receipt_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/created/created_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/deleted/deleted_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/updated/updated_receipts_func.dart';
import 'package:stockall/local_database/product_record_func.dart/product_record_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/general_report/class/general_report_class.dart';
import 'package:stockall/pages/report/sales_report_/receipt_sales_report/platforms/receipt_sales_report_desktop.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/services/lan/sync/lan_server_sync.dart';
import 'package:stockall/services/remote/remote_client.dart';
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
    mainLocalLog(
      'Receipt is ${value ? 'Loading on' : 'Loading Off'}',
    );
    notifyListeners();
  }
  //
  //
  //

  SupabaseClient get supabase => backend();
  final ConnectivityProvider connectivity =
      ConnectivityProvider();
  List<TempMainReceipt> _receipts = [];
  List<TempMainReceipt> get receipts => _receipts;
  final Set<String> _fetchedDateKeys = {};
  int? _fetchedShopId;

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month}-${d.day}';

  bool _isRangeFetched(
    int shopId,
    DateTime start,
    DateTime end,
  ) {
    if (_fetchedShopId != shopId) return false;
    var cursor = DateTime(
      start.year,
      start.month,
      start.day,
    );
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      if (!_fetchedDateKeys.contains(_dateKey(cursor)))
        return false;
      cursor = cursor.add(const Duration(days: 1));
    }
    return true;
  }

  void _markRangeFetched(
    int shopId,
    DateTime start,
    DateTime end,
  ) {
    if (_fetchedShopId != shopId) {
      _fetchedDateKeys.clear();
      _fetchedShopId = shopId;
    }
    var cursor = DateTime(
      start.year,
      start.month,
      start.day,
    );
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      _fetchedDateKeys.add(_dateKey(cursor));
      cursor = cursor.add(const Duration(days: 1));
    }
  }

  void clearReceipts() {
    _receipts.clear();
    _fetchedDateKeys.clear();
    _fetchedShopId = null;
    mainLocalLog('Receipts Cleared');
    notifyListeners();
  }

  bool isLoaded = false;
  void load(bool value) {
    isLoaded = value;
    mainLocalLog(
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
    try {
      await mainLocalLog('Inner Receipt Creation Started');
      var barcode = returnOnlyDigits(uuidGen());
      receipt.barcode = barcode;
      await MainReceiptFunc().createReceipt(receipt);
      await CreatedReceiptsFunc().createReceipts(
        CreatedReceipts(receipt: receipt),
      );
      notifyListeners();
      if (receipt.customerUuid != null) {
        if (returnShopProvider()
                    .userShop()
                    ?.manageCustomerReward ==
                true &&
            !receipt.isInvoice &&
            receipt.invoiceUuid == null) {
          CustomerAccountReceipts customerAccountReceipt =
              CustomerAccountReceipts(
                receiptUuid: receipt.uuid,
                isBalance: false,
                isAdd: true,
                amount: receipt.getCustomerReward(),
                customerName: receipt.customerName,
                customerUuid: receipt.customerUuid,
              );
          await returnCustomerAccountReceiptsProvider()
              .createCustomerAccountReceipts(
                customerAccountReceipt:
                    customerAccountReceipt,
              );
        }

        if (returnShopProvider()
                    .userShop()
                    ?.manageCustomerAccount ==
                true &&
            (receipt.customerAccount ?? 0) > 0) {
          CustomerAccountReceipts customerAccountReceipt =
              CustomerAccountReceipts(
                receiptUuid: receipt.uuid,
                isBalance: true,
                isAdd: false,
                amount: receipt.customerAccount ?? 0,
                customerName: receipt.customerName,
                customerUuid: receipt.customerUuid,
              );
          await returnCustomerAccountReceiptsProvider()
              .createCustomerAccountReceipts(
                customerAccountReceipt:
                    customerAccountReceipt,
              );
        }
      }

      return receipt;
    } catch (e) {
      await mainLocalLog(
        'Error Creating Receipt: ${e.toString()}',
      );
      return null;
    }
    // }
  }

  // UPDATE an existing receipt
  Future<TempMainReceipt?> updateReceipt(
    TempMainReceipt receipt,
  ) async {
    try {
      await mainLocalLog('Inner Receipt Update Started');
      await MainReceiptFunc().createReceipt(receipt);
      var containsCreated =
          CreatedReceiptsFunc()
              .getReceipts()
              .where(
                (rec) => rec.receipt.uuid == receipt.uuid,
              )
              .toList();
      if (containsCreated.isNotEmpty) {
        await CreatedReceiptsFunc().createReceipts(
          CreatedReceipts(receipt: receipt),
        );
      } else {
        await UpdatedReceiptsFunc().createUpdatedReceipt(
          receipt.uuid!,
        );
      }

      // Re-evaluate customer rewards & accounts:
      List<CustomerAccountReceipts> accountReceipts =
          returnCustomerAccountReceiptsProvider()
              .customerAccountReceipts
              .where(
                (item) => item.receiptUuid == receipt.uuid,
              )
              .toList();
      if (accountReceipts.isEmpty) {
        accountReceipts =
            CustomerAccountReceiptsFunc()
                .getCustomerAccountReceipts()
                .where(
                  (item) =>
                      item.receiptUuid == receipt.uuid,
                )
                .toList();
      }
      if (accountReceipts.isNotEmpty) {
        await returnCustomerAccountReceiptsProvider()
            .deleteCustomerAccountReceipts(
              customerReceipts: accountReceipts,
              updateCustomerBalance: true,
            );
      }

      if (receipt.customerUuid != null) {
        if (returnShopProvider()
                    .userShop()
                    ?.manageCustomerReward ==
                true &&
            !receipt.isInvoice &&
            receipt.invoiceUuid == null) {
          CustomerAccountReceipts customerAccountReceipt =
              CustomerAccountReceipts(
                receiptUuid: receipt.uuid,
                isBalance: false,
                isAdd: true,
                amount: receipt.getCustomerReward(),
                customerName: receipt.customerName,
                customerUuid: receipt.customerUuid,
              );
          await returnCustomerAccountReceiptsProvider()
              .createCustomerAccountReceipts(
                customerAccountReceipt:
                    customerAccountReceipt,
              );
        }

        if (returnShopProvider()
                    .userShop()
                    ?.manageCustomerAccount ==
                true &&
            (receipt.customerAccount ?? 0) > 0) {
          CustomerAccountReceipts customerAccountReceipt =
              CustomerAccountReceipts(
                receiptUuid: receipt.uuid,
                isBalance: true,
                isAdd: false,
                amount: receipt.customerAccount ?? 0,
                customerName: receipt.customerName,
                customerUuid: receipt.customerUuid,
              );
          await returnCustomerAccountReceiptsProvider()
              .createCustomerAccountReceipts(
                customerAccountReceipt:
                    customerAccountReceipt,
              );
        }
      }

      await loadReceiptsOffline(receipt.shopId);
      notifyListeners();
      return receipt;
    } catch (e) {
      await mainLocalLog(
        'Error Updating Receipt: ${e.toString()}',
      );
      return null;
    }
  }

  Future<void> loadSingleReceipt({
    required String uuid,
  }) async {
    bool isOnline = await connectivity.isOnline();
    try {
      if (isOnline) {
        final data =
            await supabase
                .from('receipts')
                .select()
                .eq('uuid', uuid)
                .maybeSingle();
        if (data == null) {
          await mainLocalLog('Receipt Not Found');
          return;
        } else {
          TempMainReceipt tempMainReceipt =
              TempMainReceipt.fromJson(data);
          TempMainReceipt? existingReceipt =
              receipts
                      .where(
                        (rec) =>
                            rec.uuid ==
                            tempMainReceipt.uuid,
                      )
                      .isNotEmpty
                  ? receipts
                      .where(
                        (rec) =>
                            rec.uuid ==
                            tempMainReceipt.uuid,
                      )
                      .first
                  : null;
          if (existingReceipt != null) {
            await mainLocalLog('💖💖👏🥰Receipt Exists');
            receipts.remove(existingReceipt);
          }
          receipts.add(tempMainReceipt);
          receipts.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          );
          await mainLocalLog(
            '💖💖👏🥰 Single Receipt Loaded',
          );
        }
        notifyListeners();
      }
    } catch (e) {
      await mainLocalLog(
        'Error Fetching Single Receipt: ${e.toString()}',
      );
    }
  }

  // READ receipts for a shop (defaults to current business day; fetches older ranges on demand)
  Future<List<TempMainReceipt>> loadReceipts(
    int shopId, {
    bool forceRefresh = false,
    bool fetchAll = false,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await loadReceiptsOffline(shopId);
    final effectiveStart =
        startDate ??
        rangeStartDate ??
        dateSet ??
        resolveBusinessDate(DateTime.now());
    final effectiveEnd =
        endDate ??
        rangeEndDate ??
        dateSet ??
        effectiveStart;
    final windowStart = fourAm(effectiveStart);
    final windowEnd = fourAmNextDay(effectiveEnd);

    bool isOnline = await connectivity.isOnline();
    List<Map<String, dynamic>> tempList = [];
    if (isOnline && !LanServerSync.pullerActive && MainReceiptFunc().isSynced()) {
      if (!forceRefresh &&
          !fetchAll &&
          _isRangeFetched(
            shopId,
            effectiveStart,
            effectiveEnd,
          )) {
        return _receipts;
      }
      try {
        var baseQuery = supabase
            .from('receipts')
            .select()
            .eq('shop_id', shopId);
        if (!fetchAll) {
          baseQuery = baseQuery
              .gte(
                'created_at',
                windowStart.toUtc().toIso8601String(),
              )
              .lt(
                'created_at',
                windowEnd.toUtc().toIso8601String(),
              );
        }
        final data = await baseQuery
            .order('created_at', ascending: false)
            .range(0, 1000);
        tempList.addAll(data);
        await mainLocalLog(
          'Receipts Gotten ${tempList.length}',
        );

        if (data.length >= 1000) {
          var baseQuery2 = supabase
              .from('receipts')
              .select()
              .eq('shop_id', shopId);
          if (!fetchAll) {
            baseQuery2 = baseQuery2
                .gte(
                  'created_at',
                  windowStart.toUtc().toIso8601String(),
                )
                .lt(
                  'created_at',
                  windowEnd.toUtc().toIso8601String(),
                );
          }
          final data2 = await baseQuery2
              .order('created_at', ascending: false)
              .range(1001, 2000);
          tempList.addAll(data2);
          await mainLocalLog(
            'Receipts Gotten Second ${tempList.length}',
          );
        }

        final deletedReceiptUuids =
            DeletedReceiptsFunc()
                .getReceiptIds()
                .map((e) => e.receiptUuid)
                .toSet();

        final fetched =
            (tempList as List)
                .map(
                  (json) => TempMainReceipt.fromJson(json),
                )
                .where(
                  (rec) =>
                      rec.uuid != null &&
                      !deletedReceiptUuids.contains(
                        rec.uuid,
                      ),
                )
                .toList();

        if (fetchAll) {
          _receipts = fetched;
        } else {
          final fetchedUuids =
              fetched.map((e) => e.uuid).toSet();
          final outsideWindow =
              _receipts.where((rec) {
                if (fetchedUuids.contains(rec.uuid)) {
                  return false;
                }
                final inWindow =
                    !rec.createdAt.isBefore(windowStart) &&
                    rec.createdAt.isBefore(windowEnd);
                return !inWindow;
              }).toList();
          _receipts = [...fetched, ...outsideWindow]..sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          );
          _markRangeFetched(
            shopId,
            effectiveStart,
            effectiveEnd,
          );
        }

        await MainReceiptFunc().insertAllReceipts(
          _receipts,
        );
        await mainLocalLog('Loaded');
        await returnInvoicesProvider().loadInvoices(
          shopId,
          startDate: startDate,
          endDate: endDate,
        );
        final dataProvider = returnData();
        if (dataProvider.productListMain.isNotEmpty) {
          await dataProvider.syncProductsIncremental();
        } else {
          await dataProvider.getProducts(
            returnShopProvider().userShop()!.shopId!,
          );
        }
        await loadProductSalesRecord(
          returnShopProvider().userShop()!.shopId!,
        );
        notifyListeners();
      } catch (e) {
        await mainLocalLog(
          'Error Getting Receipts: ${e.toString()}',
        );
        return [];
      }
    } else {
      _receipts = MainReceiptFunc().getReceipts();
      await mainLocalLog('Offline Receipts Gotten');
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
    await mainLocalLog('Offline Receipts Gotten');
    await returnInvoicesProvider().loadInvoicesOffline(
      returnShopProvider().userShop()!.shopId!,
    );
    await returnData().getProductsOffline(
      returnShopProvider().userShop()!.shopId!,
    );
    // await loadProductSalesRecordOffline(
    //   returnShopProvider().userShop()!.shopId!,
    // );
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
      mainLocalLog('Date set: $date');
      final sid = returnShopProvider().userShop()?.shopId;
      if (sid != null &&
          !_isRangeFetched(sid, date, date)) {
        loadReceipts(sid, startDate: date, endDate: date);
      }
    } else {
      dateSet = null;
      mainLocalLog('Date Cleared');
    }
    notifyListeners();
  }

  DateTime? rangeStartDate;
  DateTime? rangeEndDate;

  void setRange(DateTime rangeStart, DateTime endOfrange) {
    rangeStartDate = rangeStart;
    rangeEndDate = endOfrange;
    mainLocalLog(
      'Date Range set: Start: $rangeStart End: $endOfrange ',
    );
    dateSet = null;
    final sid = returnShopProvider().userShop()?.shopId;
    if (sid != null &&
        !_isRangeFetched(sid, rangeStart, endOfrange)) {
      loadReceipts(
        sid,
        startDate: rangeStart,
        endDate: endOfrange,
      );
    }
    notifyListeners();
  }

  // DELETE a receipt
  Future<int> deleteReceipt(
    TempMainReceipt receipt,
    List<String> productNames,
  ) async {
    try {
      await mainLocalLog('Deleting Receipt Offline');
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
        receipt: receipt,
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
      List<CustomerAccountReceipts> accountReceipts =
          returnCustomerAccountReceiptsProvider()
              .customerAccountReceipts
              .where(
                (item) => item.receiptUuid == receipt.uuid,
              )
              .toList();
      if (accountReceipts.isEmpty) {
        accountReceipts =
            CustomerAccountReceiptsFunc()
                .getCustomerAccountReceipts()
                .where(
                  (item) =>
                      item.receiptUuid == receipt.uuid,
                )
                .toList();
      }
      if (receipt.customerUuid != null &&
          accountReceipts.isNotEmpty) {
        await returnCustomerAccountReceiptsProvider()
            .deleteCustomerAccountReceipts(
              customerReceipts: accountReceipts,
              updateCustomerBalance: true,
            );
      }

      await mainLocalLog(
        '✅ Receipt and inventory successfully Delete and Updated.',
      );

      await loadReceiptsOffline(
        returnShopProvider().userShop()!.shopId!,
      );

      await mainLocalLog(
        'Totally Finished Deleting Receipt',
      );
      notifyListeners();
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Deleting Receipt: ${e.toString()}',
      );
      return 0;
    }
  }

  // DELETE a receipt
  Future<void> deleteReceiptWithoutUpdatingInventory({
    required TempMainReceipt receipt,
  }) async {
    await mainLocalLog('Deleting Receipt 2');
    await mainLocalLog('Deleting Receipt Offline');
    await MainReceiptFunc().deleteReceipt(
      receipt.uuid ?? '',
    );
    var containsCreated =
        CreatedReceiptsFunc()
            .getReceipts()
            .where(
              (rec) => rec.receipt.uuid == receipt.uuid,
            )
            .toList();
    var containsUpdate = UpdatedReceiptsFunc()
        .getReceiptIds()
        .where((rec) => rec.receiptUuid == receipt.uuid);
    if (containsCreated.isNotEmpty) {
      await CreatedReceiptsFunc().deleteReceipt(
        receipt.uuid ?? '',
      );
    } else {
      await DeletedReceiptsFunc().createDeletedReceipt(
        DeletedReceipts(receiptUuid: receipt.uuid ?? ''),
      );
    }
    if (containsUpdate.isNotEmpty) {
      await UpdatedReceiptsFunc().deleteUpdatedReceipt(
        receipt.uuid ?? '',
      );
    }
    await ProductRecordFunc()
        .deleteRecordsInReceiptWithoutUpdatingInventory(
          receipt: receipt,
        );

    List<CustomerAccountReceipts> accountReceipts =
        returnCustomerAccountReceiptsProvider()
            .customerAccountReceipts
            .where(
              (item) => item.receiptUuid == receipt.uuid,
            )
            .toList();
    if (accountReceipts.isEmpty) {
      accountReceipts =
          CustomerAccountReceiptsFunc()
              .getCustomerAccountReceipts()
              .where(
                (item) => item.receiptUuid == receipt.uuid,
              )
              .toList();
    }
    if (receipt.customerUuid != null &&
        accountReceipts.isNotEmpty) {
      await returnCustomerAccountReceiptsProvider()
          .deleteCustomerAccountReceipts(
            customerReceipts: accountReceipts,
            updateCustomerBalance: true,
          );
    }
    // }

    await mainLocalLog(
      '✅ Receipt and inventory successfully Delete and Updated.',
    );

    await loadReceiptsOffline(
      returnShopProvider().userShop()!.shopId!,
    );

    await mainLocalLog('Totally Finished Deleting Receipt');
    notifyListeners();
    returnData().syncData();
  }

  //
  //
  //
  //

  Future<void> createReceiptsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedReceiptsFunc().getReceipts().isNotEmpty &&
          isOnline) {
        List<CreatedReceipts> tempReceipts =
            CreatedReceiptsFunc().getReceipts().toList();
        // createdAt is serialized to UTC inside toJson(), so the
        // shared in-memory receipt must not be mutated here (doing so
        // made the receipt page show UTC time until it was reloaded).
        List<CreatedReceipts> newReceipts = tempReceipts;
        int count = 0;
        for (var item in newReceipts) {
          try {
            // Insert all at once
            await supabase
                .from('receipts')
                .insert(item.receipt.toJson());
            count++;
            await CreatedReceiptsFunc().deleteReceipt(
              item.receipt.uuid!,
            );
          } on PostgrestException catch (e) {
            if (e.code == '23505') {
              await CreatedReceiptsFunc().deleteReceipt(
                item.receipt.uuid!,
              );
            }
            await mainLocalLog(
              'Error Synchronizing Receipt ${item.receipt.bank + item.receipt.cashAlt + (item.receipt.customerAccount ?? 0)}: $e',
            );
          }
        }

        await mainLocalLog(
          '$count items added successfully ✅',
        );
        // await CreatedReceiptsFunc().clearReceipts();
        await mainLocalLog('Unsynced Receipts Cleared');
        await mainLocalLog(
          'Mounted, refreshing Receipts ✅',
        );
        await loadReceipts(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Receipts Insert failed ❌: $e',
      );
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

  Future<void> deleteReceiptsSync() async {
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
          try {
            await supabase
                .from('receipts')
                .delete()
                .eq('uuid', rec.receiptUuid);

            await DeletedReceiptsFunc()
                .deletedDeletedReceipts(rec.receiptUuid);
            await mainLocalLog(
              'Receipt ${rec.receiptUuid} remote deletion succeeded ✅',
            );
          } catch (e) {
            await mainLocalLog(
              'Error Syncing Deleted Receipt ${rec.receiptUuid}: ${e.toString()}',
            );
          }
        }

        if (DeletedReceiptsFunc().getReceiptIds().isEmpty) {
          await mainLocalLog(
            'All Unsynced Deleted Receipts Cleared ✅',
          );
          await loadReceipts(
            returnShopProvider().userShop()!.shopId!,
          );
        } else {
          await mainLocalLog(
            'Some deleted receipts could not be synced and remain in queue.',
          );
        }
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Receipts Delete failed ❌: $e',
      );
    }
  }
  //
  //
  //
  //
  //

  Future<void> updateReceiptsSync() async {
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
          final localReceipt = MainReceiptFunc()
              .getSingleReceipt(uuid: rec.receiptUuid);
          if (localReceipt != null) {
            await supabase
                .from('receipts')
                .upsert(
                  localReceipt.toJson(),
                  onConflict: 'uuid',
                );
          } else {
            final updateData = {'is_invoice': false};
            await supabase
                .from('receipts')
                .update(updateData)
                .eq('uuid', rec.receiptUuid);
          }
          await UpdatedReceiptsFunc().deleteUpdatedReceipt(
            rec.receiptUuid,
          );
        }

        await mainLocalLog(
          '${tempReceipts.length} items added successfully ✅',
        );
        await UpdatedReceiptsFunc().clearUpdatedReceipts();
        await mainLocalLog('Unsynced Receipts Cleared');
        await mainLocalLog(
          'Mounted, refreshing Receipts ✅',
        );
        await loadReceipts(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Receipts Update failed ❌: $e',
      );
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

  List<TempProductSaleRecord> get mainSales => _sales;

  List<TempProductSaleRecord> salesReceipts() {
    return departmentReceipts()
        .expand((item) => item.getItems())
        .toList();
    // return _salesReceipts;
  }

  List<TempProductSaleRecord> getProductRecordsNoVoid() {
    return salesReceipts()
        .where((item) => item.isVoid != true)
        .toList();
  }

  List<TempProductSaleRecord> getProductRecordsVoid() {
    return salesReceipts()
        .where((item) => item.isVoid == true)
        .toList();
  }

  List<TempProductSaleRecord> salesInvoice({
    BuildContext? context,
  }) {
    return returnInvoicesProvider(
          context: context,
          listen: false,
        ).invoicesMain
        .expand((item) => item.getItems())
        .toList();
    // return _sales;
  }

  // CREATE a new product sale record
  // Future<void> createProductSaleRecord({
  //   required List<TempProductSaleRecord> records,
  //   required bool isPartPayment,
  // }) async {
  //   try {
  //     await mainLocalLog(
  //       'About to Create Product Sales Offline: ${records.length}',
  //     );
  //     var newRecords =
  //         records.map((rec) {
  //           mainLocalLog(
  //             'Record to Create: ${rec.productName}',
  //           );

  //           return rec;
  //         }).toList();
  //     if (!isPartPayment) {
  //       await ProductRecordFunc().insertSalesProductRecords(
  //         newRecords,
  //       );
  //     }
  //     List<CreatedRecords> cRecords =
  //         newRecords.map((r) {
  //           return CreatedRecords(record: r);
  //         }).toList();
  //     await CreatedRecordsFunc().insertAllRecords(cRecords);
  //     // await loadProductSalesRecordOffline(shopId());
  //     await mainLocalLog(
  //       'Finished Creating Product Sales Offline',
  //     );
  //   } catch (e) {
  //     await mainLocalLog('Error ${e.toString()}');
  //   }

  //   notifyListeners();
  // }

  // READ sales for a shop
  Future<List<TempProductSaleRecord>>
  loadProductSalesRecord(int shopId) async {
    _sales = ProductRecordFunc().getProductRecords();
    notifyListeners();
    return _sales;
  }

  Future<List<TempProductSaleRecord>>
  loadProductSalesRecordOffline(int shopId) async {
    _sales = ProductRecordFunc().getProductRecords();

    notifyListeners();
    return _sales;
  }

  // // UPDATE a sale record
  // Future<void> updateProductSaleRecord(
  //   TempProductSaleRecord record,
  //   BuildContext context,
  // ) async {
  //   // Use toJson but remove the ID because you don't update the primary key
  //   final updateData = record.toJson()..remove('uuid');

  //   await supabase
  //       .from('product_sales')
  //       .update(updateData)
  //       .eq('uuid', record.uuid!);

  //   if (context.mounted) {
  //     await loadProductSalesRecord(
  //       returnShopProvider().userShop()!.shopId!,
  //     );
  //   }
  //   notifyListeners();
  //   // }
  // }

  // // DELETE a sale record
  // Future<void> deleteProductSaleRecord(
  //   String recordUuid,
  //   BuildContext context,
  // ) async {
  //   await supabase
  //       .from('product_sales')
  //       .delete()
  //       .eq('uuid', recordUuid);
  //   // _sales.removeWhere(
  //   //   (r) => r.productRecordId == recordId,
  //   // );
  //   if (context.mounted) {
  //     loadProductSalesRecord(
  //       returnShopProvider().userShop()!.shopId!,
  //     );
  //   }
  //   notifyListeners();
  // }

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

  // Future<void> createRecordsSync() async {
  //   try {
  //     bool isOnline = await connectivity.isOnline();
  //     // Prepare batch payload
  //     if (CreatedRecordsFunc().getRecords().isNotEmpty &&
  //         isOnline) {
  //       final tempRecords =
  //           CreatedRecordsFunc().getRecords().toList();
  //       var newRecords = tempRecords.map((rec) {
  //         rec.record.createdAt =
  //             rec.record.createdAt.toUtc();
  //         return rec;
  //       });
  //       // final payload =
  //       //     newRecords
  //       //         .map((p) => p.record.toJson())
  //       //         .toList();
  //       int count = 0;
  //       for (var item in newRecords) {
  //         try {
  //           await supabase
  //               .from('product_sales')
  //               .insert(item.record.toJson())
  //               .select();

  //           count++;
  //           await CreatedRecordsFunc().deleteRecords(
  //             item.record.uuid!,
  //           );
  //         } on PostgrestException catch (e) {
  //           if (e.code == '23505') {
  //             await CreatedRecordsFunc().deleteRecords(
  //               item.record.uuid!,
  //             );
  //           }
  //           await mainLocalLog(
  //             '🎶🎶🤦‍♀️💖💋✅Error Synchronizing Product Sales Record ${item.record.productName}: $e',
  //           );
  //         }
  //       }

  //       await mainLocalLog(
  //         '$count items added successfully ✅',
  //       );
  //       // await CreatedRecordsFunc().clearRecords();
  //       await mainLocalLog('Unsynced Records Cleared');
  //     }
  //   } catch (e) {
  //     await mainLocalLog(
  //       'Batch Sales Records insert failed ❌: $e',
  //     );
  //   }
  // }

  List<TempMainReceipt> departmentReceipts() {
    return receipts.where((cat) {
      return returnDepartmentProvider()
          .matchesCurrentDepartment(
            departmentUuid: cat.departmentUuidNew,
          );
    }).toList();
  }

  int paymentMethod = 0;
  String? selectedCustomPaymentMethod;

  void selectPaymentMethod(
    int index, {
    String? customMethodName,
  }) {
    paymentMethod = index;
    selectedCustomPaymentMethod = customMethodName;
    notifyListeners();
  }

  String paymentMethodText() {
    if (selectedCustomPaymentMethod != null &&
        paymentMethod >= 5) {
      return selectedCustomPaymentMethod!;
    }
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
      case 4:
        tempMeth = 'Account';
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

  // Filters by the amounts paid, not the saved label: Cash / Bank / Account
  // match any receipt that used that method, Split matches 2+ methods.
  List<TempMainReceipt> returnOwnReceiptsByDayOrWeek() {
    if (selectedCustomPaymentMethod != null &&
        paymentMethod >= 5) {
      return returnReceiptsBasedOnPaymentMethod()
          .where(
            (rec) => rec.showsPaymentMethod(
              selectedCustomPaymentMethod!,
            ),
          )
          .toList();
    } else if (paymentMethod == 3) {
      return returnReceiptsBasedOnPaymentMethod()
          .where((rec) => rec.paymentBreakdown().isSplit)
          .toList();
    } else if (paymentMethod == 1) {
      return returnReceiptsBasedOnPaymentMethod()
          .where(
            (rec) =>
                rec.showsPaymentMethod(PaymentMethods.cash),
          )
          .toList();
    } else if (paymentMethod == 2) {
      return returnReceiptsBasedOnPaymentMethod()
          .where(
            (rec) =>
                rec.showsPaymentMethod(PaymentMethods.bank),
          )
          .toList();
    } else if (paymentMethod == 4) {
      return returnReceiptsBasedOnPaymentMethod()
          .where(
            (rec) => rec.showsPaymentMethod(
              PaymentMethods.account,
            ),
          )
          .toList();
    } else {
      return returnReceiptsBasedOnPaymentMethod().toList();
    }
  }

  List<StaffGroupReceipts> groupReceiptsByStaff() {
    final Map<String?, StaffGroupReceipts> grouped = {};

    for (final receipt in returnOwnReceiptsByDayOrWeek()) {
      final String? staffUuid = receipt.staffId;

      if (!grouped.containsKey(staffUuid)) {
        grouped[staffUuid] = StaffGroupReceipts(
          staffUuid: staffUuid ?? '',
          staffName:
              staffUuid == null
                  ? null
                  : receipt.staffName ?? '',
          number: 0,
          totalBalance: 0,
          totalOriginalCost: 0,
          totalRevenue: 0,
        );
      }

      final group = grouped[staffUuid]!;

      group.number++;
      group.totalBalance += receipt.balance ?? 0;
      group.totalOriginalCost += receipt.originalCost ?? 0;
      group.totalRevenue +=
          receipt.cashAlt +
          receipt.bank +
          (receipt.customerAccount ?? 0);
    }

    var res = grouped.values.toList();
    res.sort(
      (a, b) => ((a.staffName ?? 'Not Set').toLowerCase())
          .compareTo(
            (b.staffName ?? 'Not Set').toLowerCase(),
          ),
    );
    return res;
  }

  List<CustomerGroupReceipts> groupReceiptsByCustomer() {
    final Map<String?, CustomerGroupReceipts> grouped = {};

    for (final receipt in returnOwnReceiptsByDayOrWeek()) {
      final String? customerUuid = receipt.customerUuid;

      if (!grouped.containsKey(customerUuid)) {
        grouped[customerUuid] = CustomerGroupReceipts(
          customerUuid: customerUuid ?? '',
          customerName:
              customerUuid == null
                  ? null
                  : receipt.customerName ?? '',
          number: 0,
          totalBalance: 0,
          totalOriginalCost: 0,
          totalRevenue: 0,
        );
      }

      final group = grouped[customerUuid]!;

      group.number++;
      group.totalBalance += receipt.balance ?? 0;
      group.totalOriginalCost += receipt.originalCost ?? 0;
      group.totalRevenue +=
          receipt.cashAlt +
          receipt.bank +
          (receipt.customerAccount ?? 0);
    }

    var res = grouped.values.toList();
    res.sort(
      (a, b) =>
          ((a.customerName ?? 'Not Set').toLowerCase())
              .compareTo(
                (b.customerName ?? 'Not Set').toLowerCase(),
              ),
    );
    return res;
  }

  // One row per method actually paid. A split receipt counts under each
  // method it used; revenue is that method's amount, and balance / cost are
  // shared out by the same proportion so column totals still match.
  List<ChannelGroupReceipts>
  groupReceiptsByPaymentChannel() {
    final Map<String, ChannelGroupReceipts> grouped = {};

    for (final receipt in returnOwnReceiptsByDayOrWeek()) {
      final payments = receipt.displayPayments();
      final receiptTotal = receipt.getTotalRevenue();

      for (final payment in payments) {
        final paymentMethod = payment.method;

        if (!grouped.containsKey(paymentMethod)) {
          grouped[paymentMethod] = ChannelGroupReceipts(
            paymentMethod: paymentMethod,
            number: 0,
            totalBalance: 0,
            totalOriginalCost: 0,
            totalRevenue: 0,
          );
        }

        final group = grouped[paymentMethod]!;
        final share =
            receiptTotal > 0
                ? payment.amount / receiptTotal
                : 1 / payments.length;

        group.number++;
        group.totalBalance +=
            (receipt.balance ?? 0) * share;
        group.totalOriginalCost +=
            (receipt.originalCost ?? 0) * share;
        group.totalRevenue += payment.amount;
      }
    }

    var res = grouped.values.toList();
    res.sort((a, b) {
      final aIdx = PaymentMethods.all.indexOf(
        a.paymentMethod,
      );
      final bIdx = PaymentMethods.all.indexOf(
        b.paymentMethod,
      );
      if (aIdx != -1 && bIdx != -1) {
        return aIdx.compareTo(bIdx);
      } else if (aIdx != -1) {
        return -1;
      } else if (bIdx != -1) {
        return 1;
      }
      return a.paymentMethod.compareTo(b.paymentMethod);
    });
    return res;
  }

  List<DepartmentGroupReceipts>
  groupReceiptsByDepartment() {
    final Map<String?, DepartmentGroupReceipts> grouped =
        {};

    for (final receipt in returnOwnReceiptsByDayOrWeek()) {
      final String? departmentUuid =
          receipt.departmentUuidNew;

      if (!grouped.containsKey(departmentUuid)) {
        grouped[departmentUuid] = DepartmentGroupReceipts(
          departmentUuid: departmentUuid ?? '',
          departmentName:
              departmentUuid == null
                  ? null
                  : receipt.departmentName ?? '',
          number: 0,
          totalBalance: 0,
          totalOriginalCost: 0,
          totalRevenue: 0,
        );
      }

      final group = grouped[departmentUuid]!;

      group.number++;
      group.totalBalance += receipt.balance ?? 0;
      group.totalOriginalCost += receipt.originalCost ?? 0;
      group.totalRevenue +=
          receipt.cashAlt +
          receipt.bank +
          (receipt.customerAccount ?? 0);
    }

    var res = grouped.values.toList();
    res.sort(
      (a, b) => ((a.departmentName ?? 'Not Set')
              .toLowerCase())
          .compareTo(
            (b.departmentName ?? 'Not Set').toLowerCase(),
          ),
    );
    return res;
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

    final currentDate =
        dateSet ?? resolveBusinessDate(DateTime.now());

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
                record.createdAt.isBefore(
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
                record.createdAt.isBefore(
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

    final currentDate =
        dateSet ?? resolveBusinessDate(DateTime.now());

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
                record.createdAt.isBefore(
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
                record.createdAt.isBefore(
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
    var total =
        ((receipt.bank +
            receipt.cashAlt +
            (receipt.customerAccount ?? 0)));

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
        returnProductsRecordByDayOrWeek()
            .where((item) => item.invoiceUuid == null)
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
            // await mainLocalLog(
            //   '✅ Product Storage Exist: ${product.name}',
            // );

            grouped.putIfAbsent(uuid, () => []);
            grouped[uuid]!.add(item);
          } else {
            // await mainLocalLog(
            //   '🔥 Product Storage Uuid does not Exist: ${product.name}',
            // );
            final uuid = product.uuid ?? '';

            grouped.putIfAbsent(uuid, () => []);
            grouped[uuid]!.add(item);
          }
        } else {
          final uuid = item.productUuid ?? '';
          // await mainLocalLog(
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
        (sum, e) => sum + e.displayQuantity(),
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
          staffName: items.first.staffName ?? '',
          staffUuid: items.first.staffId,
        ),
      );
    });
    result.sort((a, b) => b.quantity.compareTo(a.quantity));
    return result;
  }

  double getTotalSalesRevenue() {
    return returnProductsRecordByDayOrWeek()
        .where((item) => item.invoiceUuid == null)
        .toList()
        .map((item) => item.revenue)
        .toList()
        .fold(0, (first, second) => first + second);
  }

  //
  //
  //
  //
  List<GeneralReportSalesSummaryItem>
  returnGeneralReportSalesSummaryVoid() {
    final List<TempProductSaleRecord> records =
        returnProductsRecordByDayOrWeekVoid()
            .where((item) => item.invoiceUuid == null)
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
            // await mainLocalLog(
            //   '✅ Product Storage Exist: ${product.name}',
            // );

            grouped.putIfAbsent(uuid, () => []);
            grouped[uuid]!.add(item);
          } else {
            // await mainLocalLog(
            //   '🔥 Product Storage Uuid does not Exist: ${product.name}',
            // );
            final uuid = product.uuid ?? '';

            grouped.putIfAbsent(uuid, () => []);
            grouped[uuid]!.add(item);
          }
        } else {
          final uuid = item.productUuid ?? '';
          // await mainLocalLog(
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
        (sum, e) => sum + e.displayQuantity(),
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
          staffName: items.first.staffName ?? 'Not Set',
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
            .where(
              (item) =>
                  item.departmentUuid == null &&
                  item.invoiceUuid == null,
            )
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
            // await mainLocalLog(
            //   '✅ Product Storage Exist: ${product.name}',
            // );

            grouped.putIfAbsent(uuid, () => []);
            grouped[uuid]!.add(item);
          } else {
            // await mainLocalLog(
            //   '🔥 Product Storage Uuid does not Exist: ${product.name}',
            // );
            final uuid = product.uuid ?? '';

            grouped.putIfAbsent(uuid, () => []);
            grouped[uuid]!.add(item);
          }
        } else {
          final uuid = item.productUuid ?? '';
          // await mainLocalLog(
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
        (sum, e) => sum + e.displayQuantity(),
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
          staffName: items.first.staffName ?? 'Not Set',
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

  double getTotalSalesRevenueForDepartment({
    required String deptUuid,
  }) {
    return returnProductsRecordByDayOrWeek()
        .where(
          (item) =>
              item.departmentUuid == deptUuid &&
              item.invoiceUuid == null,
        )
        .map((item) => item.revenue)
        .toList()
        .fold(0, (first, second) => first + second);
  }

  //
  //
  //

  double getTotalSalesRevenueNoDepartment() {
    return returnProductsRecordByDayOrWeek()
        .where(
          (item) =>
              item.departmentUuid == null &&
              item.invoiceUuid == null,
        )
        .map((item) => item.revenue)
        .toList()
        .fold(0, (first, second) => first + second);
  }

  //
  //
  //
  //
  double getTotalSalesRevenueVoid() {
    return returnProductsRecordByDayOrWeekVoid()
        .map((item) => item.revenue)
        .toList()
        .fold(0, (first, second) => first + second);
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
        returnProductsRecordByDayOrWeek()
            .where((item) => item.invoiceUuid == null)
            .toList();

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
          staffName: first.staffName ?? 'Not Set',
          staffUuid: first.staffId,
          quantity: totalQuantity,
          totalCost: totalCost,
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
  //

  int sortColumnIndex = 0;
  bool sortAscending = true;

  List<DataColumn> _headingTotal({
    required BuildContext context,
  }) {
    return [
      DataColumn2(label: HeadingTextWidget(title: '#Id')),
      DataColumn2(
        size: ColumnSize.L,
        label: HeadingTextWidget(title: 'Staff'),
      ),
      DataColumn2(
        size: ColumnSize.L,

        label: HeadingTextWidget(title: 'Customer'),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'Channel'),
      ),
      DataColumn2(label: HeadingTextWidget(title: 'Date')),
      DataColumn2(label: HeadingTextWidget(title: 'Time')),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'Discount'),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'VAT'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Balance'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Sub-Total'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Revenue'),
      ),
    ];
  }

  List<DataColumn> _headingStaffs() {
    return [
      DataColumn2(
        size: ColumnSize.L,
        label: HeadingTextWidget(title: 'Staff'),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'Quantity'),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: HeadingTextWidget(title: 'Balance'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Sub-Total'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Revenue'),
      ),
    ];
  }

  List<DataColumn> _headingCustomers() {
    return [
      DataColumn2(
        size: ColumnSize.L,

        label: HeadingTextWidget(title: 'Customer'),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'Quantity'),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: HeadingTextWidget(title: 'Balance'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Sub-Total'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Revenue'),
      ),
    ];
  }

  List<DataColumn> _headingChannel() {
    return [
      DataColumn2(
        size: ColumnSize.L,
        label: HeadingTextWidget(title: 'Channel'),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'Quantity'),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: HeadingTextWidget(title: 'Balance'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Sub-Total'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Revenue'),
      ),
    ];
  }

  List<DataColumn> _headingDepartments() {
    return [
      DataColumn2(
        size: ColumnSize.L,
        label: HeadingTextWidget(title: 'Department'),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'Quantity'),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: HeadingTextWidget(title: 'Balance'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Sub-Total'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Revenue'),
      ),
    ];
  }

  double rowTotalTotalBalance() {
    return returnOwnReceiptsByDayOrWeek()
        .map((item) => (item.balance ?? 0))
        .toList()
        .fold(0, (p, n) => p + n);
  }

  double rowTotalTotalCostPrice() {
    return returnOwnReceiptsByDayOrWeek()
        .map((item) => (item.originalCost ?? 0))
        .toList()
        .fold(0, (p, n) => p + n);
  }

  double rowTotalTotalRevenue() {
    return returnOwnReceiptsByDayOrWeek()
        .map((item) => (item.cashAlt + item.bank))
        .toList()
        .fold(0, (p, n) => p + n);
  }

  List<DataRow> _rowTotal({required BuildContext context}) {
    return [
      ...returnOwnReceiptsByDayOrWeek().toList().map((
        item,
      ) {
        return DataRow2(
          specificRowHeight:
              (item.staffName ?? '').length > 18 ||
                      (item.customerName ?? '').length > 18
                  ? 40
                  : 30,
          cells: [
            DataCell(
              Text(
                "#${item.barcode ?? returnOnlyDigits(item.uuid ?? '')}",
              ),
            ),
            DataCell(Text(item.staffName ?? 'Not Set')),
            DataCell(Text(item.customerName ?? 'Not Set')),
            DataCell(Text(item.paymentMethod)),
            DataCell(Text(formatDateTime(item.createdAt))),
            DataCell(Text(formatTime(item.createdAt))),
            DataCell(
              Text(
                "${item.generalDiscount != null ? "" : '${shop(context, listen: false)?.currency}'}${formatLargeNumberDouble(item.fixedDiscount ?? item.generalDiscount ?? 0)}${item.generalDiscount != null ? "%" : ''}",
              ),
            ),
            DataCell(
              Text(
                "${formatLargeNumberDouble(item.vat ?? 0)}%",
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.balance ?? 0,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.originalCost ?? 0,
                  context: context,
                ),
              ),
            ),
            DataCell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ReceiptPage(
                        response: CheckoutResponse(
                          receipt: item,
                        ),
                        isMain: false,
                      );
                    },
                  ),
                );
              },
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                spacing: 5,
                children: [
                  Text(
                    formatMoneyBig(
                      amount: item.bank + item.cashAlt,
                      context: context,
                    ),
                  ),
                  Icon(
                    size: 14,
                    color: Colors.grey.shade500,
                    Icons.arrow_forward_ios_rounded,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      DataRow2(
        specificRowHeight: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.grey.shade300,
        ),
        cells: [
          DataCell(
            Text(style: TextStyle(fontSize: 14), 'TOTAL'),
          ),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text("")),
          DataCell(Text("")),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowTotalTotalBalance(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowTotalTotalCostPrice(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 16),
              formatMoneyBig(
                amount: rowTotalTotalRevenue(),
                context: context,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  rowStaffsTotalQuantity() {
    return groupReceiptsByStaff()
        .map((item) => item.number)
        .toList()
        .fold(0, (p, n) => p + n);
  }

  rowStaffsTotalBalance() {
    return groupReceiptsByStaff()
        .map((item) => item.totalBalance)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowStaffsTotalCostPrice() {
    return groupReceiptsByStaff()
        .map((item) => item.totalOriginalCost)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowStaffsTotalRevenue() {
    return groupReceiptsByStaff()
        .map((item) => item.totalRevenue)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  List<DataRow> _rowStaffs({
    required BuildContext context,
  }) {
    return [
      ...groupReceiptsByStaff().map((item) {
        return DataRow2(
          specificRowHeight:
              (item.staffName ?? '').length > 15 ? 40 : 30,
          cells: [
            DataCell(Text(item.staffName ?? 'Not Set')),
            DataCell(
              Text(formatLargeNumberDouble(item.number)),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalBalance,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalOriginalCost,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalRevenue,
                  context: context,
                ),
              ),
            ),
          ],
        );
      }),
      DataRow2(
        specificRowHeight: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.grey.shade300,
        ),
        cells: [
          DataCell(
            Text(style: TextStyle(fontSize: 14), 'TOTAL'),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatLargeNumberDouble(
                rowStaffsTotalQuantity(),
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowStaffsTotalBalance(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowStaffsTotalCostPrice(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowStaffsTotalRevenue(),
                context: context,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  rowCustomersTotalQuantity() {
    return groupReceiptsByCustomer()
        .map((item) => item.number)
        .toList()
        .fold(0, (p, n) => p + n);
  }

  rowCustomersTotalBalance() {
    return groupReceiptsByCustomer()
        .map((item) => item.totalBalance)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowCustomersTotalCostPrice() {
    return groupReceiptsByCustomer()
        .map((item) => item.totalOriginalCost)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowCustomersTotalRevenue() {
    return groupReceiptsByCustomer()
        .map((item) => item.totalRevenue)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  List<DataRow> _rowCustomers({
    required BuildContext context,
  }) {
    return [
      ...groupReceiptsByCustomer().map((item) {
        return DataRow2(
          specificRowHeight:
              (item.customerName ?? '').length > 15
                  ? 40
                  : 30,
          cells: [
            DataCell(Text(item.customerName ?? 'Not Set')),
            DataCell(
              Text(formatLargeNumberDouble(item.number)),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalBalance,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalOriginalCost,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalRevenue,
                  context: context,
                ),
              ),
            ),
          ],
        );
      }),
      DataRow2(
        specificRowHeight: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.grey.shade300,
        ),
        cells: [
          DataCell(
            Text(style: TextStyle(fontSize: 14), 'TOTAL'),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatLargeNumberDouble(
                rowCustomersTotalQuantity(),
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowCustomersTotalBalance(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowCustomersTotalCostPrice(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 16),
              formatMoneyBig(
                amount: rowCustomersTotalRevenue(),
                context: context,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  // Distinct receipts: a split receipt appears under several channels.
  rowChannelTotalQuantity() {
    return returnOwnReceiptsByDayOrWeek().length;
  }

  rowChannelTotalBalance() {
    return groupReceiptsByPaymentChannel()
        .map((item) => item.totalBalance)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowChannelTotalCostPrice() {
    return groupReceiptsByPaymentChannel()
        .map((item) => item.totalOriginalCost)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowChannelTotalRevenue() {
    return groupReceiptsByPaymentChannel()
        .map((item) => item.totalRevenue)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  List<DataRow> _rowChannel({
    required BuildContext context,
  }) {
    return [
      ...groupReceiptsByPaymentChannel().map((item) {
        return DataRow2(
          specificRowHeight: 30,
          cells: [
            DataCell(Text(item.paymentMethod)),
            DataCell(
              Text(formatLargeNumberDouble(item.number)),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalBalance,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalOriginalCost,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                spacing: 5,
                children: [
                  Text(
                    formatMoneyBig(
                      amount: item.totalRevenue,
                      context: context,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      DataRow2(
        specificRowHeight: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.grey.shade300,
        ),
        cells: [
          DataCell(
            Text(style: TextStyle(fontSize: 14), 'TOTAL'),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatLargeNumberDouble(
                rowChannelTotalQuantity(),
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowChannelTotalBalance(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowChannelTotalCostPrice(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 16),
              formatMoneyBig(
                amount: rowChannelTotalRevenue(),
                context: context,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  rowDepartmentsTotalQuantity() {
    return groupReceiptsByDepartment()
        .map((item) => item.number)
        .toList()
        .fold(0, (p, n) => p + n);
  }

  rowDepartmentsTotalBalance() {
    return groupReceiptsByDepartment()
        .map((item) => item.totalBalance)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowDepartmentsTotalCostPrice() {
    return groupReceiptsByDepartment()
        .map((item) => item.totalOriginalCost)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowDepartmentsTotalRevenue() {
    return groupReceiptsByDepartment()
        .map((item) => item.totalRevenue)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  List<DataRow> _rowDepartment({
    required BuildContext context,
  }) {
    return [
      ...groupReceiptsByDepartment().map((item) {
        return DataRow2(
          specificRowHeight: 30,
          cells: [
            DataCell(
              Text(item.departmentName ?? 'Not Set'),
            ),
            DataCell(
              Text(formatLargeNumberDouble(item.number)),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalBalance,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalOriginalCost,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                spacing: 5,
                children: [
                  Text(
                    formatMoneyBig(
                      amount: item.totalRevenue,
                      context: context,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      DataRow2(
        specificRowHeight: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.grey.shade300,
        ),
        cells: [
          DataCell(
            Text(style: TextStyle(fontSize: 14), 'TOTAL'),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatLargeNumberDouble(
                rowDepartmentsTotalQuantity(),
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowDepartmentsTotalBalance(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowDepartmentsTotalCostPrice(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 16),
              formatMoneyBig(
                amount: rowDepartmentsTotalRevenue(),
                context: context,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<DataRow> row({
    required int sortIndex,
    required BuildContext context,
  }) {
    if (sortIndex == 1) {
      return _rowTotal(context: context);
    } else if (sortIndex == 2) {
      return _rowStaffs(context: context);
    } else if (sortIndex == 3) {
      return _rowCustomers(context: context);
    } else if (sortIndex == 4) {
      return _rowChannel(context: context);
    } else {
      return _rowDepartment(context: context);
    }
  }

  List<DataColumn> heading({
    required int sortIndex,
    required BuildContext context,
  }) {
    if (sortIndex == 1) {
      return _headingTotal(context: context);
    } else if (sortIndex == 2) {
      return _headingStaffs();
    } else if (sortIndex == 3) {
      return _headingCustomers();
    } else if (sortIndex == 4) {
      return _headingChannel();
    } else {
      return _headingDepartments();
    }
  }
}
