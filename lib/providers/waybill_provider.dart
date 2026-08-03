// import 'package:flutter/material.dart';
// import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
// import 'package:stockall/classes/temp_waybills/temp_way_bills.dart';
// import 'package:stockall/classes/temp_waybills/unsynced/created_waybills/created_waybills.dart';
// import 'package:stockall/classes/temp_waybills/unsynced/deleted_waybills/deleted_waybills.dart';
// import 'package:stockall/classes/temp_waybills/unsynced/updated/updated_waybills.dart';
// import 'package:stockall/classes/temp_waybills/waybill_items.dart';
// import 'package:stockall/constants/calculations.dart';
// import 'package:stockall/constants/functions.dart';
// import 'package:stockall/local_database/waybills/unsync_funcs/created/created_waybills_func.dart';
// import 'package:stockall/local_database/waybills/unsync_funcs/deleted/deleted_waybills_func.dart';
// import 'package:stockall/local_database/waybills/unsync_funcs/updated/updated_waybills_func.dart';
// import 'package:stockall/local_database/waybills/waybills_func.dart';
// import 'package:stockall/main.dart';
// import 'package:stockall/providers/connectivity_provider.dart';
// import 'package:stockall/providers/error_log_provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class WaybillProvider extends ChangeNotifier {
//   static final WaybillProvider _instance =
//       WaybillProvider._internal();
//   factory WaybillProvider() => _instance;
//   WaybillProvider._internal();
//   bool isLoading = false;
//   void toggleIsLoading(bool value) {
//     isLoading = value;
//     // print(ill is ${value ? 'Loading on' : 'Loading Off'}',);
//     notifyListeners();
//   }
//   //
//   //
//   //

//   final SupabaseClient supabase = Supabase.instance.client;
//   final ConnectivityProvider connectivity =
//       ConnectivityProvider();
//   List<TempWayBills> _waybills = [];
//   List<TempWayBills> get waybills => _waybills;

//   final String tableName = 'way_bills';

//   void clearWaybills() {
//     _waybills.clear();
//     // clearRecords();
//     // print('Waybilprint(notifyListeners();
//   }

//   void clearAllAfterCreatingWaybill() {
//     waybillItemsTemp.clear();
//     tempCustomer = null;
//     customTotalAmount = null;
//     notifyListeners();
//   }

//   List<WaybillItems> waybillItemsTemp = [];

//   List<WaybillItems> waybillItemsReversed() {
//     return waybillItemsTemp.reversed.toList();
//   }

//   void addToItems({required WaybillItems item}) {
//     if (waybillItemsTemp.contains(item)) {
//       waybillItemsTemp.remove(item);
//     } else {
//       waybillItemsTemp.add(item);
//     }
//     notifyListeners();
//   }

//   void updateItem({required WaybillItems waybillItem}) {
//     var temp =
//         waybillItemsTemp.where((item) {
//           return waybillItem.uuid == item.uuid;
//         }).toList();
//     if (temp.isNotEmpty) {
//       temp.first.quantity = waybillItem.quantity;
//       temp.first.amount = waybillItem.amount;
//       temp.first.customPrice = waybillItem.customPrice;
//       temp.first.isGroup = waybillItem.isGroup;
//     }
//     notifyListeners();
//   }

//   TempCustomersClass? tempCustomer;

//   void selectCustomer({TempCustomersClass? customer}) {
//     tempCustomer = customer;
//     notifyListeners();
//   }

//   double? customTotalAmount;

//   void setCustomTotalAmount(double? total) {
//     customTotalAmount = total;
//     notifyListeners();
//   }

//   double totalWaybillAmount() {
//     if (customTotalAmount != null) {
//       return customTotalAmount ?? 0;
//     } else {
//       return waybillItemsTemp
//           .map((item) => item.amount)
//           .fold(0.0, (a, b) => a + b);
//     }
//   }

