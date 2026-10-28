import 'package:flutter/material.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_invoices/unsynced/created_invoices/created_invoices.dart';
import 'package:stockall/classes/temp_invoices/unsynced/deleted_invoices/deleted_invoices.dart';
import 'package:stockall/classes/temp_invoices/unsynced/updated/updated_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/local_database/invoices/invoices_func.dart';
import 'package:stockall/local_database/invoices/unsync_funcs/created/created_invoices_func.dart';
import 'package:stockall/local_database/invoices/unsync_funcs/deleted/deleted_invoices_func.dart';
import 'package:stockall/local_database/invoices/unsync_funcs/updated/updated_invoices_func.dart';
import 'package:stockall/local_database/product_record_func.dart/product_record_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/alt_display/alt_display.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InvoicesProvider extends ChangeNotifier {
  static final InvoicesProvider _instance =
      InvoicesProvider._internal();
  factory InvoicesProvider() => _instance;
  InvoicesProvider._internal();
  bool isLoading = false;
  void toggleIsLoading(bool value) {
    isLoading = value;
    mainLocalLog(
      'Invoice is ${value ? 'Loading on' : 'Loading Off'}',
    );
    notifyListeners();
  }
  //
  //
  //

  SupabaseClient get supabase => Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();
  List<TempInvoice> _invoices = [];
  List<TempInvoice> get invoicesMain => _invoices;

  void clearinvoices() {
    _invoices.clear();
    // clearRecords();
    mainLocalLog('Invoices Cleared');
    notifyListeners();
  }

  bool isLoaded = false;
  void load(bool value) {
    isLoaded = value;
    mainLocalLog(
      value == true
          ? 'Invoices Loaded is now true'
          : 'Invoices Loaded is now false',
    );
    notifyListeners();
  }

  // CREATE a new Invoice
  Future<TempInvoice?> createInvoices(
    TempInvoice invoice,
  ) async {
    await mainLocalLog('Inner Invoice Creation Started');
    var barcode = returnOnlyDigits(uuidGen());
    invoice.barcode = barcode;
    await InvoicesFunc().createInvoices(invoice);
    await CreatedInvoicesFunc().createInvoice(
      CreatedInvoices(invoice: invoice),
    );
    notifyListeners();
    return invoice;
  }

  Future<void> loadSingleInvoice({
    required String uuid,
  }) async {
    bool isOnline = await connectivity.isOnline();
    try {
      if (isOnline) {
        final data =
            await supabase
                .from('invoices')
                .select()
                .eq('invoice_uuid', uuid)
                .maybeSingle();
        if (data == null) {
          await mainLocalLog('Invoice Not Found');
          return;
        } else {
          TempInvoice tempInvoice = TempInvoice.fromJson(
            data,
          );
          TempInvoice? existingInvoice =
              invoicesMain
                      .where(
                        (rec) =>
                            rec.uuid == tempInvoice.uuid,
                      )
                      .isNotEmpty
                  ? invoicesMain
                      .where(
                        (rec) =>
                            rec.uuid == tempInvoice.uuid,
                      )
                      .first
                  : null;
          if (existingInvoice != null) {
            await mainLocalLog('Invoice Exists');
            invoicesMain.remove(existingInvoice);
          }
          invoicesMain.add(tempInvoice);
          invoicesMain.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          );
          await mainLocalLog(
            "💖💖👏🥰 Single Invoice Loaded",
          );
          notifyListeners();
        }
      }
    } catch (e) {
      await mainLocalLog(
        'Error Fetching Single Invoice: ${e.toString()}',
      );
    }
  }

  // READ all Invoices for a shop
  Future<List<TempInvoice>> loadInvoices(int shopId) async {
    await loadInvoicesOffline(shopId);
    bool isOnline = await connectivity.isOnline();
    if (isOnline && InvoicesFunc().isSynced()) {
      try {
        final data = await supabase
            .from('invoices')
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false);
        if (data.isNotEmpty) {
          await mainLocalLog(
            'Invoices Gotten ${data.length}',
          );
        }

        final deletedUuids =
            DeletedInvoicesFunc()
                .getInvoiceIds()
                .map((e) => e.invoiceUuid)
                .toSet();

        _invoices =
            (data as List)
                .map((json) => TempInvoice.fromJson(json))
                .where(
                  (inv) =>
                      inv.uuid != null &&
                      !deletedUuids.contains(inv.uuid),
                )
                .toList();
        await InvoicesFunc().clearInvoices();
        await InvoicesFunc().insertAllInvoices(_invoices);
        notifyListeners();
        await mainLocalLog('Invoices Loaded');
      } catch (e) {
        await mainLocalLog(
          '❌❌Error Getting Invoices: ${e.toString()}',
        );
        return [];
      }
    } else {
      _invoices = InvoicesFunc().getInvoices();
      notifyListeners();
      await mainLocalLog('Offline Invoices Gotten');
    }
    notifyListeners();
    return _invoices;
  }

  Future<List<TempInvoice>> loadInvoicesOffline(
    int shopId,
  ) async {
    _invoices = InvoicesFunc().getInvoices();
    notifyListeners();
    await mainLocalLog('Offline Invoices Gotten');
    notifyListeners();
    return _invoices;
  }

  Future<int> updateInvoice({
    required TempInvoice invoice,
    // required List<TempProductSaleRecord> records,
  }) async {
    invoice.updatedAt = DateTime.now();
    try {
      await InvoicesFunc().updateInvoice(invoice);
      var containsCreated =
          CreatedInvoicesFunc()
              .getInvoices()
              .where(
                (exp) => exp.invoice.uuid == invoice.uuid,
              )
              .toList();
      if (containsCreated.isEmpty) {
        await UpdatedInvoicesFunc().createUpdatedInvoice(
          UpdatedInvoices(updatedInvoice: invoice),
        );
      } else {
        await CreatedInvoicesFunc().createInvoice(
          CreatedInvoices(invoice: invoice),
        );
      }
      // await returnEventsLogProvider().createLog(
      //   returnEventsLogProvider().invoiceAdapter(
      //     invoice,
      //     records.map((rec) => rec.productName).toList(),
      //     2,
      //   ),
      // );
      notifyListeners();
      await loadInvoicesOffline(shopId());
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Updating Invoices: ${e.toString()}',
      );
      notifyListeners();
      return 0;
    }
  }

  Future<int> deleteInvoice(
    TempInvoice invoice,
    List<String> productNames,
  ) async {
    return await deleteInvoiceAndUpdateInventory(
      invoice,
      productNames,
    );
  }

  Future<int> deleteInvoiceAndUpdateInventory(
    TempInvoice invoice,
    List<String> productNames,
  ) async {
    try {
      await mainLocalLog('Deleting Invoices Offline');
      await InvoicesFunc().deleteInvoices(invoice.uuid!);
      var containsCreated =
          CreatedInvoicesFunc()
              .getInvoices()
              .where(
                (rec) => rec.invoice.uuid == invoice.uuid,
              )
              .toList();
      var containsUpdate = UpdatedInvoicesFunc()
          .getInvoiceIds()
          .where(
            (rec) =>
                rec.updatedInvoice.uuid == invoice.uuid!,
          );
      if (containsCreated.isNotEmpty) {
        await CreatedInvoicesFunc().deleteInvoice(
          invoice.uuid!,
        );
      } else {
        await DeletedInvoicesFunc().createDeletedInvoice(
          DeletedInvoices(invoiceUuid: invoice.uuid!),
        );
      }
      if (containsUpdate.isNotEmpty) {
        await UpdatedInvoicesFunc().deleteUpdatedInvoice(
          invoice.uuid!,
        );
      }
      await ProductRecordFunc().deleteRecordsInInvoice(
        invoice: invoice,
      );
      final associatedReceipts =
          returnReceiptProviderSingle().receipts
              .where(
                (rec) => rec.invoiceUuid == invoice.uuid,
              )
              .toList();
      for (final r in associatedReceipts) {
        await returnReceiptProviderSingle().deleteReceipt(
          r,
          [],
        );
      }
      if (productNames.isNotEmpty) {
        await returnEventsLogProvider().createLog(
          returnEventsLogProvider().invoiceAdapter(
            invoice,
            productNames,
            3,
          ),
        );
      }

      await mainLocalLog(
        '✅ Invoice and inventory successfully Delete and Updated.',
      );

      await loadInvoicesOffline(
        returnShopProvider().userShop()!.shopId!,
      );

      await mainLocalLog(
        'Totally Finished Deleting Invoices',
      );
      notifyListeners();
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Deleting Invoice: ${e.toString()}',
      );
      return 0;
    }
  }

  // DELETE an Invoice Without Updating Inventory
  Future<int> deleteInvoiceWithoutUpdatingInventory({
    required TempInvoice invoice,
  }) async {
    try {
      await mainLocalLog('Deleting Invoice Offline');
      await InvoicesFunc().deleteInvoices(
        invoice.uuid ?? '',
      );
      var containsCreated =
          CreatedInvoicesFunc()
              .getInvoices()
              .where(
                (inv) => inv.invoice.uuid == invoice.uuid,
              )
              .toList();
      var containsUpdate = UpdatedInvoicesFunc()
          .getInvoiceIds()
          .where(
            (inv) =>
                inv.updatedInvoice.uuid == invoice.uuid,
          );
      if (containsCreated.isNotEmpty) {
        await CreatedInvoicesFunc().deleteInvoice(
          invoice.uuid ?? '',
        );
      } else {
        await DeletedInvoicesFunc().createDeletedInvoice(
          DeletedInvoices(invoiceUuid: invoice.uuid ?? ''),
        );
      }
      if (containsUpdate.isNotEmpty) {
        await UpdatedInvoicesFunc().deleteUpdatedInvoice(
          invoice.uuid ?? '',
        );
      }
      await ProductRecordFunc()
          .deleteRecordsInInvoiceWithoutUpdatingInventory(
            invoice: invoice,
          );
      // }

      await mainLocalLog(
        '✅ Invoice and inventory successfully Delete and Updated.',
      );

      await loadInvoicesOffline(
        returnShopProvider().userShop()!.shopId!,
      );

      await mainLocalLog(
        'Totally Finished Deleting Invoice',
      );
      notifyListeners();
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Deleting Invoice without Updating Inventory: ${e.toString()}',
      );
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

  String? comment;

  void setComment({required String? newComment}) {
    comment = newComment;
    notifyListeners();
  }

  int paymentOption = 1;

  void changePaymentOptions(int index) {
    paymentOption = index;
    notifyListeners();
  }

  bool isBalanceSufficient(
    String customerUuid,
    double enteredValue,
  ) {
    List<TempCustomersClass> customers =
        returnCustomersSingle().customers
            .where((item) => item.uuid == customerUuid)
            .toList();
    if (customers.isNotEmpty) {
      var customer = customers.first;
      return customer.getBalance() >= enteredValue;
    } else {
      return false;
    }
  }

  Future<int> payAllCustomersBalance({
    required List<TempInvoice> invoices,
    required double cashAmount,
    required double bankAmount,
    required double customerAmount,
  }) async {
    try {
      for (var item in invoices) {
        // List<TempProductSaleRecord> salesRecords =
        //     returnReceiptProviderSingle()
        //         .produtRecordSalesMain
        //         .where(
        //           (item) => item.invoiceUuid == item.uuid,
        //         )
        //         .toList();
        await makeInvoicePayment(
          invoice: item,
          salesRecords: item.getItems(),
          currentPayment: item.getBalance(),
          cashAmount:
              cashAmount != 0 ? item.getBalance() : 0,
          bankAmount:
              bankAmount != 0 ? item.getBalance() : 0,
          customerAmount:
              customerAmount != 0 ? item.getBalance() : 0,
          isMultiple: true,
        );
      }
      syncData();
      await mainLocalLog(
        'Finished Paying all Customers Invoices Success',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Paying all Customers Invoices: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> makeInvoicePayment({
    required TempInvoice invoice,
    required List<TempProductSaleRecord> salesRecords,
    required double currentPayment,
    required double cashAmount,
    required double bankAmount,
    required double customerAmount,
    String? comment,
    bool? isMultiple,
    DateTime? paymentDate,
    String? paymentMethod,
  }) async {
    try {
      final createdAt =
          paymentDate ?? DateTime.now().toUtc();
      final effectivePaymentMethod =
          paymentMethod ??
          PaymentBreakdown.fromAmounts(
            bank: bankAmount,
            cash: cashAmount,
            account: customerAmount,
          ).label;

      TempMainReceipt receipt = TempMainReceipt(
        tempItems: null,
        orderUuid: null,
        salesTypeIndex: 2,
        comment: comment,
        subStaffName: invoice.subStaffName,
        createdAt: createdAt,
        shopId: invoice.shopId,
        staffId: AuthService().currentUser!,
        staffName:
            "${returnUserProviderSingle().currentUserMain!.name} ${returnUserProviderSingle().currentUserMain!.lastName}",
        paymentMethod: effectivePaymentMethod,
        bank: bankAmount,
        customerAccount: customerAmount,
        cashAlt: cashAmount,
        isInvoice: true,
        customerName: invoice.customerName,
        customerUuid: invoice.customerUuid,
        departmentName: invoice.departmentName,
        departmentUuidNew: invoice.departmentUuidNew,
        invoiceUuid: invoice.uuid,
        uuid: uuidGen(),
        generalDiscount: invoice.generalDiscount,
        fixedDiscount: invoice.fixedDiscount,
        vat: invoice.vat,
        originalCost: invoice.originalCost,
        balance: invoice.getBalance() - currentPayment,
        subStaffUuid: invoice.subStaffUuid,
        cartName: invoice.cartName,
      );

      // Built before the receipt is saved so the same lines are
      // stored in receipt.items and in product_sales.
      final productSaleRecords =
          salesRecords.map((record) {
            mainLocalLog(
              'Sales Record about to be Created',
            );
            return TempProductSaleRecord(
              isPercentageWastage:
                  record.isPercentageWastage,
              wastageAmount: record.wastageAmount,
              wastageUnitUuid: record.wastageUnitUuid,
              manageSalesWastage: record.manageSalesWastage,
              heightDimension: record.heightDimension,
              quantityType: record.quantityType,
              widthDimension: record.widthDimension,
              dimensionUnit: record.dimensionUnit,
              dimensionUnitConversion:
                  record.dimensionUnitConversion,
              priceUuid: record.priceUuid,
              pricesList: record.getPriceListFinal(),
              unitUuid: record.unitUuid,
              unitsList: record.getUnitListFinal(),
              isVoid: record.isVoid ?? false,
              customPriceSet: record.customPriceSet,
              createdAt: createdAt,
              productId: record.productId,
              productUuid: record.productUuid,
              productName: record.productName,
              shopId: invoice.shopId,
              staffId: AuthService().currentUser!,
              staffName:
                  "${returnUserProviderSingle().currentUserMain!.name} ${returnUserProviderSingle().currentUserMain!.lastName}",
              // customerId: customerId,
              customerUuid: invoice.customerUuid,
              customerName: invoice.customerName,
              recepitId: 0,
              receiptUuid: receipt.uuid,
              quantity: record.quantity,
              revenue: calcSalesRecordRevenue(
                invoceTotalAmount:
                    invoice.getTotalMainRevenueInvoice(),
                receiptPayment: currentPayment,
                salesRecodRevenue: record.revenue,
              ),
              costPrice: calcSalesRecordCostPrice(
                invoceTotalAmount:
                    invoice.getTotalMainRevenueInvoice(),
                receiptPayment: currentPayment,
                salesRecodCostPrice:
                    (record.costPrice ?? 0),
              ),
              discountedAmount:
                  calcSalesRecordDiscountedAmount(
                    invoceTotalAmount:
                        invoice
                            .getTotalMainRevenueInvoice(),
                    receiptPayment: currentPayment,
                    salesRecodDiscountedAmount:
                        (record.discountedAmount ?? 0),
                  ),
              originalCost: calcSalesRecordOriginalCost(
                invoceTotalAmount:
                    invoice.getTotalMainRevenueInvoice(),
                receiptPayment: currentPayment,
                salesRecodOriginalCost:
                    (record.originalCost ?? 0),
              ),
              discount: record.discount,
              fixedDiscount: record.fixedDiscount,

              addToStock: record.addToStock,
              departmentName:
                  record.departmentName ??
                  returnDepartmentProvider()
                      .currentDepartment()
                      ?.name,
              departmentUuid:
                  record.departmentUuid ??
                  returnDepartmentProvider()
                      .currentDepartment()
                      ?.uuid,
              uuid: uuidGen(),
              isProductManaged: record.isProductManaged,
              setTotalPrice: record.setTotalPrice,
              unit: record.unit,
              useWholeSalePrice: record.useWholeSalePrice,
              useGroupQuantity: record.useGroupQuantity,
              qttyPerGroup: record.qttyPerGroup,
              // invoiceUuid: invoice.uuid,
            );
          }).toList();
      receipt.items = productSaleRecords;

      await mainLocalLog('Checkout Started');
      var res = await returnReceiptProviderSingle()
          .createReceipt(receipt);
      if (res != null) {
        await mainLocalLog('Receipt Created');

        await returnEventsLogProvider().createLog(
          returnEventsLogProvider().receiptAdapter(
            receipt,
            salesRecords
                .map((rec) => rec.productName)
                .toList(),
            1,
          ),
        );

        await mainLocalLog(
          'Creating Record Sales About to Start',
        );
        // await returnReceiptProviderSingle()
        //     .createProductSaleRecord(
        //       records: productSaleRecords,
        //       isPartPayment: true,
        //     );
        await mainLocalLog('Sales Record Inserted');
        // invoice.balance =
        //    invoice.getBalance() - currentPayment;
        // invoice.status =
        await updateInvoice(
          invoice: invoice,
          // records: productSaleRecords,
        );
        await returnReceiptProviderSingle()
            .loadReceiptsOffline(shopId());
        if (isMultiple != true) {
          returnData().syncData();
        }
        await mainLocalLog(
          'Context is Not Mounted So Offline Data Cannot Be Synchronized',
        );
        notifyListeners();
        return 1;
      } else {
        await mainLocalLog(
          'Failed to Create Receipt From Invoice',
        );
        return 0;
      }
    } catch (e) {
      await mainLocalLog(
        'Error Creating Receipt From Invoice: ${e.toString()}',
      );
      return 0;
    }
  }

  double calcSalesRecordRevenue({
    required double invoceTotalAmount,
    required double receiptPayment,
    required double salesRecodRevenue,
  }) {
    if (invoceTotalAmount <= 0) return 0.0;
    double paymentPercent =
        ((receiptPayment * 100) / invoceTotalAmount);
    double result =
        ((paymentPercent * salesRecodRevenue) / 100);
    return result;
  }

  double calcSalesRecordCostPrice({
    required double invoceTotalAmount,
    required double receiptPayment,
    required double salesRecodCostPrice,
  }) {
    if (invoceTotalAmount <= 0) return 0.0;
    double paymentPercent =
        ((receiptPayment * 100) / invoceTotalAmount);
    double result =
        ((paymentPercent * salesRecodCostPrice) / 100);
    return result;
  }

  double calcSalesRecordDiscountedAmount({
    required double invoceTotalAmount,
    required double receiptPayment,
    required double salesRecodDiscountedAmount,
  }) {
    if (invoceTotalAmount <= 0) return 0.0;
    double paymentPercent =
        ((receiptPayment * 100) / invoceTotalAmount);
    double result =
        ((paymentPercent * salesRecodDiscountedAmount) /
            100);
    return result;
  }

  double calcSalesRecordOriginalCost({
    required double invoceTotalAmount,
    required double receiptPayment,
    required double salesRecodOriginalCost,
  }) {
    if (invoceTotalAmount <= 0) return 0.0;
    double paymentPercent =
        ((receiptPayment * 100) / invoceTotalAmount);
    double result =
        ((paymentPercent * salesRecodOriginalCost) / 100);
    return result;
  }

  Future<void> onEditInvoice({
    required TempInvoice invoice,
    required BuildContext context,
  }) async {
    SalesAuthAction().editReceiptAction(
      context: context,
      action: () async {
        // final saleRecords =
        //     returnReceiptProvider(context, listen: false)
        //         .produtRecordSalesMain
        //         .where((r) => r.invoiceUuid == invoice.uuid)
        //         .toList();

        // Convert them back to cart items
        final cartItems = convertInvoiceToCartItems(
          invoice: invoice,
          saleRecords: invoice.getItemsNoVoid() ?? [],
          context: context,
        );

        final tempCartItems = convertInvoiceToCartItems(
          invoice: invoice,
          saleRecords: invoice.getItemsNoVoid() ?? [],
          context: context,
        );

        if (returnSalesProvider()
            .currentMainCart()
            .cartQueue
            .where(
              (cart) =>
                  cart.invoiceUuidEdit != null &&
                  cart.invoiceUuidEdit == invoice.uuid,
            )
            .isEmpty) {
          var newId = uuidGen();
          var tempCart = TempCart(
            tempCartItems: tempCartItems,
            comment: invoice.comment,
            timeOfDay: null,
            hasPrintedDocket: false,
            subStaffName: invoice.subStaffName,
            customDate: null,
            departmentName: invoice.departmentName,
            departmentUuid: invoice.departmentUuidNew,
            staffId: invoice.staffId,
            staffName: invoice.staffName,
            id: newId,
            fixedDiscount: invoice.fixedDiscount,
            createdDate: invoice.createdAt,
            cartItems: cartItems,
            cartItemTypeIndex: 2,
            orderUuidEdit: null,
            discount: invoice.generalDiscount,
            invoiceUuidEdit: invoice.uuid,
            paymentMethod:
                invoice.paymentMethod == 'Cash'
                    ? 0
                    : invoice.paymentMethod == 'Bank'
                    ? 1
                    : 2,
            selectedCustomer: invoice.customerUuid,
            selectedCustomerName: invoice.customerName,
            isReceiptEdit: true,
            subStaffUuid: invoice.subStaffUuid,
          );
          await returnSalesProvider().addNewCart(
            context,
            tempCart,
          );
          await returnMultiDisplayProvider().updateWindow(
            cartClass: AltCartClass(
              manageCustomerReward:
                  returnShopProvider()
                      .userShop()!
                      .manageCustomerReward ??
                  false,
              cartId: tempCart.id!,
              cartItems:
                  tempCart.cartItems.reversed.toList(),
              fixedDiscount: invoice.fixedDiscount,
              percentDiscount: invoice.generalDiscount,
              vat: invoice.vat ?? 0,
              cashBack: invoice.getCustomerReward(),
              currency:
                  returnShopProvider().userShop()!.currency,
            ),
          );
          notifyListeners();
        } else {
          await returnSalesProvider().selectCart(
            returnSalesProvider()
                .currentMainCart()
                .cartQueue
                .where(
                  (cart) =>
                      cart.invoiceUuidEdit == invoice.uuid,
                )
                .first
                .id!,
          );
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return MakeSalesPage(isMain: true);
            },
          ),
        );
      },
    );
  }

  // The line's unit, wastage unit and price, added back from the
  // invoice line's snapshot if they were removed from the item.
  static TempProductClass editLineProduct({
    required TempProductSaleRecord record,
    required TempProductClass product,
    void Function(String message)? onMissing,
  }) {
    return product.withLineSnapshot(
      unitUuids: [
        record.unitUuid,
        if (record.manageSalesWastage == true)
          record.wastageUnitUuid,
      ],
      snapshotUnits: record.getUnitListFinal(),
      priceUuid: record.priceUuid,
      snapshotPrices: record.getPriceListFinal(),
      onMissing:
          onMissing ?? (message) => mainLocalLog(message),
    );
  }

  // EDIT Invoice
  TempCartItem saleRecordToCartItem({
    required TempProductSaleRecord record,
    required TempProductClass product,
  }) {
    double tempRev = 0;
    if (record.customPriceSet) {
      if (record.setTotalPrice != null &&
          record.setTotalPrice == true) {
        tempRev = record.originalCost ?? 0;
      } else {
        // originalCost was billed on the line's base quantity
        // (area for 2D, after unit conversion) + wastage.
        tempRev =
            (record.originalCost ?? 0) /
            record.getStockQuantity();
      }
    }
    return TempCartItem(
      isPercentageWastage: record.isPercentageWastage,
      // Lines saved before wastage was applied keep none, so
      // they aren't re-priced or re-deducted.
      wastageAmount:
          record.manageSalesWastage == true
              ? record.wastageAmount
              : null,
      wastageUnitUuid:
          record.manageSalesWastage == true
              ? record.wastageUnitUuid
              : null,
      manageSalesWastage: record.manageSalesWastage,
      heightDimension: record.heightDimension,
      quantityType: record.quantityType,
      widthDimension: record.widthDimension,
      priceUuid: record.priceUuid,
      unitUuid: record.unitUuid,
      uuid: record.uuid,
      itemUuid: product.uuid,
      isVoid: record.isVoid ?? false,
      item: product,
      quantity: record.quantity,
      discount: record.discount,
      fixedDiscount: record.fixedDiscount,
      customPrice: record.customPriceSet ? tempRev : null,
      addToStock: record.addToStock ?? false,
      setCustomPrice: record.customPriceSet,
      setTotalPrice: record.setTotalPrice ?? false,
      // salesRecordId: record.uuid,
      useWholeSalePrice: record.useWholeSalePrice ?? false,
      useGroupQuantity: record.useGroupQuantity ?? false,
      qttyPerGroup: record.qttyPerGroup,
    );
  }

  List<TempCartItem> convertInvoiceToCartItems({
    required TempInvoice invoice,
    required List<TempProductSaleRecord> saleRecords,
    required BuildContext context,
  }) {
    List<TempCartItem> cartItems = [];

    for (var record in saleRecords) {
      var product = returnData().productListMain.where(
        (p) => p.uuid == record.productUuid,
      );

      if (product.isNotEmpty) {
        var newRecord = record.copy();
        if (newRecord.discount != null) {
          newRecord.revenue = newRecord.originalCost!;
          // record.discount = 0;
        }
        var newProduct = product.first.copyWith();
        newProduct.unitsList = record.getUnitListFinal();
        newProduct.pricesList = record.getPriceListFinal();
        if (record.dimensionUnit != null) {
          newProduct.dimensionUnit = record.dimensionUnit;
        }
        if (record.dimensionUnitConversion != null &&
            record.dimensionUnitConversion! > 0) {
          newProduct.dimensionUnitConversion =
              record.dimensionUnitConversion;
        }

        if (newRecord.unitUuid == null ||
            !newProduct.getUnitsList().any(
              (u) => u.uuid == newRecord.unitUuid,
            )) {
          final matchedUnit =
              newProduct.getUnitsList().where((u) {
                final recUnit =
                    newRecord.unit?.trim().toLowerCase() ??
                    '';
                final uName = u.name.trim().toLowerCase();
                return uName == recUnit ||
                    (recUnit.isNotEmpty &&
                        recUnit.startsWith(uName));
              }).firstOrNull;
          if (matchedUnit != null) {
            newRecord.unitUuid = matchedUnit.uuid;
          }
        }

        final cartItem = saleRecordToCartItem(
          record: newRecord,
          product: editLineProduct(
            record: newRecord,
            product: newProduct,
          ),
        );
        cartItems.add(cartItem);
      } else {
        var newRecord = record.copy();
        if (newRecord.discount != null) {
          newRecord.revenue = newRecord.originalCost!;
          // record.discount = 0;
        }
        final double costPrice =
            (record.costPrice == null ||
                    record.costPrice == 0)
                ? 0
                : record.costPrice!;

        final double sellingPrice =
            record.discount == null
                ? record.revenue / record.quantity
                : (record.originalCost ?? 0) /
                    record.quantity;
        final double wholeSalePrice =
            record.discount == null
                ? record.revenue / record.quantity
                : (record.originalCost ?? 0) /
                    record.quantity;

        TempProductClass productNew = TempProductClass(
          manageSalesWastage: record.manageSalesWastage,
          setCustomPrice: record.customPriceSet,
          isManaged: record.isProductManaged ?? false,
          heightDimension: record.heightDimension,
          quantityType: record.quantityType,
          widthDimension: record.widthDimension,
          dimensionUnit: record.dimensionUnit,
          dimensionUnitConversion:
              record.dimensionUnitConversion,
          pricesList: record.getPriceListFinal(),
          unitsList: record.getUnitListFinal(),
          useGroupUnit: false,
          categories: [],
          groupUnit: 'Group(s)',
          storageUuid: null,
          qttyPerGroup: null,
          name: record.productName,
          unit: record.unit ?? 'Unit(s)',
          isRefundable: false,
          costPrice: costPrice,
          shopId: record.shopId,

          barcode: null,
          brand: null,
          color: null,
          createdAt: DateTime.now(),
          departmentUuid: record.departmentUuid,
          departmentName: record.departmentName,
          discount: null,
          endDate: null,
          expiryDate: null,
          lowQtty: 10,
          quantity: null,
          sellingPrice: sellingPrice,
          wholeSalePrice: wholeSalePrice,
          size: null,
          sizeType: null,
          startDate: null,
          updatedAt: DateTime.now(),
          uuid: uuidGen(),
        );

        if (newRecord.unitUuid == null ||
            !productNew.getUnitsList().any(
              (u) => u.uuid == newRecord.unitUuid,
            )) {
          final matchedUnit =
              productNew.getUnitsList().where((u) {
                final recUnit =
                    newRecord.unit?.trim().toLowerCase() ??
                    '';
                final uName = u.name.trim().toLowerCase();
                return uName == recUnit ||
                    (recUnit.isNotEmpty &&
                        recUnit.startsWith(uName));
              }).firstOrNull;
          if (matchedUnit != null) {
            newRecord.unitUuid = matchedUnit.uuid;
          }
        }

        final cartItem = saleRecordToCartItem(
          record: newRecord,
          product: productNew,
        );
        cartItems.add(cartItem);
      }
    }

    return cartItems;
  }

  Future<dynamic> cancelInvoiceEdit(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return ConfirmationAlert(
          theme: returnTheme(context, listen: false),
          message:
              'You are currently editing this invoice, are you sure you want to cancel this edit?',
          title: 'Cancel Edit?',
          action: () async {
            if (returnSalesProvider()
                .currentCart()
                .isReceiptEdit) {
              if (returnSalesProvider()
                      .currentMainCart()
                      .cartQueue
                      .length ==
                  1) {
                await returnSalesProvider().addNewCart(
                  context,
                  TempCart(
                    tempCartItems: null,
                    comment: null,
                    timeOfDay: null,
                    // createdDate: DateTime.now(),
                    hasPrintedDocket: false,
                    subStaffName: null,
                    customDate: null,
                    departmentName: null,
                    departmentUuid: null,
                    cartItems: [],
                    cartItemTypeIndex: 2,
                    orderUuidEdit: null,
                    staffId: currentUser().userId,
                    staffName:
                        "${currentUser().name} ${currentUser().lastName}",
                    id: uuidGen(),
                  ),
                );
              }

              await returnSalesProvider().deleteCart(
                cartId: returnSalesProvider().cartIdCache,
                context: context,
              );
              // await selectCart(cartIndex - 1);
              notifyListeners();
              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            } else {
              Navigator.of(context).pop();
            }
          },
        );
      },
    );
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
      mainLocalLog('Date set: $date');
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
    notifyListeners();
  }

  List<TempInvoice> departmentInvoices() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return invoicesMain.where((cat) {
          return cat.departmentUuidNew ==
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
          return invoicesMain;
        } else {
          return invoicesMain.where((cat) {
            return cat.departmentUuidNew ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
            // }
          }).toList();
        }
      }
    } else {
      return invoicesMain;
    }
  }

  List<TempInvoice> returnAllOrSetDateInvoices() {
    if (dateSet == null &&
        rangeEndDate == null &&
        rangeStartDate == null) {
      return invoicesMain;
    } else {
      return returnInvoicesByDayOrWeekAll();
    }
  }

  List<TempInvoice> returnUnpaidInvoices() {
    return returnInvoicesByDayOrWeekAll()
        .where(
          (inv) =>
              (inv.bank + inv.cashAlt) == inv.getBalance(),
        )
        .toList();
  }

  List<TempInvoice> returnPartiallyPaidInvoices() {
    return returnInvoicesByDayOrWeekAll()
        .where(
          (inv) =>
              inv.getBalance() != 0 &&
              (inv.bank + inv.cashAlt) > inv.getBalance(),
        )
        .toList();
  }

  List<TempInvoice> returnPaidInvoices() {
    return returnInvoicesByDayOrWeekAll()
        .where((inv) => inv.getBalance() == 0)
        .toList();
  }

  int invoicePaymentStatusIndex = 0;

  void selectPaymentStatus(int index) {
    invoicePaymentStatusIndex = index;
    notifyListeners();
  }

  List<TempInvoice> returnInvoicesBasedOnPaymentStatus() {
    if (rangeStartDate != null) {
      return departmentInvoices().where((invoice) {
        final created = invoice.createdAt.toLocal();
        return !created.isBefore(
              fourAm(rangeStartDate ?? DateTime.now()),
            ) &&
            !created.isAfter(
              fourAmNextDay(rangeEndDate ?? DateTime.now()),
            );
      }).toList();
    }

    if (dateSet != null) {
      return departmentInvoices().where((invoice) {
        final created = invoice.createdAt.toLocal();
        final inRange =
            !created.isBefore(
              fourAm(dateSet ?? DateTime.now()),
            ) &&
            !created.isAfter(
              fourAmNextDay(dateSet ?? DateTime.now()),
            );

        return inRange;
      }).toList();
    }
    return departmentInvoices();
  }

  List<TempInvoice> returnInvoicesByDayOrWeekAll() {
    if (invoicePaymentStatusIndex == 0) {
      return returnInvoicesBasedOnPaymentStatus()
          .where(
            (inv) =>
                (inv.bank + inv.cashAlt) ==
                inv.getBalance(),
          )
          .toList();
    } else if (invoicePaymentStatusIndex == 1) {
      return returnInvoicesBasedOnPaymentStatus()
          .where((inv) => inv.getBalance() == 0)
          .toList();
    } else if (invoicePaymentStatusIndex == 2) {
      return returnInvoicesBasedOnPaymentStatus()
          .where(
            (inv) =>
                inv.getBalance() != 0 &&
                (inv.bank + inv.cashAlt) > inv.getBalance(),
          )
          .toList();
    } else {
      return returnInvoicesBasedOnPaymentStatus().toList();
    }
  }

  double getTotalRevenueForSelectedDayAll({
    String? staffId,
    String? customerId,
    String? subStaffId,
  }) {
    double tempTotalRevenue = 0;

    for (var invoice
        in (staffId != null
            ? returnInvoicesByDayOrWeekAll().where(
              (rec) => rec.staffId == staffId,
            )
            : subStaffId != null
            ? returnInvoicesByDayOrWeekAll().where(
              (rec) => rec.subStaffUuid == subStaffId,
            )
            : customerId != null
            ? returnInvoicesByDayOrWeekAll().where(
              (rec) => rec.customerUuid == customerId,
            )
            : returnInvoicesByDayOrWeekAll())) {
      tempTotalRevenue += invoice.getBalance();
    }

    return tempTotalRevenue;
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

  Future<void> createInvoicesSync(
    // BuildContext context,
  ) async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedInvoicesFunc().getInvoices().isNotEmpty &&
          isOnline) {
        final tempInvoice =
            CreatedInvoicesFunc().getInvoices().toList();
        // createdAt is serialized to UTC in toJson(); don't mutate the
        // shared in-memory invoice.
        var newInvoices = tempInvoice;
        int count = 0;
        for (var item in newInvoices) {
          try {
            // Insert all at once
            await supabase
                .from('invoices')
                .insert(item.invoice.toJson())
                .select();
            count++;
            await CreatedInvoicesFunc().deleteInvoice(
              item.invoice.uuid!,
            );
          } on PostgrestException catch (e) {
            if (e.code == '23505') {
              await CreatedInvoicesFunc().deleteInvoice(
                item.invoice.uuid!,
              );
            }
            await mainLocalLog(
              'Error Synchronizing Invoice ${item.invoice.bank + item.invoice.cashAlt}: $e',
            );
          }
        }

        await mainLocalLog(
          '$count items added successfully ✅',
        );
        await mainLocalLog(
          'Mounted, refreshing Invoices ✅',
        );
        await loadInvoices(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Invoices insert failed ❌: $e',
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
  //

  Future<void> deleteInvoicesSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (DeletedInvoicesFunc()
              .getInvoiceIds()
              .isNotEmpty &&
          isOnline) {
        final tempInvoice =
            DeletedInvoicesFunc().getInvoiceIds().toList();
        final currentShopId =
            returnShopProvider().userShop()?.shopId;

        for (var inv in tempInvoice) {
          try {
            var query = supabase
                .from('invoices')
                .delete()
                .eq('invoice_uuid', inv.invoiceUuid);
            if (currentShopId != null) {
              query = query.eq('shop_id', currentShopId);
            }
            await query;

            await DeletedInvoicesFunc()
                .deletedDeletedInvoices(inv.invoiceUuid);
            await mainLocalLog(
              'Invoice ${inv.invoiceUuid} remote deletion succeeded ✅',
            );
          } catch (e) {
            await mainLocalLog(
              'Error Syncing Deleted Invoice ${inv.invoiceUuid}: ${e.toString()}',
            );
          }
        }

        if (DeletedInvoicesFunc().getInvoiceIds().isEmpty) {
          await mainLocalLog(
            'All Unsynced Deleted Invoices Cleared ✅',
          );
          await loadInvoices(
            returnShopProvider().userShop()!.shopId!,
          );
        } else {
          await mainLocalLog(
            'Some deleted invoices could not be synced and remain in queue.',
          );
        }
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Invoices Deleted failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //
  //
  Future<void> updateInvoicesSync(
    // BuildContext context,
  ) async {
    try {
      bool isOnline = await connectivity.isOnline();
      await mainLocalLog(
        UpdatedInvoicesFunc()
            .getInvoiceIds()
            .length
            .toString(),
      );

      if (UpdatedInvoicesFunc()
              .getInvoiceIds()
              .isNotEmpty &&
          isOnline) {
        final updatedInvoices =
            UpdatedInvoicesFunc().getInvoiceIds();

        for (final updated in updatedInvoices) {
          final localInvoices = updated.updatedInvoice;

          localInvoices.updatedAt ??=
              DateTime.now().toLocal();

          if (localInvoices.uuid == null) {
            await mainLocalLog(
              'Local Invoices Uuid is Null',
            );
          }
          final remoteData =
              await supabase
                  .from('invoices')
                  .select('invoice_uuid, updated_at')
                  .eq('invoice_uuid', localInvoices.uuid!)
                  .maybeSingle();

          if (remoteData == null) {
            await supabase
                .from('invoices')
                .insert(localInvoices.toJson());
            await mainLocalLog(
              'Inserted Invoices with uuid ${localInvoices.uuid}',
            );
            await UpdatedInvoicesFunc()
                .deleteUpdatedInvoice(
                  localInvoices.uuid ?? '',
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

            localInvoices.updatedAt =
                (localInvoices.updatedAt ?? DateTime.now())
                    .toUtc(); // ✅ keep both UTC
            await mainLocalLog(
              "Local updatedAt: ${localInvoices.updatedAt}",
            );
            await mainLocalLog(
              "Remote updatedAt: $remoteUpdatedAt",
            );

            if (remoteUpdatedAt == null ||
                localInvoices.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from('invoices')
                  .update(localInvoices.toJson())
                  .eq('invoice_uuid', localInvoices.uuid!);
              await mainLocalLog(
                'Updated Invoices with uuid ${localInvoices.uuid}',
              );
              await UpdatedInvoicesFunc()
                  .deleteUpdatedInvoice(
                    localInvoices.uuid ?? '',
                  );
            } else {
              await mainLocalLog(
                'Skipped Invoices ${localInvoices.uuid}, remote is newer ✅',
              );
              await UpdatedInvoicesFunc()
                  .deleteUpdatedInvoice(
                    localInvoices.uuid ?? '',
                  );
            }
          }
        }
        await mainLocalLog(
          'Unsynced updated Invoices cleared',
        );
        await mainLocalLog(
          'Mounted, refreshing Invoices ✅',
        );
        await loadInvoices(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Invoices update failed ❌: $e',
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
  //
}
