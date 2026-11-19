import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_current_department/temp_current_department.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_departments_class/unsynced/created_departments/created_departments.dart';
import 'package:stockall/classes/temp_departments_class/unsynced/deleted_departments/deleted_departments.dart';
import 'package:stockall/classes/temp_departments_class/unsynced/updated/updated_departments.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/department_current/current_department_func.dart';
import 'package:stockall/local_database/department_func/departments_func.dart';
import 'package:stockall/local_database/department_func/unsync_funcs/created_departments/created_departments_func.dart';
import 'package:stockall/local_database/department_func/unsync_funcs/deleted_department/deleted_departments_func.dart';
import 'package:stockall/local_database/department_func/unsync_funcs/updated_department/updated_department_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DepartmentProvider with ChangeNotifier {
  final ConnectivityProvider connectivity =
      ConnectivityProvider();
  static final DepartmentProvider _instance =
      DepartmentProvider._internal();
  factory DepartmentProvider() => _instance;
  DepartmentProvider._internal();
  final String tableName = 'departments';
  final SupabaseClient supabase = Supabase.instance.client;

  List<DepartmentClass> departments = [];
  DateTime? _lastSyncAt;
  int? _lastSyncShopId;

  /// True only with the `viewAllDepartments` permission. Staff
  /// with no department and no permission are not "view all":
  /// they see only records outside every department
  /// ([isUnassignedStaff]).
  bool canUserViewAllDepartments() {
    return authorization(
      authorized: Authorizations().viewAllDepartments,
    );
  }

  /// Departments are on, the user lacks `viewAllDepartments` and
  /// is assigned to no department.
  bool isUnassignedStaff() {
    if (returnShopProvider().userShop()?.manageDepartments !=
        true) {
      return false;
    }
    if (canUserViewAllDepartments()) return false;
    final userDepts = currentUser().departmentUuids;
    return userDepts == null || userDepts.isEmpty;
  }

  /// Centralized department visibility check for items and records.
  bool matchesCurrentDepartment({
    String? departmentUuid,
    List<String>? departmentUuids,
    bool includeUnassignedWhenDeptSelected = false,
  }) {
    final manageDepartments =
        returnShopProvider().userShop()?.manageDepartments ==
        true;
    if (!manageDepartments) return true;
    return departmentRecordVisible(
      manageDepartments: manageDepartments,
      canViewAll: canUserViewAllDepartments(),
      isUnassignedUser: isUnassignedStaff(),
      currentDeptUuid: currentDepartment()?.uuid,
      departmentUuid: departmentUuid,
      departmentUuids: departmentUuids,
      includeUnassignedWhenDeptSelected:
          includeUnassignedWhenDeptSelected,
    );
  }

  /// The department rule, without providers (testable):
  /// 1. Departments off: visible.
  /// 2. Unassigned user (no department, no permission): only
  ///    records in no department.
  /// 3. No current department: visible to "view all" users only.
  /// 4. Otherwise the record must be in the current department
  ///    ([includeUnassignedWhenDeptSelected] also lets records in
  ///    no department through, e.g. shared products).
  static bool departmentRecordVisible({
    required bool manageDepartments,
    required bool canViewAll,
    required bool isUnassignedUser,
    required String? currentDeptUuid,
    String? departmentUuid,
    List<String>? departmentUuids,
    bool includeUnassignedWhenDeptSelected = false,
  }) {
    if (!manageDepartments) return true;
    final hasMulti =
        departmentUuids != null &&
        departmentUuids.any((d) => d.trim().isNotEmpty);
    final hasSingle =
        departmentUuid != null && departmentUuid.trim().isNotEmpty;
    if (isUnassignedUser) return !hasMulti && !hasSingle;
    if (currentDeptUuid == null) return canViewAll;
    if (hasMulti || hasSingle) {
      return (departmentUuids?.contains(currentDeptUuid) ??
              false) ||
          departmentUuid == currentDeptUuid;
    }
    return includeUnassignedWhenDeptSelected;
  }

  DepartmentClass? currentDepartment() {
    // Staff in no department have no current department (a stale
    // stored one is ignored), so lists and reports agree: they see
    // only records in no department.
    if (isUnassignedStaff()) return null;
    var offlineDepartment =
        CurrentDepartmentFunc().getCurrentDepartment();
    if (canUserViewAllDepartments()) {
      try {
        var depts = departments.where(
          (dept) =>
              dept.uuid ==
              offlineDepartment?.currentDepartmentId,
        );
        return depts.isEmpty ? null : depts.first;
      } catch (e) {
        mainLocalLog(
          'Error With Department First: ${e.toString()}',
        );
        return null;
      }
    } else {
      if (offlineDepartment != null) {
        try {
          var depts = departments.where(
            (dept) =>
                dept.uuid ==
                offlineDepartment.currentDepartmentId,
          );
          if (depts.isNotEmpty) {
            return depts.first;
          }
        } catch (e) {
          mainLocalLog(
            'Error With Department First: ${e.toString()}',
          );
        }
      }
      if (departments.isNotEmpty) {
        try {
          CurrentDepartmentFunc().createCurrentDepartment(
            TempCurrentDepartment(
              currentDepartmentId: departments.first.uuid,
            ),
          );
          return departments.first;
        } catch (e) {
          mainLocalLog(
            'Error With Department Second: ${e.toString()}',
          );
          return null;
        }
      }
      return null;
    }
  }

  Future<void> selectDepartment({
    DepartmentClass? departmentClass,
  }) async {
    try {
      await mainLocalLog('Department Selection Started');
      int res =
          departmentClass != null
              ? await CurrentDepartmentFunc()
                  .createCurrentDepartment(
                    TempCurrentDepartment(
                      currentDepartmentId:
                          departmentClass.uuid,
                    ),
                  )
              : /*await clearDepartments()*/ await CurrentDepartmentFunc()
                  .clearCurrentDepartment();
      if (res == 1) {
        await mainLocalLog(
          'Current Department set: ${CurrentDepartmentFunc().getCurrentDepartment()?.currentDepartmentId}',
        );
        notifyListeners();
      } else {
        await mainLocalLog('Department Selection Failed');
        notifyListeners();
      }
      returnShopProvider().setState();
    } catch (e) {
      await mainLocalLog(
        '❌❌ Select Department Error: ${e.toString()}',
      );
    }
  }

  Future<int> clearDepartments() async {
    departments.clear();
    _lastSyncAt = null;
    _lastSyncShopId = null;
    await mainLocalLog('Departments Cleared');
    notifyListeners();
    return await CurrentDepartmentFunc()
        .clearCurrentDepartment();
  }

  Future<int> createDepartment(
    DepartmentClass department,
  ) async {
    try {
      department.updatedAt = DateTime.now();
      department.createdAt = DateTime.now();
      await DepartmentsFunc().createDepartment(department);
      await CreatedDepartmentsFunc().createDepartment(
        CreatedDepartments(department: department),
      );
      await returnEventsLogProvider().createLog(
        returnEventsLogProvider().departmentAdapter(
          department,
          1,
        ),
      );
      await getDepartmentsOffline();
      notifyListeners();
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Creating Department: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<List<DepartmentClass>> getDepartments({
    bool forceRefresh = false,
  }) async {
    await getDepartmentsOffline();
    bool isOnline = await connectivity.isOnline();
    try {
      if (isOnline && DepartmentsFunc().isSynced()) {
        final currentShopId = shopId();
        if (!forceRefresh &&
            _lastSyncAt != null &&
            _lastSyncShopId == currentShopId &&
            departments.isNotEmpty) {
          final safeSince =
              _lastSyncAt!
                  .subtract(const Duration(seconds: 5))
                  .toUtc();
          final res = await supabase
              .from(tableName)
              .select()
              .eq('shop_id', currentShopId)
              .gt('updated_at', safeSince.toIso8601String())
              .order('updated_at', ascending: true);
          if (res.isNotEmpty) {
            final pendingUuids = {
              ...UpdatedDepartmentFunc()
                  .getDepartments()
                  .map((u) => u.department.uuid),
              ...CreatedDepartmentsFunc()
                  .getDepartment()
                  .map((c) => c.department.uuid),
            };
            final updated =
                (res as List)
                    .map((j) => DepartmentClass.fromJson(j))
                    .where(
                      (d) => !pendingUuids.contains(d.uuid),
                    )
                    .toList();
            for (final item in updated) {
              if (returnShopProvider()
                          .userShop()
                          ?.manageDepartments ==
                      true &&
                  !canUserViewAllDepartments() &&
                  !(currentUser().departmentUuids?.contains(
                        item.uuid,
                      ) ??
                      false)) {
                continue;
              }
              final idx = departments.indexWhere(
                (d) => d.uuid == item.uuid,
              );
              if (idx != -1) {
                departments[idx] = item;
              } else {
                departments.add(item);
              }
            }
            departments.sort(
              (a, b) => a.name.compareTo(b.name),
            );
            await DepartmentsFunc().insertAllDepartment(
              departments,
            );
            notifyListeners();
          }
          _lastSyncAt = DateTime.now().toUtc();
          return departments;
        }

        final res = await supabase
            .from(tableName)
            .select()
            .eq('shop_id', currentShopId);
        await mainLocalLog(
          'Departments Gotten: ${res.length}',
        );

        final allShopDepartments =
            (res as List)
                .map((e) => DepartmentClass.fromJson(e))
                .toList();
        await DepartmentsFunc().insertAllDepartment(
          allShopDepartments,
        );
        departments = List<DepartmentClass>.from(
          allShopDepartments,
        );
        if (returnShopProvider()
                .userShop()
                ?.manageDepartments ==
            true) {
          if (!canUserViewAllDepartments()) {
            departments =
                departments
                    .where(
                      (dept) =>
                          currentUser().departmentUuids
                                  ?.contains(dept.uuid) ??
                              false,
                    )
                    .toList();
          }
        }
        _lastSyncAt = DateTime.now().toUtc();
        _lastSyncShopId = currentShopId;
        notifyListeners();
      } else {
        departments = DepartmentsFunc().getDepartment();
        if (returnShopProvider()
                .userShop()
                ?.manageDepartments ==
            true) {
          if (!canUserViewAllDepartments()) {
            departments =
                departments
                    .where(
                      (dept) =>
                          currentUser().departmentUuids
                                  ?.contains(dept.uuid) ??
                              false,
                    )
                    .toList();
          }
        }
        notifyListeners();
      }

      departments.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      return departments;
    } catch (e) {
      await mainLocalLog(
        'Error Getting Departments: ${e.toString()}',
      );
      return [];
    }
  }

  Future<List<DepartmentClass>>
  getDepartmentsOffline() async {
    try {
      departments = DepartmentsFunc().getDepartment();
      if (returnShopProvider()
              .userShop()
              ?.manageDepartments ==
          true) {
        if (!canUserViewAllDepartments()) {
          departments =
              departments
                  .where(
                    (dept) =>
                        currentUser().departmentUuids
                                ?.contains(dept.uuid) ??
                            false,
                  )
                  .toList();
        }
      }

      departments.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      return departments;
    } catch (e) {
      await mainLocalLog(
        'Error Getting Departments: ${e.toString()}',
      );
      return [];
    }
  }

  Future<int> updateDeparment({
    required DepartmentClass department,
  }) async {
    department.updatedAt = DateTime.now();
    try {
      await DepartmentsFunc().updateDepartment(department);
      var containsCreated =
          CreatedDepartmentsFunc()
              .getDepartment()
              .where(
                (dept) =>
                    dept.department.uuid == department.uuid,
              )
              .toList();
      if (containsCreated.isEmpty) {
        await UpdatedDepartmentFunc()
            .createUpdatedDepartment(
              UpdatedDepartments(department: department),
            );
      } else {
        await CreatedDepartmentsFunc().updateDepartment(
          CreatedDepartments(department: department),
        );
      }
      await returnEventsLogProvider().createLog(
        returnEventsLogProvider().departmentAdapter(
          department,
          2,
        ),
      );
      await getDepartmentsOffline();
      notifyListeners();
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Updating Department: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteDepartment({
    required DepartmentClass department,
  }) async {
    try {
      var containsCreated =
          CreatedDepartmentsFunc()
              .getDepartment()
              .where(
                (dept) =>
                    dept.department.uuid == department.uuid,
              )
              .toList();
      var containsUpdated =
          UpdatedDepartmentFunc()
              .getDepartments()
              .where(
                (dept) =>
                    dept.department.uuid == department.uuid,
              )
              .toList();
      await DepartmentsFunc().deleteDepartment(
        department.uuid,
      );

      if (containsCreated.isNotEmpty) {
        CreatedDepartmentsFunc().deleteDepartment(
          department.uuid,
        );
      } else {
        await DeletedDepartmentsFunc()
            .createDeletedDepartment(
              DeletedDepartments(
                departmentUuid: department.uuid,
                shopId:
                    returnShopProvider()
                        .userShop()!
                        .shopId!,
              ),
            );
      }
      if (containsUpdated.isNotEmpty) {
        UpdatedDepartmentFunc().deleteUpdatedDepartment(
          department.uuid,
        );
      }
      await returnEventsLogProvider().createLog(
        returnEventsLogProvider().departmentAdapter(
          department,
          3,
        ),
      );
      var dept =
          CurrentDepartmentFunc().getCurrentDepartment();
      if (dept?.currentDepartmentId == department.uuid) {
        CurrentDepartmentFunc().clearCurrentDepartment();
      }

      await getDepartmentsOffline();
      notifyListeners();
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Deleting Department: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<void> createDepartmentsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedDepartmentsFunc()
              .getDepartment()
              .isNotEmpty &&
          isOnline) {
        final tempDepartments =
            CreatedDepartmentsFunc()
                .getDepartment()
                .toList();
        for (var dept in tempDepartments) {
          await mainLocalLog(
            'Updated Time: ${dept.department.updatedAt?.toString()}',
          );
        }
        final payload =
            tempDepartments
                .map((p) => p.department.toJson())
                .toList();

        final data = await supabase
            .from(tableName)
            .insert(payload)
            .select('uuid');

        await mainLocalLog(
          '${data.length} items added Successfully ✅',
        );
        await CreatedDepartmentsFunc().clearDepartment();
        await mainLocalLog('Unsynced Departments Cleared');
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Departments insert failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //
  //

  Future<void> deleteDepartmentsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();

      if (DeletedDepartmentsFunc()
              .getDepartmentIds()
              .isNotEmpty &&
          isOnline) {
        final uuids =
            DeletedDepartmentsFunc()
                .getDepartmentIds()
                .map((p) => p.departmentUuid)
                .toList();

        final data = await supabase
            .from(tableName)
            .delete()
            .inFilter(
              'uuid',
              uuids,
            ) // delete where id is in the list
            .select('uuid');

        await mainLocalLog(
          '${data.length} items deleted successfully ✅',
        );

        await DeletedDepartmentsFunc()
            .clearDeletedDepartments();
        await mainLocalLog(
          'Unsynced deleted Departments cleared',
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Departments delete failed ❌: $e',
      );
    }
  }

  //
  //
  //

  Future<void> updateDepartmentsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      await mainLocalLog(
        UpdatedDepartmentFunc()
            .getDepartments()
            .length
            .toString(),
      );

      if (UpdatedDepartmentFunc()
              .getDepartments()
              .isNotEmpty &&
          isOnline) {
        final updatedDepartments =
            UpdatedDepartmentFunc().getDepartments();

        for (final updated in updatedDepartments) {
          final localDepartments = updated.department;

          localDepartments.updatedAt =
              DateTime.now().toLocal();

          final remoteData =
              await supabase
                  .from(tableName)
                  .select('uuid, updated_at')
                  .eq('uuid', localDepartments.uuid)
                  .maybeSingle();

          if (remoteData == null) {
            await supabase
                .from(tableName)
                .insert(localDepartments.toJson());
            await mainLocalLog(
              'Inserted Department with uuid ${localDepartments.uuid}',
            );
            await UpdatedDepartmentFunc()
                .deleteUpdatedDepartment(
                  localDepartments.uuid,
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

            localDepartments.updatedAt =
                (localDepartments.updatedAt ??
                        DateTime.now())
                    .toUtc();
            await mainLocalLog(
              "Local updatedAt: ${localDepartments.updatedAt}",
            );
            await mainLocalLog(
              "Remote updatedAt: $remoteUpdatedAt",
            );

            if (remoteUpdatedAt == null ||
                localDepartments.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from(tableName)
                  .update(localDepartments.toJson())
                  .eq('uuid', localDepartments.uuid);
              await mainLocalLog(
                'Updated Department with uuid ${localDepartments.uuid}',
              );
              await UpdatedDepartmentFunc()
                  .deleteUpdatedDepartment(
                    localDepartments.uuid,
                  );
            } else {
              await mainLocalLog(
                'Skipped Department ${localDepartments.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedDepartmentFunc()
            .clearupdatedDepartments();
        await mainLocalLog(
          'Unsynced updated Departments cleared',
        );
        await mainLocalLog(
          'Mounted, refreshing Departments ✅',
        );
        await getDepartments();
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Departments update failed ❌: $e',
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

  List<DepartmentClass> multipleSelectedDepartments = [];

  void clearMulitpleSelectedDepartments() {
    multipleSelectedDepartments.clear();
    notifyListeners();
  }

  void selectMultipleDepartments(
    DepartmentClass newDepartment,
  ) {
    if (multipleSelectedDepartments.contains(
      newDepartment,
    )) {
      multipleSelectedDepartments.remove(newDepartment);
    } else {
      multipleSelectedDepartments.add(newDepartment);
    }
    notifyListeners();
  }
}