//   // CREATE a new receipt
//   Future<TempWayBills?> createWaybill({
//     required TempWayBills waybill,
//   }) async {
//     // print('Inner Waybill Creatprint(
//     bool isOnline = await connectivity.isOnline();
//     var newUuid = uuidGen();
//     waybill.uuid = newUuid;
//     try {
//       for (var item in waybillItemsTemp) {
//         item.waybillId = newUuid;
//       }
//     } catch (e) {
//       mainLocalLog('Error Setting Waybill Item Waybillid');
//       return null;
//     }
//     waybill.items = waybillItemsTemp;
//     waybill.createdAt = DateTime.now();
//     waybill.updatedAt = DateTime.now();
//     if (isOnline) {
//       try {
//         final res =
//             await supabase
//                 .from(tableName)
//                 .upsert(
//                   waybill.toJson(),
//                   onConflict: 'uuid',
//                 )
//                 .select()
//                 .single();
//         final newWaybill = TempWayBills.fromJson(res);
//         notifyListeners();
//         await loadWaybills(shopId());
//         clearAllAfterCreatingWaybill();
//         return newWaybill;
//       } catch (e) {
//         mainLocalLog(
//           '❌❌ Create Waybill Error Online: ${e.toString()}',
//         );
//         return null;
//       }
//     } else {
//       try {
//         await WaybillsFunc().createWaybill(waybill);
//         await CreatedWaybillsFunc().createWaybills(
//           CreatedWaybills(waybill: waybill),
//         );
//         notifyListeners();
//         await loadWaybills(shopId());
//         clearAllAfterCreatingWaybill();
//         return waybill;
//       } catch (e) {
//         print(
//           '❌❌ Create Waybill Error Offline: ${e.toString()}',
//         );
//         return null;
//       }
//     }
//   }

//   void initUpdateWaybill({
//     required TempWayBills waybill,
//     required BuildContext context,
//   }) {
//     waybillItemsTemp.clear();
//     for (var item in waybill.items) {
//       waybillItemsTemp.add(item.copyWith());
//     }
//     tempCustomer =
//         returnCustomers(context, listen: false).customers
//                 .where(
//                   (cust) => cust.uuid == waybill.customerId,
//                 )
//                 .isNotEmpty
//             ? returnCustomers(context, listen: false)
//                 .customers
//                 .where(
//                   (cust) => cust.uuid == waybill.customerId,
//                 )
//                 .first
//             : null;
//     customTotalAmount =
//         waybill.isCustomPriceSet == true
//             ? waybill.totalAmount
//             : null;
//     notifyListeners();
//   }

//   // CREATE a new receipt
//   //   Future<TempWayBills?> updateWaybill({
//   //     required TempWayBills waybill,
//   //   }) async {
//   //     print('Inner Waybill Update Started');
//   //     bool isOnline =  connectivity.isConnected;
//   //       waybill.updatedAt = DateTime.now();
//   //     try {
//   //       for (var item in waybillItemsTemp) {
//   //         item.waybillId = waybill.uuid;
//   //       }
//   //     } catch (e) {
//   //       print('Error Setting Waybill Item Waybill Uuid');
//   //       return null;
//   //     }
//   //     waybill.createdAt = DateTime.now();
//   //     if (isOnline) {
//   //       try {
//   //         final res =
//   //             await supabase
//   //                 .from(tableName)
//   //                 .upsert(
//   //                   waybill.toJson(),
//   //                   onConflict: 'uuid',
//   //                 )
//   //                 .select()
//   //                 .single();
//   //         final newWaybill = TempWayBills.fromJson(res);
//   //         notifyListeners();
//   //         await loadWaybills(shopId());
//   //         clearAllAfterCreatingWaybill();
//   //         return newWaybill;
//   //       } catch (e) {
//   //         print(
//   //           '❌❌ Update Waybill Error Online: ${e.toString()}',
//   //         );
//   //         return null;
//   //       }
//   // print( {
//   //       waybill.updatedAt = DateTime.now().add(
//   //         Duration(days: 1),
//   //       );
//   //       try {
//   //         var res = await WaybillsFunc().createWaybill(
//   //           waybill,
//   //         );
//   //         if (res == 1) {
//   //           var containsCreated =
//   //               CreatedWaybillsFunc()
//   //                   .getWaybills()
//   //                   .where(
//   //                     (createdProduct) =>
//   //                         createdProduct.waybill.uuid ==
//   //                         waybill.uuid,
//   //                   )
//   //                   .toList();
//   //           if (containsCreated.isEmpty) {
//   //             await UpdatedWaybillsFunc()
//   //                 .createUpdatedWaybill(
//   //                   UpdatedWaybills(waybill: waybill),
//   //                 );
//   //           } else {
//   //             await CreatedWaybillsFunc().createWaybills(
//   //               CreatedWaybills(waybill: waybill),
//   //             );
//   //           }
//   //         } else {
//   //           notifyListeners();
//   //           return null;
//   //         }
//   //         await loadWaybills(shopId());
//   //         clearAllAfterCreatingWaybill();
//   //         return waybill;
//   //       } catch (e) {
//   //         print(
//   //           '❌❌ Update Waybill Error Offline: ${e.toString()}',
//   //         );
//   //         return null;
//   //       }
//   //  print(D all receipts for a shop

