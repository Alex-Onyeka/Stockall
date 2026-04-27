import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_item_purchase_record/unsynced/created_item_records/created_item_records.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_purchase/unsynced/created_purchases/created_purchases.dart';
import 'package:stockall/classes/temp_purchase/unsynced/deleted_purchase/deleted_purchases.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/purchases/purchase_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/created/created_purchases_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/deleted/deleted_purchases_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/updated/updated_purchases_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../local_database/item_purchase_func.dart copy/item_purchase_func.dart';
import '../local_database/item_purchase_func.dart copy/unsync_funcs/created/created_item_purchase_func.dart';

class PurchaseProvider extends ChangeNotifier {
  static final PurchaseProvider _instance =
      PurchaseProvider._internal();
  factory PurchaseProvider() => _instance;
  PurchaseProvider._internal();
  bool isLoading = false;
  void toggleIsLoading(bool value) {
    isLoading = value;
    print(
      'Purchase is ${value ? 'Loading on' : 'Loading Off'}',
    );
    notifyListeners();
  }
  //
  //
  //

  final SupabaseClient supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();
  List<TempPurchase> _purchases = [];
  List<TempPurchase> get purchases => _purchases;

  final String tableName = 'purchases';

  void clearPurchases() {
    _purchases.clear();
    // clearRecords();
    print('Purchases Cleared');
    notifyListeners();
  }

  // void clearRecords() {
  //   itemPurchaseRecords.clear();
  //   // notifyListeners();
  // }

