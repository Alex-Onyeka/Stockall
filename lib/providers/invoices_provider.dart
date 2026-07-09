import 'package:flutter/material.dart';
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
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
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
    print(
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
    print('Invoices Cleared');
    notifyListeners();
  }

  bool isLoaded = false;
  void load(bool value) {
    isLoaded = value;
    print(
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
    print('Inner Invoice Creation Started');
    // bool isOnline = await connectivity.isOnline();
    // if (isOnline) {
    //   print('Inner Invoice Online Started');
    //   final res =
    //       await supabase
    //           .from('invoices')
    //           .upsert(
    //             invoice.toJson(),
    //             onConflict: 'invoice_uuid',
    //           )
    //           .select()
    //           .single();

    //   print('Inner Invoice Online Finished');
    //   print('Casting Started');
    //   try {
    //     final newInvoice = TempInvoice.fromJson(res);
    //     await InvoicesFunc().createInvoices(newInvoice);
    //     notifyListeners();
    //     return newInvoice;
    //   } catch (e) {
    //     print('❌❌ Create Invoice Error: ${e.toString()}');
    //     return null;
    //   }
    // } else {
    var barcode = returnOnlyDigits(uuidGen());
    invoice.barcode = barcode;
    // invoice.createdAt = DateTime.now();
    await InvoicesFunc().createInvoices(invoice);
    await CreatedInvoicesFunc().createInvoice(
      CreatedInvoices(invoice: invoice),
    );
    notifyListeners();
    return invoice;
    // }
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
          print('Invoice Not Found');
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
            print('Invoice Exists');
            invoicesMain.remove(existingInvoice);
          }
          invoicesMain.add(tempInvoice);
          invoicesMain.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          );
          print("💖💖👏🥰 Single Invoice Loaded");
          notifyListeners();
        }
      }
    } catch (e) {
      print(
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
          print('Invoices Gotten ${data.length}');
        }

        _invoices =
            (data as List)
                .map((json) => TempInvoice.fromJson(json))
                .toList();
        notifyListeners();
        await InvoicesFunc().insertAllInvoices(_invoices);
        notifyListeners();
        print('Invoices Loaded');
      } catch (e) {
        print('❌❌Error Getting Invoices: ${e.toString()}');
        return [];
      }
    } else {
      _invoices = InvoicesFunc().getInvoices();
      notifyListeners();
      print('Offline Invoices Gotten');
    }
    notifyListeners();
    return _invoices;
  }

  Future<List<TempInvoice>> loadInvoicesOffline(
    int shopId,
  ) async {
    _invoices = InvoicesFunc().getInvoices();
    notifyListeners();
    print('Offline Invoices Gotten');
    notifyListeners();
    return _invoices;
  }

  Future<int> updateInvoice({
    required TempInvoice invoice,
    required List<TempProductSaleRecord> records,
  }) async {
    // bool isOnline = await connectivity.isOnline();
    invoice.updatedAt = DateTime.now();
    try {
      // if (isOnline) {
      //   Map<String, dynamic>? res =
      //       await supabase
      //           .from('invoices')
      //           .update(invoice.toJson())
      //           .eq('invoice_uuid', invoice.uuid!)
      //           .select()
      //           .maybeSingle();

      //   if (res != null) {
      //     print('Invoice Update Successfull');
      //     await returnEventsLogProvider().createLog(
      //       returnEventsLogProvider(
      //         // ignore: use_build_context_synchronously
      //       ).invoiceAdapter(
      //         invoice,
      //         records
      //             .map((rec) => rec.productName)
      //             .toList(),
      //         2,
      //       ),
      //       // ignore: use_build_context_synchronously
      //     );
      //     notifyListeners();
      //     return 1;
      //   } else {
      //     print('Invoice Update Failed');
      //     notifyListeners();
      //     return 0;
      //   }
      // } else {
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
      // }
    } catch (e) {
      print('Error Updating Invoices: ${e.toString()}');
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
      print('Deleting Invoices Offline');
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

      print(
        '✅ Invoice and inventory successfully Delete and Updated.',
      );

      await loadInvoicesOffline(
        returnShopProvider().userShop()!.shopId!,
      );

      print('Totally Finished Deleting Invoices');
      notifyListeners();
      syncData();
      return 1;
    } catch (e) {
      print('Error Deleting Invoice: ${e.toString()}');
      return 0;
    }
  }

  // DELETE an Invoice Without Updating Inventory
  Future<int> deleteInvoiceWithoutUpdatingInventory(
    String uuid,
  ) async {
    try {
      print('Deleting Invoice Offline');
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

      print(
        '✅ Invoice and inventory successfully Delete and Updated.',
      );

      await loadInvoicesOffline(
        returnShopProvider().userShop()!.shopId!,
      );

      print('Totally Finished Deleting Invoice');
      notifyListeners();
      syncData();
      return 1;
    } catch (e) {
      print(
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

      print('Checkout Started');
      var res = await returnReceiptProviderSingle()
          .createReceipt(receipt);
      if (res != null) {
        print('Receipt Created');

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
              print('Sales Record about to be Created');
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

        print('Creating Record Sales About to Start');
        await returnReceiptProviderSingle()
            .createProductSaleRecord(
              records: productSaleRecords,
              isPartPayment: true,
            );
        print('Sales Record Inserted');
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
        print(
          'Context is Not Mounted So Offline Data Cannot Be Synchronized',
        );
        notifyListeners();
        return 1;
      } else {
        print('Failed to Create Receipt From Invoice');
        return 0;
      }
    } catch (e) {
      print(
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
          groupUnit: 'Others',
          storageUuid: null,
          qttyPerGroup: null,
          name: record.productName,
          unit: record.unit ?? 'Others',
          isRefundable: false,
          costPrice: costPrice,
          shopId: record.shopId,
          setCustomPrice: true,
          isManaged: false,
          barcode: null,
          brand: null,
          categoryUuid: null,
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

  List<TempInvoice> returnUnpaidInvoices() {
    return returnInvoicesByDayOrWeekAll()
        .where((inv) => getBalance(invoice: inv) != 0)
        .toList();
  }

  List<TempInvoice> returnInvoicesBasedOnPaymentMethod() {
    if (rangeStartDate != null) {
      return departmentInvoices().where((invoice) {
        final created = invoice.createdAt.toLocal();
        return !created.isBefore(fourAm(rangeStartDate!)) &&
            !created.isAfter(
              fourAmNextDay(rangeEndDate ?? DateTime.now()),
            );
      }).toList();
    }

    if (dateSet != null) {
      return departmentInvoices().where((invoice) {
        final created = invoice.createdAt.toLocal();
        final inRange =
            !created.isBefore(fourAm(dateSet!)) &&
            !created.isAfter(fourAmNextDay(dateSet!));

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

        print('$count items added successfully ✅');
        print('Unsynced Invoices Cleared');
        print('Mounted, refreshing Invoices ✅');
        await loadInvoices(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      print('Batch Invoices insert failed ❌: $e');
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

  Future<void> deleteInvoicesSync(
    // BuildContext context,
  ) async {
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
              'delete_invoice_and_update_inventory_new',
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

        print(
          '${tempInvoice.length} Invoices Created successfully ✅',
        );
        await DeletedInvoicesFunc().clearDeletedInvoices();
        print('Unsynced Deleted Invoices Cleared');
        print('Mounted, refreshing Invoices ✅');
        await loadInvoices(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      print('Batch Invoices Deleted failed ❌: $e');
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
      print(
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
            print('Local Invoices Uuid is Null');
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
            print(
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
            print(
              "Local updatedAt: ${localInvoices.updatedAt}",
            );
            print("Remote updatedAt: $remoteUpdatedAt");

            if (remoteUpdatedAt == null ||
                localInvoices.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from('invoices')
                  .update(localInvoices.toJson())
                  .eq('invoice_uuid', localInvoices.uuid!);
              print(
                'Updated Invoices with uuid ${localInvoices.uuid}',
              );
              await UpdatedInvoicesFunc()
                  .deleteUpdatedInvoice(
                    localInvoices.uuid ?? '',
                  );
            } else {
              print(
                'Skipped Invoices ${localInvoices.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedInvoicesFunc()
            .clearupdatedInvoiceUpdatedInvoices();
        print('Unsynced updated Invoices cleared');
        print('Mounted, refreshing Invoices ✅');
        await loadInvoices(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      print('Batch Invoices update failed ❌: $e');
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
}