//   Future<List<TempWayBills>> loadWaybills(
//     int shopId,
//   ) async {
//     bool isOnline = await connectivity.isOnline();
//     if (isOnline && WaybillsFunc().isSynced()) {
//       await WaybillsFunc().clearWaybills();
//       try {
//         final data = await supabase
//             .from(tableName)
//             .select()
//             .eq('shop_id', shopId)
//             .order('created_at', ascending: false);
//         if (data.isNotEmpty) {
//           print('Waybills Gotten ${data.length}');
//         }

//         _waybills =
//             (data as List)
//                 .map((item) => TempWayBills.fromJson(item))
//                 .toList();
//         await WaybillsFunc().insertAllWaybills(_waybills);
//         print('Loaded');
//         notifyListeners();
//       } catch (e) {
//         print('❌ Error Getting Waybills: ${e.toString()}');
//         return [];
//       }
//     } else {
//       _waybills = WaybillsFunc().getWaybills();
//       // printprint(Gotten');
//       notifyListeners();
//     }
//     notifyListeners();
//     return _waybills;
//   }

//   DateTime? dateSet;

//   void clearDate() {
//     //  print(
//     rangeStartDate = null;
//     rangeEndDate = null;
//     notifyListeners();
//   }

//   void setDate(DateTime date) {
//     if (dateSet == null) {
//       dateSet = date;
//       rangeStartDate = null;
//       rangeEndDate = null;
//       //  print(('Date set: $date');
//     } else {
//       dateSet = null;
//       //  print(('Date Cleared');
//     }
//     notifyListeners();
//   }

//   DateTime? rangeStartDate;
//   DateTime? rangeEndprint;

//   // ((ange(DateTime rangeStart, DateTime endOfrange) {
//   //   rangeStarprint((
//   //   rangeEndDate = endOfrange;
//   // print(t(
//   //     'Date Range set: Start: $rangeStart End: $endOfrange ',
//   //   );
//   //   dateSet = null;
//   //   notifyListeners();
//   // }