  // CREATE a new receipt
  Future<TempPurchase?> createPurchase(
    TempPurchase purchase,
  ) async {
    print('Inner Purchase Creation Started');
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      print('Inner Purchase Online Started');
      final res =
          await supabase
              .from(tableName)
              .upsert(
                purchase.toJson(),
                onConflict:
                    'uuid', // match existing row by uuid
              )
              .select()
              .single();

      print('Inner Purchase Online Finished');
      print('Casting Started');
      try {
        final newPurchase = TempPurchase.fromJson(res);
        notifyListeners();
        return newPurchase;
      } catch (e) {
        print('❌❌ Create Purchase Error: ${e.toString()}');
        return null;
      }
    } else {
      purchase.createdAt = DateTime.now();
      await PurchaseFunc().createPurchase(purchase);
      await CreatedPurchasesFunc().createPurchases(
        CreatedPurchases(purchase: purchase),
      );
      notifyListeners();
      return purchase;
    }
  }

  // READ all receipts for a shop
  Future<List<TempPurchase>> loadPurchases(
    int shopId,
  ) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      await PurchaseFunc().clearPurchases();
      try {
        final data = await supabase
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false);
        if (data.isNotEmpty) {
          print('Purchases Gotten ${data.length}');
        }

        _purchases =
            (data as List)
                .map((json) => TempPurchase.fromJson(json))
                .toList();
        await PurchaseFunc().insertAllPurchases(_purchases);
        print('Loaded');
        // // await returnInvoicesProvider().loadInvoices(shopId);
        // await returnData().getProducts(
        //   returnShopProvider().userShop()!.shopId!,
        // );
        // await loadItemPurchaseRecords(
        //   returnShopProvider().userShop()!.shopId!,
        // );
        notifyListeners();
      } catch (e) {
        print('Error Getting Purchases: ${e.toString()}');
        return [];
      }
    } else {
      _purchases = PurchaseFunc().getPurchases();
      print('Offline Purchases Gotten');
      // await returnInvoicesProvider().loadInvoices(
      //   returnShopProvider().userShop()!.shopId!,
      // );
      // await returnData().getProducts(
      //   returnShopProvider().userShop()!.shopId!,
      // );
      // await loadItemPurchaseRecords(
      //   returnShopProvider().userShop()!.shopId!,
      // );
      notifyListeners();
    }
    notifyListeners();
    return _purchases;
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
  Future<void> deletePurchase(
    TempPurchase purchase,
    // List<String> productNames,
    // BuildContext context,
  ) async {
    print('Deleting Purchase');
    bool isOnline = await connectivity.isOnline();
    try {
      if (isOnline) {
        print('Deleting Purchase Online');
        await supabase
            .from(tableName)
            .delete()
            .eq('uuid', purchase.uuid!);
        print('Finished Deleting Purchase Online');
        var containsUpdate = UpdatedPurchasesFunc()
            .getPurchaseIds()
            .where(
              (purch) =>
                  purch.purchaseUuid == purchase.uuid,
            );
        if (containsUpdate.isNotEmpty) {
          await UpdatedPurchasesFunc()
              .deleteUpdatedPurchase(purchase.uuid!);
        }
      } else {
        print('Deleting Purchase Offline');
        await PurchaseFunc().deletePurchase(purchase.uuid!);
        var containsCreated =
            CreatedPurchasesFunc()
                .getPurchases()
                .where(
                  (purch) =>
                      purch.purchase.uuid == purchase.uuid,
                )
                .toList();
        var containsUpdate = UpdatedPurchasesFunc()
            .getPurchaseIds()
            .where(
              (purch) =>
                  purch.purchaseUuid == purchase.uuid!,
            );
        if (containsCreated.isNotEmpty) {
          await CreatedPurchasesFunc().deletePurchase(
            purchase.uuid!,
          );
        } else {
          await DeletedPurchasesFunc()
              .createDeletedPurchase(
                DeletedPurchases(
                  purchaseUuid: purchase.uuid!,
                ),
              );
        }
        if (containsUpdate.isNotEmpty) {
          await UpdatedPurchasesFunc()
              .deleteUpdatedPurchase(purchase.uuid!);
        }
        await ItemPurchaseFunc().deleteRecordsInPurchase(
          purchase.uuid!,
        );
      }
      // if (productNames.isNotEmpty) {
      //   await returnEventsLogProvider().createLog(
      //     returnEventsLogProvider().receiptAdapter(
      //       receipt,
      //       productNames,
      //       3,
      //     ),
      //   );
      // }

      print('✅ Purchase successfully Delete.');

      await loadPurchases(
        returnShopProvider().userShop()!.shopId!,
      );

      print('Totally Finished Deleting Receipt');
      notifyListeners();
    } catch (e) {
      print('Error Deleting Purchase: ${e.toString()}');
    }
  }

  //
  //
  //
  //

  Future<void> createPurchasesSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedPurchasesFunc()
              .getPurchases()
              .isNotEmpty &&
          isOnline) {
        final tempPurchases =
            CreatedPurchasesFunc().getPurchases().toList();
        var newPurchases = tempPurchases.map((rec) {
          rec.purchase.createdAt =
              rec.purchase.createdAt.toUtc();
          return rec;
        });
        final payload =
            newPurchases
                .map((p) => p.purchase.toJson())
                .toList();

        // Insert all at once
        final data =
            await supabase
                .from(tableName)
                .insert(payload)
                .select();

        print('${data.length} items added successfully ✅');
        await CreatedPurchasesFunc().clearPurchases();
        print('Unsynced Purchases Cleared');

        print('Mounted, refreshing Purchases ✅');
        await loadPurchases(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      print('Batch Purchases insert failed ❌: $e');
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

  Future<void> deletePurchasesSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (DeletedPurchasesFunc()
              .getPurchaseIds()
              .isNotEmpty &&
          isOnline) {
        final tempPurchases =
            DeletedPurchasesFunc()
                .getPurchaseIds()
                .toList();

        for (var rec in tempPurchases) {
          await supabase
              .from(tableName)
              .delete()
              .eq('uuid', rec.purchaseUuid);
          // await DeletedPurchasesFunc()
          //     .deletedDeletedPurchases(rec.purchaseUuid);
        }

        print(
          '${tempPurchases.length} Purchases Created successfully ✅',
        );
        await DeletedPurchasesFunc()
            .clearDeletedPurchases();
        print('Unsynced Deleted Purchases Cleared');

        print('Mounted, refreshing Purchases ✅');
        await loadPurchases(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      print('Batch Purchases Deleted failed ❌: $e');
    }
  }
  //
  //
  //
  //
  //

  // Future<void> updatePurchasesSync(
  //   BuildContext context,
  // ) async {
  //   try {
  //     bool isOnline = await connectivity.isOnline();
  //     // Prepare batch payload
  //     if (UpdatedPurchasesFunc()
  //             .getPurchaseIds()
  //             .isNotEmpty &&
  //         isOnline) {
  //       final tempPurchases =
  //           UpdatedPurchasesFunc()
  //               .getPurchaseIds()
  //               .toList();
  //       for (var rec in tempPurchases) {
  //         final updateData = {'is_invoice': false};
  //         await supabase
  //             .from(tableName)
  //             .update(updateData)
  //             .eq('uuid', rec.purchaseUuid);
  //         await UpdatedPurchasesFunc()
  //             .deleteUpdatedPurchase(rec.purchaseUuid);
  //       }

  //       print(
  //         '${tempPurchases.length} items added successfully ✅',
  //       );
  //       await UpdatedPurchasesFunc()
  //           .clearUpdatedPurchases();
  //       print('Unsynced Purchases Cleared');
  //       if (context.mounted) {
  //         print('Mounted, refreshing Purchases ✅');
  //         await loadPurchases(
  //           returnShopProvider().userShop()!.shopId!,
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     print('Batch Purchases insert failed ❌: $e');
  //   }
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

  List<TempItemPurchaseRecord> _itemPurchaseRecords = [];
  List<TempItemPurchaseRecord> get itemPurchaseRecords =>
      _itemPurchaseRecords;

  // CREATE a new product sale record
  Future<void> createItemPurchaseRecord(
    List<TempItemPurchaseRecord> records,
    // BuildContext context,
  ) async {
    bool isOnline = await connectivity.isOnline();
    print('About to Start Mapping');
    try {
      final dataToInsert =
          records.map((e) => e.toJson()).toList();
      print('Finished Mapping');

      if (isOnline) {
        print(
          'About to Create Item Purchase Records Online',
        );
        await supabase
            .from('item_purchase_records')
            .upsert(dataToInsert, onConflict: 'uuid');
        await ItemPurchaseFunc()
            .insertSalesItemPurchaseRecords(records);
        print(
          'Finished Creating Item Purchase Records Online',
        );
      } else {
        print(
          'About to Create Item Purchase Records Offline',
        );
        var newRecords =
            records.map((rec) {
              rec.createdAt = DateTime.now();

              return rec;
            }).toList();
        await ItemPurchaseFunc()
            .insertSalesItemPurchaseRecords(newRecords);
        List<CreatedItemRecords> cRecords =
            newRecords.map((r) {
              return CreatedItemRecords(record: r);
            }).toList();
        await CreatedItemPurchaseFunc().insertAllRecords(
          cRecords,
        );
        print(
          'Finished Creating Item Purchase Records Offline',
        );
      }
    } catch (e) {
      print('Error ${e.toString()}');
    }

    notifyListeners();
  }

  // READ sales for a shop
  Future<List<TempItemPurchaseRecord>>
  loadItemPurchaseRecords(int shopId) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      final data = await supabase
          .from('item_purchase_records')
          .select()
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);

      print('Items Records gotten');
      _itemPurchaseRecords =
          (data as List)
              .map(
                (json) =>
                    TempItemPurchaseRecord.fromJson(json),
              )
              .toList();
      await ItemPurchaseFunc().insertAllItemPurchaseRecords(
        _itemPurchaseRecords,
      );
    } else {
      _itemPurchaseRecords =
          ItemPurchaseFunc().getItemPurchaseRecords();
    }

    notifyListeners();
    return _itemPurchaseRecords;
  }

  // UPDATE a sale record
  // Future<void> updateProductSaleRecord(
  //   TempItemPurchaseRecord record,
  //   BuildContext context,
  // ) async {
  //   // Use toJson but remove the ID because you don't update the primary key
  //   final updateData = record.toJson()..remove('uuid');

  //   await supabase
  //       .from('product_itemPurchaseRecords')
  //       .update(updateData)
  //       .eq('uuid', record.uuid!);

  //   if (context.mounted) {
  //     await loadItemPurchaseRecords(
  //       returnShopProvider().userShop()!.shopId!,
  //     );
  //   }
  //   notifyListeners();
  //   // }
  // }

  // DELETE a sale record
  Future<void> deleteItemPurchaseRecord(
    String recordUuid,
    BuildContext context,
  ) async {
    await supabase
        .from('item_purchase_records')
        .delete()
        .eq('uuid', recordUuid);
    // _itemPurchaseRecords.removeWhere(
    //   (r) => r.productRecordId == recordId,
    // );
    if (context.mounted) {
      loadItemPurchaseRecords(
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
      if (CreatedItemPurchaseFunc()
              .getRecords()
              .isNotEmpty &&
          isOnline) {
        final tempRecords =
            CreatedItemPurchaseFunc().getRecords().toList();
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
                .from('item_purchase_records')
                .insert(payload)
                .select();

        print('${data.length} items added successfully ✅');
        await CreatedItemPurchaseFunc().clearRecords();
        print('Unsynced Records Cleared');
      }
    } catch (e) {
      print('Batch Records insert failed ❌: $e');
    }
  }

  List<TempPurchase> departmentPurchases() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return purchases.where((cat) {
          return cat.departmentUuid ==
              returnDepartmentProvider()
                  .currentDepartment()
                  ?.uuid;
        }).toList();
      } else {
        if (returnDepartmentProvider()
                .currentDepartment()
                ?.uuid ==
            null) {
          return purchases;
        } else {
          return purchases.where((cat) {
            return cat.departmentUuid ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
            // }
          }).toList();
        }
      }
    } else {
      return purchases;
    }
  }

  List<TempPurchase> returnOwnPurchasesByDayOrWeek() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (rangeStartDate != null) {
        return departmentPurchases().where((purchase) {
          final created = purchase.createdAt.toLocal();
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

        return departmentPurchases()
            .where(
              (purchase) =>
                  !purchase.createdAt.isBefore(
                    fourAm(currentDate),
                  ) &&
                  purchase.createdAt.isBefore(
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
          return purchases.where((purchase) {
            final created = purchase.createdAt.toLocal();
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
          return purchases.where((purchase) {
            final created = purchase.createdAt.toLocal();
            return !created.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                created.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ) &&
                purchase.staffId == currentUser().userId;
          }).toList();
        }
      } else {
        final currentDate = dateSet ?? DateTime.now();

        if (authorization(
          authorized:
              Authorizations().viewAllTransactionRecords,
        )) {
          return purchases
              .where(
                (purchase) =>
                    !purchase.createdAt.isBefore(
                      fourAm(currentDate),
                    ) &&
                    !purchase.createdAt.isAfter(
                      fourAmNextDay(currentDate),
                    ),
              )
              .toList();
        } else {
          return purchases
              .where(
                (purchase) =>
                    !purchase.createdAt.isBefore(
                      fourAm(currentDate),
                    ) &&
                    !purchase.createdAt.isAfter(
                      fourAmNextDay(currentDate),
                    ) &&
                    purchase.staffId ==
                        currentUser().userId,
              )
              .toList();
        }
      }
    }
  }

  List<TempItemPurchaseRecord>
  returnItemPurchaseRecordByDayOrWeek() {
    List<TempItemPurchaseRecord> recordss = [];

    for (var rec in itemPurchaseRecords) {
      TempPurchase? purchase;

      try {
        purchase = returnOwnPurchasesByDayOrWeek()
            .firstWhere(
              (recx) => recx.uuid == rec.purchaseId,
            );
      } catch (e) {
        purchase = null;
      }

      if (purchase != null) {
        recordss.add(rec);
      }
    }

    if (rangeStartDate != null) {
      if (authorization(
        authorized:
            Authorizations().viewAllTransactionRecords,
      )) {
        return recordss.where((record) {
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
        return recordss.where((record) {
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
      return recordss
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
      return recordss
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
    // List<TempPurchase> receipts,
  ) {
    double tempTotalRevenue = 0;

    for (var purchase in returnOwnPurchasesByDayOrWeek(
      // context,
    )) {
      tempTotalRevenue += (purchase.total ?? 0);
    }

    return tempTotalRevenue;
  }

  // double getTotalRevenueForSelectedDayAll({
  //   String? staffId,
  //   String? customerId,
  //   String? subStaffId,
  // }) {
  //   double tempTotalRevenue = 0;

  //   for (var receipt
  //       in (staffId != null
  //           ? returnOwnPurchasesByDayOrWeek().where(
  //             (rec) => rec.staffId == staffId,
  //           )
  //           : subStaffId != null
  //           ? returnOwnPurchasesByDayOrWeek().where(
  //             (rec) => rec.subStaffUuid == subStaffId,
  //           )
  //           : customerId != null
  //           ? returnOwnPurchasesByDayOrWeek().where(
  //             (rec) => rec.customerUuid == customerId,
  //           )
  //           : returnOwnPurchasesByDayOrWeek())) {
  //     tempTotalRevenue += getTotalMainRevenuePurchase(
  //       receipt,
  //     );
  //   }

  //   return tempTotalRevenue;
  // }
  //
  //
  //
  //

  // double getTotalCostPriceForSelectedDay(
  //   BuildContext context,
  //   List<TempPurchase> receipts,
  //   List<TempItemPurchaseRecord> productSalesRecords,
  // ) {
  //   double tempTotalCostPrice = 0;

  //   for (var receipt in returnOwnPurchasesByDayOrWeek(
  //     // context,
  //   )) {
  //     var productRecords =
  //         productSalesRecords
  //             .where(
  //               (record) =>
  //                   record.purchaseUuid == purchase.uuid,
  //             )
  //             .toList();

  //     for (var record in productRecords) {
  //       tempTotalCostPrice += record.costPrice ?? 0;
  //     }
  //   }

  //   return tempTotalCostPrice;
  // }

  // double getVATForReceipt(TempPurchase receipt) {
  //   var vat =
  //       ((purchase.originalCost ?? 0) *
  //           ((purchase.vat ?? 0) / 100));
  //   return vat;
  // }

  // double getDiscountAmountForReceipt(TempPurchase receipt) {
  //   if (purchase.fixedDiscount != null) {
  //     return (purchase.fixedDiscount ?? 0);
  //   } else if (purchase.generalDiscount != null) {
  //     return (getOriginalCostReceipt(receipt) *
  //         ((purchase.generalDiscount ?? 0) / 100));
  //   } else {
  //     return 0;
  //   }
  // }

  // double getOriginalCostReceipt(TempPurchase receipt) {
  //   return purchase.originalCost ?? 0;
  // }

  // double getTotalMainRevenuePurchase(TempPurchase receipt) {
  //   var total = ((purchase.bank + purchase.cashAlt));

  //   return total;
  // }
}
