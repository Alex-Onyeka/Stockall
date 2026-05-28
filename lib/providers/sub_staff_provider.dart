import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_sub_staff/temp_sub_staff.dart';
import 'package:stockall/classes/temp_sub_staff/unsynced/created_sub_staffs/created_sub_staff.dart';
import 'package:stockall/classes/temp_sub_staff/unsynced/deleted_sub_staff/deleted_sub_staff.dart';
import 'package:stockall/classes/temp_sub_staff/unsynced/updated/updated_sub_staff.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/sub_staff/sub_staff_func.dart';
import 'package:stockall/local_database/sub_staff/unsync_funcs/created/created_sub_staff_func.dart';
import 'package:stockall/local_database/sub_staff/unsync_funcs/deleted/deleted_sub_staff_func.dart';
import 'package:stockall/local_database/sub_staff/unsync_funcs/updated/updated_sub_staff_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubStaffProvider extends ChangeNotifier {
  static final SubStaffProvider _instance =
      SubStaffProvider._internal();
  factory SubStaffProvider() => _instance;
  SubStaffProvider._internal();
  final supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();

  List<TempSubStaff> subStaffsMain = [];

  List<TempSubStaff> subStaffs() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return subStaffsMain.where((cat) {
          // if (cat.departmentUuid == null) {
          //   return true;
          // } else {
          return cat.departmentUuid ==
              returnDepartmentProvider()
                  .currentDepartment()
                  ?.uuid;
          // }
        }).toList();
      } else {
        if (returnDepartmentProvider()
                .currentDepartment()
                ?.uuid ==
            null) {
          return subStaffsMain;
        } else {
          return subStaffsMain.where((cat) {
            // if (cat.departmentUuid == null) {
            //   return true;
            // } else {
            return cat.departmentUuid ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
            // }
          }).toList();
        }
      }
    } else {
      return subStaffsMain;
    }
  }

  final String tableName = 'sub_staff';
  void clearSubStaffs() {
    subStaffsMain.clear();
    print('Sub Staffs Cleared');
    notifyListeners();
  }

  Future<int> createSubStaff(TempSubStaff subStaff) async {
    bool isOnline = await connectivity.isOnline();
    try {
      subStaff.updatedAt = DateTime.now();
      subStaff.createdAt = DateTime.now();
      subStaff.uuid = uuidGen();
      if (isOnline) {
        Map<String, dynamic>? res =
            await supabase
                .from(tableName)
                .insert(subStaff.toJson())
                .select()
                .maybeSingle();

        if (res == null) {
          print('Failed to Create Sub Staff');
          return 0;
        }

        TempSubStaff exp = TempSubStaff.fromJson(res);
        await SubStaffFunc().createSubStaff(exp);
        await returnEventsLogProvider().createLog(
          returnEventsLogProvider(
            // ignore: use_build_context_synchronously
          ).subStaffAdapter(exp, 1),
          // ignore: use_build_context_synchronously
        );
        print('Created Sub Staff Online');
        await getSubStaffs();
        notifyListeners();
        return 1;
      } else {
        await SubStaffFunc().createSubStaff(subStaff);
        await CreatedSubStaffFunc().createSubStaff(
          CreatedSubStaff(subStaff: subStaff),
        );
        await returnEventsLogProvider().createLog(
          returnEventsLogProvider(
            // ignore: use_build_context_synchronously
          ).subStaffAdapter(subStaff, 1),
          // ignore: use_build_context_synchronously
        );
        print('Created Sub Staff Offline');
        await getSubStaffs();
        notifyListeners();
        return 1;
      }
    } catch (e) {
      print('Error Creating Sub Staff: ${e.toString()}');
      return 0;
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

  Future<List<TempSubStaff>> getSubStaffs() async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline && returnData().isSynced() == 1) {
      final response = await supabase
          .from(tableName)
          .select()
          .eq('shop_id', shopId())
          .order('created_at', ascending: false);
      print('Sub Staffs Gotten: ${response.length}');

      subStaffsMain =
          (response as List)
              .map((e) => TempSubStaff.fromJson(e))
              .toList();
      await SubStaffFunc().insertAllSubStaffs(
        subStaffsMain,
      );
    } else {
      subStaffsMain = SubStaffFunc().getSubStaffs();
    }
    notifyListeners();
    return subStaffsMain;
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
  Future<int> updateSubStaff(
    TempSubStaff subStaff,
    // BuildContext context,
  ) async {
    bool isOnline = await connectivity.isOnline();
    try {
      subStaff.updatedAt = DateTime.now();
      print(subStaff.uuid);
      if (isOnline) {
        var res =
            await supabase
                .from(tableName)
                .update(subStaff.toJson())
                .eq('uuid', subStaff.uuid!)
                .select()
                .maybeSingle();
        if (res == null) {
          print('Failed to Update Sub Staff');
          return 0;
        }
        await returnEventsLogProvider().createLog(
          returnEventsLogProvider().subStaffAdapter(
            subStaff,
            2,
          ),
        );
        await getSubStaffs();
        notifyListeners();
        return 1;
      } else {
        await SubStaffFunc().updateSubStaff(subStaff);
        var containsCreated =
            CreatedSubStaffFunc()
                .getSubStaffs()
                .where(
                  (exp) =>
                      exp.subStaff.uuid == subStaff.uuid,
                )
                .toList();
        if (containsCreated.isEmpty) {
          await UpdatedSubStaffFunc().createUpdatedSubStaff(
            UpdatedSubStaff(subStaff: subStaff),
          );
        } else {
          await CreatedSubStaffFunc().updateSubStaff(
            CreatedSubStaff(subStaff: subStaff),
          );
        }
        await returnEventsLogProvider().createLog(
          returnEventsLogProvider().subStaffAdapter(
            subStaff,
            2,
          ),
        );
        notifyListeners();
        await getSubStaffs();
        return 1;
      }
    } catch (e) {
      print('Error Updating Sub Staff: ${e.toString()}');
      return 0;
    }
  }
  //
  //
  //
  //
  //
  //
  //

  Future<int> deleteSubStaff(TempSubStaff subStaff) async {
    bool isOnline = await connectivity.isOnline();
    try {
      if (isOnline) {
        await supabase
            .from(tableName)
            .delete()
            .eq('uuid', subStaff.uuid!);
        await returnEventsLogProvider().createLog(
          returnEventsLogProvider().subStaffAdapter(
            subStaff,
            3,
          ),
        );

        await getSubStaffs();
        notifyListeners();
        return 1;
      } else {
        var containsCreated =
            CreatedSubStaffFunc()
                .getSubStaffs()
                .where(
                  (exp) =>
                      exp.subStaff.uuid == subStaff.uuid,
                )
                .toList();
        var containsUpdated =
            UpdatedSubStaffFunc()
                .getSubStaffs()
                .where(
                  (exp) =>
                      exp.subStaff.uuid == subStaff.uuid,
                )
                .toList();
        await SubStaffFunc().deleteSubStaff(subStaff.uuid!);

        if (containsCreated.isNotEmpty) {
          CreatedSubStaffFunc().deleteSubStaff(
            subStaff.uuid!,
          );
        } else {
          await DeletedSubStaffFunc().createDeletedSubStaff(
            DeletedSubStaff(subStaffUuid: subStaff.uuid!),
          );
        }
        if (containsUpdated.isNotEmpty) {
          UpdatedSubStaffFunc().deleteUpdatedSubStaff(
            subStaff.uuid!,
          );
        }
        await returnEventsLogProvider().createLog(
          returnEventsLogProvider(
            // ignore: use_build_context_synchronously
          ).subStaffAdapter(subStaff, 3),
          // ignore: use_build_context_synchronously
        );

        await getSubStaffs();
        notifyListeners();
        return 1;
      }
    } catch (e) {
      print('Error Deleting Sub Staff: ${e.toString()}');
      return 0;
    }
  }

  //
  //
  //
  //
  //

  Future<void> createSubStaffSync(
    // BuildContext context,
  ) async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedSubStaffFunc().getSubStaffs().isNotEmpty &&
          isOnline) {
        final subStaffs =
            CreatedSubStaffFunc().getSubStaffs().toList();
        for (var subStaff in subStaffs) {
          print(
            'Updated Time: ${subStaff.subStaff.updatedAt?.toString()}',
          );
        }
        final payload =
            subStaffs
                .map((p) => p.subStaff.toJson())
                .toList();

        // Insert all at once
        final data =
            await supabase
                .from(tableName)
                .insert(payload)
                .select();

        print('${data.length} items added successfully ✅');
        await CreatedSubStaffFunc().clearSubStaffs();
        print('Unsynced Sub Staffs Cleared');
        print('Mounted, refreshing Sub Staffs ✅');
        await getSubStaffs();
      }
    } catch (e) {
      print('Batch Sub Staffs insert failed ❌: $e');
    }
  }

  //
  //
  //
  //
  //

  Future<void> deleteSubStaffSync() async {
    try {
      bool isOnline = await connectivity.isOnline();

      if (DeletedSubStaffFunc()
              .getSubStaffIds()
              .isNotEmpty &&
          isOnline) {
        final uuids =
            DeletedSubStaffFunc()
                .getSubStaffIds()
                .map((p) => p.subStaffUuid)
                .toList();

        final data =
            await supabase
                .from(tableName)
                .delete()
                .inFilter(
                  'uuid',
                  uuids,
                ) // delete where id is in the list
                .select();

        print(
          '${data.length} items deleted successfully ✅',
        );

        await DeletedSubStaffFunc().clearDeletedSubStaff();
        print('Unsynced deleted Sub Staffs cleared');
        print('Mounted, refreshing Sub Staffs ✅');
        await getSubStaffs();
      }
    } catch (e) {
      print('Batch delete failed ❌: $e');
    }
  }

  //
  //
  //

  Future<void> updateSubStaffSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      print(
        UpdatedSubStaffFunc()
            .getSubStaffs()
            .length
            .toString(),
      );

      if (UpdatedSubStaffFunc().getSubStaffs().isNotEmpty &&
          isOnline) {
        final updatedSubStaffs =
            UpdatedSubStaffFunc().getSubStaffs();

        for (final updated in updatedSubStaffs) {
          final localSubStaffs = updated.subStaff;

          localSubStaffs.updatedAt ??=
              DateTime.now().toLocal();

          if (localSubStaffs.uuid == null) {
            print('Local Sub Staffs Uuid is Null');
          }
          final remoteData =
              await supabase
                  .from(tableName)
                  .select('uuid, updated_at')
                  .eq('uuid', localSubStaffs.uuid!)
                  .maybeSingle();

          if (remoteData == null) {
            await supabase
                .from(tableName)
                .insert(localSubStaffs.toJson());
            print(
              'Inserted Sub Staffs with uuid ${localSubStaffs.uuid}',
            );
            await UpdatedSubStaffFunc()
                .deleteUpdatedSubStaff(
                  localSubStaffs.uuid ?? '',
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

            localSubStaffs.updatedAt =
                (localSubStaffs.updatedAt ?? DateTime.now())
                    .toUtc(); // ✅ keep both UTC
            print(
              "Local updatedAt: ${localSubStaffs.updatedAt}",
            );
            print("Remote updatedAt: $remoteUpdatedAt");

            if (remoteUpdatedAt == null ||
                localSubStaffs.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from(tableName)
                  .update(localSubStaffs.toJson())
                  .eq('uuid', localSubStaffs.uuid!);
              print(
                'Updated Sub Staffs with uuid ${localSubStaffs.uuid}',
              );
              await UpdatedSubStaffFunc()
                  .deleteUpdatedSubStaff(
                    localSubStaffs.uuid ?? '',
                  );
            } else {
              print(
                'Skipped Sub Staffs ${localSubStaffs.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedSubStaffFunc().clearUpdatedSubStaff();
        print('Unsynced updated Sub Staffs cleared');
        print('Mounted, refreshing Sub Staffs ✅');
        await getSubStaffs();
      }
    } catch (e) {
      print('Batch update failed ❌: $e');
    }
  }

  //
  //
  //
  //
}