//   // DELETE a receipt
//   // Future<int> deleteWaybill(
//   //   TempWayBills waybill,
//   //   bool createUpdate,
//   // ) async {
//   // // print(t('Deleting Waybill');
//   //   bool isOnline = await connectivity.isOnline();
//   //   try {
//   //     if (isOnline) {
//   //     // print(t('Deleting Waybill Online');
//   //       await supabase
//   //           .from(tableName).delete() .eq('uuid', waybill.uuid!);
//   //     // print(t('Finished Deleting Waybill Online');
//   //       var containsUpdate print(t(()
//   //           .getWaybillIds()
//   //           .where(
//   //             (purch) => purch.waybill.uuid == waybill.uuid,
//   //           );
//   //       if (containsprint(t(
//   //         await UpdatedWaybillsFunc().deleteUpdatedWaybill(
//   //           waybill.uuid!,
//   //         );
//   //       }
//   //     } else {
//   //    print(nt('Deleting Waybill Offline');
//   //       await WaybillsFunc().deleteWaybill(waybill.uuid!);
//   //       var containsCreated =
//   //           CreatedWaybillsFunc()
//   //               .getWaybills()
//   //               .where(
//   //                 (purch) =>
//   //       print(nt(ybill.uuid == waybill.uuid,
//   //               )
//   //               .toList();
//   //       var containsUpdate = UpdatedWaybillsFunc()
//   //           .getWaybillIds()
//   //           .where(
//   //             (purch) =>
//   //                 purch.waybill.uuid == waybill.uuid!,
//   //           );
//   //       if (containsCreated.isNotEmpty) {
//   //         await CreatedWaybillsFunc().deleteWaybill(
//   //           waybill.uuid!,
//   //         );
//   //       } else {
//   //         await DeletedWaybillsFunc().createDeletedWaybill(
//   //           DeletedWaybills(waybillUuid: waybill.uuid!),
//   //         );
//   //       }
//   //       if (containsUpdate.isNotEmpty) {
//   //         await UpdatedWaybillsFunc().deleteUpdatedWaybill(
//   //           waybill.uuid!,
//   //         );
//   //       }
//   //     }

//   //  print(nt('✅ Waybill successfully Delete.');

//   //     notifyListeners();
//   //     return 1;
//   //   } catch (e) {
//   //  print(nt('Error Deleting Waybill: ${e.toString()}');
//   //     return 0;
//   //   }
//   // }

//   //
//   //
//   //
//   //

//   //   Future<void> createWaybillsSync() async {
//   //     tprint(nt(ine = await connectivity.isOnline();
//   //       // Prepare batch payload
//   //       if (CreatedWaybillsFunc().gprint(nt(y &&
//   //           isOnline) {
//   //         final tempWaybills =
//   //             CreatedWaybillsFunc().getWaybills().toList();
//   //         var newWaybills = tempWaybills.map((rec) {
//   //           rec.waybill.createdAt =
//   //               rec.waybill.createdAt!.toUtc();
//   //           return rec;
//   //         });
//   //         final payload =
//   //             newWaybills
//   //                 .map((p) => p.waybill.toJson())
//   //                 .toList();

//   //         // Insert all at once
//   //         final data =
//   //             await supabase
//   //                 .from(tableName)
//   //                 .insert(payload)
//   //                 .select();

//   //      print(nt('${data.length} items added successfully ✅');
//   //         await CreatedWaybillsFunc().clearWaybills();
//   //      print(nt('Unsynced Waybills Cleared');

//   //      print(nt('Mounted, refreshing Waybills ✅');
//   //         await loadWaybills(
//   //           returnShopProvider().userShop()!.shopId!,
//   //         );print(nt( (e) {
//   //    print(nt('Batch Waybill Insert failed ❌: $e');
//   //       await createErrorLog(
//   //         error: 'Baprint(nt(led ❌: $e',
//   //       );
//   //     }
//   //   }

//   //  print(nt(
//   //

//   //
//   //
//   //
//   //
//   //

//   // Future<void> deleteWaybillsSync() async {
//   //   try {
//   //     bool isOnline = await connectivity.isOnline();
//   //     // print(int(      if (DeletedWaybillsFunc()
//   //             .getWaybillIds()
//   //             .isNotEmpty &&
//   //         isOnline) {
//   //       final tempWaybills =
//   //           DeletedWaybillsFunc().getWaybillIds().toList();

//   //       for (var rec in tempWaybills) {
//   //         await supabase
//   //             .from(tableName)
//   //             .delete()
//   //             .eq('uuid', rec.waybillUuid);
//   //         // await DeletedWaybillsFunc()
//   //         //     .deletedDeletedWaybills(rec.waybillUuid);
//   //       }

