import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockall/classes/temp_inventory_updates/temp_inventory_update_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/unsynced/created_products/created_products.dart';
import 'package:stockall/classes/temp_product_class/unsynced/deleted_products/deleted_products.dart';
import 'package:stockall/classes/temp_product_class/unsynced/updated/updated_products.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/created/created_customers_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/deleted/deleted_customers_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/updated/updated_customers_func.dart';
import 'package:stockall/local_database/department_func/unsync_funcs/created_departments/created_departments_func.dart';
import 'package:stockall/local_database/department_func/unsync_funcs/deleted_department/deleted_departments_func.dart';
import 'package:stockall/local_database/department_func/unsync_funcs/updated_department/updated_department_func.dart';
import 'package:stockall/local_database/events_log/unsync_funcs/created_events_log_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/created_expenses/created_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/deleted_expenses/deleted_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/updated_expenses/updated_expenses_func.dart';
import 'package:stockall/local_database/inventory_updates/unsync_funcs/created_inventory_updates_func.dart';
import 'package:stockall/local_database/invoices/unsync_funcs/created/created_invoices_func.dart';
import 'package:stockall/local_database/invoices/unsync_funcs/deleted/deleted_invoices_func.dart';
import 'package:stockall/local_database/invoices/unsync_funcs/updated/updated_invoices_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/created/created_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/deleted/deleted_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/updated/updated_receipts_func.dart';
import 'package:stockall/local_database/product_record_func.dart/unsync_funcs/created/created_records_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/created_products%20copy/sales_product_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/created_products/created_product_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/deleted_products/deleted_products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/updated_products/updated_products_func.dart';
import 'package:stockall/local_database/shop/updated_shop/updated_shop_func.dart';
import 'package:stockall/local_database/shop_logos/created_shop_logo/created_shop_logos_func.dart';
import 'package:stockall/local_database/sub_staff/unsync_funcs/created/created_sub_staff_func.dart';
import 'package:stockall/local_database/sub_staff/unsync_funcs/deleted/deleted_sub_staff_func.dart';
import 'package:stockall/local_database/sub_staff/unsync_funcs/updated/updated_sub_staff_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/department_provider.dart';
import 'package:stockall/providers/invoices_provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class DataProvider extends ChangeNotifier {
  static final DataProvider _instance =
      DataProvider._internal();
  factory DataProvider() => _instance;
  DataProvider._internal();
  // final TextEditingController searchController =
  //     TextEditingController();
  final FocusNode searchNode = FocusNode();

  void keepNodeFocus() {
    if (!searchNode.hasFocus) {
      searchNode.requestFocus();
    }
  }

  void addSearchNodeListener() {
    searchNode.addListener(keepNodeFocus);
    notifyListeners();
  }

  Timer? timer;

  void removeSearchNodeListener() {
    timer = Timer.periodic(Duration(microseconds: 10), (
      timer,
    ) {
      if (searchNode.hasFocus) {
        searchNode.removeListener(keepNodeFocus);
        unFocusSearchNode();
        print('Search Node has Listners');
      } else {
        timer.cancel();
        print('Search Node Does not have Listners');
        notifyListeners();
      }
    });
  }

  void requestFocusSearchNode() {
    searchNode.requestFocus();
    notifyListeners();
  }

  void unFocusSearchNode() {
    searchNode.unfocus();
    notifyListeners();
  }

  // void clearsearchTextField() {
  //   searchController.clear();
  // }

  // Timer? timer;
  // void startBarcodeTimer() {
  //   cancelBarcodeTimer();
  //   keepNodeFocus();
  //   timer = Timer.periodic(Duration(seconds: 2), (timer) {
  //     keepNodeFocus();
  //   });
  //   print('Timer Started');
  // }

  // void cancelBarcodeTimer() {
  //   timer?.cancel();
  //   print('Timer Cancelled');
  // }

  bool isLoading = false;
  ConnectivityProvider connectivity =
      ConnectivityProvider();

  void toggleIsLoading(bool value) {
    isLoading = value;
    print('Loading: ${value.toString()}');
    notifyListeners();
  }

  final supabase = Supabase.instance.client;

  Future<void> createProduct(
    TempProductClass product,
    BuildContext context,
  ) async {
    // var data =
    bool isOnline = await connectivity.isOnline();

    // product.uuid = uuidGen();
    product.updatedAt = DateTime.now();

    if (isOnline) {
      var data =
          await supabase
              .from('products')
              .upsert(product.toJson(), onConflict: 'uuid')
              .select()
              .single();
      print('Item added successfully');
      final newProduct = TempProductClass.fromJson(data);
      await ProductsFunc().createProduct(newProduct);
      await returnEventsLogProvider().createLog(
        returnEventsLogProvider(
          // ignore: use_build_context_synchronously
        ).productAdapter(product, 1),
        // ignore: use_build_context_synchronously
      );
      print('Total Success');
    } else {
      product.createdAt ??= DateTime.now();

      await ProductsFunc().createProduct(product);
      await CreatedProductFunc().createProduct(
        CreatedProducts(product: product),
      );
      await returnEventsLogProvider().createLog(
        returnEventsLogProvider(
          // ignore: use_build_context_synchronously
        ).productAdapter(product, 1),
        // ignore: use_build_context_synchronously
      );
      print('Offline Success');
      print('Offline Product inserted Successfully');
    }

    // productList.add(newProduct);
    if (context.mounted) {
      print('Mounted');
      await getProducts(
        returnShopProvider().userShop()!.shopId!,
      );
    }

    clearFields();
  }

  Future<void> createProductsSync(
    BuildContext context,
  ) async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedProductFunc().getProducts().isNotEmpty &&
          isOnline) {
        final tempProducts =
            CreatedProductFunc().getProducts().toList();
        final payload =
            tempProducts
                .map((p) => p.product.toJson())
                .toList();

        // Insert all at once
        final data =
            await supabase
                .from('products')
                .insert(payload)
                .select();

        print('${data.length} items added successfully ✅');
        await CreatedProductFunc().clearProducts();
        print('Unsynced Products Cleared');
      }
    } catch (e) {
      print('Batch insert failed ❌: $e');
    }

    if (context.mounted) {
      print('Mounted, refreshing products ✅');
      await getProducts(
        returnShopProvider().userShop()!.shopId!,
      );
    }

    clearFields();
  }

  Future<void> deleteProductsSync(
    BuildContext context,
  ) async {
    try {
      bool isOnline = await connectivity.isOnline();

      if (DeletedProductsFunc()
              .getProductIds()
              .isNotEmpty &&
          isOnline) {
        final uuids =
            DeletedProductsFunc()
                .getProductIds()
                .map((p) => p.productUuid)
                .toList();

        final data =
            await supabase
                .from('products')
                .delete()
                .inFilter(
                  'uuid',
                  uuids,
                ) // delete where id is in the list
                .select();

        print(
          '${data.length} items deleted successfully ✅',
        );

        await DeletedProductsFunc().clearDeletedProducts();
        print('Unsynced deleted products cleared');
      }
    } catch (e) {
      print('Batch delete failed ❌: $e');
    }

    if (context.mounted) {
      print('Mounted, refreshing products ✅');
      await getProducts(
        returnShopProvider().userShop()!.shopId!,
      );
    }

    clearFields();
  }

  Future<void> updateProductsSync(
    BuildContext context,
  ) async {
    try {
      bool isOnline = await connectivity.isOnline();
      print(
        UpdatedProductsFunc()
            .getProducts()
            .length
            .toString(),
      );

      if (UpdatedProductsFunc().getProducts().isNotEmpty &&
          isOnline) {
        final updatedProducts =
            UpdatedProductsFunc().getProducts();

        for (final updated in updatedProducts) {
          final localProduct = updated.product;

          localProduct.updatedAt ??=
              DateTime.now().toLocal();

          if (localProduct.uuid == null) {
            print('Local Product Uuid is Null');
          }
          final remoteData =
              await supabase
                  .from('products')
                  .select('uuid, updated_at')
                  .eq('uuid', localProduct.uuid!)
                  .maybeSingle();

          if (remoteData == null) {
            await supabase
                .from('products')
                .insert(localProduct.toJson());
            print(
              'Inserted product with uuid ${localProduct.uuid}',
            );
            await UpdatedProductsFunc()
                .deleteUpdatedProduct(
                  localProduct.uuid ?? '',
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

            localProduct.updatedAt =
                (localProduct.updatedAt ?? DateTime.now())
                    .toUtc(); // ✅ keep both UTC
            print(
              "Local updatedAt: ${localProduct.updatedAt}",
            );
            print("Remote updatedAt: $remoteUpdatedAt");

            if (remoteUpdatedAt == null ||
                localProduct.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from('products')
                  .update(localProduct.toJson())
                  .eq('uuid', localProduct.uuid!);
              print(
                'Updated product with uuid ${localProduct.uuid}',
              );
              await UpdatedProductsFunc()
                  .deleteUpdatedProduct(
                    localProduct.uuid ?? '',
                  );
            } else {
              print(
                'Skipped product ${localProduct.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedProductsFunc().clearupdatedProducts();
        print('Unsynced updated products cleared');
      }
    } catch (e) {
      print('Batch update failed ❌: $e');
    }

    if (context.mounted) {
      print('Mounted, refreshing products ✅');
      await getProducts(
        returnShopProvider().userShop()!.shopId!,
      );
    }

    clearFields();
  }

  //
  //
  //
  //
  //
  //
  Future<void> salesProductsSync(
    BuildContext context,
  ) async {
    try {
      bool isOnline = await connectivity.isOnline();
      print(
        SalesProductFunc().getProducts().length.toString(),
      );

      if (SalesProductFunc().getProducts().isNotEmpty &&
          isOnline) {
        final salesProducts =
            SalesProductFunc().getProducts();

        for (final salesProduct in salesProducts) {
          await supabase.rpc(
            'decrement_product_quantity_during_sync',
            params: {
              'p_uuid': salesProduct.productUuid,
              'p_qty': salesProduct.quantity.toInt(),
            },
          );

          print(
            'Decremented ${salesProduct.quantity} from product ${salesProduct.productUuid}',
          );

          await SalesProductFunc().deleteProduct(
            salesProduct.productUuid,
          );
        }
      }
    } catch (e) {
      print('Batch update failed ❌: $e');
    }

    if (context.mounted) {
      print('Mounted, refreshing products ✅');
      await getProducts(
        returnShopProvider().userShop()!.shopId!,
      );
    }

    clearFields();
  }

  //
  //
  //
  //
  //
  //

  Future<void> syncData(BuildContext context) async {
    int isSynced = returnData().isSynced();
    List<TempShopClass> shop =
        await returnShopProvider().getUserShops();
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      if (shop.isNotEmpty) {
        if (context.mounted) {
          if (isSynced == 0) {
            toggleSyncing(true);
            if (CreatedProductFunc()
                    .getProducts()
                    .isNotEmpty &&
                isOnline) {
              await createProductsSync(context);
              print('Finished Syncing Created Products');
              setSyncProgress(1);
            }
            if (DeletedProductsFunc()
                    .getProductIds()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await deleteProductsSync(context);
              print('Finished Syncing Deleted Products');
              setSyncProgress(2);
            }
            if (UpdatedProductsFunc()
                    .getProducts()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await updateProductsSync(context);
              print('Finished Syncing Updated Products');
              setSyncProgress(3);
            }
            if (SalesProductFunc()
                    .getProducts()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await salesProductsSync(context);
              print('Finished Syncing Sales Products');
              setSyncProgress(4);
            }
            if (CreatedExpensesFunc()
                    .getExpenses()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await returnExpensesProvider(
                context,
                listen: false,
              ).createExpensesSync(context);
              print('Finished Syncing Created Expenses');
              setSyncProgress(5);
            }
            if (UpdatedExpensesFunc()
                    .getExpenses()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await returnExpensesProvider(
                context,
                listen: false,
              ).updateExpensesSync(context);
              print('Finished Syncing Updated Expenses');
              setSyncProgress(6);
            }
            if (DeletedExpensesFunc()
                    .getExpenseIds()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await returnExpensesProvider(
                context,
                listen: false,
              ).deleteExpensesSync(context);
              print('Finished Syncing Deleted Expenses');
              setSyncProgress(7);
            }
            if (CreatedCustomersFunc()
                    .getCustomers()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await returnCustomers(
                context,
                listen: false,
              ).createCustomersSync(context);
              print('Finished Syncing Created Customer');
              setSyncProgress(8);
            }
            if (UpdatedCustomersFunc()
                    .getCustomers()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await returnCustomers(
                context,
                listen: false,
              ).updateCustomersSync(context);
              print('Finished Syncing Updated Customers');
              setSyncProgress(9);
            }
            if (DeletedCustomersFunc()
                    .getCustomerIds()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await returnCustomers(
                context,
                listen: false,
              ).deletedCustomersSync(context);
              print('Finished Syncing Deleted Customers');
              setSyncProgress(10);
            }
            if (CreatedReceiptsFunc()
                    .getReceipts()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              print(
                'Finished Syncing Products Decrementiation',
              );
              setSyncProgress(11);
            }
            if (DeletedReceiptsFunc()
                    .getReceiptIds()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await returnReceiptProvider(
                context,
                listen: false,
              ).deleteReceiptsSync(context);
              print('Finished Syncing Created Receipts');
              setSyncProgress(12);
            }

            if (CreatedReceiptsFunc()
                    .getReceipts()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await returnReceiptProvider(
                context,
                listen: false,
              ).createRecordsSync(context);
              print(
                'Finished Syncing Created Records Customers',
              );
              setSyncProgress(13);
            }
            if (CreatedReceiptsFunc()
                    .getReceipts()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await returnReceiptProvider(
                context,
                listen: false,
              ).createReceiptsSync(context);
              print('Finished Syncing Created Receipts');
              setSyncProgress(14);
            }

            if (UpdatedReceiptsFunc()
                    .getReceiptIds()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await returnReceiptProvider(
                context,
                listen: false,
              ).updateReceiptsSync(context);
              print('Finished Syncing Created Receipts');
              setSyncProgress(15);
            }
            if (UpdatedShopFunc()
                    .getUpdatedShop()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await returnShopProvider().updateShopSync(
                context,
              );
              print('Finished Syncing Created Receipts');
              setSyncProgress(16);
            }
            if (CreatedShopLogosFunc().getCreatedLogo() !=
                    null &&
                context.mounted &&
                isOnline) {
              await returnShopProvider().uploadShopLogoSync(
                context,
              );
              print('Finished Syncing Created Logo');
              setSyncProgress(17);
            }
            if (CreatedEventsLogFunc()
                    .getCreatedEventsLogs()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await returnEventsLogProvider().eventsLogSync(
                context,
              );
              print('Finished Syncing Created Events Log');
              setSyncProgress(18);
            }

            if (CreatedDepartmentsFunc()
                    .getDepartment()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await DepartmentProvider()
                  .createDepartmentsSync();
              print('Finished Syncing Created Departments');
              setSyncProgress(19);
            }
            if (UpdatedDepartmentFunc()
                    .getDepartments()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await DepartmentProvider()
                  .updateDepartmentsSync();
              print('Finished Syncing Updated Departments');
              setSyncProgress(20);
            }
            if (DeletedDepartmentsFunc()
                    .getDepartmentIds()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await DepartmentProvider()
                  .deleteDepartmentsSync();
              print('Finished Syncing Deleted Departments');
              setSyncProgress(21);
            }
            if (CreatedInvoicesFunc()
                    .getInvoices()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await returnInvoicesProvider()
                  .createInvoicesSync();
              print('Finished Syncing Created Invoices');
              setSyncProgress(22);
            }
            if (UpdatedInvoicesFunc()
                    .getInvoiceIds()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await InvoicesProvider().updateInvoicesSync();
              print('Finished Syncing Updated Invoices');
              setSyncProgress(23);
            }
            if (DeletedInvoicesFunc()
                    .getInvoiceIds()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await InvoicesProvider().deleteInvoicesSync();
              print('Finished Syncing Deleted Invoices');
              setSyncProgress(24);
            }
            if (CreatedInventoryUpdatesFunc()
                    .getCreatedInventoryUpdatess()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await returnInventoryUpdatesProvider()
                  .inventoryUpdatesSync();
              print('Finished Syncing Inventory Updates');
              setSyncProgress(25);
            }
            if (CreatedSubStaffFunc()
                    .getSubStaffs()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await returnSubStaffProvider()
                  .createSubStaffSync();
              print('Finished Syncing Created Sub Staffs');
              setSyncProgress(26);
            }
            if (UpdatedSubStaffFunc()
                    .getSubStaffs()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await returnSubStaffProvider()
                  .updateSubStaffSync();
              print('Finished Syncing Updated Sub Staffs');
              setSyncProgress(27);
            }
            if (DeletedSubStaffFunc()
                    .getSubStaffIds()
                    .isNotEmpty &&
                context.mounted &&
                isOnline) {
              await returnSubStaffProvider()
                  .deleteSubStaffSync();
              print('Finished Syncing Deleted Sub Staffs');
              setSyncProgress(28);
            }
            await clearTotalCache();
            toggleSyncing(false);
          }
        }
      } else {
        // await ShopFunc().clearShop();
        if (context.mounted) {
          returnNavProvider(
            context,
            listen: false,
          ).nullShop(
            logoutAction:
                () => returnNavProvider(
                  context,
                  listen: false,
                ).navPush(context),
          );
        }
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return InfoAlert(
              title: 'Syncing Error',
              message:
                  'You have to turn on your data to sync.',
              theme: returnTheme(context, listen: false),
              action: () {
                // Navigator.of(context).pop();
              },
            );
          },
        );
      }
    }
  }

  //
  //
  //
  //
  bool isSyncing = false;
  double syncProgress = 0;
  void setSyncProgress(int value) {
    syncProgress = (value / 28) * 100;
    notifyListeners();
  }

  bool isRefreshing = false;
  void toggleRefreshing(bool value) {
    isRefreshing = value;
    notifyListeners();
  }

  void toggleSyncing(bool value) {
    isSyncing = value;
    notifyListeners();
  }

  int isSynced() {
    if (isSyncing) {
      return 2;
    } else {
      if (CreatedProductFunc().getProducts().isEmpty &&
          DeletedProductsFunc().getProductIds().isEmpty &&
          UpdatedProductsFunc().getProducts().isEmpty &&
          CreatedInventoryUpdatesFunc()
              .getCreatedInventoryUpdatess()
              .isEmpty &&
          SalesProductFunc().getProducts().isEmpty &&
          CreatedExpensesFunc().getExpenses().isEmpty &&
          DeletedExpensesFunc().getExpenseIds().isEmpty &&
          UpdatedExpensesFunc().getExpenses().isEmpty &&
          CreatedCustomersFunc().getCustomers().isEmpty &&
          UpdatedCustomersFunc().getCustomers().isEmpty &&
          DeletedCustomersFunc().getCustomerIds().isEmpty &&
          CreatedReceiptsFunc().getReceipts().isEmpty &&
          CreatedRecordsFunc().getRecords().isEmpty &&
          DeletedReceiptsFunc().getReceiptIds().isEmpty &&
          UpdatedReceiptsFunc().getReceiptIds().isEmpty &&
          UpdatedShopFunc().getUpdatedShop().isEmpty &&
          CreatedShopLogosFunc().getCreatedLogo() == null &&
          CreatedEventsLogFunc()
              .getCreatedEventsLogs()
              .isEmpty &&
          CreatedDepartmentsFunc()
              .getDepartment()
              .isEmpty &&
          UpdatedDepartmentFunc()
              .getDepartments()
              .isEmpty &&
          DeletedDepartmentsFunc()
              .getDepartmentIds()
              .isEmpty &&
          CreatedInvoicesFunc().getInvoices().isEmpty &&
          UpdatedInvoicesFunc().getInvoiceIds().isEmpty &&
          DeletedInvoicesFunc().getInvoiceIds().isEmpty &&
          CreatedSubStaffFunc().getSubStaffs().isEmpty &&
          UpdatedSubStaffFunc().getSubStaffs().isEmpty &&
          DeletedSubStaffFunc().getSubStaffIds().isEmpty
      // && DeletedRecordsFunc().getRecordIds().isEmpty &&
      // IncrementedProductsFunc()
      //     .getIncrementedProducts()
      //     .isEmpty
      ) {
        return 1;
      } else {
        return 0;
      }
    }
  }

  Future<void> clearTotalCache() async {
    await CreatedCustomersFunc().clearCustomers();
    await UpdatedCustomersFunc().clearupdatedCustomers();
    await DeletedCustomersFunc().clearDeletedCustomers();
    await CreatedExpensesFunc().clearExpenses();
    await UpdatedExpensesFunc().clearupdatedExpenses();
    await DeletedExpensesFunc().clearDeletedExpenses();
    await CreatedReceiptsFunc().clearReceipts();
    await CreatedRecordsFunc().clearRecords();
    await CreatedProductFunc().clearProducts();
    await UpdatedProductsFunc().clearupdatedProducts();
    await DeletedProductsFunc().clearDeletedProducts();
    await CreatedInventoryUpdatesFunc()
        .clearInventoryUpdate();
    await DeletedReceiptsFunc().clearDeletedReceipts();
    await SalesProductFunc().clearProducts();
    await SalesProductFunc().clearProducts();
    await UpdatedReceiptsFunc().clearUpdatedReceipts();
    await UpdatedShopFunc().clearUpdatedShop();
    await SalesProductFunc().clearProducts();
    await CreatedShopLogosFunc().clearCreatedLogos();
    await CreatedEventsLogFunc().clearEvents();
    await CreatedDepartmentsFunc().clearDepartment();
    await UpdatedDepartmentFunc().clearupdatedDepartments();
    await DeletedDepartmentsFunc()
        .clearDeletedDepartments();
    await CreatedSubStaffFunc().clearSubStaffs();
    await UpdatedSubStaffFunc().clearUpdatedSubStaff();
    await DeletedSubStaffFunc().clearDeletedSubStaff();
  }

  DateTime? expiryDate;
  void setExpDate(DateTime date) {
    expiryDate = date;
    notifyListeners();
  }

  void clearExpDate() {
    expiryDate = null;
    notifyListeners();
  }

  // bool isStartDate = true;

  // DateTime? startDate;
  // DateTime? endDate;

  // void changeDateBoolToTrue() {
  //   isStartDate = true;
  //   notifyListeners();
  // }

  // void clearStartDate() {
  //   startDate = null;
  //   notifyListeners();
  // }

  // void changeDateBoolToFalse() {
  //   isStartDate = false;
  //   notifyListeners();
  // }

  // void clearEndDate() {
  //   endDate = null;
  //   notifyListeners();
  // }

  // void setBothDates({
  //   DateTime? start,
  //   DateTime? end,
  //   DateTime? expDate,
  // }) {
  //   startDate = start;
  //   endDate = end;
  //   expiryDate = expDate;
  //   notifyListeners();
  // }

  // void setDate(DateTime date) {
  //   if (isStartDate) {
  //     startDate = date;
  //   } else {
  //     endDate = date;
  //   }
  //   notifyListeners();
  // }

  List<TempProductClass> productList = [];

  void clearProducts() {
    productList.clear();
    print('Products Cleared');
    notifyListeners();
  }

  int? allowedRangeItems;

  void setAllowedRange({
    int? plan,
    required BuildContext context,
  }) {
    allowedRangeItems =
        plan == 3
            ? null
            : subPlans
                .firstWhere((sub) => sub.plan == plan)
                .itemsAuth
                .numberOfItems;
    notifyListeners();
  }

  Future<List<TempProductClass>> getProducts(
    int shopId,
  ) async {
    bool isOnline = await connectivity.isOnline();
    print('✅✅ Products List Cleared');
    if (isOnline) {
      final data = await supabase
          .from('products')
          .select()
          .eq('shop_id', shopId)
          .order('name', ascending: true)
          .range(
            0,
            allowedRangeItems != null
                ? (allowedRangeItems ?? 0) - 1
                : 1000,
          );

      print('Items gotten: ${data.length}');

      productList =
          (data as List)
              .map(
                (json) => TempProductClass.fromJson(json),
              )
              .toList();
      productList.sort(
        (a, b) => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
      );
      print('Product List Set: ${productList.length}');
      if (data.length > 999) {
        final data2 = await supabase
            .from('products')
            .select()
            .eq('shop_id', shopId)
            .order('name', ascending: true)
            .range(
              1001,
              allowedRangeItems != null
                  ? (allowedRangeItems ?? 0) - 1
                  : 2000,
            );
        print('Items 2 gotten: ${data2.length}');
        productList.addAll(
          (data2 as List)
              .map(
                (stuff) => TempProductClass.fromJson(stuff),
              )
              .toList(),
        );
        productList.sort(
          (a, b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
        );
        print('Product List 2 Set: ${productList.length}');

        if (productList.length > 1999) {
          final data3 = await supabase
              .from('products')
              .select()
              .eq('shop_id', shopId)
              .order('name', ascending: true)
              .range(2001, allowedRangeItems ?? 3000);
          print('Items 3 gotten: ${data3.length}');
          productList.addAll(
            (data3 as List)
                .map(
                  (stuff) =>
                      TempProductClass.fromJson(stuff),
                )
                .toList(),
          );
          productList.sort(
            (a, b) => a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            ),
          );
          print(
            'Product List 3 Set: ${productList.length}',
          );
        }
        notifyListeners();
      }
      await returnInventoryUpdatesProvider()
          .getInventoryUpdates();

      await ProductsFunc().insertAllProducts(productList);
    } else {
      // int getRange() {
      //   if ((allowedRangeItems ?? 0) >
      //       ProductsFunc().getProducts().length) {
      //     return ProductsFunc().getProducts().length;
      //   } else {
      //     return (allowedRangeItems ?? 0);
      //   }
      // }

      // var offlineData =
      //     ProductsFunc()
      //         .getProducts()
      //         .getRange(0, getRange())
      //         .toList();
      print(
        "Offline Data Gotten: ${ProductsFunc().getProducts().length}",
      );
      productList = ProductsFunc().getProducts();
      await returnInventoryUpdatesProvider()
          .getInventoryUpdates();
      // productList.clear();
    }

    notifyListeners();
    return productList;
  }

  Future<List<TempProductClass>> searchProductName(
    BuildContext context,
    String name,
  ) async {
    var temp = await getProducts(shopId());
    final tempData =
        temp
            .where((product) => product.name.contains(name))
            .toList();

    return tempData;
  }

  Future<List<TempProductClass>> getLowProducts(
    int shopId,
  ) async {
    final data = await getProducts(shopId);

    final tempData = data.where(
      (product) =>
          product.quantity != null &&
          product.quantity! < product.lowQtty!,
    );

    return tempData.toList();
  }

  Future<TempProductClass?> updateProduct({
    required TempProductClass product,
    TempProductClass? oldProduct,
  }) async {
    bool isOnline = await connectivity.isOnline();

    try {
      print(product.isManaged.toString());
      if (isOnline) {
        product.updatedAt = DateTime.now().toLocal();
        var res =
            await supabase
                .from('products')
                .update(product.toJson())
                .eq('uuid', product.uuid!)
                .select()
                .maybeSingle();
        if (res != null) {
          print('${product.uuid}');
          await returnEventsLogProvider().createLog(
            returnEventsLogProvider().productAdapter(
              product,
              2,
            ),
          );
          if (oldProduct != null) {
            TempInventoryUpdateClass
            inventoryUpdate = TempInventoryUpdateClass(
              shopId: shopId(),
              title: 'title',
              createdAt: DateTime.now(),
              staffId: currentUser().userId,
              staffName:
                  "${currentUser().name} ${currentUser().lastName ?? ''}",
              uuid: uuidGen(),
              itemName: product.name,
              itemUuid: product.uuid,
            );
            if ((oldProduct.quantity ?? 0) !=
                (product.quantity ?? 0)) {
              inventoryUpdate.title =
                  'Item Sales Quantity Updated';
              inventoryUpdate.oldValue =
                  oldProduct.quantity?.toString();
              inventoryUpdate.newValue =
                  product.quantity?.toString();
            } else if ((oldProduct.totalQttyInStorage ??
                    0) !=
                (product.totalQttyInStorage ?? 0)) {
              inventoryUpdate.title =
                  'Item Storage Quantity Updated';
              inventoryUpdate.oldValue =
                  oldProduct.totalQttyInStorage?.toString();
              inventoryUpdate.newValue =
                  product.totalQttyInStorage?.toString();
            } else if (oldProduct.isManaged !=
                product.isManaged) {
              inventoryUpdate.title =
                  'Item Is-Managed Updated';
              if (product.isManaged) {
                inventoryUpdate.oldValue = 'Un-Managed';
                inventoryUpdate.newValue = 'Managed';
              } else {
                inventoryUpdate.newValue = 'Un-Managed';
                inventoryUpdate.oldValue = 'Managed';
              }
            } else if ((oldProduct.sellingPrice ?? 0) !=
                (product.sellingPrice ?? 0)) {
              inventoryUpdate.title =
                  'Item Selling Price Updated';
              inventoryUpdate.oldValue =
                  oldProduct.sellingPrice?.toString();
              inventoryUpdate.newValue =
                  product.sellingPrice?.toString();
            }
            await returnInventoryUpdatesProvider()
                .createInventoryUpdate(inventoryUpdate);
          }
          print('Context Mounted');
          await getProducts(
            returnShopProvider().userShop()!.shopId!,
          );
          notifyListeners();
          return TempProductClass.fromJson(res);
        } else {
          print('Product Update Failed');
          return null;
        }
      } else {
        var res = await ProductsFunc().updateProduct(
          product,
        );
        if (res == 1) {
          var containsCreated =
              CreatedProductFunc()
                  .getProducts()
                  .where(
                    (createdProduct) =>
                        createdProduct.product.uuid ==
                        product.uuid,
                  )
                  .toList();
          if (containsCreated.isEmpty) {
            await UpdatedProductsFunc()
                .createUpdatedProduct(
                  UpdatedProducts(product: product),
                );
          } else {
            await CreatedProductFunc().updateProduct(
              CreatedProducts(product: product),
            );
          }
          print(product.updatedAt.toString());
          print('${product.uuid}');
          await returnEventsLogProvider().createLog(
            returnEventsLogProvider(
              // ignore: use_build_context_synchronously
            ).productAdapter(product, 2),
            // ignore: use_build_context_synchronously
          );
          print('Context Mounted');
          await getProducts(
            returnShopProvider().userShop()!.shopId!,
          );
          notifyListeners();
          return ProductsFunc().getSingleProduct(
            uuid: product.uuid!,
          );
        } else {
          notifyListeners();
          return null;
        }
      }
    } catch (e) {
      notifyListeners();
      print("Error Updating Product: ${e.toString()}");
      return null;
    }
  }

  // Future<bool> updateQuantity({
  //   required int productId,
  //   required double? newQuantity,
  //   required BuildContext context,
  // }) async {
  //   final response =
  //       await supabase
  //           .from('products')
  //           .update({
  //             'quantity': newQuantity,
  //             'updated_at': DateTime.now(),
  //           })
  //           .eq('id', productId)
  //           .maybeSingle();
  //   if (context.mounted) {
  //     await getProducts(
  //       returnShopProvider(
  //         context,
  //         listen: false,
  //       ). userShop()!.shopId!,
  //     );
  //   }
  //   notifyListeners();
  //   return response != null;
  // }

  // Future<bool> updateDiscount({
  //   required TempProductClass product,
  //   required double? newDiscount,
  //   DateTime? statDate,
  //   DateTime? endDate,
  //   required BuildContext context,
  // }) async {
  //   final response =
  //       await supabase
  //           .from('products')
  //           .update({
  //             'discount': newDiscount,
  //             'starting_date':
  //                 startDate
  //                     ?.toIso8601String()
  //                     .split('T')
  //                     .first,
  //             'ending_date':
  //                 endDate
  //                     ?.toIso8601String()
  //                     .split('T')
  //                     .first,
  //             'updated_at': DateTime.now(),
  //           })
  //           .eq('uuid', product.uuid!)
  //           .maybeSingle();
  //   await returnEventsLogProvider().createLog(
  //     returnEventsLogProvider(
  //       // ignore: use_build_context_synchronously
  //     ).productAdapter(product, 2),
  //     // ignore: use_build_context_synchronously
  //   );

  //   if (context.mounted) {
  //     await getProducts(
  //       returnShopProvider().userShop()!.shopId!,
  //     );
  //   }
  //   notifyListeners();
  //   return response != null;
  // }

  // Future<bool> updateIsManaged({
  //   required int productId,
  //   required BuildContext context,
  //   required bool value,
  //   required int? qtty,
  // }) async {
  //   final response =
  //       await supabase
  //           .from('products')
  //           .update({
  //             'is_managed': value,
  //             'quantity': qtty,
  //             'updated_at': DateTime.now(),
  //           })
  //           .eq('id', productId)
  //           .maybeSingle();
  //   print(response?['is_managed']);
  //   if (context.mounted) {
  //     await getProducts(
  //       returnShopProvider(
  //         context,
  //         listen: false,
  //       ). userShop()!.shopId!,
  //     );
  //   }
  //   notifyListeners();
  //   return response != null;
  // }

  Future<void> deleteProductMain(
    TempProductClass product,
    BuildContext context,
  ) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      await supabase
          .from('products')
          .delete()
          .eq('uuid', product.uuid!);
      await returnEventsLogProvider().createLog(
        returnEventsLogProvider(
          // ignore: use_build_context_synchronously
        ).productAdapter(product, 3),
        // ignore: use_build_context_synchronously
      );
    } else {
      await ProductsFunc().deleteProduct(product.uuid!);
      var containsCreated =
          CreatedProductFunc()
              .getProducts()
              .where(
                (product) =>
                    product.product.uuid ==
                    product.product.uuid,
              )
              .toList();

      var containsUpdated =
          UpdatedProductsFunc()
              .getProducts()
              .where(
                (product) =>
                    product.product.uuid ==
                    product.product.uuid,
              )
              .toList();
      print(
        'Updated: ${containsCreated.length.toString()}',
      );
      print(
        'Updated: ${containsUpdated.length.toString()}',
      );
      if (containsCreated.isNotEmpty) {
        await CreatedProductFunc().createdProductsBox
            .delete(product.uuid);
      } else {
        await DeletedProductsFunc().createDeletedProduct(
          DeletedProducts(
            productUuid: product.uuid!,
            date: DateTime.now(),
          ),
        );
      }
      if (containsUpdated.isNotEmpty) {
        await UpdatedProductsFunc().deleteUpdatedProduct(
          containsUpdated.first.product.uuid!,
        );
        print('Deleted Update Log');
      }
      await returnEventsLogProvider().createLog(
        returnEventsLogProvider(
          // ignore: use_build_context_synchronously
        ).productAdapter(product, 3),
        // ignore: use_build_context_synchronously
      );
    }
    if (context.mounted) {
      await getProducts(
        returnShopProvider().userShop()!.shopId!,
      );
    }
    notifyListeners();
  }

  String name = '';
  String desc = '';
  String brand = '';
  String category = '';
  String unit = '';
  bool isRefundable = false;
  bool setCustomPrice = false;
  bool isManaged = true;
  String sizeType = '';
  String size = '';
  double costPrice = 0;
  double quantity = 0;
  double sellingPrice = 0;
  double? discount;
  String color = '';
  String barcode = '';

  void clearFields({bool? setIsManaged}) {
    isProductRefundable = false;
    setCustomPrice = false;
    isRefundable = false;
    selectedCategory = null;
    selectedColor = null;
    selectedSize = null;
    inStock = false;
    catValueSet = false;
    if (setIsManaged == null) {
      isManaged = true;
    }
    isOpen = false;
    unitValueSet = false;
    colorValueSet = false;
    sizeValueSet = false;
    // clearEndDate();
    // clearStartDate();
    clearExpDate();
    clearExpenseUnit();
    notifyListeners();
  }

  bool isProductRefundable = false;
  void toggleRefundable() {
    isProductRefundable = !isProductRefundable;
    notifyListeners();
  }

  void toggleSetCustomPrice() {
    setCustomPrice = !setCustomPrice;
    notifyListeners();
  }

  void toggleIsManaged({
    required BuildContext context,
    // required bool value,
  }) {
    if (isManaged == false) {
      ItemsAuthAction().allowStockallToManageItemAction(
        context: context,
        action: () {
          isManaged = true;
          notifyListeners();
        },
        failAction: () {
          isManaged = false;
          notifyListeners();
        },
      );
    } else {
      isManaged = false;
      notifyListeners();
    }
  }

  void toggleIsManagedTemp(bool value) {
    isManaged = value;
    notifyListeners();
  }

  bool inStock = false;
  void toggleStock() {
    inStock = !inStock;
    notifyListeners();
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
  // C A T E G O R Y  D A T A
  bool catValueSet = false;
  List<String> categories = [
    'Appliances',
    'Automotive',
    'Baby Items',
    'Beverages',
    'Books',
    'Clothing',
    'Computers',
    'Cosmetics',
    'Dairy',
    'Electronics',
    'Footwear',
    'Furniture',
    'Groceries',
    'Hardware',
    'Health',
    'Home Essentials',
    'Household Supplies',
    'Jewelry',
    'Kitchenware',
    'Length',
    'Meat & Seafood',
    'Medicines',
    'Mobile Phones',
    'Office Supplies',
    'Personal Care',
    'Pet Supplies',
    'Snacks',
    'Sports Equipment',
    'Stationery',
    'Toys',
    'Vegetables',
    'Others',
  ];

  String? selectedCategory;

  bool isOpen = false;

  // void toggleCatOpen(BuildContext context) {
  //   ItemsAuthAction().applyVariationsAction(
  //     context: context,
  //     action: () {
  //       isOpen = !isOpen;
  //       notifyListeners();
  //     },
  //   );
  // }

  void selectCategory(String category) {
    if (selectedCategory == null) {
      selectedCategory = category;
      catValueSet = true;
    } else if (selectedCategory != category) {
      selectedCategory = category;
      catValueSet = true;
    } else {
      selectedCategory = null;
      catValueSet = false;
    }
    notifyListeners();
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
  // U N I T   D A T A

  bool unitValueSet = false;

  List<String> units = [
    'bags',
    'barrels',
    'bottles',
    'boxes',
    'bundles',
    'cans',
    'cartons',
    'dozens',
    'gallons',
    'items',
    'jars',
    'kg',
    'lb',
    'liters',
    'mg',
    'ml',
    'packs',
    'pairs',
    'pieces',
    'reams',
    'rolls',
    'sachets',
    'sheets',
    'sets',
    'sticks',
    'tins',
    'trays',
    'tubes',
    'units',
    'Others',
  ];

  String? selectedUnit;

  void clearExpenseUnit() {
    selectedUnit = null;
    notifyListeners();
  }

  void selectUnit(String unit) {
    if (selectedUnit == null) {
      selectedUnit = unit;
      unitValueSet = true;
    } else if (selectedUnit != unit) {
      selectedUnit = unit;
      unitValueSet = true;
    } else {
      selectedUnit = null;
      unitValueSet = false;
    }
    notifyListeners();
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
  // C O L O R S  D A T A

  bool colorValueSet = false;

  List<String> colors = [
    'Red',
    'Yellow',
    'Blue',
    'Green',
    'Purple',
    'Pink',
    'Brown',
    'Indigo',
    'Violet',
    'Orange',
    'Others',
  ];

  String? selectedColor;

  void selectColor(String color) {
    if (selectedColor == null) {
      selectedColor = color;
      colorValueSet = true;
    } else if (selectedColor != color) {
      selectedColor = color;
      colorValueSet = true;
    } else {
      selectedColor = null;
      colorValueSet = false;
    }
    notifyListeners();
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
  // C O L O R S  D A T A

  bool sizeValueSet = false;

  List<String> sizes = [
    'XX Small',
    'X Small',
    'Small',
    'Medium Small',
    'Medium',
    'Medium Large',
    'Large',
    'X Large',
    'XX Large',
    'XXX Large',
    'Others',
  ];

  String? selectedSize;

  void selectSize(String size) {
    if (selectedSize == null) {
      selectedSize = size;
      sizeValueSet = true;
    } else if (selectedSize != size) {
      selectedSize = size;
      sizeValueSet = true;
    } else {
      selectedSize = null;
      sizeValueSet = false;
    }
    notifyListeners();
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
  // F L O A T I N G   A C T I O N   B U T T O N

  bool isFloatingButtonVisible = true;

  void hideFloatingActionButtonWithDelay() {
    Future.delayed(Duration(seconds: 5), () {
      isFloatingButtonVisible = false;
      notifyListeners();
    });
  }

  void showFloatingActionButton() {
    isFloatingButtonVisible = true;
    notifyListeners();
  }

  void toggleFloatingAction(BuildContext context) {
    Future.microtask(() {
      if (!context.mounted) return;

      if (!isFloatingButtonVisible) {
        showFloatingActionButton();
        hideFloatingActionButtonWithDelay();
      } else {
        hideFloatingActionButtonWithDelay();
      }
    });
  }

  // List<ProductBarcode> productBarcode = [];
  int barcodeGeneratingIndex = 0;

  void selectBarcodeGeneratingINdex(int value) {
    barcodeGeneratingIndex = value;
    notifyListeners();
  }

  List<ProductBarcode> barcodeGenerationList = [];

  void addToBarcodeGenerationList(
    ProductBarcode productBarcode,
  ) {
    barcodeGenerationList.add(productBarcode);
    notifyListeners();
  }

  void removeFromBarcodeGenerationList(
    ProductBarcode productBarcode,
  ) {
    barcodeGenerationList.removeWhere(
      (pr) =>
          pr.product.uuid == productBarcode.product.uuid,
    );
    notifyListeners();
  }

  void clearBarcodeGenerationList() {
    barcodeGenerationList.clear();
    notifyListeners();
  }

  void initProductBarcode(List<ProductBarcode> data) {
    barcodeGenerationList.addAll(data);
    notifyListeners();
  }

  // void clearProductBarcode() {
  //   productBarcode.clear();
  //   notifyListeners();
  // }

  void setBarcodeNumber(
    int number,
    ProductBarcode pBarcode,
  ) {
    barcodeGenerationList
        .firstWhere(
          (br) => br.product.uuid == pBarcode.product.uuid,
        )
        .number = number;
    notifyListeners();
  }

  void editNumber(bool isAdd, ProductBarcode pBarcode) {
    if (isAdd) {
      barcodeGenerationList
          .firstWhere(
            (br) =>
                br.product.uuid == pBarcode.product.uuid,
          )
          .number += 1;
      // numberC.text = '$barcodeNumber';
    } else {
      if (barcodeGenerationList
              .firstWhere(
                (br) =>
                    br.product.uuid ==
                    pBarcode.product.uuid,
              )
              .number >
          1) {
        barcodeGenerationList
            .firstWhere(
              (br) =>
                  br.product.uuid == pBarcode.product.uuid,
            )
            .number -= 1;
        // numberC.text = '$pBarcode.number';
      } else {
        barcodeGenerationList
            .firstWhere(
              (br) =>
                  br.product.uuid == pBarcode.product.uuid,
            )
            .number = 1;
        // numberC.text = '$barcodeNumber';
      }
    }
    notifyListeners();
  }

  double getTotalSellingPrice({
    List<TempProductClass>? products,
  }) {
    double tempTotal = 0;

    if (returnShopProvider()
            .userShop()
            ?.manageInventoryStorage ==
        true) {
      for (var item in (products ?? productList)) {
        tempTotal +=
            ((item.sellingPrice ?? 0) *
                ((item.quantity ?? 0) +
                    (item.totalQttyInStorage ?? 0)));
      }
    } else {
      for (var item in (products ?? productList)) {
        tempTotal +=
            ((item.sellingPrice ?? 0) *
                (item.quantity ?? 0));
      }
    }
    return tempTotal;
  }

  double getTotalCostPrice({
    List<TempProductClass>? products,
  }) {
    double tempTotal = 0;
    if (returnShopProvider()
            .userShop()
            ?.manageInventoryStorage ==
        true) {
      for (var item in (products ?? productList)) {
        tempTotal +=
            item.costPrice *
            ((item.quantity ?? 0) +
                (item.totalQttyInStorage ?? 0));
      }
    } else {
      for (var item in (products ?? productList)) {
        tempTotal += item.costPrice * (item.quantity ?? 0);
      }
    }
    return tempTotal;
  }

  double getTotalQuantity({
    List<TempProductClass>? products,
  }) {
    double tempTotal = 0;
    for (var item in (products ?? productList)) {
      tempTotal += item.quantity ?? 0;
    }
    return tempTotal;
  }

  double getTotalQuantityInStorage({
    List<TempProductClass>? products,
  }) {
    double tempTotal = 0;
    for (var item in (products ?? productList)) {
      tempTotal += item.totalQttyInStorage ?? 0;
    }
    return tempTotal;
  }

  double getTotalOverallQuantity({
    List<TempProductClass>? products,
  }) {
    return getTotalQuantity(products: products) +
        getTotalQuantityInStorage(products: products);
  }
}

class ProductBarcodeCounter extends StatefulWidget {
  final ProductBarcode pBarcode;
  const ProductBarcodeCounter({
    super.key,
    required this.pBarcode,
  });

  @override
  State<ProductBarcodeCounter> createState() =>
      _ProductBarcodeCounterState();
}

class _ProductBarcodeCounterState
    extends State<ProductBarcodeCounter> {
  TextEditingController numberC = TextEditingController();

  void editNumberLocal(bool isAdd) {
    returnData().editNumber(isAdd, widget.pBarcode);
    numberC.text = '${widget.pBarcode.number}';
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    numberC.text = '${widget.pBarcode.number}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0.0),
      child: Container(
        width: numberC.text.length > 2 ? 35 : 32,
        padding: EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey.shade100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 3,
          children: [
            Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.grey.shade300,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(2),
                  onTap: () {
                    editNumberLocal(true);
                  },
                  child: Container(
                    padding: EdgeInsets.all(2),

                    child: Center(
                      child: Icon(
                        size: 12,
                        color: Colors.grey.shade700,
                        Icons.add,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 25,
              child: TextField(
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade800,
                      width: 0.5,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 0,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                controller: numberC,
                keyboardType:
                    TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                onChanged: (value) {
                  if (value.isEmpty || value == '0') {
                    returnData().setBarcodeNumber(
                      1,
                      widget.pBarcode,
                    );
                    numberC.text = '1';
                  } else {
                    returnData().setBarcodeNumber(
                      int.parse(value),
                      widget.pBarcode,
                    );
                  }
                  setState(() {});
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                autofocus: false,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.grey.shade300,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(2),
                  onTap: () {
                    editNumberLocal(false);
                  },
                  child: Container(
                    padding: EdgeInsets.all(2),

                    child: Center(
                      child: Icon(
                        size: 12,
                        color: Colors.grey.shade700,
                        Icons.remove,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductBarcode {
  final TempProductClass product;
  int number;

  ProductBarcode({
    required this.product,
    required this.number,
  });
}
