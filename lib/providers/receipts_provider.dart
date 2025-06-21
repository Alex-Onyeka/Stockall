import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_sale_record.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReceiptsProvider extends ChangeNotifier {
  //
  //
  //

  final SupabaseClient supabase = Supabase.instance.client;

  List<TempMainReceipt> _receipts = [];
  List<TempMainReceipt> get receipts => _receipts;

  // CREATE a new receipt
  Future<int> createReceipt(
    TempMainReceipt receipt,
    BuildContext context,
  ) async {
    final res =
        await supabase
            .from('receipts')
            .insert(receipt.toJson())
            .select()
            .single();

    final newReceipt = TempMainReceipt.fromJson(res);

    // _receipts.add(newReceipt);
    if (context.mounted) {
      await loadReceipts(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
        context,
      );
    }

    notifyListeners();
    return newReceipt.id!;
  }

  // READ all receipts for a shop
  Future<List<TempMainReceipt>> loadReceipts(
    int shopId,
    BuildContext context,
  ) async {
    try {
      final data = await supabase
          .from('receipts')
          .select()
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);

      _receipts =
          (data as List)
              .map((json) => TempMainReceipt.fromJson(json))
              .toList();
      if (context.mounted) {
        print('Loaded');
        await returnData(
          context,
          listen: false,
        ).getProducts(
          returnShopProvider(
            context,
            listen: false,
          ).userShop!.shopId!,
        );
        if (context.mounted) {
          await loadProductSalesRecord(
            returnShopProvider(
              context,
              listen: false,
            ).userShop!.shopId!,
          );
        }
      }
      notifyListeners();
      return _receipts;
    } catch (e) {
      return [];
    }
  }

  Future<List<TempMainReceipt>> loadReceiptsByUserId({
    required int shopId,
    required BuildContext context,
    required String userId,
  }) async {
    try {
      final now = DateTime.now();
      final startOfDay =
          DateTime(
            now.year,
            now.month,
            now.day,
          ).toIso8601String();
      final endOfDay =
          DateTime(
            now.year,
            now.month,
            now.day,
            23,
            59,
            59,
          ).toIso8601String();

      final data = await supabase
          .from('receipts')
          .select('*') // select only needed fields
          .eq('shop_id', shopId)
          .eq('staff_id', userId)
          .gte('created_at', startOfDay)
          .lte('created_at', endOfDay)
          .order('created_at', ascending: false);

      if (context.mounted) {
        await loadReceipts(
          returnShopProvider(
            context,
            listen: false,
          ).userShop!.shopId!,
          context,
        );
      }
      notifyListeners();
      return (data as List)
          .map((json) => TempMainReceipt.fromJson(json))
          .toList();
    } catch (e) {
      print("❌ Failed to load today's receipts: $e");
      return [];
    }
  }

  //
  //
  //

  DateTime? singleDay;
  DateTime? weekStartDate;

  bool setDate = false;
  bool isDateSet = false;
  String? dateSet;

  void openDatePicker() {
    setDate = true;
    notifyListeners();
  }

  void setReceiptDay(DateTime day) {
    singleDay = day;
    weekStartDate = null;
    isDateSet = true;
    setDate = false;
    dateSet = 'For ${formatDateTime(day)}';
    notifyListeners();
  }

  void setReceiptWeek(
    DateTime weekStart,
    DateTime endOfWeek,
  ) {
    weekStartDate = weekStart;
    singleDay = null;
    isDateSet = true;
    setDate = false;
    dateSet =
        '${formatDateWithoutYear(weekStart)} - ${formatDateWithoutYear(endOfWeek)}';
    notifyListeners();
  }

  void clearReceiptDate() {
    singleDay = null;
    weekStartDate = null;
    setDate = false;
    isDateSet = false;
    dateSet = null;
    notifyListeners();
  }

  // UPDATE a receipt
  Future<void> updateReceipt(
    TempMainReceipt updated,
  ) async {
    // Use only the updatable fields
    final updateData = {
      'barcode': updated.barcode,
      'payment_method': updated.paymentMethod,
      'cash_alt': updated.cashAlt,
      'bank': updated.bank,
      'customer_id': updated.customerId,
    };

    await supabase
        .from('receipts')
        .update(updateData)
        .eq('id', updated.id!);

    final index = _receipts.indexWhere(
      (r) => r.id == updated.id,
    );
    if (index != -1) {
      _receipts[index] = updated;
      notifyListeners();
    }
  }

  // DELETE a receipt
  Future<void> deleteReceipt(
    int id,
    BuildContext context,
  ) async {
    // final response =
    await supabase.rpc(
      'delete_receipt_and_update_inventory',
      params: {'target_receipt_id': id},
    );

    print('✅ Receipt and inventory successfully updated.');

    if (context.mounted) {
      await loadReceipts(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
        context,
      );
      notifyListeners();
    }
    notifyListeners();
  }

  //
  //
  //
  //
  //

  List<TempProductSaleRecord> _sales = [];
  List<TempProductSaleRecord> get produtRecordSalesMain =>
      _sales;

  // CREATE a new product sale record
  Future<void> createProductSaleRecord(
    List<TempProductSaleRecord> records,
    BuildContext context,
  ) async {
    final dataToInsert =
        records.map((e) => e.toJson()).toList();

    await supabase
        .from('product_sales')
        .insert(dataToInsert);
    if (context.mounted) {
      await returnData(context, listen: false).getProducts(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
      );
      if (context.mounted) {
        await loadProductSalesRecord(
          returnShopProvider(
            context,
            listen: false,
          ).userShop!.shopId!,
        );
      }
    }

    notifyListeners();
  }

  // READ sales for a shop
  Future<List<TempProductSaleRecord>>
  loadProductSalesRecord(int shopId) async {
    final data = await supabase
        .from('product_sales')
        .select()
        .eq('shop_id', shopId)
        .order('created_at', ascending: false);

    _sales =
        (data as List)
            .map(
              (json) =>
                  TempProductSaleRecord.fromJson(json),
            )
            .toList();

    print('Products Records gotten');

    notifyListeners();
    return _sales;
  }

  // UPDATE a sale record
  Future<void> updateProductSaleRecord(
    TempProductSaleRecord record,
    BuildContext context,
  ) async {
    // Use toJson but remove the ID because you don't update the primary key
    final updateData =
        record.toJson()..remove('product_record_id');

    await supabase
        .from('product_sales')
        .update(updateData)
        .eq('product_record_id', record.productRecordId!);

    // final index = _sales.indexWhere(
    //   (r) => r.productRecordId == record.productRecordId,
    // );
    // if (index != -1) {
    //   _sales[index] = record;
    if (context.mounted) {
      await loadProductSalesRecord(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
      );
    }
    notifyListeners();
    // }
  }

  // DELETE a sale record
  Future<void> deleteProductSaleRecord(
    int recordId,
    BuildContext context,
  ) async {
    await supabase
        .from('product_sales')
        .delete()
        .eq('product_record_id', recordId);
    // _sales.removeWhere(
    //   (r) => r.productRecordId == recordId,
    // );
    if (context.mounted) {
      loadProductSalesRecord(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
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

  List<TempProductSaleRecord> productSaleRecords = [
    TempProductSaleRecord(
      customPriceSet: false,
      discount: 10,
      discountedAmount: 3000,
      originalCost: 5000,
      productRecordId: 1,
      createdAt: DateTime(2025, 5, 1, 10, 30),
      productId: 1,
      productName: '',
      shopId: 1,
      staffId: 'staff001',
      customerId: 1,
      staffName: 'Alice Johnson',
      recepitId: 2,
      quantity: 3,
      revenue: 4500.0,
    ),
    TempProductSaleRecord(
      customPriceSet: false,
      discount: 10,
      discountedAmount: 2100,
      originalCost: 4000,
      productRecordId: 2,
      createdAt: DateTime(2025, 5, 3, 14, 15),
      productId: 2,
      productName: '',
      shopId: 1,
      staffId: 'staff002',
      customerId: 1,
      staffName: 'Bob Smith',
      recepitId: 1,
      quantity: 2,
      revenue: 3000.0,
    ),
    TempProductSaleRecord(
      customPriceSet: false,
      discount: 10,
      discountedAmount: 5000,
      originalCost: 2500,
      productRecordId: 3,
      createdAt: DateTime(2025, 5, 5, 9, 0),
      productId: 3,
      productName: '',
      shopId: 2,
      staffId: 'staff003',
      customerId: 2,
      staffName: 'Chinwe Okafor',
      recepitId: 3,
      quantity: 5,
      revenue: 7500.0,
    ),
  ];

  List<TempProductSaleRecord> getOwnProductSalesRecord(
    BuildContext context,
  ) {
    return returnProductSalesRecordsByDate(context)
        .where(
          (record) =>
              record.shopId ==
              returnShopProvider(
                context,
                listen: false,
              ).returnShop(userId()).shopId,
        )
        .toList();
  }

  List<TempProductSaleRecord>
  returnProductSalesRecordsByDate(BuildContext context) {
    final sortedList =
        productSaleRecords.toList()..sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );
    return sortedList;
  }

  List<TempProductSaleRecord> getProductRecordsByReceiptId(
    int receiptId,
    BuildContext context,
  ) {
    return getOwnProductSalesRecord(context)
        .where((product) => product.recepitId == receiptId)
        .toList();
  }

  void createProductSalesRecord(
    BuildContext context,
    int newReceiptId,
    int? customerId,
  ) {
    for (var item
        in returnSalesProvider(
          context,
          listen: false,
        ).cartItems) {
      productSaleRecords.add(
        TempProductSaleRecord(
          customPriceSet: item.item.setCustomPrice,
          productName: '',
          discount: item.discount,
          originalCost: item.totalCost(),
          customerId: customerId,
          discountedAmount: item.discountCost(),
          productRecordId: productSaleRecords.length + 1,
          createdAt: DateTime.now(),
          productId: item.item.id!,
          shopId: item.item.shopId,
          staffId: 'staffId',
          staffName: 'staffName',
          recepitId: newReceiptId,
          quantity: item.quantity,
          revenue: item.revenue(),
        ),
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
  List<TempMainReceipt> mainReceipts = [
    TempMainReceipt(
      id: 1,
      barcode: 'B12345',
      createdAt: DateTime(2025, 5, 5),
      shopId: 1,
      staffId: 's001',
      staffName: 'Alice Johnson',
      customerId: 1,
      bank: 0,
      cashAlt: 20000,
      paymentMethod: 'Cash',
    ),
    TempMainReceipt(
      id: 1,
      barcode: 'B12346',
      createdAt: DateTime(2025, 5, 7),
      shopId: 1,
      staffId: 's002',
      staffName: 'Bob Smith',
      customerId: 1,
      bank: 40000,
      cashAlt: 0,
      paymentMethod: 'Bank',
    ),
    TempMainReceipt(
      id: 1,
      barcode: 'B12347',
      createdAt: DateTime(2025, 5, 6),
      shopId: 1,
      staffId: 's001',
      staffName: 'Alice Johnson',
      customerId: 1,
      bank: 2500,
      cashAlt: 3000,
      paymentMethod: 'Split',
    ),
  ];

  void deleteMainReceipt(int id) {
    mainReceipts.removeWhere((receipt) => receipt.id == id);
    notifyListeners();
  }

  List<TempMainReceipt> returnOwnReceiptsByDayOrWeek(
    BuildContext context,
    List<TempMainReceipt> receipts,
  ) {
    if (weekStartDate != null) {
      final weekStartLocal = weekStartDate!;
      final weekEndLocal = weekStartLocal.add(
        const Duration(days: 7),
      );

      return receipts.where((receipt) {
        final created =
            receipt.createdAt
                .toLocal(); // convert UTC to local
        return !created.isBefore(weekStartLocal) &&
            created.isBefore(weekEndLocal);
      }).toList();
    }

    // Force local date without UTC logic
    final localNow = DateTime.now();
    final localTarget = singleDay?.toLocal() ?? localNow;

    final startOfDay = DateTime(
      localTarget.year,
      localTarget.month,
      localTarget.day,
    );
    final endOfDay = startOfDay.add(
      const Duration(days: 1),
    );

    return receipts.where((receipt) {
      final created =
          receipt.createdAt
              .toLocal(); // ALWAYS convert to local
      final inRange =
          !created.isBefore(startOfDay) &&
          created.isBefore(endOfDay);

      return inRange;
    }).toList();
  }

  List<TempProductSaleRecord>
  returnproductsRecordByDayOrWeek(
    BuildContext context,
    List<TempProductSaleRecord> records,
  ) {
    if (weekStartDate != null) {
      final weekStartLocal = weekStartDate!;
      final weekEndLocal = weekStartLocal.add(
        const Duration(days: 7),
      );

      return records.where((record) {
        final created = record.createdAt.toLocal();
        return !created.isBefore(weekStartLocal) &&
            created.isBefore(weekEndLocal);
      }).toList();
    }

    final localNow = DateTime.now();
    final localTarget = singleDay?.toLocal() ?? localNow;

    final startOfDay = DateTime(
      localTarget.year,
      localTarget.month,
      localTarget.day,
    );
    final endOfDay = startOfDay.add(
      const Duration(days: 1),
    );

    return records.where((record) {
      final created = record.createdAt.toLocal();
      return !created.isBefore(startOfDay) &&
          created.isBefore(endOfDay);
    }).toList();
  }

  double getTotalRevenueForSelectedDay(
    BuildContext context,
    List<TempMainReceipt> receiptss,
    List<TempProductSaleRecord> productSalesRecords,
  ) {
    double tempTotalRevenue = 0;

    for (var receipt in returnOwnReceiptsByDayOrWeek(
      context,
      receiptss,
    )) {
      var productRecords =
          productSalesRecords
              .where(
                (record) => record.recepitId == receipt.id,
              )
              .toList();

      for (var record in productRecords) {
        tempTotalRevenue += record.revenue;
      }
    }

    return tempTotalRevenue;
  }

  double getTotalCostPriceForSelectedDay(
    BuildContext context,
    List<TempMainReceipt> receiptss,
    List<TempProductSaleRecord> productSalesRecords,
  ) {
    double tempTotalCostPrice = 0;

    for (var receipt in returnOwnReceiptsByDayOrWeek(
      context,
      receiptss,
    )) {
      var productRecords =
          productSalesRecords
              .where(
                (record) => record.recepitId == receipt.id,
              )
              .toList();

      for (var record in productRecords) {
        tempTotalCostPrice += record.costPrice ?? 0;
      }
    }

    return tempTotalCostPrice;
  }

  List<TempMainReceipt> returnOwnReceipts(
    BuildContext context,
  ) {
    return mainReceipts
        .where(
          (receipt) =>
              receipt.shopId ==
              returnShopProvider(
                context,
                listen: false,
              ).returnShop(userId()).shopId,
        )
        .toList();
  }

  List<TempMainReceipt> getSortedReceiptsByDate(
    BuildContext context,
  ) {
    final sortedList =
        returnOwnReceipts(context).toList()
          ..sort((a, b) => b.id!.compareTo(a.id!));
    return sortedList;
  }

  int createMainReceipt(TempMainReceipt mainReceipt) {
    final newId = mainReceipts.length + 1;
    mainReceipts.add(
      TempMainReceipt(
        id: newId,
        createdAt: DateTime.now(),
        barcode: mainReceipt.barcode,
        customerId: mainReceipt.customerId,
        shopId: mainReceipt.shopId,
        staffId: mainReceipt.staffId,
        staffName: mainReceipt.staffName,
        bank: mainReceipt.bank,
        cashAlt: mainReceipt.cashAlt,
        paymentMethod: mainReceipt.paymentMethod,
      ),
    );
    notifyListeners();
    return newId;
  }

  double getSubTotalRevenueForReceipt(
    BuildContext context,
    List<TempProductSaleRecord> records,
  ) {
    double tempRev = 0;
    // var temp =
    //     await loadProductSalesRecord(returnShopProvider(context, listen: false).userShop!.shopId!);
    //     var beans=   temp.where(
    //           (bean) => bean.recepitId == mainReceipt.id,
    //         )
    //         .toList();

    for (var bean in records) {
      tempRev += bean.originalCost!;
    }
    return tempRev;
  }

  double getTotalMainRevenueReceipt(
    List<TempProductSaleRecord> records,
    BuildContext context,
  ) {
    double tempTotal = 0;

    for (var productRecord in records) {
      tempTotal += productRecord.revenue;
    }

    return tempTotal;
  }
}
