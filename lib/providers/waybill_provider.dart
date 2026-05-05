import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_waybills/temp_way_bills.dart';
import 'package:stockall/classes/temp_waybills/unsynced/created_waybills/created_waybills.dart';
import 'package:stockall/classes/temp_waybills/unsynced/deleted_waybills/deleted_waybills.dart';
import 'package:stockall/classes/temp_waybills/unsynced/updated/updated_waybills.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/waybills/unsync_funcs/created/created_waybills_func.dart';
import 'package:stockall/local_database/waybills/unsync_funcs/deleted/deleted_waybills_func.dart';
import 'package:stockall/local_database/waybills/unsync_funcs/updated/updated_waybills_func.dart';
import 'package:stockall/local_database/waybills/waybills_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WaybillProvider extends ChangeNotifier {
  static final WaybillProvider _instance =
      WaybillProvider._internal();
  factory WaybillProvider() => _instance;
  WaybillProvider._internal();
  bool isLoading = false;
  void toggleIsLoading(bool value) {
    isLoading = value;
    print(
      'Waybill is ${value ? 'Loading on' : 'Loading Off'}',
    );
    notifyListeners();
  }
  //
  //
  //

  final SupabaseClient supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();
  List<TempWayBills> _waybills = [];
  List<TempWayBills> get waybills => _waybills;

  final String tableName = 'waybills';

  void clearWaybills() {
    _waybills.clear();
    // clearRecords();
    print('Waybills Cleared');
    notifyListeners();
  }

  // CREATE a new receipt
  Future<TempWayBills?> createWaybill(
    TempWayBills waybill,
  ) async {
    print('Inner Waybill Creation Started');
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      try {
        final res =
            await supabase
                .from(tableName)
                .upsert(
                  waybill.toJson(),
                  onConflict: 'uuid',
                )
                .select()
                .single();
        final newWaybill = TempWayBills.fromJson(res);
        notifyListeners();
        // await loadWaybills(shopId());
        return newWaybill;
      } catch (e) {
        print(
          '❌❌ Create Waybill Error Online: ${e.toString()}',
        );
        return null;
      }
    } else {
      try {
        waybill.createdAt = DateTime.now();
        await WaybillsFunc().createWaybill(waybill);
        await CreatedWaybillsFunc().createWaybills(
          CreatedWaybills(waybill: waybill),
        );
        notifyListeners();
        // await loadWaybills(shopId());
        return waybill;
      } catch (e) {
        print(
          '❌❌ Create Waybill Error Offline: ${e.toString()}',
        );
        return null;
      }
    }
  }

  // CREATE a new receipt
  Future<TempWayBills?> updateWaybill(
    TempWayBills waybill,
  ) async {
    print('Inner Waybill Update Started');
    bool isOnline = await connectivity.isOnline();
    waybill.updatedAt = DateTime.now();
    if (isOnline) {
      try {
        final res =
            await supabase
                .from(tableName)
                .upsert(
                  waybill.toJson(),
                  onConflict: 'uuid',
                )
                .select()
                .single();
        final newWaybill = TempWayBills.fromJson(res);
        notifyListeners();
        await loadWaybills(shopId());
        return newWaybill;
      } catch (e) {
        print(
          '❌❌ Update Waybill Error Online: ${e.toString()}',
        );
        return null;
      }
    } else {
      waybill.updatedAt = DateTime.now().add(
        Duration(days: 1),
      );
      try {
        var res = await WaybillsFunc().createWaybill(
          waybill,
        );
        if (res == 1) {
          var containsCreated =
              CreatedWaybillsFunc()
                  .getWaybills()
                  .where(
                    (createdProduct) =>
                        createdProduct.waybill.uuid ==
                        waybill.uuid,
                  )
                  .toList();
          if (containsCreated.isEmpty) {
            await UpdatedWaybillsFunc()
                .createUpdatedWaybill(
                  UpdatedWaybills(waybill: waybill),
                );
          } else {
            await CreatedWaybillsFunc().createWaybills(
              CreatedWaybills(waybill: waybill),
            );
          }
        } else {
          notifyListeners();
          return null;
        }
        await loadWaybills(shopId());
        return waybill;
      } catch (e) {
        print(
          '❌❌ Update Waybill Error Offline: ${e.toString()}',
        );
        return null;
      }
    }
  }

  // READ all receipts for a shop
  Future<List<TempWayBills>> loadWaybills(
    int shopId,
  ) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      await WaybillsFunc().clearWaybills();
      try {
        final data = await supabase
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false);
        if (data.isNotEmpty) {
          print('Waybills Gotten ${data.length}');
        }

        _waybills =
            (data as List)
                .map((json) => TempWayBills.fromJson(json))
                .toList();
        await WaybillsFunc().insertAllWaybills(_waybills);
        print('Loaded');
        notifyListeners();
      } catch (e) {
        print('❌ Error Getting Waybills: ${e.toString()}');
        return [];
      }
    } else {
      _waybills = WaybillsFunc().getWaybills();
      print('Offline Waybills Gotten');
      notifyListeners();
    }
    notifyListeners();
    return _waybills;
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
  Future<int> deleteWaybill(
    TempWayBills waybill,
    bool? updateInventory,
    bool createUpdate,
  ) async {
    print('Deleting Waybill');
    bool isOnline = await connectivity.isOnline();
    try {
      if (isOnline) {
        print('Deleting Waybill Online');
        await supabase
            .from(tableName)
            .delete()
            .eq('uuid', waybill.uuid!);
        print('Finished Deleting Waybill Online');
        var containsUpdate = UpdatedWaybillsFunc()
            .getWaybillIds()
            .where(
              (purch) => purch.waybill.uuid == waybill.uuid,
            );
        if (containsUpdate.isNotEmpty) {
          await UpdatedWaybillsFunc().deleteUpdatedWaybill(
            waybill.uuid!,
          );
        }
      } else {
        print('Deleting Waybill Offline');
        await WaybillsFunc().deleteWaybill(waybill.uuid!);
        var containsCreated =
            CreatedWaybillsFunc()
                .getWaybills()
                .where(
                  (purch) =>
                      purch.waybill.uuid == waybill.uuid,
                )
                .toList();
        var containsUpdate = UpdatedWaybillsFunc()
            .getWaybillIds()
            .where(
              (purch) =>
                  purch.waybill.uuid == waybill.uuid!,
            );
        if (containsCreated.isNotEmpty) {
          await CreatedWaybillsFunc().deleteWaybill(
            waybill.uuid!,
          );
        } else {
          await DeletedWaybillsFunc().createDeletedWaybill(
            DeletedWaybills(waybillUuid: waybill.uuid!),
          );
        }
        if (containsUpdate.isNotEmpty) {
          await UpdatedWaybillsFunc().deleteUpdatedWaybill(
            waybill.uuid!,
          );
        }
      }

      print('✅ Waybill successfully Delete.');

      notifyListeners();
      return 1;
    } catch (e) {
      print('Error Deleting Waybill: ${e.toString()}');
      return 0;
    }
  }

  //
  //
  //
  //

  Future<void> createWaybillsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedWaybillsFunc().getWaybills().isNotEmpty &&
          isOnline) {
        final tempWaybills =
            CreatedWaybillsFunc().getWaybills().toList();
        var newWaybills = tempWaybills.map((rec) {
          rec.waybill.createdAt =
              rec.waybill.createdAt!.toUtc();
          return rec;
        });
        final payload =
            newWaybills
                .map((p) => p.waybill.toJson())
                .toList();

        // Insert all at once
        final data =
            await supabase
                .from(tableName)
                .insert(payload)
                .select();

        print('${data.length} items added successfully ✅');
        await CreatedWaybillsFunc().clearWaybills();
        print('Unsynced Waybills Cleared');

        print('Mounted, refreshing Waybills ✅');
        await loadWaybills(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      print('Batch Waybills insert failed ❌: $e');
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

  Future<void> deleteWaybillsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (DeletedWaybillsFunc()
              .getWaybillIds()
              .isNotEmpty &&
          isOnline) {
        final tempWaybills =
            DeletedWaybillsFunc().getWaybillIds().toList();

        for (var rec in tempWaybills) {
          await supabase
              .from(tableName)
              .delete()
              .eq('uuid', rec.waybillUuid);
          // await DeletedWaybillsFunc()
          //     .deletedDeletedWaybills(rec.waybillUuid);
        }

        print(
          '${tempWaybills.length} Waybills Created successfully ✅',
        );
        await DeletedWaybillsFunc().clearDeletedWaybills();
        print('Unsynced Deleted Waybills Cleared');

        print('Mounted, refreshing Waybills ✅');
        await loadWaybills(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      print('Batch Waybills Deleted failed ❌: $e');
    }
  }

  //
  //
  //
  //

  Future<void> updateWaybillSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      print(
        UpdatedWaybillsFunc()
            .getWaybillIds()
            .length
            .toString(),
      );

      if (UpdatedWaybillsFunc()
              .getWaybillIds()
              .isNotEmpty &&
          isOnline) {
        final updatedWaybills =
            UpdatedWaybillsFunc().getWaybillIds();

        for (final updated in updatedWaybills) {
          final localWaybills = updated.waybill;

          localWaybills.updatedAt ??=
              DateTime.now().toLocal();

          if (localWaybills.uuid == null) {
            print('Local Waybills Uuid is Null');
          }
          final remoteData =
              await supabase
                  .from('waybills')
                  .select('uuid, updated_at')
                  .eq('uuid', localWaybills.uuid!)
                  .maybeSingle();

          if (remoteData == null) {
            await supabase
                .from('waybills')
                .insert(localWaybills.toJson());
            print(
              'Inserted product with uuid ${localWaybills.uuid}',
            );
            await UpdatedWaybillsFunc()
                .deleteUpdatedWaybill(
                  localWaybills.uuid ?? '',
                );
          } else {
            final remoteUpdatedAtRaw =
                remoteData['updated_at'];
            final remoteUpdatedAt =
                remoteUpdatedAtRaw == null
                    ? null
                    : DateTime.parse(
                      remoteUpdatedAtRaw,
                    ).toUtc();

            localWaybills.updatedAt =
                (localWaybills.updatedAt ?? DateTime.now())
                    .toUtc(); // ✅ keep both UTC
            print(
              "Local updatedAt: ${localWaybills.updatedAt}",
            );
            print("Remote updatedAt: $remoteUpdatedAt");

            if (remoteUpdatedAt == null ||
                localWaybills.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from('waybills')
                  .update(localWaybills.toJson())
                  .eq('uuid', localWaybills.uuid!);
              print(
                'Updated Waybill with uuid ${localWaybills.uuid}',
              );
              await UpdatedWaybillsFunc()
                  .deleteUpdatedWaybill(
                    localWaybills.uuid ?? '',
                  );
            } else {
              print(
                'Skipped Waybill ${localWaybills.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedWaybillsFunc().clearUpdatedWaybills();
        print('Unsynced Waybill products cleared');
      }
    } catch (e) {
      print('Batch update failed ❌: $e');
    }

    print('Mounted, refreshing products ✅');
    await loadWaybills(
      returnShopProvider().userShop()!.shopId!,
    );
  }
  //
  //

  List<TempWayBills> departmentWaybills() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return waybills.where((cat) {
          return cat.departmentId ==
              returnDepartmentProvider()
                  .currentDepartment()
                  ?.uuid;
        }).toList();
      } else {
        if (returnDepartmentProvider()
                .currentDepartment()
                ?.uuid ==
            null) {
          return waybills;
        } else {
          return waybills.where((cat) {
            return cat.departmentId ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
            // }
          }).toList();
        }
      }
    } else {
      return waybills;
    }
  }

  List<TempWayBills> returnWaybillsByDateForIndex() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (rangeStartDate != null) {
        return departmentWaybills().where((waybill) {
          final created = waybill.createdAt!.toLocal();
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

        return departmentWaybills()
            .where(
              (waybill) =>
                  !waybill.createdAt!.isBefore(
                    fourAm(currentDate),
                  ) &&
                  waybill.createdAt!.isBefore(
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
          return waybills.where((waybill) {
            final created = waybill.createdAt!.toLocal();
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
          return waybills.where((waybill) {
            final created = waybill.createdAt!.toLocal();
            return !created.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                created.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ) &&
                waybill.staffId == currentUser().userId;
          }).toList();
        }
      } else {
        final currentDate = dateSet ?? DateTime.now();

        if (authorization(
          authorized:
              Authorizations().viewAllTransactionRecords,
        )) {
          return waybills
              .where(
                (waybill) =>
                    !waybill.createdAt!.isBefore(
                      fourAm(currentDate),
                    ) &&
                    !waybill.createdAt!.isAfter(
                      fourAmNextDay(currentDate),
                    ),
              )
              .toList();
        } else {
          return waybills
              .where(
                (waybill) =>
                    !waybill.createdAt!.isBefore(
                      fourAm(currentDate),
                    ) &&
                    !waybill.createdAt!.isAfter(
                      fourAmNextDay(currentDate),
                    ) &&
                    waybill.staffId == currentUser().userId,
              )
              .toList();
        }
      }
    }
  }

  // List<TempWayBills> returnOwnWaybillsByDayOrWeek({
  //   required int index,
  // }) {
  //   if (index == 1) {
  //     return returnWaybillsByDateForIndex();
  //   } else if (index == 2) {
  //     return returnWaybillsByDateForIndex().where((purch) {
  //       if (getWaybillPaymentBalance(purch) == 0) {
  //         return true;
  //       } else {
  //         return false;
  //       }
  //     }).toList();
  //   } else {
  //     return returnWaybillsByDateForIndex().where((purch) {
  //       if (getWaybillPaymentBalance(purch) != 0) {
  //         return true;
  //       } else {
  //         return false;
  //       }
  //     }).toList();
  //   }
  // }

  // double getTotalRevenueForSelectedDayAll({
  //   String? staffId,
  //   String? customerId,
  //   required int index,
  // }) {
  //   double tempTotalRevenue = 0;

  //   for (var waybill
  //       in (staffId != null
  //           ? returnOwnWaybillsByDayOrWeek(
  //             index: index,
  //           ).where((rec) => rec.staffId == staffId)
  //           : customerId != null
  //           ? returnOwnWaybillsByDayOrWeek(
  //             index: index,
  //           ).where((rec) => rec.customerId == customerId)
  //           : returnOwnWaybillsByDayOrWeek(index: index))) {
  //     tempTotalRevenue += getTotalMainRevenueWaybill(
  //       waybill,
  //     );
  //   }

  //   return tempTotalRevenue;
  // }

  String getWaybillStatus(TempWayBills waybill) {
    if (waybill.status == 'delivered') {
      return 'Delivered';
    } else if (waybill.status == 'delivering') {
      return 'Delivering';
    } else if (waybill.status == 'picked') {
      return 'Picked Up';
    } else {
      return 'Cancelled';
    }
  }

  double getTotalMainRevenueWaybill(TempWayBills waybill) {
    var total = ((waybill.totalAmount ?? 0));

    return total;
  }
}
