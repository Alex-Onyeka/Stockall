import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/unsynced/created_products/created_products.dart';
import 'package:stockall/classes/temp_product_class/unsynced/deleted_products/deleted_products.dart';
import 'package:stockall/classes/temp_product_class/unsynced/updated/updated_products.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/local_database/category/unsync_funcs/created_categories/created_categories_func.dart';
import 'package:stockall/local_database/category/unsync_funcs/deleted_categories/deleted_categories_func.dart';
import 'package:stockall/local_database/category/unsync_funcs/updated_categories/updated_categories_func.dart';
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
import 'package:stockall/local_database/item_purchase_func.dart%20copy/unsync_funcs/created/created_item_purchase_func.dart';
import 'package:stockall/local_database/item_purchase_func.dart%20copy/unsync_funcs/deleted/deleted_item_purchase_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/created/created_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/deleted/deleted_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/updated/updated_receipts_func.dart';
import 'package:stockall/local_database/product_record_func.dart/unsync_funcs/created/created_records_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/created_products%20copy/sales_product_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/created_products/created_product_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/deleted_products/deleted_products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/updated_products/updated_products_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/created/created_purchases_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/deleted/deleted_purchases_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/updated/updated_purchases_func.dart';
import 'package:stockall/local_database/shop/updated_shop/updated_shop_func.dart';
import 'package:stockall/local_database/shop_logos/created_shop_logo/created_shop_logos_func.dart';
import 'package:stockall/local_database/storage_product/unsync_funcs/created/created_storage_products_func.dart';
import 'package:stockall/local_database/storage_product/unsync_funcs/deleted/deleted_storage_products_func.dart';
import 'package:stockall/local_database/storage_product/unsync_funcs/updated/updated_storage_products_func.dart';
import 'package:stockall/local_database/sub_staff/unsync_funcs/created/created_sub_staff_func.dart';
import 'package:stockall/local_database/sub_staff/unsync_funcs/deleted/deleted_sub_staff_func.dart';
import 'package:stockall/local_database/sub_staff/unsync_funcs/updated/updated_sub_staff_func.dart';
import 'package:stockall/local_database/suppliers_func/unsync_funcs/created/created_supplier_func.dart';
import 'package:stockall/local_database/suppliers_func/unsync_funcs/deleted/deleted_supplier_func.dart';
import 'package:stockall/local_database/suppliers_func/unsync_funcs/updated/updated_supplier_func.dart';
import 'package:stockall/local_database/waybills/unsync_funcs/created/created_waybills_func.dart';
import 'package:stockall/local_database/waybills/unsync_funcs/deleted/deleted_waybills_func.dart';
import 'package:stockall/local_database/waybills/unsync_funcs/updated/updated_waybills_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/department_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataProvider extends ChangeNotifier {
  static final DataProvider _instance =
      DataProvider._internal();
  factory DataProvider() => _instance;
  DataProvider._internal();
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
    // BuildContext context,
  ) async {
    // bool isOnline = await connectivity.isOnline();
    product.updatedAt = DateTime.now();
    // if (isOnline) {
    //   var data =
    //       await supabase
    //           .from('products')
    //           .upsert(product.toJson(), onConflict: 'uuid')
    //           .select()
    //           .single();
    //   print('Item added successfully');
    //   final newProduct = TempProductClass.fromJson(data);
    //   await ProductsFunc().createProduct(newProduct);
    //   await returnEventsLogProvider().createLog(
    //     returnEventsLogProvider(
    //       // ignore: use_build_context_synchronously
    //     ).productAdapter(product, 1),
    //     // ignore: use_build_context_synchronously
    //   );
    //   print('Total Success');
    // } else {
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
    // }

    print('Mounted');
    await getProductsOffline(
      returnShopProvider().userShop()!.shopId!,
    );

    clearFields();
  }

  Future<void> createProductsSync(
    // BuildContext context,
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
        print('Mounted, refreshing products ✅');
        await getProducts(
          returnShopProvider().userShop()!.shopId!,
        );

        clearFields();
        print('Unsynced Products Cleared');
      }
    } catch (e) {
      print('Batch insert failed ❌: $e');
    }
  }

  Future<void> deleteProductsSync() async {
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

        print('Mounted, refreshing products ✅');
        await getProducts(
          returnShopProvider().userShop()!.shopId!,
        );

        clearFields();
        print('Unsynced deleted products cleared');
      }
    } catch (e) {
      print('Batch delete failed ❌: $e');
    }
  }

  Future<void> updateProductsSync() async {
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
        print('Mounted, refreshing products ✅');
        await getProducts(
          returnShopProvider().userShop()!.shopId!,
        );
        clearFields();
      }
    } catch (e) {
      print('Batch update failed ❌: $e');
    }
  }

  //
  //
  //
  //
  //
  //
  Future<void> salesProductsSync() async {
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
            'decrement_product_quantity_during_sync_double',
            params: {
              'p_uuid': salesProduct.productUuid,
              'p_qty': salesProduct.quantity,
            },
          );

          print(
            'Decremented ${salesProduct.quantity} from product ${salesProduct.productUuid}',
          );

          await SalesProductFunc().deleteProduct(
            salesProduct.productUuid,
          );

          print('Mounted, refreshing products ✅');
          await getProducts(
            returnShopProvider().userShop()!.shopId!,
          );

          clearFields();
        }
      }
    } catch (e) {
      print('Batch update failed ❌: $e');
    }
  }

  //
  //
  //
  //
  //
  //

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
    await UpdatedReceiptsFunc().clearUpdatedReceipts();
    await UpdatedShopFunc().clearUpdatedShop();
    await CreatedShopLogosFunc().clearCreatedLogos();
    await CreatedEventsLogFunc().clearEvents();
    await CreatedDepartmentsFunc().clearDepartment();
    await UpdatedDepartmentFunc().clearupdatedDepartments();
    await DeletedDepartmentsFunc()
        .clearDeletedDepartments();
    await CreatedSubStaffFunc().clearSubStaffs();
    await UpdatedSubStaffFunc().clearUpdatedSubStaff();
    await DeletedSubStaffFunc().clearDeletedSubStaff();
    await CreatedCategoriesFunc().clearCategories();
    await UpdatedCategoriesFunc().clearUpdatedCategory();
    await DeletedCategoriesFunc().clearDeletedCategories();
    await CreatedSupplierFunc().clearSuppliers();
    await UpdatedSupplierFunc().clearUpdatedSuppliers();
    await DeletedSupplierFunc().clearDeletedSupplier();
    await CreatedPurchasesFunc().clearPurchases();
    await UpdatedPurchasesFunc().clearUpdatedPurchases();
    await DeletedPurchasesFunc().clearDeletedPurchases();
    await CreatedItemPurchaseFunc().clearRecords();
    await DeletedItemPurchaseFunc()
        .clearDeletedItemRecords();
    await CreatedStorageProductsFunc()
        .clearCreatedStorageProducts();
    await UpdatedStorageProductsFunc()
        .clearUpdatedStorageProduct();
    await DeletedStorageProductsFunc()
        .clearDeletedStorageProduct();
    await CreatedWaybillsFunc().clearWaybills();
    await UpdatedWaybillsFunc().clearUpdatedWaybills();
    await DeletedWaybillsFunc().clearDeletedWaybills();
    await CreatedInvoicesFunc().clearInvoices();
    await DeletedInvoicesFunc().clearDeletedInvoices();
    await UpdatedInvoicesFunc()
        .clearupdatedInvoiceUpdatedInvoices();
    notifyListeners();
  }

  Future<void> syncData({BuildContext? context}) async {
    if (isSynced() == 0) {
      syncProgress = 0;
      toggleSyncing(true);
      bool isOnline = await connectivity.isOnline();
      if (isOnline) {
        List<TempShopClass> shop =
            await returnShopProvider().getUserShops();
        if (shop.isNotEmpty) {
          if (CreatedCategoriesFunc()
                  .getCreateCategories()
                  .isNotEmpty &&
              isOnline) {
            await returnCategoriesProvider()
                .createCategoriesSync();
            print('Finished Syncing Created Categories');
            setSyncProgress(1);
          }
          if (UpdatedCategoriesFunc()
                  .getCategories()
                  .isNotEmpty &&
              isOnline) {
            await returnCategoriesProvider()
                .updateCategoriesSync();
            print('Finished Syncing Updated Categories');
            setSyncProgress(2);
          }
          if (DeletedCategoriesFunc()
                  .getCategoryIds()
                  .isNotEmpty &&
              isOnline) {
            await returnCategoriesProvider()
                .deleteCategoriesSync();
            print('Finished Syncing Deleted Categories');
            setSyncProgress(3);
          }
          if (CreatedDepartmentsFunc()
                  .getDepartment()
                  .isNotEmpty &&
              isOnline) {
            await DepartmentProvider()
                .createDepartmentsSync();
            print('Finished Syncing Created Departments');
            setSyncProgress(4);
          }
          if (UpdatedDepartmentFunc()
                  .getDepartments()
                  .isNotEmpty &&
              isOnline) {
            await DepartmentProvider()
                .updateDepartmentsSync();
            print('Finished Syncing Updated Departments');
            setSyncProgress(5);
          }
          if (DeletedDepartmentsFunc()
                  .getDepartmentIds()
                  .isNotEmpty &&
              isOnline) {
            await DepartmentProvider()
                .deleteDepartmentsSync();
            print('Finished Syncing Deleted Departments');
            setSyncProgress(6);
          }
          if (CreatedStorageProductsFunc()
                  .getStorageProducts()
                  .isNotEmpty &&
              isOnline) {
            await returnStorageProductProvider()
                .createStorageProductsSync();
            print(
              'Finished Syncing Created StorageProductss',
            );
            setSyncProgress(7);
          }
          if (UpdatedStorageProductsFunc()
                  .getStorageProductIds()
                  .isNotEmpty &&
              isOnline) {
            await returnStorageProductProvider()
                .updateStorageProductsSync();
            print(
              'Finished Syncing Updated StorageProductss',
            );
            setSyncProgress(8);
          }
          if (DeletedStorageProductsFunc()
                  .getStorageProductIds()
                  .isNotEmpty &&
              isOnline) {
            await returnStorageProductProvider()
                .deleteStorageProductsSync();
            print(
              'Finished Syncing Deleted StorageProductss',
            );
            setSyncProgress(9);
          }
          if (CreatedProductFunc()
                  .getProducts()
                  .isNotEmpty &&
              isOnline) {
            await createProductsSync();
            print('Finished Syncing Created Products');
            setSyncProgress(10);
          }
          if (DeletedProductsFunc()
                  .getProductIds()
                  .isNotEmpty &&
              isOnline) {
            await deleteProductsSync();
            print('Finished Syncing Deleted Products');
            setSyncProgress(11);
          }
          if (UpdatedProductsFunc()
                  .getProducts()
                  .isNotEmpty &&
              isOnline) {
            await updateProductsSync();
            print('Finished Syncing Updated Products');
            setSyncProgress(12);
          }
          if (SalesProductFunc().getProducts().isNotEmpty &&
              isOnline) {
            await salesProductsSync();
            print('Finished Syncing Sales Products');
            setSyncProgress(13);
          }
          if (CreatedExpensesFunc()
                  .getExpenses()
                  .isNotEmpty &&
              isOnline) {
            await returnExpensesProviderSingle()
                .createExpensesSync();
            print('Finished Syncing Created Expenses');
            setSyncProgress(14);
          }
          if (UpdatedExpensesFunc()
                  .getExpenses()
                  .isNotEmpty &&
              isOnline) {
            await returnExpensesProviderSingle()
                .updateExpensesSync();
            print('Finished Syncing Updated Expenses');
            setSyncProgress(15);
          }
          if (DeletedExpensesFunc()
                  .getExpenseIds()
                  .isNotEmpty &&
              isOnline) {
            await returnExpensesProviderSingle()
                .deleteExpensesSync();
            print('Finished Syncing Deleted Expenses');
            setSyncProgress(16);
          }
          if (CreatedCustomersFunc()
                  .getCustomers()
                  .isNotEmpty &&
              isOnline) {
            await returnCustomersSingle()
                .createCustomersSync();
            print('Finished Syncing Created Customer');
            setSyncProgress(17);
          }
          if (UpdatedCustomersFunc()
                  .getCustomers()
                  .isNotEmpty &&
              isOnline) {
            await returnCustomersSingle()
                .updateCustomersSync();
            print('Finished Syncing Updated Customers');
            setSyncProgress(18);
          }
          if (DeletedCustomersFunc()
                  .getCustomerIds()
                  .isNotEmpty &&
              isOnline) {
            await returnCustomersSingle()
                .deletedCustomersSync();
            print('Finished Syncing Deleted Customers');
            setSyncProgress(19);
          }
          if (CreatedSubStaffFunc()
                  .getSubStaffs()
                  .isNotEmpty &&
              isOnline) {
            await returnSubStaffProvider()
                .createSubStaffSync();
            print('Finished Syncing Created Sub Staffs');
            setSyncProgress(20);
          }
          if (UpdatedSubStaffFunc()
                  .getSubStaffs()
                  .isNotEmpty &&
              isOnline) {
            await returnSubStaffProvider()
                .updateSubStaffSync();
            print('Finished Syncing Updated Sub Staffs');
            setSyncProgress(21);
          }
          if (DeletedSubStaffFunc()
                  .getSubStaffIds()
                  .isNotEmpty &&
              isOnline) {
            await returnSubStaffProvider()
                .deleteSubStaffSync();
            print('Finished Syncing Deleted Sub Staffs');
            setSyncProgress(22);
          }
          if (CreatedSupplierFunc()
                  .getSuppliers()
                  .isNotEmpty &&
              isOnline) {
            await returnSuppliersProvider()
                .createSupplierSync();
            print('Finished Syncing Created Suppliers');
            setSyncProgress(23);
          }
          if (UpdatedSupplierFunc()
                  .getSuppliers()
                  .isNotEmpty &&
              isOnline) {
            await returnSuppliersProvider()
                .updateSuppliersSync();
            print('Finished Syncing Updated Suppliers');
            setSyncProgress(24);
          }
          if (DeletedSupplierFunc()
                  .getSupplierIds()
                  .isNotEmpty &&
              isOnline) {
            await returnSuppliersProvider()
                .deletedSuppliersSync();
            print('Finished Syncing Deleted Suppliers');
            setSyncProgress(25);
          }
          if (DeletedInvoicesFunc()
                  .getInvoiceIds()
                  .isNotEmpty &&
              isOnline) {
            await returnInvoicesProvider()
                .deleteInvoicesSync();
            print('Finished Syncing Deleted Invoices');
            setSyncProgress(26);
          }
          if (CreatedInvoicesFunc()
                  .getInvoices()
                  .isNotEmpty &&
              isOnline) {
            await returnInvoicesProvider()
                .createInvoicesSync();
            print('Finished Syncing Created Invoices');
            setSyncProgress(27);
          }
          if (UpdatedInvoicesFunc()
                  .getInvoiceIds()
                  .isNotEmpty &&
              isOnline) {
            await returnInvoicesProvider()
                .updateInvoicesSync();
            print('Finished Syncing Updated Invoices');
            setSyncProgress(28);
          }
          if (DeletedReceiptsFunc()
                  .getReceiptIds()
                  .isNotEmpty &&
              isOnline) {
            await returnReceiptProviderSingle()
                .deleteReceiptsSync();
            print('Finished Syncing Deleted Receipts');
            setSyncProgress(29);
          }
          if (CreatedRecordsFunc()
                  .getRecords()
                  .isNotEmpty &&
              isOnline) {
            await returnReceiptProviderSingle()
                .createRecordsSync();
            print(
              'Finished Syncing Created Records Customers',
            );
            setSyncProgress(30);
          }
          if (CreatedReceiptsFunc()
                  .getReceipts()
                  .isNotEmpty &&
              isOnline) {
            await returnReceiptProviderSingle()
                .createReceiptsSync();
            print('Finished Syncing Created Receipts');
            setSyncProgress(31);
          }
          if (UpdatedReceiptsFunc()
                  .getReceiptIds()
                  .isNotEmpty &&
              isOnline) {
            await returnReceiptProviderSingle()
                .updateReceiptsSync();
            print('Finished Syncing Created Receipts');
            setSyncProgress(32);
          }
          if (UpdatedShopFunc()
                  .getUpdatedShop()
                  .isNotEmpty &&
              isOnline) {
            await returnShopProvider().updateShopSync();
            print('Finished Syncing Created Receipts');
            setSyncProgress(33);
          }
          if (CreatedShopLogosFunc().getCreatedLogo() !=
                  null &&
              isOnline) {
            await returnShopProvider().uploadShopLogoSync();
            print('Finished Syncing Created Logo');
            setSyncProgress(34);
          }
          if (CreatedEventsLogFunc()
                  .getCreatedEventsLogs()
                  .isNotEmpty &&
              isOnline) {
            await returnEventsLogProvider().eventsLogSync();
            print('Finished Syncing Created Events Log');
            setSyncProgress(35);
          }
          if (CreatedInventoryUpdatesFunc()
                  .getCreatedInventoryUpdatess()
                  .isNotEmpty &&
              isOnline) {
            await returnInventoryUpdatesProvider()
                .inventoryUpdatesSync();
            print('Finished Syncing Inventory Updates');
            setSyncProgress(36);
          }
          if (CreatedPurchasesFunc()
                  .getPurchases()
                  .isNotEmpty &&
              isOnline) {
            await returnPurchaseProvider()
                .createPurchasesSync();
            print('Finished Syncing Created Purchasess');
            setSyncProgress(37);
          }
          if (UpdatedPurchasesFunc()
                  .getPurchaseIds()
                  .isNotEmpty &&
              isOnline) {
            await returnPurchaseProvider()
                .updatePurchaseSync();
            print('Finished Syncing Updated Purchasess');
            setSyncProgress(38);
          }
          if (DeletedPurchasesFunc()
                  .getPurchaseIds()
                  .isNotEmpty &&
              isOnline) {
            await returnPurchaseProvider()
                .deletePurchasesSync();
            print('Finished Syncing Deleted Purchasess');
            setSyncProgress(39);
          }
          if (CreatedItemPurchaseFunc()
                  .getRecords()
                  .isNotEmpty &&
              isOnline) {
            await returnPurchaseProvider()
                .createRecordsSync();
            print(
              'Finished Syncing Created Purchase Item Records',
            );
            setSyncProgress(40);
          }
          if (DeletedItemPurchaseFunc()
                  .getItemPurchaseIds()
                  .isNotEmpty &&
              isOnline) {
            await returnPurchaseProvider()
                .deleteItemRecordsSync();
            print(
              'Finished Syncing Deleted Purchase Item Records',
            );
            setSyncProgress(41);
          }
          if (CreatedWaybillsFunc()
                  .getWaybills()
                  .isNotEmpty &&
              isOnline) {
            await returnWaybillProvider()
                .createWaybillsSync();
            print('Finished Syncing Created Waybills');
            setSyncProgress(42);
          }
          if (UpdatedWaybillsFunc()
                  .getWaybillIds()
                  .isNotEmpty &&
              isOnline) {
            await returnWaybillProvider()
                .updateWaybillSync();
            print('Finished Syncing Updated Waybills');
            setSyncProgress(43);
          }
          if (DeletedWaybillsFunc()
                  .getWaybillIds()
                  .isNotEmpty &&
              isOnline) {
            await returnWaybillProvider()
                .deleteWaybillsSync();
            print('Finished Syncing Deleted Waybills');
            setSyncProgress(44);
          }

          // await clearTotalCache();
          toggleSyncing(false);
        } else {
          // await ShopFunc().clearShop();
          toggleSyncing(false);
          // returnNavProvider(context, listen: false).nullShop(
          //   logoutAction:
          //       () => returnNavProviderSingle().navPush(
          //         context,
          //       ),
          // );
        }
      } else {
        toggleSyncing(false);
        if (context != null && context.mounted) {
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
  }

  //
  //
  //
  //
  bool isSyncing = false;
  double syncProgress = 0;
  void setSyncProgress(int value) {
    syncProgress = (value / 44) * 100;
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
          DeletedSubStaffFunc().getSubStaffIds().isEmpty &&
          CreatedCategoriesFunc()
              .getCreateCategories()
              .isEmpty &&
          UpdatedCategoriesFunc().getCategories().isEmpty &&
          DeletedCategoriesFunc()
              .getCategoryIds()
              .isEmpty &&
          CreatedSupplierFunc().getSuppliers().isEmpty &&
          UpdatedSupplierFunc().getSuppliers().isEmpty &&
          DeletedSupplierFunc().getSupplierIds().isEmpty &&
          CreatedPurchasesFunc().getPurchases().isEmpty &&
          DeletedPurchasesFunc().getPurchaseIds().isEmpty &&
          UpdatedPurchasesFunc().getPurchaseIds().isEmpty &&
          CreatedItemPurchaseFunc().getRecords().isEmpty &&
          DeletedItemPurchaseFunc()
              .getItemPurchaseIds()
              .isEmpty &&
          CreatedStorageProductsFunc()
              .getStorageProducts()
              .isEmpty &&
          UpdatedStorageProductsFunc()
              .getStorageProductIds()
              .isEmpty &&
          DeletedStorageProductsFunc()
              .getStorageProductIds()
              .isEmpty &&
          CreatedWaybillsFunc().getWaybills().isEmpty &&
          UpdatedWaybillsFunc().getWaybillIds().isEmpty &&
          DeletedWaybillsFunc().getWaybillIds().isEmpty) {
        return 1;
      } else {
        return 0;
      }
    }
  }

  String? departmentUuid;
  void setDepartment(String? uuid) {
    departmentUuid = uuid;

    notifyListeners();
  }

  void clearDepartment() {
    departmentUuid = null;
    notifyListeners();
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

  List<TempProductClass> productListMain = [];

  List<TempProductClass> productList() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return productListMain.where((cat) {
          if (cat.departmentUuid == null) {
            return true;
          } else {
            return cat.departmentUuid ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
          }
        }).toList();
      } else {
        if (returnDepartmentProvider()
                .currentDepartment()
                ?.uuid ==
            null) {
          return productListMain;
        } else {
          return productListMain.where((cat) {
            if (cat.departmentUuid == null) {
              return true;
            } else {
              return cat.departmentUuid ==
                  returnDepartmentProvider()
                      .currentDepartment()
                      ?.uuid;
            }
          }).toList();
        }
      }
    } else {
      return productListMain;
    }
  }

  void clearProducts() {
    productListMain.clear();
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
    if (isOnline && isSynced() == 1) {
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

      productListMain =
          (data as List)
              .map(
                (json) => TempProductClass.fromJson(json),
              )
              .toList();
      productListMain.sort(
        (a, b) => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
      );
      print('Product List Set: ${productListMain.length}');
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
        productListMain.addAll(
          (data2 as List)
              .map(
                (stuff) => TempProductClass.fromJson(stuff),
              )
              .toList(),
        );
        productListMain.sort(
          (a, b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
        );
        print(
          'Product List 2 Set: ${productListMain.length}',
        );

        if (productListMain.length > 1999) {
          final data3 = await supabase
              .from('products')
              .select()
              .eq('shop_id', shopId)
              .order('name', ascending: true)
              .range(2001, allowedRangeItems ?? 3000);
          print('Items 3 gotten: ${data3.length}');
          productListMain.addAll(
            (data3 as List)
                .map(
                  (stuff) =>
                      TempProductClass.fromJson(stuff),
                )
                .toList(),
          );
          productListMain.sort(
            (a, b) => a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            ),
          );
          print(
            'Product List 3 Set: ${productListMain.length}',
          );
        }
        notifyListeners();
      }
      notifyListeners();
      if (returnShopProvider()
              .userShop()
              ?.manageInventoryStorage ==
          true) {
        await returnStorageProductProvider()
            .getStorageProducts(shopId);
        // await returnInventoryUpdatesProvider()
        //     .getInventoryUpdates();
      }

      await ProductsFunc().insertAllProducts(
        productListMain,
      );
    } else {
      // productListMain.clear();
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
      productListMain = ProductsFunc().getProducts();
      notifyListeners();
      if (returnShopProvider()
              .userShop()
              ?.manageInventoryStorage ==
          true) {
        await returnStorageProductProvider()
            .getStorageProducts(shopId);
        // await returnInventoryUpdatesProvider()
        //     .getInventoryUpdates();
      }
      // productListMain.clear();
    }

    notifyListeners();
    return productListMain;
  }

  Future<List<TempProductClass>> getProductsOffline(
    int shopId,
  ) async {
    productListMain = ProductsFunc().getProducts();
    notifyListeners();
    if (returnShopProvider()
            .userShop()
            ?.manageInventoryStorage ==
        true) {
      await returnStorageProductProvider()
          .getStorageProductsOffline(shopId);

      notifyListeners();
    }
    return productListMain;
  }

  // Future<List<TempProductClass>> searchProductName(
  //   BuildContext context,
  //   String name,
  // ) async {
  //   var temp = await getProducts(shopId());
  //   final tempData =
  //       temp
  //           .where((product) => product.name.contains(name))
  //           .toList();

  //   return tempData;
  // }

  // Future<List<TempProductClass>> getLowProducts(
  //   int shopId,
  // ) async {
  //   final data = await getProducts(shopId);

  //   final tempData = data.where(
  //     (product) =>
  //         product.quantity != null &&
  //         product.quantity! < product.lowQtty!,
  //   );

  //   return tempData.toList();
  // }

  Future<TempProductClass?> updateProduct({
    required TempProductClass product,
    TempProductClass? oldProduct,
  }) async {
    // bool isOnline = await connectivity.isOnline();
    try {
      print(product.isManaged.toString());
      // if (isOnline) {
      //   product.updatedAt = DateTime.now().toLocal();
      //   var res =
      //       await supabase
      //           .from('products')
      //           .update(product.toJson())
      //           .eq('uuid', product.uuid!)
      //           .select()
      //           .maybeSingle();
      //   if (res != null) {
      //     print('${product.uuid}');
      //     await returnEventsLogProvider().createLog(
      //       returnEventsLogProvider().productAdapter(
      //         product,
      //         2,
      //       ),
      //     );
      //     print('Context Mounted');
      //     await getProducts(
      //       returnShopProvider().userShop()!.shopId!,
      //     );
      //     notifyListeners();
      //     return TempProductClass.fromJson(res);
      //   } else {
      //     print('Product Update Failed');
      //     return null;
      //   }
      // } else {
      var res = await ProductsFunc().updateProduct(product);
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
          await UpdatedProductsFunc().createUpdatedProduct(
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
        await getProductsOffline(
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
      // }
    } catch (e) {
      notifyListeners();
      print("Error Updating Product: ${e.toString()}");
      return null;
    }
  }

  Future<void> deleteProductMain(
    TempProductClass product,
    // BuildContext context,
  ) async {
    // bool isOnline = await connectivity.isOnline();
    // if (isOnline) {
    //   await supabase
    //       .from('products')
    //       .delete()
    //       .eq('uuid', product.uuid!);
    //   await returnEventsLogProvider().createLog(
    //     returnEventsLogProvider(
    //       // ignore: use_build_context_synchronously
    //     ).productAdapter(product, 3),
    //     // ignore: use_build_context_synchronously
    //   );
    // } else {
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
    print('Updated: ${containsCreated.length.toString()}');
    print('Updated: ${containsUpdated.length.toString()}');
    if (containsCreated.isNotEmpty) {
      await CreatedProductFunc().createdProductsBox.delete(
        product.uuid,
      );
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
    // }
    await getProductsOffline(
      returnShopProvider().userShop()!.shopId!,
    );
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
    groupUnitValueSet = false;
    // clearEndDate();
    // clearStartDate();
    clearGroupUnit();
    clearExpDate();
    clearDepartment();
    clearUnit();
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

  CategoryClass? selectedCategory;

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

  void selectCategory(CategoryClass category) {
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

  bool groupUnitValueSet = false;

  List<String> units = [
    'Ags',
    'Barrels',
    'Bottles',
    'Boxes',
    'Bundles',
    'Cans',
    'Cartons',
    'Crates',
    'Dozens',
    'Gallons',
    'Items',
    'Jars',
    'Kg',
    'Lb',
    'Liters',
    'Mg',
    'Ml',
    'Packs',
    'Pairs',
    'Pieces',
    'Reams',
    'Rolls',
    'Sachets',
    'Sheets',
    'Sets',
    'Slates',
    'Sticks',
    'Tins',
    'Trays',
    'Tubes',
    'Units',
    'Others',
  ];

  String? selectedUnit;

  void clearUnit() {
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

  String? selectedGroupUnit;

  void clearGroupUnit() {
    selectedGroupUnit = null;
    notifyListeners();
  }

  void selectGroupUnit({String? unit}) {
    if (selectedGroupUnit == null) {
      selectedGroupUnit = unit;
      groupUnitValueSet = true;
    } else if (selectedGroupUnit != unit) {
      selectedGroupUnit = unit;
      groupUnitValueSet = true;
    } else {
      selectedGroupUnit = null;
      groupUnitValueSet = false;
    }
    notifyListeners();
  }

  double returnGroupQuantityValue(
    TempProductClass product,
  ) {
    return product.quantity != null &&
            product.qttyPerGroup != null
        ? (product.quantity ?? 0) /
            (product.qttyPerGroup ?? 0)
        : 0;
  }

  double returnTotalGroupQuantityValue(
    TempProductClass product,
    double totalValue,
  ) {
    return product.qttyPerGroup != null
        ? totalValue / (product.qttyPerGroup ?? 0)
        : 0;
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

  double getTotalWholeSalePrice({
    List<TempProductClass>? products,
  }) {
    double tempTotal = 0;

    if (returnShopProvider()
            .userShop()
            ?.manageInventoryStorage ==
        true) {
      for (var item in (products ?? productListMain)) {
        tempTotal +=
            ((item.wholeSalePrice ?? 0) *
                ((item.quantity ?? 0) +
                    (item.totalQttyInStorageDouble ?? 0)));
      }
    } else {
      for (var item in (products ?? productListMain)) {
        tempTotal +=
            ((item.wholeSalePrice ?? 0) *
                (item.quantity ?? 0));
      }
    }
    return tempTotal;
  }

  double getTotalSellingPrice({
    List<TempProductClass>? products,
  }) {
    double tempTotal = 0;

    if (returnShopProvider()
            .userShop()
            ?.manageInventoryStorage ==
        true) {
      var storageProducts =
          returnStorageProductProvider()
              .storageProductListMain;
      for (var item in (products ?? productListMain)) {
        tempTotal +=
            (item.sellingPrice ?? 0) * (item.quantity ?? 0);
      }
      for (var item in storageProducts) {
        tempTotal +=
            (item.sellingPrice ?? 0) * (item.quantity ?? 0);
      }
    } else {
      for (var item in (products ?? productListMain)) {
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
      var storageProducts =
          returnStorageProductProvider()
              .storageProductListMain;
      for (var item in (products ?? productListMain)) {
        tempTotal += item.costPrice * (item.quantity ?? 0);
      }
      for (var item in storageProducts) {
        tempTotal +=
            (item.costPrice ?? 0) * (item.quantity ?? 0);
      }
    } else {
      for (var item in (products ?? productListMain)) {
        tempTotal += item.costPrice * (item.quantity ?? 0);
      }
    }
    return tempTotal;
  }

  double getTotalQuantity({
    List<TempProductClass>? products,
  }) {
    double tempTotal = 0;
    for (var item in (products ?? productListMain)) {
      tempTotal += item.quantity ?? 0;
    }
    return tempTotal;
  }

  double getTotalQuantityInStorage({
    List<TempProductClass>? products,
  }) {
    double tempTotal = 0;
    for (var item in (products ?? productListMain)) {
      tempTotal += item.totalQttyInStorageDouble ?? 0;
    }
    return tempTotal;
  }

  double getTotalOverallQuantity({
    List<TempProductClass>? products,
  }) {
    return getTotalQuantity(products: products) +
        getTotalQuantityInStorage(products: products);
  }

  bool isSelectProducts = false;
  List<TempProductClass> selectedProducts = [];

  void toggleIsSelectProduct(bool value) {
    isSelectProducts = value;
    if (!value) {
      selectedProducts.clear();
    }
    notifyListeners();
  }

  void selectProduct(TempProductClass newProduct) {
    if (selectedProducts.contains(newProduct)) {
      selectedProducts.remove(newProduct);
    } else {
      selectedProducts.add(newProduct);
    }
    notifyListeners();
  }

  Future<int> deleteSelectedProducts() async {
    // bool isOnline = await ConnectivityProvider().isOnline();
    try {
      // if (isOnline) {
      //   var productUuids =
      //       selectedProducts.map((pr) => pr.uuid!).toList();
      //   await supabase.rpc(
      //     'delete_products_by_uuids',
      //     params: {'product_uuids': productUuids},
      //   );
      //   print("Products Delete Successful Online");
      //   for (var pr in selectedProducts) {
      //     await returnEventsLogProvider().createLog(
      //       returnEventsLogProvider().productAdapter(pr, 3),
      //     );
      //   }

      //   await getProducts(shopId());
      //   toggleIsSelectProduct(false);
      //   return 1;
      // } else {
      for (var pr in ProductsFunc().getProducts().where(
        (prr) => selectedProducts.contains(prr),
      )) {
        await deleteProductMain(pr);
      }
      toggleIsSelectProduct(false);
      return 1;
      // }
    } catch (e) {
      print(
        "Error Deleting Multiple Products: ${e.toString()}",
      );
      return 0;
    }
  }

  Future<int> duplicateSelectedProducts() async {
    // bool isOnline = await ConnectivityProvider().isOnline();
    try {
      // if (isOnline) {
      //   var productUuids =
      //       selectedProducts.map((pr) => pr.uuid!).toList();
      //   await supabase.rpc(
      //     'duplicate_products',
      //     params: {'product_uuids': productUuids},
      //   );
      //   print("Products Duplicated Successful Online");
      //   for (var pr in selectedProducts) {
      //     await returnEventsLogProvider().createLog(
      //       returnEventsLogProvider().productAdapter(pr, 1),
      //     );
      //   }

      //   await getProducts(shopId());
      //   toggleIsSelectProduct(false);
      //   return 1;
      // } else {
      for (var pr in selectedProducts) {
        final random = Random();
        final number = random.nextInt(50);

        final newProduct = pr.copyWith(
          uuid: uuidGen(),
          name: '${pr.name} Copy $number',
          createdAt: DateTime.now(),
        );

        await ProductsFunc().createProduct(newProduct);

        await CreatedProductFunc().createProduct(
          CreatedProducts(product: newProduct),
        );

        await returnEventsLogProvider().createLog(
          returnEventsLogProvider().productAdapter(
            newProduct,
            1,
          ),
        );
      }
      await getProductsOffline(shopId());
      toggleIsSelectProduct(false);
      return 1;
      // }
    } catch (e) {
      print(
        "Error Duplicating Multiple Products: ${e.toString()}",
      );
      return 0;
    }
  }

  Future<int> generateStorageSelectedProducts() async {
    // bool isOnline = await ConnectivityProvider().isOnline();
    try {
      // if (isOnline) {
      //   List<StorageProductInput> temp =
      //       selectedProducts
      //           .map(
      //             (pr) => StorageProductInput(
      //               name: pr.name,
      //               productUuid: pr.uuid!,
      //               shopId: pr.shopId,
      //               groupUnit: pr.groupUnit,
      //               singleUnit: pr.unit,
      //             ),
      //           )
      //           .toList();
      //   List<Map<String, dynamic>> payload =
      //       temp.map((pr) => pr.toJson()).toList();
      //   await supabase.rpc(
      //     'insert_storage_products_bulk',
      //     params: {'products': payload},
      //   );
      //   print(
      //     "Storage Products Generation Successful Online",
      //   );
      //   // for (var pr in selectedProducts) {
      //   //   await returnEventsLogProvider().createLog(
      //   //     returnEventsLogProvider().productAdapter(pr, 1),
      //   //   );
      //   // }

      //   await getProducts(shopId());
      //   toggleIsSelectProduct(false);
      //   return 1;
      // } else {
      for (var pr in selectedProducts) {
        var newUuid = uuidGen();
        await returnStorageProductProvider()
            .createStorageProduct(
              TempStorageProducts(
                name: pr.name,
                shopId: pr.shopId,
                groupUnit: pr.groupUnit,
                unit: pr.unit,
                createdAt: DateTime.now(),
                uuid: newUuid,
                updatedAt: DateTime.now(),
                qttyPerGroup: pr.qttyPerGroup,
                costPrice: pr.costPrice,
                sellingPrice: pr.sellingPrice,
              ),
            );

        var product = pr.copyWith(storageUuid: newUuid);

        await updateProduct(product: product);
      }
      await getProductsOffline(shopId());
      toggleIsSelectProduct(false);
      return 1;
      // }
    } catch (e) {
      print(
        "Error Generating Multiple Storage Products: ${e.toString()}",
      );
      return 0;
    }
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
