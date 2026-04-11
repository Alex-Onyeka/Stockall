import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopDashboardProvider extends ChangeNotifier {
  static final ShopDashboardProvider _instance =
      ShopDashboardProvider._internal();
  factory ShopDashboardProvider() => _instance;
  ShopDashboardProvider._internal();

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
      await returnShopProvider().getUserShops();
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
      for (var shop in returnShopProvider().userShops) {
        final data = await supabase
            .from('receipts')
            .select()
            .eq('shop_id', shop.shopId!)
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
    TempShopClass? shop,
  }) {
    List<TempMainReceipt> tempRecs =
        shop == null
            ? allReceipts
            : allReceipts
                .where((rec) => rec.shopId == shop.shopId)
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

  Future<List<TempExpensesClass>> getAllExpenses() async {
    try {
      List<TempExpensesClass> temp = [];
      for (var shop in returnShopProvider().userShops) {
        final data = await supabase
            .from('expenses')
            .select()
            .eq('shop_id', shop.shopId!);
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
    TempShopClass? shop,
  }) {
    List<TempExpensesClass> tempExp =
        shop == null
            ? allExpenses
            : allExpenses
                .where((ex) => ex.shopId == shop.shopId)
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

  Future<List<TempInvoice>> getAllInvoices() async {
    try {
      List<TempInvoice> temp = [];
      for (var shop in returnShopProvider().userShops) {
        final data = await supabase
            .from('invoices')
            .select()
            .eq('shop_id', shop.shopId!)
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

  List<TempInvoice> returnInvoices({TempShopClass? shop}) {
    List<TempInvoice> tempInv =
        shop == null
            ? allInvoices
            : allInvoices
                .where((inv) => inv.shopId == shop.shopId)
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
      for (var shop in returnShopProvider().userShops) {
        final data = await supabase
            .from('customers')
            .select()
            .eq('shop_id', shop.shopId!);
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
    TempShopClass? shop,
  }) {
    List<TempCustomersClass> tempCustomers =
        shop == null
            ? allCustomers
            : allCustomers
                .where(
                  (customer) =>
                      shop.shopId == customer.shopId,
                )
                .toList();
    return tempCustomers;
  }

  Future<List<TempProductClass>> getAllItems() async {
    try {
      List<TempProductClass> temp = [];
      for (var shop in returnShopProvider().userShops) {
        final data = await supabase
            .from('products')
            .select()
            .eq('shop_id', shop.shopId!);
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
    TempShopClass? shop,
  }) {
    List<TempProductClass> tempItems =
        shop == null
            ? allItems
            : allItems
                .where((item) => item.shopId == shop.shopId)
                .toList();
    return tempItems;
  }

  double returnAllItems({TempShopClass? shop}) {
    double temp = 0;
    for (var item in returnItems(shop: shop)) {
      if (item.quantity != null && item.quantity != 0) {
        temp += item.quantity!;
      }
    }
    return temp;
  }

  double returnAllItemsValeu({TempShopClass? shop}) {
    double temp = 0;
    for (var item in returnItems(shop: shop)) {
      if (item.quantity != null && item.quantity != 0) {
        temp += (item.quantity! * (item.sellingPrice ?? 0));
      }
    }
    return temp;
  }

  Future<List<TempUserClass>> getAllStaffs() async {
    try {
      List<TempUserClass> temp = [];
      for (var shop in returnShopProvider().userShops) {
        final data = await supabase
            .from('users')
            .select()
            .inFilter('user_id', (shop.employees ?? []));
        // print('Users Gotten from Supabase: ${data.length}');

        temp.addAll(
          data
              .map<TempUserClass>(
                (json) => TempUserClass.fromJson(json),
              )
              .toList(),
        );
      }
      allStaffs = temp;
      print("Staffs Gotten ${allStaffs.length}");
      return allStaffs;
    } catch (e) {
      print('Error Getting Items: ${e.toString()}');
      return [];
    }
  }

  List<TempUserClass> returnStaffs({TempShopClass? shop}) {
    List<TempUserClass> tempStaffs =
        shop == null
            ? allStaffs
            : allStaffs
                .where(
                  (staff) => shop.employees!.contains(
                    staff.userId,
                  ),
                )
                .toList();
    return tempStaffs;
  }

  double returnTotalRevenue({TempShopClass? shop}) {
    double tempTotal = 0;

    for (var rec in returnReceipts(shop: shop)) {
      tempTotal += returnReceiptProviderSingle()
          .getTotalMainRevenueReceipt(rec);
    }
    return tempTotal;
  }

  double returnTotalExpenses({TempShopClass? shop}) {
    double tempTotal = 0;

    for (var exp in returnExpenses(shop: shop)) {
      tempTotal += exp.amount;
    }
    return tempTotal;
  }

  double returnProfit({TempShopClass? shop}) {
    return (returnTotalRevenue(shop: shop) -
        returnTotalExpenses(shop: shop));
  }
}
