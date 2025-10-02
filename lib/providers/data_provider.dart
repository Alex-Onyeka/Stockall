import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/unsynced/created_products/created_products.dart';
import 'package:stockall/classes/temp_product_class/unsynced/deleted_products/deleted_products.dart';
import 'package:stockall/classes/temp_product_class/unsynced/updated/updated_products.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/customers/unsync_funcs/created/created_customers_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/deleted/deleted_customers_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/updated/updated_customers_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/created_expenses/created_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/deleted_expenses/deleted_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/updated_expenses/updated_expenses_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/created/created_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/deleted/deleted_receipts_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/updated/updated_receipts_func.dart';
import 'package:stockall/local_database/product_record_func.dart/unsync_funcs/created/created_records_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/created_products%20copy/sales_product_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/created_products/created_product_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/deleted_products/deleted_products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/updated_products/updated_products_func.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/local_database/shop/updated_shop/updated_shop_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataProvider extends ChangeNotifier {
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

    product.uuid = uuidGen();
    product.updatedAt = DateTime.now();

    if (isOnline) {
      // if (isSynced() == 0 && context.mounted) {
      //   print('Syncing Data In t')
      //   syncData(context);
      // }
      var data =
          await supabase
              .from('products')
              .insert(product.toJson())
              .select()
              .single();
      print('Item added successfully');
      final newProduct = TempProductClass.fromJson(data);
      await ProductsFunc().createProduct(newProduct);
      print('Total Success');
    } else {
      product.createdAt ??= DateTime.now();

      await ProductsFunc().createProduct(product);
      await CreatedProductFunc().createProduct(
        CreatedProducts(product: product),
      );
      print('Offline Success');
      print('Offline Product inserted Successfully');
    }

    // productList.add(newProduct);
    if (context.mounted) {
      print('Mounted');
      await getProducts(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
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
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
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
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
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
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
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
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
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
    int isSynced =
        returnData(context, listen: false).isSynced();
    TempShopClass? shop = await returnShopProvider(
      context,
      listen: false,
    ).getUserShop(AuthService().currentUser!);
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      if (shop != null) {
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
              // await decrementProductsQuantitySync(context);
              print(
                'Finished Syncing Products Decrementiation',
              );
              setSyncProgress(11);
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
              ).createReceiptsSync(context);
              print('Finished Syncing Created Receipts');
              setSyncProgress(13);
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
              await returnShopProvider(
                context,
                listen: false,
              ).updateShopSync(context);
              print('Finished Syncing Created Receipts');
              setSyncProgress(16);
            }
            toggleSyncing(false);
          }
        }
      } else {
        await ShopFunc().clearShop();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/');
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
    syncProgress = (value / 16) * 100;
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
          UpdatedShopFunc().getUpdatedShop().isEmpty
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

  DateTime? expiryDate;
  void setExpDate(DateTime date) {
    expiryDate = date;
    notifyListeners();
  }

  void clearExpDate() {
    expiryDate = null;
    notifyListeners();
  }

  bool isStartDate = true;

  DateTime? startDate;
  DateTime? endDate;

  void changeDateBoolToTrue() {
    isStartDate = true;
    notifyListeners();
  }

  void clearStartDate() {
    startDate = null;
    notifyListeners();
  }

  void changeDateBoolToFalse() {
    isStartDate = false;
    notifyListeners();
  }

  void clearEndDate() {
    endDate = null;
    notifyListeners();
  }

  void setBothDates({
    DateTime? start,
    DateTime? end,
    DateTime? expDate,
  }) {
    startDate = start;
    endDate = end;
    expiryDate = expDate;
    notifyListeners();
  }

  void setDate(DateTime date) {
    if (isStartDate) {
      startDate = date;
    } else {
      endDate = date;
    }
    notifyListeners();
  }

  List<TempProductClass> productList = [];

  void clearProducts() {
    productList.clear();
    print('Products Cleared');
    notifyListeners();
  }

  Future<List<TempProductClass>> getProducts(
    int shopId,
  ) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      final data = await supabase
          .from('products')
          .select()
          .eq('shop_id', shopId)
          .order('name', ascending: true);
      print('Items gotten');
      productList =
          (data as List)
              .map(
                (json) => TempProductClass.fromJson(json),
              )
              .toList();
      await ProductsFunc().insertAllProducts(productList);
    } else {
      productList = ProductsFunc().getProducts();
    }
    notifyListeners();
    return productList;
  }

  Future<List<TempProductClass>> searchProductName(
    BuildContext context,
    String name,
  ) async {
    var temp = await getProducts(shopId(context));
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

  Future<void> updateProduct({
    required TempProductClass product,
    required BuildContext context,
  }) async {
    bool isOnline = await connectivity.isOnline();

    print(product.isManaged.toString());
    if (isOnline) {
      product.updatedAt = DateTime.now().toLocal();
      await supabase
          .from('products')
          .update(product.toJson())
          .eq('uuid', product.uuid!);
      print('${product.uuid}');
    } else {
      await ProductsFunc().updateProduct(product);
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
    }
    if (context.mounted) {
      print('Context Mounted');
      await getProducts(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
      );
    } else {
      print('Context Not Mounted');
    }
    notifyListeners();
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
  //       ).userShop!.shopId!,
  //     );
  //   }
  //   notifyListeners();
  //   return response != null;
  // }

  Future<bool> updateDiscount({
    required String productUuid,
    required double? newDiscount,
    DateTime? statDate,
    DateTime? endDate,
    required BuildContext context,
  }) async {
    final response =
        await supabase
            .from('products')
            .update({
              'discount': newDiscount,
              'starting_date':
                  startDate
                      ?.toIso8601String()
                      .split('T')
                      .first,
              'ending_date':
                  endDate
                      ?.toIso8601String()
                      .split('T')
                      .first,
              'updated_at': DateTime.now(),
            })
            .eq('uuid', productUuid)
            .maybeSingle();

    if (context.mounted) {
      await getProducts(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
      );
    }
    notifyListeners();
    return response != null;
  }

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
  //       ).userShop!.shopId!,
  //     );
  //   }
  //   notifyListeners();
  //   return response != null;
  // }

  Future<void> deleteProductMain(
    String productUuid,
    BuildContext context,
  ) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      await supabase
          .from('products')
          .delete()
          .eq('uuid', productUuid);
    } else {
      await ProductsFunc().deleteProduct(productUuid);
      var containsCreated =
          CreatedProductFunc()
              .getProducts()
              .where(
                (product) =>
                    product.product.uuid == productUuid,
              )
              .toList();

      var containsUpdated =
          UpdatedProductsFunc()
              .getProducts()
              .where(
                (product) =>
                    product.product.uuid == productUuid,
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
            .delete(productUuid);
      } else {
        await DeletedProductsFunc().createDeletedProduct(
          DeletedProducts(
            productUuid: productUuid,
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
    }
    if (context.mounted) {
      await getProducts(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
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

  void clearFields() {
    isProductRefundable = false;
    setCustomPrice = false;
    isRefundable = false;
    selectedCategory = null;
    selectedColor = null;
    selectedSize = null;
    inStock = false;
    catValueSet = false;
    isManaged = true;
    isOpen = false;
    unitValueSet = false;
    colorValueSet = false;
    sizeValueSet = false;
    clearEndDate();
    clearStartDate();
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

  void toggleIsManaged() {
    isManaged = !isManaged;
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

  void toggleCatOpen() {
    isOpen = !isOpen;
    notifyListeners();
  }

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

      // final uiProvider = returnData(context, listen: false);

      if (!isFloatingButtonVisible) {
        showFloatingActionButton();
        hideFloatingActionButtonWithDelay();
      } else {
        hideFloatingActionButtonWithDelay();
      }
    });
  }
}