//   //   print(int(
//   //         '${tempWaybills.length} Waybills Created successfully ✅',
//   //       );
//   //       await DeletedWaybillsFunc().clearDeletedWaybills();
//   //   print(int('Unsynced Deleted Waybills Cleared');

//   //   print(int('Mounted, refreshing Waybills ✅');
//   //       await loadWaybills(
//   //         returnShopProvider().userShop()!.shopId!,
//   //       );print(int((e) {
//   // print(int('Batch Waybills Delete failed ❌: $e');
//   //     await createErrorLog(
//   //       error: 'Batch Waybills Delete failed ❌: $e',
//   //     print(int(
//   //
//   //
//   //

//   //   Future<void> updateWaprint(rint( try {
//   //       bool isOnline = await connectivity.isOnline();
//   //  print(rint(
//   //         UpdatedWaybillsFunc()
//   //             .getWaybillIds()
//   //             .length
//   //  print(rint(
//   //       );

//   //       if (UpdatedWaybillsFunc()
//   //               .getWaybillIds()
//   //               .isNotEmpty &&
//   //           isOnline) {
//   //         final updatedWaybills =
//   //             UpdatedWaybillsFunc().getWaybillIds();

//   //         for (final updated in updatedWaybills) {
//   //           finaprint(print(.waybill;

//   //           localWaybills.updatedAt ??=
//   //               DateTime.now().toLocal();

//   //           if (localWaybills.uuid == null) {
//   //       print(print('Local Waybills Uuid is Null');
//   //           }
//   //           final remoteData =
//   //               await supabase
//   //                   .from('waybills')
//   //                   .select('uuid, updated_at')
//   //                   .eq('uuid', localWaybills.uuid!)
//   //                   .maybeSingle();

//   //           if (remoteData == null) {
//   //             await supabase
//   //                 .from('waybills')
//   //                 .insert(lprint(print(      print(print(
//   //               'Inserted product with uuid ${localWaybills.uuid}',
//   //             );
//   //             await UpdatedWaybillsFunc()
//   //                 .deleteUpdatedWaybill(
//   //                   localWaybills.uuid ?? '',
//   //                 );
//   //           } else {
//   //             final remoteUpdatedAtRaw =
//   //                 remoteData['updated_at'];
//   //             final remoteUpdatedAt =
//   //                 remoteUpdatedAtRaw == null
//   //   print(print(
//   //                     : DateTime.parse(
//   //                       remoteUpdatedAtRaw,
//   //                     ).toUtc();

//   //             localWaybills.updatedAt =
//   //                 (localWaybills.updatedAt ?? DateTime.now())
//   //                     .toUtc(); // ✅ keep both UTC
//   //      print( print(
//   //               "Local updatedAt: ${localWaybills.updatedAt}",
//   //             );
//   //      print( print("Remote updatedAt: $remoteUpdatedAt");

//   //             if (remoteUpdatedAt == null ||
//   //                 localWaybills.updatedAt!.isAfter(
//   //                   remoteUpdatedAt,
//   //                 )) {
//   //               await supabase
//   //                   .from('waybills')
//   //                   .update(localWaybills.toJson())
//   //                   print(uprint(uuid!);
//   //        print( print(
//   //                 'Updated Waybill with uuid ${localWaybprint(uprint(  );
//   //               await UpdatedWaybillsFunc()
//   //                   .deleteUpdatedWaybill(
//   //                     localWaybills.uuid ?? '',
//   //                   );
//   //             } else {
//   //        print( print(
//   //                 'Skipped Waybill ${localWaybills.uuid}, remote is newer ✅',
//   //               );
//   //             }
//   //           }
//   //         }

