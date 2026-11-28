import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DepartmentsDashboardProvider extends ChangeNotifier {
  static final DepartmentsDashboardProvider _instance =
      DepartmentsDashboardProvider._internal();
  factory DepartmentsDashboardProvider() => _instance;
  DepartmentsDashboardProvider._internal();

  SupabaseClient get supabase => backend();

  List<TempMainReceipt> allReceipts = [];
  List<TempExpensesClass> allExpenses = [];
  List<TempInvoice> allInvoices = [];
  List<TempCustomersClass> allCustomers = [];
  List<TempProductClass> allItems = [];
  List<TempUserClass> allStaffs = [];

  bool isLoading = false;

  void toggleIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  DateTime? dateSet;
  final Set<String> _fetchedReceiptKeys = {};
  final Set<String> _fetchedExpenseKeys = {};
  final Set<String> _fetchedInvoiceKeys = {};

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month}-${d.day}';

  bool _isRangeFetched(
    Set<String> keys,
    DateTime start,
    DateTime end,
  ) {
    var cursor = DateTime(
      start.year,
      start.month,
      start.day,
    );
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      if (!keys.contains(_dateKey(cursor))) return false;
      cursor = cursor.add(const Duration(days: 1));
    }
    return true;
  }

  void _markRangeFetched(
    Set<String> keys,
    DateTime start,
    DateTime end,
  ) {
    var cursor = DateTime(
      start.year,
      start.month,
      start.day,
    );
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      keys.add(_dateKey(cursor));
      cursor = cursor.add(const Duration(days: 1));
    }
  }

  Future<void> _fetchForSelectedWindow({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        getAllReceipts(
          startDate: startDate,
          endDate: endDate,
        ),
        getAllExpenses(
          startDate: startDate,
          endDate: endDate,
        ),
        getAllInvoices(
          startDate: startDate,
          endDate: endDate,
        ),
      ]);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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
      _fetchForSelectedWindow(
        startDate: date,
        endDate: date,
      );
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
    _fetchForSelectedWindow(
      startDate: rangeStart,
      endDate: endOfrange,
    );
    notifyListeners();
  }

  Future<int> fetchAllData() async {
    isLoading = true;
    notifyListeners();
    try {
      await returnDepartmentProvider().getDepartments();
      await getAllReceipts(forceRefresh: true);
      await getAllExpenses(forceRefresh: true);
      await getAllCustomers();
      await getAllInvoices();
      await getAllItems();
      await getAllStaffs();
      isLoading = false;
      notifyListeners();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Fetching All Records: ${e.toString()}',
      );
      isLoading = false;
      return 0;
    }
  }

  Future<List<TempMainReceipt>> getAllReceipts({
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      final effectiveStart =
          startDate ??
          dateSet ??
          rangeStartDate ??
          resolveBusinessDate(DateTime.now());
      final effectiveEnd =
          endDate ??
          (dateSet ?? rangeEndDate ?? effectiveStart);

      if (!forceRefresh &&
          _isRangeFetched(
            _fetchedReceiptKeys,
            effectiveStart,
            effectiveEnd,
          )) {
        return allReceipts;
      }

      final windowStart = fourAm(effectiveStart);
      final windowEnd = fourAmNextDay(effectiveEnd);

      final deptUuids =
          returnDepartmentProvider().departments
              .map((d) => d.uuid)
              .whereType<String>()
              .toList();
      if (deptUuids.isEmpty) {
        return allReceipts;
      }

      final data = await supabase
          .from('receipts')
          .select()
          .inFilter('department_uuid_new', deptUuids)
          .gte(
            'created_at',
            windowStart.toUtc().toIso8601String(),
          )
          .lt(
            'created_at',
            windowEnd.toUtc().toIso8601String(),
          )
          .order('created_at', ascending: false);

      final fetched =
          data
              .map((dat) => TempMainReceipt.fromJson(dat))
              .toList();
      final fetchedUuids =
          fetched.map((e) => e.uuid).toSet();
      final outsideWindow =
          allReceipts.where((rec) {
            if (fetchedUuids.contains(rec.uuid))
              return false;
            final inWindow =
                !rec.createdAt.isBefore(windowStart) &&
                rec.createdAt.isBefore(windowEnd);
            return !inWindow;
          }).toList();
      allReceipts = [
        ...fetched,
        ...outsideWindow,
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _markRangeFetched(
        _fetchedReceiptKeys,
        effectiveStart,
        effectiveEnd,
      );
      await mainLocalLog(
        "Receipts Gotten: ${allReceipts.length}",
      );
      return allReceipts;
    } catch (e) {
      await mainLocalLog(
        'Error Getting Receipts: ${e.toString()}',
      );
      return [];
    }
  }

  List<TempMainReceipt> returnReceipts({
    DepartmentClass? department,
  }) {
    List<TempMainReceipt> tempRecs =
        department == null
            ? allReceipts
            : allReceipts
                .where(
                  (rec) =>
                      rec.departmentUuidNew ==
                      department.uuid,
                )
                .toList();
    if (rangeStartDate != null) {
      return tempRecs
          .where(
            (recc) =>
                !recc.createdAt.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                recc.createdAt.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ),
          )
          .toList();
    } else {
      return tempRecs
          .where(
            (recc) =>
                !recc.createdAt.isBefore(
                  fourAm(
                    dateSet ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ) &&
                recc.createdAt.isBefore(
                  fourAmNextDay(
                    dateSet ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ),
          )
          .toList();
    }
  }

  Future<List<TempExpensesClass>> getAllExpenses({
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      final effectiveStart =
          startDate ??
          dateSet ??
          rangeStartDate ??
          resolveBusinessDate(DateTime.now());
      final effectiveEnd =
          endDate ??
          (dateSet ?? rangeEndDate ?? effectiveStart);

      if (!forceRefresh &&
          _isRangeFetched(
            _fetchedExpenseKeys,
            effectiveStart,
            effectiveEnd,
          )) {
        return allExpenses;
      }

      final windowStart = fourAm(effectiveStart);
      final windowEnd = fourAmNextDay(effectiveEnd);

      final deptUuids =
          returnDepartmentProvider().departments
              .map((d) => d.uuid)
              .whereType<String>()
              .toList();
      if (deptUuids.isEmpty) {
        return allExpenses;
      }

      final data = await supabase
          .from('expenses')
          .select()
          .inFilter('department_uuid', deptUuids)
          .gte(
            'created_date',
            windowStart.toUtc().toIso8601String(),
          )
          .lt(
            'created_date',
            windowEnd.toUtc().toIso8601String(),
          );

      final fetched =
          data
              .map((dat) => TempExpensesClass.fromJson(dat))
              .toList();
      final fetchedUuids =
          fetched.map((e) => e.uuid).toSet();
      final outsideWindow =
          allExpenses.where((exp) {
            if (fetchedUuids.contains(exp.uuid))
              return false;
            final created = exp.createdDate;
            if (created == null) return true;
            final inWindow =
                !created.isBefore(windowStart) &&
                created.isBefore(windowEnd);
            return !inWindow;
          }).toList();
      allExpenses = [...fetched, ...outsideWindow];
      _markRangeFetched(
        _fetchedExpenseKeys,
        effectiveStart,
        effectiveEnd,
      );
      await mainLocalLog(
        "Expenses Gotten ${allExpenses.length}",
      );
      return allExpenses;
    } catch (e) {
      await mainLocalLog(
        'Error Getting Expenses: ${e.toString()}',
      );
      return [];
    }
  }

  List<TempExpensesClass> returnExpenses({
    DepartmentClass? department,
  }) {
    List<TempExpensesClass> tempExp =
        department == null
            ? allExpenses
            : allExpenses
                .where(
                  (ex) =>
                      ex.departmentUuid == department.uuid,
                )
                .toList();
    if (rangeStartDate != null) {
      return tempExp
          .where(
            (exp) =>
                !exp.createdDate!.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                exp.createdDate!.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ),
          )
          .toList();
    } else {
      return tempExp
          .where(
            (exp) =>
                !exp.createdDate!.isBefore(
                  fourAm(
                    dateSet ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ) &&
                exp.createdDate!.isBefore(
                  fourAmNextDay(
                    dateSet ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ),
          )
          .toList();
    }
  }

  Future<List<TempInvoice>> getAllInvoices({
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      final effectiveStart =
          startDate ??
          dateSet ??
          rangeStartDate ??
          resolveBusinessDate(DateTime.now());
      final effectiveEnd =
          endDate ??
          (dateSet ?? rangeEndDate ?? effectiveStart);

      if (!forceRefresh &&
          _isRangeFetched(
            _fetchedInvoiceKeys,
            effectiveStart,
            effectiveEnd,
          )) {
        return allInvoices;
      }

      final windowStart = fourAm(effectiveStart);
      final windowEnd = fourAmNextDay(effectiveEnd);

      final deptUuids =
          returnDepartmentProvider().departments
              .map((d) => d.uuid)
              .whereType<String>()
              .toList();
      if (deptUuids.isEmpty) {
        return allInvoices;
      }

      final data = await supabase
          .from('invoices')
          .select()
          .inFilter('department_uuid_new', deptUuids)
          .gte(
            'created_at',
            windowStart.toUtc().toIso8601String(),
          )
          .lt(
            'created_at',
            windowEnd.toUtc().toIso8601String(),
          )
          .order('created_at', ascending: false);

      final fetched =
          data
              .map((dat) => TempInvoice.fromJson(dat))
              .toList();
      final fetchedUuids =
          fetched.map((e) => e.uuid).toSet();
      final outsideWindow =
          allInvoices.where((inv) {
            if (fetchedUuids.contains(inv.uuid))
              return false;
            final inWindow =
                !inv.createdAt.isBefore(windowStart) &&
                inv.createdAt.isBefore(windowEnd);
            return !inWindow;
          }).toList();
      allInvoices = [
        ...fetched,
        ...outsideWindow,
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _markRangeFetched(
        _fetchedInvoiceKeys,
        effectiveStart,
        effectiveEnd,
      );
      await mainLocalLog(
        "Invoices Gotten ${allInvoices.length}",
      );
      return allInvoices;
    } catch (e) {
      await mainLocalLog(
        'Error Getting Invoices: ${e.toString()}',
      );
      return [];
    }
  }

  List<TempInvoice> returnInvoices({
    DepartmentClass? department,
  }) {
    List<TempInvoice> tempInv =
        department == null
            ? allInvoices
            : allInvoices
                .where(
                  (inv) =>
                      inv.departmentUuidNew ==
                      department.uuid,
                )
                .toList();
    if (rangeStartDate != null) {
      return tempInv
          .where(
            (inv) =>
                !inv.createdAt.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                inv.createdAt.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ),
          )
          .toList();
    } else {
      return tempInv
          .where(
            (inv) =>
                !inv.createdAt.isBefore(
                  fourAm(
                    dateSet ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ) &&
                inv.createdAt.isBefore(
                  fourAmNextDay(
                    dateSet ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ),
          )
          .toList();
    }
  }

  Future<List<TempCustomersClass>> getAllCustomers() async {
    try {
      List<TempCustomersClass> temp = [];
      for (var department
          in returnDepartmentProvider().departments) {
        final data = await supabase
            .from('customers')
            .select()
            .eq('department_uuid', department.uuid);
        temp.addAll(
          data
              .map(
                (dat) => TempCustomersClass.fromJson(dat),
              )
              .toList(),
        );
      }
      allCustomers = temp;
      await mainLocalLog(
        "Customers Gotten ${allCustomers.length}",
      );
      return allCustomers;
    } catch (e) {
      await mainLocalLog(
        'Error Getting Customers: ${e.toString()}',
      );
      return [];
    }
  }

  List<TempCustomersClass> returnCustomers({
    DepartmentClass? department,
  }) {
    List<TempCustomersClass> tempCustomers =
        department == null
            ? allCustomers
            : allCustomers
                .where(
                  (customer) =>
                      customer.departmentUuid ==
                      department.uuid,
                )
                .toList();
    return tempCustomers;
  }

  Future<List<TempProductClass>> getAllItems() async {
    try {
      List<TempProductClass> temp = [];
      for (var department
          in returnDepartmentProvider().departments) {
        final data = await supabase
            .from('products')
            .select()
            .eq('department_uuid', department.uuid);
        temp.addAll(
          data
              .map((dat) => TempProductClass.fromJson(dat))
              .toList(),
        );
      }
      allItems = temp;
      await mainLocalLog("Items Gotten ${allItems.length}");
      return allItems;
    } catch (e) {
      await mainLocalLog(
        'Error Getting Items: ${e.toString()}',
      );
      return [];
    }
  }

  List<TempProductClass> returnItems({
    DepartmentClass? department,
  }) {
    List<TempProductClass> tempItems =
        department == null
            ? allItems
            : allItems
                .where(
                  (item) =>
                      item.departmentUuid ==
                      department.uuid,
                )
                .toList();
    return tempItems;
  }

  double returnAllItems({DepartmentClass? department}) {
    double temp = 0;
    for (var item in returnItems(department: department)) {
      if (item.getActualQuantity() != null &&
          item.getActualQuantity() != 0) {
        temp += item.getActualQuantity()!;
      }
    }
    return temp;
  }

  double returnAllItemsValeu({
    DepartmentClass? department,
  }) {
    double temp = 0;
    for (var item in returnItems(department: department)) {
      if (item.getActualQuantity() != null &&
          item.getActualQuantity() != 0) {
        temp +=
            (item.getActualQuantity()! *
                (item.getPrimaryPrice().priceValue));
      }
    }
    return temp;
  }

  Future<List<TempUserClass>> getAllStaffs() async {
    try {
      List<TempUserClass> temp = [];
      var employees =
          returnShopProvider().userShop()!.employees!;
      // for (var department
      //     in returnDepartmentProvider().departments) {
      final data = await supabase
          .from('users')
          .select()
          .inFilter('user_id', employees);
      temp.addAll(
        data
            .map<TempUserClass>(
              (json) => TempUserClass.fromJson(json),
            )
            .toList(),
      );
      // }
      allStaffs = temp;
      await mainLocalLog(
        "Staffs Gotten ${allStaffs.length}",
      );
      return allStaffs;
    } catch (e) {
      await mainLocalLog(
        'Error Getting Items: ${e.toString()}',
      );
      return [];
    }
  }

  List<TempUserClass> returnStaffs({
    DepartmentClass? department,
  }) {
    List<TempUserClass> tempStaffs =
        department == null
            ? allStaffs
            : allStaffs
                .where(
                  (staff) =>
                      staff.departmentUuids != null
                          ? staff.departmentUuids!.contains(
                            department.uuid,
                          )
                          : false,
                )
                .toList();
    return tempStaffs;
  }

  double returnTotalRevenue({
    DepartmentClass? departmentClass,
  }) {
    double tempTotal = 0;

    for (var rec in returnReceipts(
      department: departmentClass,
    )) {
      tempTotal += returnReceiptProviderSingle()
          .getTotalMainRevenueReceipt(rec);
    }
    return tempTotal;
  }

  double returnTotalExpenses({
    DepartmentClass? departmentClass,
  }) {
    double tempTotal = 0;

    for (var exp in returnExpenses(
      department: departmentClass,
    )) {
      // Stock purchase payments are purchases, not expenses.
      if (exp.isStockPurchase) continue;
      tempTotal += exp.amount;
    }
    return tempTotal;
  }

  double returnProfit({DepartmentClass? departmentClass}) {
    return (returnTotalRevenue(
          departmentClass: departmentClass,
        ) -
        returnTotalExpenses(
          departmentClass: departmentClass,
        ));
  }
}
