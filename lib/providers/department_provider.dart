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

  DepartmentClass? currentDepartment() {
    var offlineDepartment =
        CurrentDepartmentFunc().getCurrentDepartment();
    if (authorization(
      authorized: Authorizations().viewAllDepartments,
    )) {
      try {
        var depts = departments.where(
          (dept) =>
              dept.uuid ==
              offlineDepartment?.currentDepartmentId,
        );
        return depts.isEmpty ? null : depts.first;
      } catch (e) {
        print(
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
          return depts.isEmpty ? null : depts.first;
        } catch (e) {
          print(
            'Error With Department First: ${e.toString()}',
          );
          return null;
        }
      } else {
        if (departments.isNotEmpty) {
          try {
            CurrentDepartmentFunc().createCurrentDepartment(
              TempCurrentDepartment(
                currentDepartmentId: departments.first.uuid,
              ),
            );
            var dept =
                departments.isNotEmpty
                    ? departments.first
                    : null;
            return dept;
          } catch (e) {
            print(
              'Error With Department Second: ${e.toString()}',
            );
            return null;
          }
        } else {
          return null;
        }
      }
    }
  }

  Future<void> selectDepartment({
    DepartmentClass? departmentClass,
  }) async {
    try {
      print('Department Selection Started');
      var res =
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
        print(
          'Current Department set: ${CurrentDepartmentFunc().getCurrentDepartment()?.currentDepartmentId}',
        );
        notifyListeners();
      } else {
        print('Department Selection Failed');
        notifyListeners();
      }
      returnShopProvider().setState();
    } catch (e) {
      print('❌❌ Select Department Error: ${e.toString()}');
    }
  }

  Future<int> clearDepartments() async {
    departments.clear();
    print('Departments Cleared');
    notifyListeners();
    return await CurrentDepartmentFunc()
        .clearCurrentDepartment();
  }

  Future<int> createDepartment(
    DepartmentClass department,
  ) async {
    try {
      bool isOnline = await connectivity.isOnline();
      department.updatedAt = DateTime.now();
      if (isOnline) {
        Map<String, dynamic>? res =
            await supabase
                .from(tableName)
                .insert(department.toJson())
                .select()
                .maybeSingle();

        if (res != null) {
          DepartmentClass dept = DepartmentClass.fromJson(
            res,
          );
          await DepartmentsFunc().createDepartment(dept);
          await returnEventsLogProvider().createLog(
            returnEventsLogProvider().departmentAdapter(
              department,
              1,
            ),
          );
        } else {
          print('Error Creating Departments');
        }
      } else {
        department.createdAt = DateTime.now();
        await DepartmentsFunc().createDepartment(
          department,
        );
        await CreatedDepartmentsFunc().createDepartment(
          CreatedDepartments(department: department),
        );
        await returnEventsLogProvider().createLog(
          returnEventsLogProvider().departmentAdapter(
            department,
            1,
          ),
        );
      }
      await getDepartments();
      notifyListeners();
      return 1;
    } catch (e) {
      print('Error Creating Department: ${e.toString()}');
      return 0;
    }
  }

  Future<List<DepartmentClass>> getDepartments() async {
    bool isOnline = await connectivity.isOnline();
    try {
      if (isOnline) {
        final res = await supabase
            .from(tableName)
            .select()
            .eq('shop_id', shopId());
        print('Departments Gotten: ${res.length}');

        departments =
            (res as List)
                .map((e) => DepartmentClass.fromJson(e))
                .toList();
        if (returnShopProvider()
                .userShop()
                ?.manageDepartments ==
            true) {
          if (!authorization(
            authorized: Authorizations().viewAllDepartments,
          )) {
            departments =
                departments.where((dept) {
                  if (currentUser().departmentUuids !=
                      null) {
                    return currentUser().departmentUuids !=
                            null
                        ? currentUser().departmentUuids!
                            .contains(dept.uuid)
                        : false;
                  } else {
                    return false;
                  }
                }).toList();
          }
        }

        await DepartmentsFunc().insertAllDepartment(
          departments,
        );
        notifyListeners();
      } else {
        departments = DepartmentsFunc().getDepartment();
        if (returnShopProvider()
                .userShop()
                ?.manageDepartments ==
            true) {
          if (!authorization(
            authorized: Authorizations().viewAllDepartments,
          )) {
            departments =
                departments
                    .where(
                      (dept) =>
                          currentUser().departmentUuids !=
                                  null
                              ? currentUser()
                                  .departmentUuids!
                                  .contains(dept.uuid)
                              : false,
                    )
                    .toList();
          }
        }
        notifyListeners();
      }

      departments.sort((a, b) => a.name.compareTo(b.name));
      // print('Staffs Departments: ${departments.length}');
      // print(
      //   'Current Department: ${returnDepartmentProvider().currentDepartment()?.name}',
      // );
      notifyListeners();
      return departments;
    } catch (e) {
      print('Error Getting Departments: ${e.toString()}');
      return [];
    }
  }

  Future<int> updateDeparment({
    required DepartmentClass department,
  }) async {
    bool isOnline = await connectivity.isOnline();
    department.updatedAt = DateTime.now();
    try {
      if (isOnline) {
        await supabase
            .from(tableName)
            .update(department.toJson())
            .eq('uuid', department.uuid);
        await returnEventsLogProvider().createLog(
          returnEventsLogProvider().departmentAdapter(
            department,
            2,
          ),
        );
      } else {
        await DepartmentsFunc().updateDepartment(
          department,
        );
        var containsCreated =
            CreatedDepartmentsFunc()
                .getDepartment()
                .where(
                  (dept) =>
                      dept.department.uuid ==
                      department.uuid,
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
      }
      await getDepartments();
      notifyListeners();
      return 1;
    } catch (e) {
      print('Error Updating Department: ${e.toString()}');
      return 0;
    }
  }

  Future<int> deleteDepartment({
    required DepartmentClass department,
  }) async {
    bool isOnline = await connectivity.isOnline();
    try {
      if (isOnline) {
        await supabase
            .from(tableName)
            .delete()
            .eq('uuid', department.uuid);
        await returnEventsLogProvider().createLog(
          returnEventsLogProvider().departmentAdapter(
            department,
            3,
          ),
        );
      } else {
        var containsCreated =
            CreatedDepartmentsFunc()
                .getDepartment()
                .where(
                  (dept) =>
                      dept.department.uuid ==
                      department.uuid,
                )
                .toList();
        var containsUpdated =
            UpdatedDepartmentFunc()
                .getDepartments()
                .where(
                  (dept) =>
                      dept.department.uuid ==
                      department.uuid,
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
      }

      var dept =
          CurrentDepartmentFunc().getCurrentDepartment();
      if (dept?.currentDepartmentId == department.uuid) {
        CurrentDepartmentFunc().clearCurrentDepartment();
      }

      await getDepartments();
      notifyListeners();
      return 1;
    } catch (e) {
      print('Error Deleting Department: ${e.toString()}');
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
          print(
            'Updated Time: ${dept.department.updatedAt?.toString()}',
          );
        }
        final payload =
            tempDepartments
                .map((p) => p.department.toJson())
                .toList();

        final data =
            await supabase
                .from(tableName)
                .insert(payload)
                .select();

        print('${data.length} items added Successfully ✅');
        await CreatedDepartmentsFunc().clearDepartment();
        print('Unsynced Departments Cleared');
      }
    } catch (e) {
      print('Batch Departments insert failed ❌: $e');
    }

    print('Mounted, refreshing Departments ✅');
    await getDepartments();
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

        await DeletedDepartmentsFunc()
            .clearDeletedDepartments();
        print('Unsynced deleted Departments cleared');
      }
    } catch (e) {
      print('Batch Departments delete failed ❌: $e');
    }

    print('Mounted, refreshing Departments ✅');
    await getDepartments();
  }

  //
  //
  //

  Future<void> updateDepartmentsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      print(
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
            print(
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
            print(
              "Local updatedAt: ${localDepartments.updatedAt}",
            );
            print("Remote updatedAt: $remoteUpdatedAt");

            if (remoteUpdatedAt == null ||
                localDepartments.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from(tableName)
                  .update(localDepartments.toJson())
                  .eq('uuid', localDepartments.uuid);
              print(
                'Updated Department with uuid ${localDepartments.uuid}',
              );
              await UpdatedDepartmentFunc()
                  .deleteUpdatedDepartment(
                    localDepartments.uuid,
                  );
            } else {
              print(
                'Skipped Department ${localDepartments.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedDepartmentFunc()
            .clearupdatedDepartments();
        print('Unsynced updated Departments cleared');
      }
    } catch (e) {
      print('Batch Departments update failed ❌: $e');
    }

    print('Mounted, refreshing Departments ✅');
    await getDepartments();
  }

  //
  //
  //
  //
}
