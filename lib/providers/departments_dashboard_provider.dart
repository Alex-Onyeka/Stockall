import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DepartmentsDashboardProvider extends ChangeNotifier {
  static final DepartmentsDashboardProvider _instance =
      DepartmentsDashboardProvider._internal();
  factory DepartmentsDashboardProvider() => _instance;
  DepartmentsDashboardProvider._internal();

  final SupabaseClient supabase = Supabase.instance.client;

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

  Future<int> fetchAllData() async {
    isLoading = true;
    notifyListeners();
    try {
      await returnDepartmentProvider().getDepartments();
      await getAllReceipts();
      await getAllExpenses();
      await getAllCustomers();
      await getAllInvoices();
      await getAllItems();
      await getAllStaffs();
      isLoading = false;
      notifyListeners();
      return 1;
    } catch (e) {
      print('Error Fetching All Records: ${e.toString()}');
      isLoading = false;
      return 0;
    }
  }

  Future<List<TempMainReceipt>> getAllReceipts() async {
    try {
      List<TempMainReceipt> temp = [];
      for (var department
          in returnDepartmentProvider().departments) {
        final data = await supabase
            .from('receipts')
            .select()
            .eq('department_uuid', department.uuid)
            .order('created_at', ascending: false);
        temp.addAll(
          data
              .map((dat) => TempMainReceipt.fromJson(dat))
              .toList(),
        );
      }
      allReceipts = temp;
      print("Receipts Gotten: ${allReceipts.length}");
      return allReceipts;
    } catch (e) {
      print('Error Getting Receipts: ${e.toString()}');
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
                !recc.createdAt.isBefore(rangeStartDate!) &&
                !recc.createdAt.isAfter(
                  rangeEndDate ?? DateTime.now(),
                ),
          )
          .toList();
    } else {
      return tempRecs
          .where(
            (recc) =>
                (recc.createdAt.day ==
                    (dateSet?.day ?? DateTime.now().day)) &&
                (recc.createdAt.month ==
                    (dateSet?.month ??
                        DateTime.now().month)) &&
                (recc.createdAt.year ==
                    (dateSet?.year ?? DateTime.now().year)),
          )
          .toList();
    }
  }

  Future<List<TempExpensesClass>> getAllExpenses() async {
    try {
      List<TempExpensesClass> temp = [];
      for (var department
          in returnDepartmentProvider().departments) {
        final data = await supabase
            .from('expenses')
            .select()
            .eq('department_uuid', department.uuid);
        temp.addAll(
          data
              .map((dat) => TempExpensesClass.fromJson(dat))
              .toList(),
        );
      }
      allExpenses = temp;
      print("Expenses Gotten ${allExpenses.length}");
      return allExpenses;
    } catch (e) {
      print('Error Getting Expenses: ${e.toString()}');
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
                  rangeStartDate!,
                ) &&
                !exp.createdDate!.isAfter(
                  rangeEndDate ?? DateTime.now(),
                ),
          )
          .toList();
    } else {
      return tempExp
          .where(
            (exp) =>
                (exp.createdDate!.day ==
                    (dateSet?.day ?? DateTime.now().day)) &&
                (exp.createdDate!.month ==
                    (dateSet?.month ??
                        DateTime.now().month)) &&
                (exp.createdDate!.year ==
                    (dateSet?.year ?? DateTime.now().year)),
          )
          .toList();
    }
  }

  Future<List<TempInvoice>> getAllInvoices() async {
    try {
      List<TempInvoice> temp = [];
      for (var department
          in returnDepartmentProvider().departments) {
        final data = await supabase
            .from('invoices')
            .select()
            .eq('department_uuid', department.uuid)
            .order('created_at', ascending: false);
        temp.addAll(
          data
              .map((dat) => TempInvoice.fromJson(dat))
              .toList(),
        );
      }
      allInvoices = temp;
      print("Invoices Gotten ${allInvoices.length}");
      return allInvoices;
    } catch (e) {
      print('Error Getting Invoices: ${e.toString()}');
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
                !inv.createdAt.isBefore(rangeStartDate!) &&
                !inv.createdAt.isAfter(
                  rangeEndDate ?? DateTime.now(),
                ),
          )
          .toList();
    } else {
      return tempInv
          .where(
            (inv) =>
                (inv.createdAt.day ==
                    (dateSet?.day ?? DateTime.now().day)) &&
                (inv.createdAt.month ==
                    (dateSet?.month ??
                        DateTime.now().month)) &&
                (inv.createdAt.year ==
                    (dateSet?.year ?? DateTime.now().year)),
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
      print("Customers Gotten ${allCustomers.length}");
      return allCustomers;
    } catch (e) {
      print('Error Getting Customers: ${e.toString()}');
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
      print("Items Gotten ${allItems.length}");
      return allItems;
    } catch (e) {
      print('Error Getting Items: ${e.toString()}');
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
      if (item.quantity != null && item.quantity != 0) {
        temp += item.quantity!;
      }
    }
    return temp;
  }

  double returnAllItemsValeu({
    DepartmentClass? department,
  }) {
    double temp = 0;
    for (var item in returnItems(department: department)) {
      if (item.quantity != null && item.quantity != 0) {
        temp += (item.quantity! * (item.sellingPrice ?? 0));
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
      print("Staffs Gotten ${allStaffs.length}");
      return allStaffs;
    } catch (e) {
      print('Error Getting Items: ${e.toString()}');
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
                  (staff) => staff.departmentUuids!
                      .contains(department.uuid),
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