//   //         await UpdatedWaybillsFuncprint(aprint(
//   //  print( print('Unsynced Waybill products cleared');
//   //  print( print('Mounted, refreshing products ✅');
//   //         await loadWaybills(
//   //           returnShopProvider().userShop()!.shopId!,
//   //         );
//   //       }
//   //     } catch (e) {aprint(print('Batch Waybills Update failed ❌:aprint(rint(ErrorLog(
//   //         error: 'Batch Waybills Update failed ❌: $e',
//   //       );
//   //     }
//   //   }
//   //
//   //

//   //   List<TempWayBills> departmentWaybills() {
//   //     if (returnShopProvider()
//   //             .userShop()
//   // aprint(rint(tments ==
//   //         true) {
//   //       if (!auaprint(rint(horized: Authorizations().viewAllDepartments,
//   //       )) {
//   //         return waybills.where((cat) {
//   //           return cat.departmentId ==
//   //               returnDeaprint(rint(             .currentDepartment()
//   //                   ?.uuid;
//   //         }).toList();
//   //       } else {
//   //         if (returnDepartmentProvider()
//   //                 .currentDepartment()
//   //                 ?.uuid ==
//   //             null) {
//   //           return waybills;
//   //         } else {
//   //           return waybills.where((cat) {
//   //             return cat.departmentId ==
//   //                 returnDepartmentProvider()
//   //                     .currentDepartment()
//   //                     ?.uuid;
//   //             // }
//   //           }).toList();
//   //         }
//   //       }
//   //     } else {
//   //       return waybills;
//   //     }
//   //   }

//   // List<TempWayBills> returnWaybillsByDateForIndex() {
//   //   if (returnShopProvider()
//   //           .userShop()
//   //           ?.manageDepartments ==
//   //       true) {
//   //     if (rangeStartDate != null) {
//   //       return departmentWaybills().where((waybill) {
//   //         final created = waybill.createdAt!.toLocal();
//   //         return !created.isBefore(
//   //               fourAm(rangeStartDate!),
//   //             ) &&
//   //             created.isBefore(
//   //               fourAmNextDay(
//   //                 rangeEndDate ??
//   //                     resolveBusinessDate(DateTime.now()),
//   //               ),
//   //             );
//   //       }).toList();
//   //     } else {
//   //       // final currentDate = dateSet ?? DateTime.now();
//   //       final currentDate =
//   //           dateSet ?? resolveBusinessDate(DateTime.now());

//   //       return departmentWaybills()
//   //           .where(
//   //             (waybill) =>
//   //                 !waybill.createdAt!.isBefore(
//   //                   fourAm(currentDate),
//   //                 ) &&
//   //                 waybill.createdAt!.isBefore(
//   //                   fourAmNextDay(currentDate),
//   //                 ),
//   //           )
//   //           .toList();
//   //     }
//   //   } else {
//   //     if (rangeStartDate != null) {
//   //       if (authorization(
//   //         authorized:
//   //             Authorizations().viewAllTransactionRecords,
//   //       )) {
//   //         return waybills.where((waybill) {
//   //           final created = waybill.createdAt!.toLocal();
//   //           return !created.isBefore(
//   //                 fourAm(rangeStartDate!),
//   //               ) &&
//   //               created.isBefore(
//   //                 fourAmNextDay(
//   //                   rangeEndDate ??
//   //                       resolveBusinessDate(DateTime.now()),
//   //                 ),
//   //               );
//   //         }).toList();
//   //       } else {
//   //         return waybills.where((waybill) {
//   //           final created = waybill.createdAt!.toLocal();
//   //           return !created.isBefore(
//   //                 fourAm(rangeStartDate!),
//   //               ) &&
//   //               created.isBefore(
//   //                 fourAmNextDay(
//   //                   rangeEndDate ??
//   //                       resolveBusinessDate(DateTime.now()),
//   //                 ),
//   //               ) &&
//   //               waybill.staffId == currentUser().userId;
//   //         }).toList();
//   //       }
//   //     } else {
//   //       final currentDate = dateSet ?? DateTime.now();

