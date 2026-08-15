import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
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
import 'package:stockall/pages/report/invoice_sales_report/platforms/invoice_sales_report_desktop.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/error_log_provider.dart';
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

  final SupabaseClient supabase = Supabase.instance.client;
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
    bool isOnline = await connectivity.isOnline();
    if (isOnline && InvoicesFunc().isSynced()) {
      await InvoicesFunc().clearInvoices();
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

        _invoices =
            (data as List)
                .map((json) => TempInvoice.fromJson(json))
                .toList();
        notifyListeners();
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
    required List<TempProductSaleRecord> records,
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
      await returnEventsLogProvider().createLog(
        returnEventsLogProvider().invoiceAdapter(
          invoice,
          records.map((rec) => rec.productName).toList(),
          2,
        ),
      );
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
    if (returnReceiptProviderSingle().receipts
        .where((rec) => rec.invoiceUuid == invoice.uuid)
        .isEmpty) {
      return await deleteInvoiceAndUpdateInventory(
        invoice,
        productNames,
      );
    } else {
      return await deleteInvoiceWithoutUpdatingInventory(
        invoice.uuid!,
      );
    }
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
        invoice.uuid!,
      );
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
  Future<int> deleteInvoiceWithoutUpdatingInventory(
    String uuid,
  ) async {
    try {
      await mainLocalLog('Deleting Invoice Offline');
      await InvoicesFunc().deleteInvoices(uuid);
      var containsCreated =
          CreatedInvoicesFunc()
              .getInvoices()
              .where((inv) => inv.invoice.uuid == uuid)
              .toList();
      var containsUpdate = UpdatedInvoicesFunc()
          .getInvoiceIds()
          .where((inv) => inv.updatedInvoice.uuid == uuid);
      if (containsCreated.isNotEmpty) {
        await CreatedInvoicesFunc().deleteInvoice(uuid);
      } else {
        await DeletedInvoicesFunc().createDeletedInvoice(
          DeletedInvoices(invoiceUuid: uuid),
        );
      }
      if (containsUpdate.isNotEmpty) {
        await UpdatedInvoicesFunc().deleteUpdatedInvoice(
          uuid,
        );
      }
      await ProductRecordFunc()
          .deleteRecordsInInvoiceWithoutUpdatingInventory(
            uuid,
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

  Future<int> makeInvoicePayment({
    required TempInvoice invoice,
    required List<TempProductSaleRecord> salesRecords,
    required double currentPayment,
  }) async {
    try {
      final createdAt = DateTime.now().toUtc();

      TempMainReceipt receipt = TempMainReceipt(
        comment: null,
        subStaffName: invoice.subStaffName,
        createdAt: createdAt,
        shopId: invoice.shopId,
        staffId: AuthService().currentUser!,
        staffName:
            "${returnUserProviderSingle().currentUserMain!.name} ${returnUserProviderSingle().currentUserMain!.lastName}",
        paymentMethod: 'Bank',
        bank: currentPayment,
        cashAlt: 0,
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
        balance:
            getBalance(invoice: invoice) - currentPayment,
        subStaffUuid: invoice.subStaffUuid,
        cartName: invoice.cartName,
      );

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

        final productSaleRecords =
            salesRecords.map((record) {
              mainLocalLog(
                'Sales Record about to be Created',
              );
              return TempProductSaleRecord(
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
                receiptUuid: res.uuid,
                quantity: record.quantity,
                revenue: calcSalesRecordRevenue(
                  invoceTotalAmount:
                      getTotalMainRevenueInvoice(
                        invoice: invoice,
                      ),
                  receiptPayment: currentPayment,
                  salesRecodRevenue: record.revenue,
                ),
                costPrice: calcSalesRecordCostPrice(
                  invoceTotalAmount:
                      getTotalMainRevenueInvoice(
                        invoice: invoice,
                      ),
                  receiptPayment: currentPayment,
                  salesRecodCostPrice:
                      (record.costPrice ?? 0),
                ),
                discountedAmount:
                    calcSalesRecordDiscountedAmount(
                      invoceTotalAmount:
                          getTotalMainRevenueInvoice(
                            invoice: invoice,
                          ),
                      receiptPayment: currentPayment,
                      salesRecodDiscountedAmount:
                          (record.discountedAmount ?? 0),
                    ),
                originalCost: calcSalesRecordOriginalCost(
                  invoceTotalAmount:
                      getTotalMainRevenueInvoice(
                        invoice: invoice,
                      ),
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

        await mainLocalLog(
          'Creating Record Sales About to Start',
        );
        await returnReceiptProviderSingle()
            .createProductSaleRecord(
              records: productSaleRecords,
              isPartPayment: true,
            );
        await mainLocalLog('Sales Record Inserted');
        // invoice.balance =
        //    getBalance(invoice: invoice) - currentPayment;
        // invoice.status =
        await updateInvoice(
          invoice: invoice,
          records: productSaleRecords,
        );
        await returnReceiptProviderSingle()
            .loadReceiptsOffline(shopId());
        returnData().syncData();
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
        final saleRecords =
            returnReceiptProvider(context, listen: false)
                .produtRecordSalesMain
                .where((r) => r.invoiceUuid == invoice.uuid)
                .toList();

        // Convert them back to cart items
        final cartItems = convertInvoiceToCartItems(
          invoice: invoice,
          saleRecords: saleRecords,
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
            isInvoice: true,
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
              cartId: tempCart.id!,
              cartItems:
                  tempCart.cartItems.reversed.toList(),
              fixedDiscount: invoice.fixedDiscount,
              percentDiscount: invoice.generalDiscount,
              vat: invoice.vat ?? 0,
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
        tempRev =
            (record.originalCost ?? 0) / record.quantity;
      }
    }
    return TempCartItem(
      uuid: record.uuid,
      itemUuid: product.uuid,
      isVoid: record.isVoid ?? false,
      item: product,
      quantity: record.quantity,
      discount: 0,
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
      var product = returnData().productList().where(
        (p) => p.uuid == record.productUuid,
      );

      if (product.isNotEmpty) {
        var newRecord = record.copy();
        if (newRecord.discount != null) {
          newRecord.revenue = newRecord.originalCost!;
          // record.discount = 0;
        }
        final cartItem = saleRecordToCartItem(
          record: newRecord,
          product: product.first,
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
          setCustomPrice: true,
          isManaged: false,
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
                    comment: null,
                    timeOfDay: null,
                    // createdDate: DateTime.now(),
                    hasPrintedDocket: false,
                    subStaffName: null,
                    customDate: null,
                    departmentName: null,
                    departmentUuid: null,
                    cartItems: [],
                    isInvoice: false,
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
        .where((inv) => getBalance(invoice: inv) != 0)
        .toList();
  }

  List<TempInvoice> returnPaidInvoices() {
    return returnInvoicesByDayOrWeekAll()
        .where((inv) => getBalance(invoice: inv) == 0)
        .toList();
  }

  List<TempInvoice> returnInvoicesBasedOnPaymentMethod() {
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
    if (returnReceiptProviderSingle().paymentMethod == 3) {
      return returnInvoicesBasedOnPaymentMethod()
          .where((rec) => rec.paymentMethod == 'Split')
          .toList();
    } else if (returnReceiptProviderSingle()
            .paymentMethod ==
        1) {
      return returnInvoicesBasedOnPaymentMethod()
          .where((rec) => rec.paymentMethod == 'Cash')
          .toList();
    } else if (returnReceiptProviderSingle()
            .paymentMethod ==
        2) {
      return returnInvoicesBasedOnPaymentMethod()
          .where((rec) => rec.paymentMethod == 'Bank')
          .toList();
    } else {
      return returnInvoicesBasedOnPaymentMethod().toList();
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
      tempTotalRevenue += getBalance(invoice: invoice);
    }

    return tempTotalRevenue;
  }
  //
  //
  //
  //

  double getTotalMainRevenueInvoice({
    required TempInvoice invoice,
  }) {
    var total = ((invoice.bank + invoice.cashAlt));

    return total;
  }

  double getBalance({required TempInvoice invoice}) {
    double tempValue = 0;
    List<TempMainReceipt> receiptsTemp =
        returnReceiptProviderSingle().receipts
            .where((rec) => rec.invoiceUuid == invoice.uuid)
            .toList();
    for (var val in receiptsTemp) {
      tempValue += (val.bank + val.cashAlt);
    }
    return getTotalMainRevenueInvoice(invoice: invoice) -
        tempValue;
  }

  int getInvoiceStatus({required TempInvoice invoice}) {
    if (getBalance(invoice: invoice) ==
        getTotalMainRevenueInvoice(invoice: invoice)) {
      return 0;
    } else if (getBalance(invoice: invoice) <
            getTotalMainRevenueInvoice(invoice: invoice) &&
        getBalance(invoice: invoice) > 0) {
      return 1;
    } else {
      return 2;
    }
  }

  double getDiscountAmountForInvoice(TempInvoice invoice) {
    if (invoice.fixedDiscount != null) {
      return (invoice.fixedDiscount ?? 0);
    } else if (invoice.generalDiscount != null) {
      return (getOriginalCostInvoice(invoice) *
          ((invoice.generalDiscount ?? 0) / 100));
    } else {
      return 0;
    }
  }

  double getAmountPaid({required TempInvoice invoice}) {
    return getTotalMainRevenueInvoice(invoice: invoice) -
        getBalance(invoice: invoice);
  }

  double getVATInvoice({TempInvoice? invoice}) {
    return invoice == null
        ? 0
        : (invoice.originalCost ?? 0) *
            ((invoice.vat ?? 0) / 100);
  }

  double getOriginalCostInvoice(TempInvoice invoice) {
    return invoice.originalCost ?? 0;
  }

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
        var newInvoices = tempInvoice.map((inv) {
          inv.invoice.createdAt =
              inv.invoice.createdAt.toUtc();
          return inv;
        });
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
            await createErrorLog(
              error:
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
      await createErrorLog(
        error: 'Batch Invoices insert failed ❌: $e',
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

        for (var inv in tempInvoice) {
          try {
            await supabase.rpc(
              'delete_invoice_without_updating_inventory',
              params: {
                'target_invoice_uuid': inv.invoiceUuid,
              },
            );
            await DeletedInvoicesFunc()
                .deletedDeletedInvoices(inv.invoiceUuid);
          } catch (e) {
            await DeletedInvoicesFunc()
                .deletedDeletedInvoices(inv.invoiceUuid);
            createErrorLog(
              error:
                  'Error Syncing Deleted Invoice: ${e.toString()}',
            );
          }
        }

        await mainLocalLog(
          '${tempInvoice.length} Invoices Created successfully ✅',
        );
        await DeletedInvoicesFunc().clearDeletedInvoices();
        await mainLocalLog(
          'Unsynced Deleted Invoices Cleared',
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
        'Batch Invoices Deleted failed ❌: $e',
      );
      await createErrorLog(
        error: 'Batch Invoices Delete failed ❌: $e',
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
            }
          }
        }

        await UpdatedInvoicesFunc()
            .clearupdatedInvoiceUpdatedInvoices();
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
      await createErrorLog(
        error: 'Batch Invoices update failed ❌: $e',
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

  List<StaffGroupInvoices> groupInvoicesByStaff() {
    final Map<String?, StaffGroupInvoices> grouped = {};

    for (final invoice in returnAllOrSetDateInvoices()) {
      final String staffUuid = invoice.staffId;

      if (!grouped.containsKey(staffUuid)) {
        grouped[staffUuid] = StaffGroupInvoices(
          staffUuid: staffUuid,
          staffName: invoice.staffName,
          number: 0,
          totalPaid: 0,
          totalBalance: 0,
          totalOriginalCost: 0,
          totalRevenue: 0,
        );
      }

      final group = grouped[staffUuid]!;

      group.number++;
      group.totalBalance += getBalance(invoice: invoice);
      group.totalPaid += getAmountPaid(invoice: invoice);
      group.totalOriginalCost += invoice.originalCost ?? 0;
      group.totalRevenue += invoice.cashAlt + invoice.bank;
    }

    var res = grouped.values.toList();
    res.sort(
      (a, b) => ((a.staffName ?? 'Not Set').toLowerCase())
          .compareTo(
            (b.staffName ?? 'Not Set').toLowerCase(),
          ),
    );
    return res;
  }

  List<CustomerGroupInvoices> groupInvoicesByCustomer() {
    final Map<String?, CustomerGroupInvoices> grouped = {};

    for (final invoice in returnAllOrSetDateInvoices()) {
      final String? customerUuid = invoice.customerUuid;

      if (!grouped.containsKey(customerUuid)) {
        grouped[customerUuid] = CustomerGroupInvoices(
          customerUuid: customerUuid ?? '',
          customerName:
              customerUuid == null
                  ? null
                  : invoice.customerName ?? '',
          number: 0,
          totalPaid: 0,
          totalBalance: 0,
          totalOriginalCost: 0,
          totalRevenue: 0,
        );
      }

      final group = grouped[customerUuid]!;

      group.number++;
      group.totalBalance += getBalance(invoice: invoice);
      group.totalPaid += getAmountPaid(invoice: invoice);
      group.totalOriginalCost += invoice.originalCost ?? 0;
      group.totalRevenue += invoice.cashAlt + invoice.bank;
    }

    var res = grouped.values.toList();
    res.sort(
      (a, b) =>
          ((a.customerName ?? 'Not Set').toLowerCase())
              .compareTo(
                (b.customerName ?? 'Not Set').toLowerCase(),
              ),
    );
    return res;
  }

  List<ChannelGroupInvoices>
  groupInvoicesByPaymentChannel() {
    final Map<String, ChannelGroupInvoices> grouped = {};

    for (final invoice in returnAllOrSetDateInvoices()) {
      final paymentMethod = invoice.paymentMethod;

      if (!grouped.containsKey(paymentMethod)) {
        grouped[paymentMethod] = ChannelGroupInvoices(
          paymentMethod: paymentMethod,
          number: 0,
          totalPaid: 0,
          totalBalance: 0,
          totalOriginalCost: 0,
          totalRevenue: 0,
        );
      }

      final group = grouped[paymentMethod]!;

      group.number++;
      group.totalBalance += getBalance(invoice: invoice);
      group.totalPaid += getAmountPaid(invoice: invoice);
      group.totalOriginalCost += invoice.originalCost ?? 0;
      group.totalRevenue += invoice.cashAlt + invoice.bank;
    }

    var res = grouped.values.toList();
    return res;
  }

  List<DepartmentGroupInvoices>
  groupInvoicesByDepartment() {
    final Map<String?, DepartmentGroupInvoices> grouped =
        {};

    for (final invoice in returnAllOrSetDateInvoices()) {
      final String? departmentUuid =
          invoice.departmentUuidNew;

      if (!grouped.containsKey(departmentUuid)) {
        grouped[departmentUuid] = DepartmentGroupInvoices(
          departmentUuid: departmentUuid ?? '',
          departmentName:
              departmentUuid == null
                  ? null
                  : invoice.departmentName ?? '',
          number: 0,
          totalPaid: 0,
          totalBalance: 0,
          totalOriginalCost: 0,
          totalRevenue: 0,
        );
      }

      final group = grouped[departmentUuid]!;

      group.number++;
      group.totalBalance += getBalance(invoice: invoice);
      group.totalPaid += getAmountPaid(invoice: invoice);
      group.totalOriginalCost += invoice.originalCost ?? 0;
      group.totalRevenue += invoice.cashAlt + invoice.bank;
    }

    var res = grouped.values.toList();
    res.sort(
      (a, b) => ((a.departmentName ?? 'Not Set')
              .toLowerCase())
          .compareTo(
            (b.departmentName ?? 'Not Set').toLowerCase(),
          ),
    );
    return res;
  }

  int sortColumnIndex = 0;
  bool sortAscending = true;

  List<DataColumn> _headingTotal({
    required BuildContext context,
  }) {
    return [
      DataColumn2(label: HeadingTextWidget(title: '#Id')),
      DataColumn2(
        size: ColumnSize.L,

        label: HeadingTextWidget(title: 'Staff'),
      ),
      DataColumn2(
        size: ColumnSize.L,

        label: HeadingTextWidget(title: 'Customer'),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'Channel'),
      ),
      DataColumn2(label: HeadingTextWidget(title: 'Date')),
      DataColumn2(label: HeadingTextWidget(title: 'Time')),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'Discount'),
      ),
      // DataColumn2(
      //   size: ColumnSize.S,
      //   label: HeadingTextWidget(title: 'VAT'),
      // ),
      DataColumn2(label: HeadingTextWidget(title: 'Paid')),
      DataColumn2(
        label: HeadingTextWidget(title: 'Balance'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Sub-Total'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Revenue'),
      ),
    ];
  }

  List<DataColumn> _headingStaffs() {
    return [
      DataColumn2(
        size: ColumnSize.L,

        label: HeadingTextWidget(title: 'Staff'),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'Quantity'),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: HeadingTextWidget(title: 'Paid'),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: HeadingTextWidget(title: 'Balance'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Sub-Total'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Revenue'),
      ),
    ];
  }

  List<DataColumn> _headingCustomers() {
    return [
      DataColumn2(
        size: ColumnSize.L,

        label: HeadingTextWidget(title: 'Customer'),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'Quantity'),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: HeadingTextWidget(title: 'Paid'),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: HeadingTextWidget(title: 'Balance'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Sub-Total'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Revenue'),
      ),
    ];
  }

  List<DataColumn> _headingChannel() {
    return [
      DataColumn2(
        size: ColumnSize.L,
        label: HeadingTextWidget(title: 'Channel'),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'Quantity'),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: HeadingTextWidget(title: 'Paid'),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: HeadingTextWidget(title: 'Balance'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Sub-Total'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Revenue'),
      ),
    ];
  }

  List<DataColumn> _headingDepartments() {
    return [
      DataColumn2(
        size: ColumnSize.L,
        label: HeadingTextWidget(title: 'Department'),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'Quantity'),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: HeadingTextWidget(title: 'Paid'),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: HeadingTextWidget(title: 'Balance'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Sub-Total'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Revenue'),
      ),
    ];
  }

  double rowTotalTotalBalance() {
    return returnAllOrSetDateInvoices()
        .map((item) => getBalance(invoice: item))
        .toList()
        .fold(0, (p, n) => p + n);
  }

  double rowTotalTotalPaid() {
    return returnAllOrSetDateInvoices()
        .map((item) => getAmountPaid(invoice: item))
        .toList()
        .fold(0, (p, n) => p + n);
  }

  double rowTotalTotalCostPrice() {
    return returnAllOrSetDateInvoices()
        .map((item) => (item.originalCost ?? 0))
        .toList()
        .fold(0, (p, n) => p + n);
  }

  double rowTotalTotalRevenue() {
    return returnAllOrSetDateInvoices()
        .map((item) => (item.cashAlt + item.bank))
        .toList()
        .fold(0, (p, n) => p + n);
  }

  List<DataRow> _rowTotal({
    required BuildContext context,
    required int index,
  }) {
    return [
      ...(index == 1
              ? returnAllOrSetDateInvoices()
              : index == 2
              ? returnPaidInvoices()
              : returnUnpaidInvoices())
          .toList()
          .map((item) {
            return DataRow2(
              specificRowHeight:
                  (item.staffName).length > 18 ||
                          (item.customerName ?? '').length >
                              18
                      ? 40
                      : 30,
              cells: [
                DataCell(
                  Text(
                    "#${item.barcode ?? returnOnlyDigits(item.uuid ?? '')}",
                  ),
                ),
                DataCell(Text(item.staffName)),
                DataCell(
                  Text(item.customerName ?? 'Not Set'),
                ),
                DataCell(Text(item.paymentMethod)),
                DataCell(
                  Text(formatDateTime(item.createdAt)),
                ),
                DataCell(Text(formatTime(item.createdAt))),
                DataCell(
                  Text(
                    "${item.generalDiscount != null ? "" : '${shop(context)?.currency}'}${formatLargeNumberDouble(item.fixedDiscount ?? item.generalDiscount ?? 0)}${item.generalDiscount != null ? "%" : ''}",
                  ),
                ),
                DataCell(
                  Text(
                    formatMoneyBig(
                      amount: getAmountPaid(invoice: item),
                      context: context,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    formatMoneyBig(
                      amount: getBalance(invoice: item),
                      context: context,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    formatMoneyBig(
                      amount: item.originalCost ?? 0,
                      context: context,
                    ),
                  ),
                ),
                DataCell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ReceiptPage(
                            response: CheckoutResponse(
                              resUuid: item.uuid!,
                              isReceipt: false,
                              invoice: item,
                            ),
                            isMain: false,
                          );
                        },
                      ),
                    );
                  },
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    spacing: 5,
                    children: [
                      Text(
                        formatMoneyBig(
                          amount: item.bank + item.cashAlt,
                          context: context,
                        ),
                      ),
                      Icon(
                        size: 14,
                        color: Colors.grey.shade500,
                        Icons.arrow_forward_ios_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
      DataRow2(
        specificRowHeight: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.grey.shade300,
        ),
        cells: [
          DataCell(
            Text(style: TextStyle(fontSize: 14), 'TOTAL'),
          ),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text("")),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowTotalTotalPaid(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowTotalTotalBalance(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowTotalTotalCostPrice(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 16),
              formatMoneyBig(
                amount: rowTotalTotalRevenue(),
                context: context,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  rowStaffsTotalQuantity() {
    return groupInvoicesByStaff()
        .map((item) => item.number)
        .toList()
        .fold(0, (p, n) => p + n);
  }

  rowStaffsTotalPaid() {
    return groupInvoicesByStaff()
        .map((item) => item.totalPaid)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowStaffsTotalBalance() {
    return groupInvoicesByStaff()
        .map((item) => item.totalBalance)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowStaffsTotalCostPrice() {
    return groupInvoicesByStaff()
        .map((item) => item.totalOriginalCost)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowStaffsTotalRevenue() {
    return groupInvoicesByStaff()
        .map((item) => item.totalRevenue)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  List<DataRow> _rowStaffs({
    required BuildContext context,
  }) {
    return [
      ...groupInvoicesByStaff().map((item) {
        return DataRow2(
          specificRowHeight:
              (item.staffName ?? '').length > 15 ? 40 : 30,
          cells: [
            DataCell(Text(item.staffName ?? 'Not Set')),
            DataCell(
              Text(formatLargeNumberDouble(item.number)),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalPaid,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalBalance,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalOriginalCost,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalRevenue,
                  context: context,
                ),
              ),
            ),
          ],
        );
      }),
      DataRow2(
        specificRowHeight: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.grey.shade300,
        ),
        cells: [
          DataCell(
            Text(style: TextStyle(fontSize: 14), 'TOTAL'),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatLargeNumberDouble(
                rowStaffsTotalQuantity(),
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowStaffsTotalPaid(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowStaffsTotalBalance(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowStaffsTotalCostPrice(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowStaffsTotalRevenue(),
                context: context,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  rowCustomersTotalQuantity() {
    return groupInvoicesByCustomer()
        .map((item) => item.number)
        .toList()
        .fold(0, (p, n) => p + n);
  }

  rowCustomersTotalPaid() {
    return groupInvoicesByCustomer()
        .map((item) => item.totalPaid)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowCustomersTotalBalance() {
    return groupInvoicesByCustomer()
        .map((item) => item.totalBalance)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowCustomersTotalCostPrice() {
    return groupInvoicesByCustomer()
        .map((item) => item.totalOriginalCost)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowCustomersTotalRevenue() {
    return groupInvoicesByCustomer()
        .map((item) => item.totalRevenue)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  List<DataRow> _rowCustomers({
    required BuildContext context,
  }) {
    return [
      ...groupInvoicesByCustomer().map((item) {
        return DataRow2(
          specificRowHeight:
              (item.customerName ?? '').length > 15
                  ? 40
                  : 30,
          cells: [
            DataCell(Text(item.customerName ?? 'Not Set')),
            DataCell(
              Text(formatLargeNumberDouble(item.number)),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalPaid,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalBalance,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalOriginalCost,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalRevenue,
                  context: context,
                ),
              ),
            ),
          ],
        );
      }),
      DataRow2(
        specificRowHeight: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.grey.shade300,
        ),
        cells: [
          DataCell(
            Text(style: TextStyle(fontSize: 14), 'TOTAL'),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatLargeNumberDouble(
                rowCustomersTotalQuantity(),
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowCustomersTotalPaid(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowCustomersTotalBalance(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowCustomersTotalCostPrice(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 16),
              formatMoneyBig(
                amount: rowCustomersTotalRevenue(),
                context: context,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  rowChannelTotalQuantity() {
    return groupInvoicesByPaymentChannel()
        .map((item) => item.number)
        .toList()
        .fold(0, (p, n) => p + n);
  }

  rowChannelTotalPaid() {
    return groupInvoicesByPaymentChannel()
        .map((item) => item.totalPaid)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowChannelTotalBalance() {
    return groupInvoicesByPaymentChannel()
        .map((item) => item.totalBalance)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowChannelTotalCostPrice() {
    return groupInvoicesByPaymentChannel()
        .map((item) => item.totalOriginalCost)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowChannelTotalRevenue() {
    return groupInvoicesByPaymentChannel()
        .map((item) => item.totalRevenue)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  List<DataRow> _rowChannel({
    required BuildContext context,
  }) {
    return [
      ...groupInvoicesByPaymentChannel().map((item) {
        return DataRow2(
          specificRowHeight: 30,
          cells: [
            DataCell(Text(item.paymentMethod)),
            DataCell(
              Text(formatLargeNumberDouble(item.number)),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalPaid,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalBalance,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalOriginalCost,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                spacing: 5,
                children: [
                  Text(
                    formatMoneyBig(
                      amount: item.totalRevenue,
                      context: context,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      DataRow2(
        specificRowHeight: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.grey.shade300,
        ),
        cells: [
          DataCell(
            Text(style: TextStyle(fontSize: 14), 'TOTAL'),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatLargeNumberDouble(
                rowChannelTotalQuantity(),
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowChannelTotalPaid(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowChannelTotalBalance(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowChannelTotalCostPrice(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 16),
              formatMoneyBig(
                amount: rowChannelTotalRevenue(),
                context: context,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  rowDepartmentsTotalQuantity() {
    return groupInvoicesByDepartment()
        .map((item) => item.number)
        .toList()
        .fold(0, (p, n) => p + n);
  }

  rowDepartmentsTotalPaid() {
    return groupInvoicesByDepartment()
        .map((item) => item.totalPaid)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowDepartmentsTotalBalance() {
    return groupInvoicesByDepartment()
        .map((item) => item.totalBalance)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowDepartmentsTotalCostPrice() {
    return groupInvoicesByDepartment()
        .map((item) => item.totalOriginalCost)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowDepartmentsTotalRevenue() {
    return groupInvoicesByDepartment()
        .map((item) => item.totalRevenue)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  List<DataRow> _rowDepartment({
    required BuildContext context,
  }) {
    return [
      ...groupInvoicesByDepartment().map((item) {
        return DataRow2(
          specificRowHeight: 30,
          cells: [
            DataCell(
              Text(item.departmentName ?? 'Not Set'),
            ),
            DataCell(
              Text(formatLargeNumberDouble(item.number)),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalPaid,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalBalance,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalOriginalCost,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                spacing: 5,
                children: [
                  Text(
                    formatMoneyBig(
                      amount: item.totalRevenue,
                      context: context,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      DataRow2(
        specificRowHeight: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.grey.shade300,
        ),
        cells: [
          DataCell(
            Text(style: TextStyle(fontSize: 14), 'TOTAL'),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatLargeNumberDouble(
                rowDepartmentsTotalQuantity(),
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowDepartmentsTotalPaid(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowDepartmentsTotalBalance(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowDepartmentsTotalCostPrice(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 16),
              formatMoneyBig(
                amount: rowDepartmentsTotalRevenue(),
                context: context,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<DataRow> row({
    required int sortIndex,
    required BuildContext context,
  }) {
    if (sortIndex == 1) {
      return _rowTotal(context: context, index: 1);
    } else if (sortIndex == 2) {
      return _rowTotal(context: context, index: 2);
    } else if (sortIndex == 3) {
      return _rowTotal(context: context, index: 3);
    } else if (sortIndex == 4) {
      return _rowStaffs(context: context);
    } else if (sortIndex == 5) {
      return _rowCustomers(context: context);
    } else if (sortIndex == 6) {
      return _rowChannel(context: context);
    } else {
      return _rowDepartment(context: context);
    }
  }

  List<DataColumn> heading({
    required int sortIndex,
    required BuildContext context,
  }) {
    if (sortIndex == 1 ||
        sortIndex == 2 ||
        sortIndex == 3) {
      return _headingTotal(context: context);
    } else if (sortIndex == 4) {
      return _headingStaffs();
    } else if (sortIndex == 5) {
      return _headingCustomers();
    } else if (sortIndex == 6) {
      return _headingChannel();
    } else {
      return _headingDepartments();
    }
  }
}