//   //       if (authorization(
//   //         authorized:
//   //             Authorizations().viewAllTransactionRecords,
//   //       )) {
//   //         return waybills
//   //             .where(
//   //               (waybill) =>
//   //                   !waybill.createdAt!.isBefore(
//   //                     fourAm(currentDate),
//   //                   ) &&
//   //                   !waybill.createdAt!.isAfter(
//   //                     fourAmNextDay(currentDate),
//   //                   ),
//   //             )
//   //             .toList();
//   //       } else {
//   //         return waybills
//   //             .where(
//   //               (waybill) =>
//   //                   !waybill.createdAt!.isBefore(
//   //                     fourAm(currentDate),
//   //                   ) &&
//   //                   !waybill.createdAt!.isAfter(
//   //                     fourAmNextDay(currentDate),
//   //                   ) &&
//   //                   waybill.staffId == currentUser().userId,
//   //             )
//   //             .toList();
//   //       }
//   //     }
//   //   }
//   // }

//   // List<TempWayBills> returnOwnWaybillsByDayOrWeek({
//   //   required int index,
//   // }) {
//   //   if (index == 2) {
//   //     return returnWaybillsByDateForIndex().where((
//   //       waybill,
//   //     ) {
//   //       return waybill.status == 'not-sent';
//   //     }).toList();
//   //   } else if (index == 3) {
//   //     return returnWaybillsByDateForIndex().where((
//   //       waybill,
//   //     ) {
//   //       return waybill.status == 'en-route';
//   //     }).toList();
//   //   } else if (index == 4) {
//   //     return returnWaybillsByDateForIndex().where((
//   //       waybill,
//   //     ) {
//   //       return waybill.status == 'delivered';
//   //     }).toList();
//   //   } else if (index == 5) {
//   //     return returnWaybillsByDateForIndex().where((
//   //       waybill,
//   //     ) {
//   //       return waybill.status == 'pick-up';
//   //     }).toList();
//   //   } else {
//   //     return returnWaybillsByDateForIndex();
//   //   }
//   // }

//   // double getTotalRevenueForSelectedDayAll({
//   //   String? staffId,
//   //   String? customerUuid,
//   //   required int index,
//   // }) {
//   //   double tempTotalRevenue = 0;

//   //   for (var waybill
//   //       in (staffId != null
//   //           ? returnOwnWaybillsByDayOrWeek(
//   //             index: index,
//   //           ).where((rec) => rec.staffId == staffId)
//   //           : customerUuid != null
//   //           ? returnOwnWaybillsByDayOrWeek(
//   //             index: index,
//   //           ).where((rec) => rec.customerId == customerUuid)
//   //           : returnOwnWaybillsByDayOrWeek(index: index))) {
//   //     tempTotalRevenue += getTotalMainRevenueWaybill(
//   //       waybill,
//   //     );
//   //   }

//   //   return tempTotalRevenue;
//   // }

//   String getWaybillText(TempWayBills waybill) {
//     if (waybill.status == 'delivered') {
//       return 'Delivered';
//     } else if (waybill.status == 'en-route') {
//       return 'En-Route';
//     } else if (waybill.status == 'picked-up') {
//       return 'Picked Up';
//     } else {
//       return 'Not Sent';
//     }
//   }

//   int getWaybillStatus(TempWayBills waybill) {
//     if (waybill.status == 'delivered') {
//       return 2;
//     } else if (waybill.status == 'en-route') {
//       return 1;
//     } else if (waybill.status == 'picked-up') {
//       return 3;
//     } else {
//       return 0;
//     }
//   }

//   double getTotalMainRevenueWaybill(TempWayBills waybill) {
//     var total = ((waybill.totalAmount ?? 0));

//     return total;
//   }

//   //
//   //
//   //
//   //
//   //
//   //
//   //
//   //

//   //
//   //
//   //
//   ///
//   //////
//   /////
//   /////
//   ///
//   /////
//   ///
//   ///
//   //
//   //
//   //
//   //
//   //
//   //
// }
