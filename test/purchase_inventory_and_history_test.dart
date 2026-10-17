import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_purchase/purchase_list_item/purchase_list_item.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history_event_class.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/item_history/item_histories_func.dart';
import 'package:stockall/local_database/item_history/unsync_funcs/created_item_histories_func.dart';
import 'package:stockall/local_database/item_purchase_func.dart%20copy/item_purchase_func.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/main_database.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/created_products/created_product_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/deleted_products/deleted_products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/updated_products/updated_products_func.dart';
import 'package:stockall/local_database/purchases/purchase_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/created/created_purchases_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/deleted/deleted_purchases_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/updated/updated_purchases_func.dart';
import 'package:stockall/local_database/storage_item_history/storage_item_histories_func.dart';
import 'package:stockall/local_database/storage_item_history/unsync_funcs/created_item_histories_func.dart';
import 'package:stockall/local_database/storage_product/storage_products_func.dart';
import 'package:stockall/local_database/storage_product/unsync_funcs/created/created_storage_products_func.dart';
import 'package:stockall/local_database/storage_product/unsync_funcs/deleted/deleted_storage_products_func.dart';
import 'package:stockall/local_database/storage_product/unsync_funcs/updated/updated_storage_products_func.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/item_history_provider.dart';
import 'package:stockall/providers/purchase_action_provider.dart';
import 'package:stockall/providers/purchase_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/storage_item_history_provider.dart';
import 'package:stockall/providers/storage_product_provider.dart';
import 'package:stockall/providers/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MemoryAsyncStorage extends GotrueAsyncStorage {
  final _items = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async => _items[key];

  @override
  Future<void> setItem({
    required String key,
    required String value,
  }) async => _items[key] = value;

  @override
  Future<void> removeItem({required String key}) async => _items.remove(key);
}

void main() {
  const pathProviderChannel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );
  const connectivityChannel = MethodChannel(
    'dev.fluttercommunity.plus/connectivity',
  );
  late Directory tempDir;

  TempShopClass makeShop({
    int shopId = 101,
    required bool manageInventoryStorage,
  }) {
    return TempShopClass(
      shopId: shopId,
      createdAt: DateTime.utc(2026, 1, 1),
      userId: 'user-1',
      name: 'Test Shop',
      currency: 'NGN',
      isVerified: true,
      isHeadQuarters: true,
      manageInventoryStorage: manageInventoryStorage,
      wholeSale: false,
      manageDepartments: false,
      printSalesDocket: false,
      closeSaleTimeString: null,
      trackCart: false,
      accessPin: null,
      manageProductions: false,
      manageProductionsStorage: false,
      manageProductionItems: false,
      customerPercentageReward: null,
      manageCustomerReward: false,
      manageCustomerAccount: false,
    );
  }

  TempProductClass makeProduct({
    String uuid = 'prod-1',
    String name = 'Bottled Water',
    int shopId = 101,
    String unit = 'Bottle',
    double quantity = 20,
    double costPrice = 100,
    double sellingPrice = 150,
    bool useGroupUnit = false,
    String? groupUnit,
    double? qttyPerGroup,
    List<ProductUnitsClass>? unitsList,
    int? quantityType = 1,
    double? widthDimension,
    double? heightDimension,
  }) {
    return TempProductClass(
      uuid: uuid,
      name: name,
      shopId: shopId,
      unit: unit,
      isRefundable: true,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      quantity: quantity,
      setCustomPrice: false,
      departmentName: null,
      departmentUuid: null,
      isManaged: true,
      groupUnit: groupUnit,
      qttyPerGroup: qttyPerGroup,
      wholeSalePrice: null,
      storageUuid: null,
      categories: [],
      useGroupUnit: useGroupUnit,
      unitsList: unitsList,
      pricesList: [
        ProductPricesClass(
          uuid: '${uuid}_price',
          staffUuid: 'staff-1',
          createdAt: DateTime.utc(2026, 1, 1),
          staffName: 'Tester',
          priceValue: sellingPrice,
          name: 'Default',
          isPrimary: true,
          itemUuid: uuid,
        ),
      ],
      quantityType: quantityType,
      widthDimension: widthDimension,
      heightDimension: heightDimension,
      manageSalesWastage: false,
    );
  }

  TempStorageProducts makeStorageProduct({
    String uuid = 'storage-1',
    String name = 'Warehouse Water',
    int shopId = 101,
    String unit = 'Bottle',
    double quantity = 50,
    double costPrice = 90,
    double sellingPrice = 140,
    bool useGroupUnit = false,
    String? groupUnit,
    double? qttyPerGroup,
    List<ProductUnitsClass>? unitsList,
  }) {
    return TempStorageProducts(
      uuid: uuid,
      createdAt: DateTime.utc(2026, 1, 1),
      shopId: shopId,
      name: name,
      quantity: quantity,
      unit: unit,
      groupUnit: groupUnit,
      qttyPerGroup: qttyPerGroup,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      useGroupUnit: useGroupUnit,
      unitsList: unitsList,
    );
  }

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = Directory.systemTemp.createTempSync('stockall_purchase_test_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          pathProviderChannel,
          (call) async => tempDir.path,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          connectivityChannel,
          (call) async => <String>['none'],
        );

    final logFile = File('${tempDir.path}/mainLog.log');
    if (!logFile.existsSync()) {
      logFile.createSync(recursive: true);
    }

    await Supabase.initialize(
      url: 'http://localhost',
      anonKey: 'test-anon-key',
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: _MemoryAsyncStorage(),
        detectSessionInUri: false,
        autoRefreshToken: false,
      ),
    );

    await MainDatabase().initHive();
  });

  tearDownAll(() async {
    await Hive.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  setUp(() async {
    ConnectivityProvider().isConnected = false;
    await LoggedInUserFunc().insertLoggedInUser(
      LoggedInUser(
        loggedInUser: TempUserClass(
          password: 'pw',
          userId: 'staff-1',
          name: 'Alex Staff',
          email: 'alex@stockall.test',
          role: 'Owner',
          departmentUuids: [],
          createdAt: DateTime.utc(2026, 1, 1),
          access: [],
        ),
      ),
    );
    await UserProvider().fetchCurrentUserOffline();

    await ProductsFunc().clearProducts();
    await CreatedProductFunc().clearProducts();
    await UpdatedProductsFunc().clearupdatedProducts();
    await DeletedProductsFunc().clearDeletedProducts();
    await QuantityUpdateFunc().clearQuantitiesUpdate();

    await ItemHistoriesFunc().clearItemHistories();
    await CreatedItemHistoriesFunc().clearItemHistory();
    ItemHistoryProvider().itemHistories.clear();

    await StorageProductsFunc().clearStorageProducts();
    await CreatedStorageProductsFunc().clearCreatedStorageProducts();
    await UpdatedStorageProductsFunc().clearUpdatedStorageProduct();
    await DeletedStorageProductsFunc().clearDeletedStorageProduct();

    await StorageItemHistoriesFunc().clearStorageItemHistories();
    await CreatedStorageItemHistoriesFunc().clearStorageItemHistory();
    StorageItemHistoryProvider().storageItemHistories.clear();

    await PurchaseFunc().clearPurchases();
    await CreatedPurchasesFunc().clearPurchases();
    await UpdatedPurchasesFunc().clearUpdatedPurchases();
    await DeletedPurchasesFunc().clearDeletedPurchases();
    await ItemPurchaseFunc().clearRecords();

    DataProvider().clearProducts();
    StorageProductProvider().clearProducts();
    PurchaseProvider().clearPurchases();
    PurchaseActionProvider().clearAll();
  });

  Future<void> seedEnvironment({
    required bool manageInventoryStorage,
    List<TempProductClass> products = const [],
    List<TempStorageProducts> storageProducts = const [],
  }) async {
    final shop = makeShop(
      shopId: 101,
      manageInventoryStorage: manageInventoryStorage,
    );
    ShopProvider().setShops([shop]);

    if (products.isNotEmpty) {
      await ProductsFunc().insertAllProducts(products);
    }
    await DataProvider().getProductsOffline(101);

    if (storageProducts.isNotEmpty) {
      await StorageProductsFunc().insertAllStorageProducts(storageProducts);
    }
    await StorageProductProvider().getStorageProductsOffline(101);
  }

  group('Manage Storage Disabled (Ordinary Products)', () {
    test(
      '1, 2, 3, 7, 18: Primary-unit purchase increases products quantity, creates ordinary ItemHistory, and does not touch storage_products',
      () async {
        final product = makeProduct(
          uuid: 'prod-water',
          name: 'Bottled Water',
          unit: 'Bottle',
          quantity: 20,
          costPrice: 100,
        );
        final storageProduct = makeStorageProduct(
          uuid: 'storage-water',
          name: 'Storage Water',
          unit: 'Bottle',
          quantity: 50,
        );
        await seedEnvironment(
          manageInventoryStorage: false,
          products: [product],
          storageProducts: [storageProduct],
        );

        final units = product.getUnitListFinal();
        final primaryUnit = units.firstWhere((u) => u.isPrimary);

        PurchaseActionProvider().addItemToList(
          item: PurchaseListItem(
            itemName: product.name,
            itemUuid: product.uuid,
            storageItemUuid: null,
            unit: primaryUnit.name,
            unitUuid: primaryUnit.uuid,
            unitsList: units,
            quantity: 15,
            originalPrice: product.costPrice,
            customPrice: null,
            totalPrice: 1500,
            isGroup: false,
            qttyPerGroup: product.qttyPerGroup,
          ),
        );

        final res = await PurchaseActionProvider().createPurchaseAction();
        expect(res, 1);

        // 1. Products record increased from 20 to 35
        final updatedProd = ProductsFunc().getSingleProduct(uuid: 'prod-water');
        expect(updatedProd, isNotNull);
        expect(updatedProd!.quantity, 35);
        expect(
          DataProvider().productListMain
              .firstWhere((p) => p.uuid == 'prod-water')
              .quantity,
          35,
        );

        // Queued quantity update for Supabase sync
        final queuedUpdates = QuantityUpdateFunc().getQuantitiesUpdate();
        expect(queuedUpdates.length, 1);
        expect(queuedUpdates.first.productUuid, 'prod-water');
        expect(queuedUpdates.first.quantity, 15);
        expect(queuedUpdates.first.isIncrement, isTrue);

        // 2 & 18. Ordinary ItemHistory created with expected fields
        final histories = ItemHistoriesFunc().getItemHistories();
        expect(histories.length, 1);
        final history = histories.first;
        expect(history.shopId, 101);
        expect(history.itemUuid, 'prod-water');
        expect(history.itemName, 'Bottled Water');
        expect(history.event, ItemHistoryEventClass.purchase);
        expect(history.source, ItemHistoryEventClass.purchaseSource);
        expect(history.destination, ItemHistoryEventClass.productDestination);
        expect(history.isIncreased, isTrue);
        expect(double.parse(history.oldValue!), 20);
        expect(double.parse(history.newValue!), 35);
        expect(history.quantityChange, 15);
        expect(history.unit, 'Bottle');
        expect(history.primaryUnit, 'Bottle');
        expect(
          CreatedItemHistoriesFunc().getCreatedItemHistoriess().length,
          1,
        );

        // 3. Storage products and StorageItemHistory untouched
        expect(
          StorageProductsFunc()
              .getStorageProducts()
              .firstWhere((s) => s.uuid == 'storage-water')
              .quantity,
          50,
        );
        expect(StorageItemHistoriesFunc().getStorageItemHistories(), isEmpty);
      },
    );

    test(
      '8: Secondary/group-unit purchase (unitsList & legacy qttyPerGroup) converts quantity before updating products inventory',
      () async {
        final primaryBottle = ProductUnitsClass(
          uuid: 'u-bottle',
          staffUuid: 'staff-1',
          createdAt: DateTime.utc(2026, 1, 1),
          staffName: 'Tester',
          conversion: 1,
          name: 'Bottle',
          isPrimary: true,
          productUuid: 'prod-juice',
        );
        final cartonUnit = ProductUnitsClass(
          uuid: 'u-carton',
          staffUuid: 'staff-1',
          createdAt: DateTime.utc(2026, 1, 1),
          staffName: 'Tester',
          conversion: 12,
          name: 'Carton',
          isPrimary: false,
          productUuid: 'prod-juice',
        );

        final productWithUnitsList = makeProduct(
          uuid: 'prod-juice',
          name: 'Fruit Juice',
          unit: 'Bottle',
          quantity: 10,
          unitsList: [primaryBottle, cartonUnit],
        );

        final legacyGroupProduct = makeProduct(
          uuid: 'prod-milk',
          name: 'Tinned Milk',
          unit: 'Tin',
          groupUnit: 'Pack',
          useGroupUnit: true,
          qttyPerGroup: 24,
          quantity: 6,
          unitsList: null,
        );

        await seedEnvironment(
          manageInventoryStorage: false,
          products: [productWithUnitsList, legacyGroupProduct],
        );

        // Purchase 3 Cartons (3 * 12 = 36 Bottles) of prod-juice
        // and 2 Packs (2 * 24 = 48 Tins) of legacyGroupProduct
        final milkUnits = legacyGroupProduct.getUnitListFinal();
        final milkPackUnit = milkUnits.firstWhere((u) => !u.isPrimary);

        PurchaseActionProvider().addItemToList(
          item: PurchaseListItem(
            itemName: productWithUnitsList.name,
            itemUuid: productWithUnitsList.uuid,
            storageItemUuid: null,
            unit: cartonUnit.name,
            unitUuid: cartonUnit.uuid,
            unitsList: productWithUnitsList.getUnitListFinal(),
            quantity: 3,
            originalPrice: 100,
            customPrice: null,
            totalPrice: 3600,
            isGroup: true,
            qttyPerGroup: 12,
          ),
        );

        PurchaseActionProvider().addItemToList(
          item: PurchaseListItem(
            itemName: legacyGroupProduct.name,
            itemUuid: legacyGroupProduct.uuid,
            storageItemUuid: null,
            unit: milkPackUnit.name,
            unitUuid: milkPackUnit.uuid,
            unitsList: milkUnits,
            quantity: 2,
            originalPrice: 200,
            customPrice: null,
            totalPrice: 9600,
            isGroup: true,
            qttyPerGroup: 24,
          ),
        );

        final res = await PurchaseActionProvider().createPurchaseAction();
        expect(res, 1);

        // 10 + 36 = 46 Bottles
        final updatedJuice = ProductsFunc().getSingleProduct(uuid: 'prod-juice');
        expect(updatedJuice!.quantity, 46);

        // 6 + 48 = 54 Tins
        final updatedMilk = ProductsFunc().getSingleProduct(uuid: 'prod-milk');
        expect(updatedMilk!.quantity, 54);

        final histories = ItemHistoriesFunc().getItemHistories();
        expect(histories.length, 2);

        final juiceHistory = histories.firstWhere(
          (h) => h.itemUuid == 'prod-juice',
        );
        expect(double.parse(juiceHistory.oldValue!), 10);
        expect(double.parse(juiceHistory.newValue!), 46);
        expect(juiceHistory.quantityChange, 3);
        expect(juiceHistory.unit, 'Carton');
        expect(juiceHistory.primaryUnit, 'Bottle');

        final milkHistory = histories.firstWhere(
          (h) => h.itemUuid == 'prod-milk',
        );
        expect(double.parse(milkHistory.oldValue!), 6);
        expect(double.parse(milkHistory.newValue!), 54);
        expect(milkHistory.quantityChange, 2);
        expect(milkHistory.unit, 'Pack');
        expect(milkHistory.primaryUnit, 'Tin');
      },
    );

    test(
      '9: Purchasing a fractional quantity updates inventory and history with the correct fractional or converted quantity',
      () async {
        final kgUnit = ProductUnitsClass(
          uuid: 'u-kg',
          staffUuid: 'staff-1',
          createdAt: DateTime.utc(2026, 1, 1),
          staffName: 'Tester',
          conversion: 1,
          name: 'Kg',
          isPrimary: true,
          productUuid: 'prod-rice',
        );
        final bagUnit = ProductUnitsClass(
          uuid: 'u-bag',
          staffUuid: 'staff-1',
          createdAt: DateTime.utc(2026, 1, 1),
          staffName: 'Tester',
          conversion: 50,
          name: 'Bag',
          isPrimary: false,
          productUuid: 'prod-rice',
        );

        final rice = makeProduct(
          uuid: 'prod-rice',
          name: 'Rice',
          unit: 'Kg',
          quantity: 12.5,
          unitsList: [kgUnit, bagUnit],
        );

        await seedEnvironment(
          manageInventoryStorage: false,
          products: [rice],
        );

        // Purchase 1.5 Bags = 75 Kg -> 12.5 + 75 = 87.5 Kg
        PurchaseActionProvider().addItemToList(
          item: PurchaseListItem(
            itemName: rice.name,
            itemUuid: rice.uuid,
            storageItemUuid: null,
            unit: bagUnit.name,
            unitUuid: bagUnit.uuid,
            unitsList: rice.getUnitListFinal(),
            quantity: 1.5,
            originalPrice: 1000,
            customPrice: null,
            totalPrice: 75000,
            isGroup: true,
            qttyPerGroup: 50,
          ),
        );

        final res = await PurchaseActionProvider().createPurchaseAction();
        expect(res, 1);

        final updatedRice = ProductsFunc().getSingleProduct(uuid: 'prod-rice');
        expect(updatedRice!.quantity, closeTo(87.5, 1e-6));

        final history = ItemHistoriesFunc().getItemHistories().single;
        expect(history.oldValue, '12.5');
        expect(history.newValue, '87.5');
        expect(history.quantityChange, 1.5);
        expect(history.unit, 'Bag');
        expect(history.primaryUnit, 'Kg');
      },
    );

    test(
      '10: Purchasing a two-dimensional item preserves the existing dimensional quantity model',
      () async {
        // 2D product: 4m x 3m sheet (12 m² per sheet).
        // Stored quantity = 5 sheets (getActualQuantity() = 60 m²).
        final sheetPrimary = ProductUnitsClass(
          uuid: 'u-sheet',
          staffUuid: 'staff-1',
          createdAt: DateTime.utc(2026, 1, 1),
          staffName: 'Tester',
          conversion: 1,
          name: 'Sheet',
          isPrimary: true,
          productUuid: 'prod-glass',
          dimensionType: ProductUnitsClass.sheetUnit,
        );
        final sqmUnit = ProductUnitsClass(
          uuid: 'u-sqm',
          staffUuid: 'staff-1',
          createdAt: DateTime.utc(2026, 1, 1),
          staffName: 'Tester',
          conversion: 1,
          name: 'Sqm',
          isPrimary: false,
          productUuid: 'prod-glass',
          dimensionType: ProductUnitsClass.areaUnit,
        );

        final glass = makeProduct(
          uuid: 'prod-glass',
          name: 'Tempered Glass',
          unit: 'Sheet',
          quantity: 5, // 5 sheets = 60 m²
          quantityType: 2,
          widthDimension: 4,
          heightDimension: 3,
          unitsList: [sheetPrimary, sqmUnit],
        );

        await seedEnvironment(
          manageInventoryStorage: false,
          products: [glass],
        );

        // Purchase 3 Sheets -> should increase sheets from 5 to 8 (area from 60 to 96)
        PurchaseActionProvider().addItemToList(
          item: PurchaseListItem(
            itemName: glass.name,
            itemUuid: glass.uuid,
            storageItemUuid: null,
            unit: sheetPrimary.name,
            unitUuid: sheetPrimary.uuid,
            unitsList: glass.getUnitListFinal(),
            quantity: 3,
            originalPrice: 500,
            customPrice: null,
            totalPrice: 18000,
            isGroup: false,
            qttyPerGroup: null,
          ),
        );

        final res = await PurchaseActionProvider().createPurchaseAction();
        expect(res, 1);

        final updatedGlass = ProductsFunc().getSingleProduct(uuid: 'prod-glass');
        expect(updatedGlass!.quantity, closeTo(8, 1e-6));
        expect(updatedGlass.getActualQuantity(), closeTo(96, 1e-6));

        final history = ItemHistoriesFunc().getItemHistories().single;
        expect(double.parse(history.oldValue!), 5);
        expect(double.parse(history.newValue!), 8);
        expect(history.quantityChange, 3);
        expect(history.unit, 'Sheet');

        // Also test purchasing by area unit (24 Sqm = 2 Sheets -> 8 + 2 = 10 Sheets)
        PurchaseActionProvider().addItemToList(
          item: PurchaseListItem(
            itemName: glass.name,
            itemUuid: glass.uuid,
            storageItemUuid: null,
            unit: sqmUnit.name,
            unitUuid: sqmUnit.uuid,
            unitsList: glass.getUnitListFinal(),
            quantity: 24,
            originalPrice: 500,
            customPrice: null,
            totalPrice: 12000,
            isGroup: false,
            qttyPerGroup: null,
          ),
        );

        final res2 = await PurchaseActionProvider().createPurchaseAction();
        expect(res2, 1);

        final updatedGlass2 = ProductsFunc().getSingleProduct(uuid: 'prod-glass');
        expect(updatedGlass2!.quantity, closeTo(10, 1e-6));
        expect(updatedGlass2.getActualQuantity(), closeTo(120, 1e-6));
      },
    );
  });

  group('Manage Storage Enabled (Storage Products)', () {
    test(
      '4, 5, 6, 18: Creating a purchase with Manage Storage enabled updates storage_products, creates StorageItemHistory, and does not touch ordinary products',
      () async {
        final ordinaryProduct = makeProduct(
          uuid: 'prod-1',
          name: 'Shop Floor Soda',
          unit: 'Bottle',
          quantity: 15,
        );
        final storagePrimary = ProductUnitsClass(
          uuid: 'su-bottle',
          staffUuid: 'staff-1',
          createdAt: DateTime.utc(2026, 1, 1),
          staffName: 'Tester',
          conversion: 1,
          name: 'Bottle',
          isPrimary: true,
          productUuid: 'storage-1',
        );
        final storageCrate = ProductUnitsClass(
          uuid: 'su-crate',
          staffUuid: 'staff-1',
          createdAt: DateTime.utc(2026, 1, 1),
          staffName: 'Tester',
          conversion: 24,
          name: 'Crate',
          isPrimary: false,
          productUuid: 'storage-1',
        );
        final storageProduct = makeStorageProduct(
          uuid: 'storage-1',
          name: 'Warehouse Soda',
          unit: 'Bottle',
          quantity: 100,
          unitsList: [storagePrimary, storageCrate],
        );

        await seedEnvironment(
          manageInventoryStorage: true,
          products: [ordinaryProduct],
          storageProducts: [storageProduct],
        );

        // Purchase 2 Crates (2 * 24 = 48 Bottles) into Storage
        PurchaseActionProvider().addItemToList(
          item: PurchaseListItem(
            itemName: storageProduct.name,
            itemUuid: null,
            storageItemUuid: storageProduct.uuid,
            unit: storageCrate.name,
            unitUuid: storageCrate.uuid,
            unitsList: storageProduct.getUnitListFinal(),
            quantity: 2,
            originalPrice: 80,
            customPrice: null,
            totalPrice: 3840,
            isGroup: true,
            qttyPerGroup: 24,
          ),
        );

        final res = await PurchaseActionProvider().createPurchaseAction();
        expect(res, 1);

        // 4. Storage product increased from 100 to 148
        final updatedStorage = StorageProductsFunc()
            .getStorageProducts()
            .firstWhere((s) => s.uuid == 'storage-1');
        expect(updatedStorage.quantity, 148);
        expect(
          StorageProductProvider().storageProductListMain
              .firstWhere((s) => s.uuid == 'storage-1')
              .quantity,
          148,
        );
        expect(
          UpdatedStorageProductsFunc().getStorageProductIds().length,
          1,
        );

        // 5 & 18. StorageItemHistory created with expected fields
        final storageHistories =
            StorageItemHistoriesFunc().getStorageItemHistories();
        expect(storageHistories.length, 1);
        final sh = storageHistories.first;
        expect(sh.shopId, 101);
        expect(sh.storageItemUuid, 'storage-1');
        expect(sh.storageItemName, 'Warehouse Soda');
        expect(sh.event, StorageItemHistoryEventClass.purchase);
        expect(sh.source, StorageItemHistoryEventClass.purchaseSource);
        expect(
          sh.destination,
          StorageItemHistoryEventClass.storageDestination,
        );
        expect(sh.isIncreased, isTrue);
        expect(double.parse(sh.storageItemOldValue!), 100);
        expect(double.parse(sh.storageItemNewValue!), 148);
        expect(sh.quantityChange, 2);
        expect(sh.storageUnit, 'Crate');
        expect(sh.storagePrimaryUnit, 'Bottle');
        expect(
          CreatedStorageItemHistoriesFunc()
              .getCreatedStorageItemHistoriess()
              .length,
          1,
        );

        // 6. Ordinary products and ordinary ItemHistory untouched
        expect(
          ProductsFunc().getSingleProduct(uuid: 'prod-1')!.quantity,
          15,
        );
        expect(ItemHistoriesFunc().getItemHistories(), isEmpty);
      },
    );
  });

  group('Purchase Deletion Behaviour & Double-Reversal Prevention', () {
    test(
      '11, 12: Deleting a purchase without returning items deletes the purchase record without decreasing inventory or creating return history',
      () async {
        final product = makeProduct(
          uuid: 'prod-del-keep',
          name: 'Notebook',
          unit: 'Piece',
          quantity: 10,
        );
        await seedEnvironment(
          manageInventoryStorage: false,
          products: [product],
        );

        final units = product.getUnitListFinal();
        PurchaseActionProvider().addItemToList(
          item: PurchaseListItem(
            itemName: product.name,
            itemUuid: product.uuid,
            storageItemUuid: null,
            unit: units.first.name,
            unitUuid: units.first.uuid,
            unitsList: units,
            quantity: 5,
            originalPrice: 200,
            customPrice: null,
            totalPrice: 1000,
            isGroup: false,
            qttyPerGroup: null,
          ),
        );

        await PurchaseActionProvider().createPurchaseAction();
        expect(
          ProductsFunc().getSingleProduct(uuid: 'prod-del-keep')!.quantity,
          15,
        );
        expect(ItemHistoriesFunc().getItemHistories().length, 1);
        expect(PurchaseProvider().purchases.length, 1);

        final savedPurchase = PurchaseProvider().purchases.first;

        // Delete WITHOUT returning items (updateInventory: false)
        final delRes = await PurchaseProvider().deletePurchase(
          savedPurchase,
          false,
          true,
        );
        expect(delRes, 1);

        // Purchase record is deleted
        expect(PurchaseFunc().getPurchases(), isEmpty);
        expect(PurchaseProvider().purchases, isEmpty);

        // Inventory stays at 15 (not decreased)
        expect(
          ProductsFunc().getSingleProduct(uuid: 'prod-del-keep')!.quantity,
          15,
        );

        // No return/decrease history created (still only the 1 creation history)
        final histories = ItemHistoriesFunc().getItemHistories();
        expect(histories.length, 1);
        expect(histories.single.event, ItemHistoryEventClass.purchase);
      },
    );

    test(
      '13, 14, 17: Deleting a purchase with returned items and Manage Storage disabled decreases products by converted quantity, creates return ItemHistory, and prevents double reversal on retry',
      () async {
        final primaryUnit = ProductUnitsClass(
          uuid: 'u-can',
          staffUuid: 'staff-1',
          createdAt: DateTime.utc(2026, 1, 1),
          staffName: 'Tester',
          conversion: 1,
          name: 'Can',
          isPrimary: true,
          productUuid: 'prod-cans',
        );
        final packUnit = ProductUnitsClass(
          uuid: 'u-pack6',
          staffUuid: 'staff-1',
          createdAt: DateTime.utc(2026, 1, 1),
          staffName: 'Tester',
          conversion: 6,
          name: 'SixPack',
          isPrimary: false,
          productUuid: 'prod-cans',
        );

        final product = makeProduct(
          uuid: 'prod-cans',
          name: 'Energy Drink',
          unit: 'Can',
          quantity: 12,
          unitsList: [primaryUnit, packUnit],
        );

        await seedEnvironment(
          manageInventoryStorage: false,
          products: [product],
        );

        // Purchase 4 SixPacks (24 Cans) -> 12 + 24 = 36 Cans
        PurchaseActionProvider().addItemToList(
          item: PurchaseListItem(
            itemName: product.name,
            itemUuid: product.uuid,
            storageItemUuid: null,
            unit: packUnit.name,
            unitUuid: packUnit.uuid,
            unitsList: product.getUnitListFinal(),
            quantity: 4,
            originalPrice: 300,
            customPrice: null,
            totalPrice: 7200,
            isGroup: true,
            qttyPerGroup: 6,
          ),
        );

        await PurchaseActionProvider().createPurchaseAction();
        expect(
          ProductsFunc().getSingleProduct(uuid: 'prod-cans')!.quantity,
          36,
        );

        final savedPurchase = PurchaseProvider().purchases.first;

        // Delete WITH returned items (updateInventory: true)
        final delRes = await PurchaseProvider().deletePurchase(
          savedPurchase,
          true,
          true,
        );
        expect(delRes, 1);

        // 13. Products quantity decreased from 36 back to 12
        expect(
          ProductsFunc().getSingleProduct(uuid: 'prod-cans')!.quantity,
          12,
        );

        // 14. Return ItemHistory created
        final histories = ItemHistoriesFunc().getItemHistories();
        expect(histories.length, 2);
        final returnHistory = histories.firstWhere(
          (h) => h.event == ItemHistoryEventClass.returnEvent,
        );
        expect(returnHistory.shopId, 101);
        expect(returnHistory.itemUuid, 'prod-cans');
        expect(returnHistory.isIncreased, isFalse);
        expect(double.parse(returnHistory.oldValue!), 36);
        expect(double.parse(returnHistory.newValue!), 12);
        expect(returnHistory.quantityChange, 4);
        expect(returnHistory.unit, 'SixPack');
        expect(returnHistory.primaryUnit, 'Can');
        expect(
          returnHistory.source,
          ItemHistoryEventClass.productSource,
        );
        expect(
          returnHistory.destination,
          ItemHistoryEventClass.purchaseDestination,
        );

        // 17. Retrying/repeating deletePurchase on the same purchase does NOT subtract a second time
        await PurchaseProvider().deletePurchase(
          savedPurchase,
          true,
          true,
        );
        expect(
          ProductsFunc().getSingleProduct(uuid: 'prod-cans')!.quantity,
          12,
        );
        expect(ItemHistoriesFunc().getItemHistories().length, 2);
      },
    );

    test(
      '15, 16, 17: Deleting a purchase with returned items and Manage Storage enabled decreases storage_products by converted quantity, creates StorageItemHistory, and prevents double reversal',
      () async {
        final primaryUnit = ProductUnitsClass(
          uuid: 'su-bag',
          staffUuid: 'staff-1',
          createdAt: DateTime.utc(2026, 1, 1),
          staffName: 'Tester',
          conversion: 1,
          name: 'Bag',
          isPrimary: true,
          productUuid: 'storage-cement',
        );
        final palletUnit = ProductUnitsClass(
          uuid: 'su-pallet',
          staffUuid: 'staff-1',
          createdAt: DateTime.utc(2026, 1, 1),
          staffName: 'Tester',
          conversion: 40,
          name: 'Pallet',
          isPrimary: false,
          productUuid: 'storage-cement',
        );

        final storageProduct = makeStorageProduct(
          uuid: 'storage-cement',
          name: 'Cement',
          unit: 'Bag',
          quantity: 100,
          unitsList: [primaryUnit, palletUnit],
        );

        await seedEnvironment(
          manageInventoryStorage: true,
          storageProducts: [storageProduct],
        );

        // Purchase 2 Pallets (80 Bags) -> 100 + 80 = 180 Bags
        PurchaseActionProvider().addItemToList(
          item: PurchaseListItem(
            itemName: storageProduct.name,
            itemUuid: null,
            storageItemUuid: storageProduct.uuid,
            unit: palletUnit.name,
            unitUuid: palletUnit.uuid,
            unitsList: storageProduct.getUnitListFinal(),
            quantity: 2,
            originalPrice: 5000,
            customPrice: null,
            totalPrice: 400000,
            isGroup: true,
            qttyPerGroup: 40,
          ),
        );

        await PurchaseActionProvider().createPurchaseAction();
        expect(
          StorageProductsFunc()
              .getStorageProducts()
              .firstWhere((s) => s.uuid == 'storage-cement')
              .quantity,
          180,
        );

        final savedPurchase = PurchaseProvider().purchases.first;

        // Delete WITH returned items (updateInventory: true)
        final delRes = await PurchaseProvider().deletePurchase(
          savedPurchase,
          true,
          true,
        );
        expect(delRes, 1);

        // 15. Storage product decreased from 180 back to 100
        expect(
          StorageProductsFunc()
              .getStorageProducts()
              .firstWhere((s) => s.uuid == 'storage-cement')
              .quantity,
          100,
        );

        // 16. StorageItemHistory decrease record created
        final histories =
            StorageItemHistoriesFunc().getStorageItemHistories();
        expect(histories.length, 2);
        final deleteHistory = histories.firstWhere(
          (h) => h.event == StorageItemHistoryEventClass.purchaseDeleted,
        );
        expect(deleteHistory.shopId, 101);
        expect(deleteHistory.storageItemUuid, 'storage-cement');
        expect(deleteHistory.isIncreased, isFalse);
        expect(double.parse(deleteHistory.storageItemOldValue!), 180);
        expect(double.parse(deleteHistory.storageItemNewValue!), 100);
        expect(deleteHistory.quantityChange, 2);
        expect(deleteHistory.storageUnit, 'Pallet');
        expect(deleteHistory.storagePrimaryUnit, 'Bag');
        expect(
          deleteHistory.source,
          StorageItemHistoryEventClass.storageSource,
        );
        expect(
          deleteHistory.destination,
          StorageItemHistoryEventClass.purchaseDestination,
        );

        // 17. Retrying deletePurchase does NOT subtract inventory a second time
        await PurchaseProvider().deletePurchase(
          savedPurchase,
          true,
          true,
        );
        expect(
          StorageProductsFunc()
              .getStorageProducts()
              .firstWhere((s) => s.uuid == 'storage-cement')
              .quantity,
          100,
        );
        expect(
          StorageItemHistoriesFunc().getStorageItemHistories().length,
          2,
        );
      },
    );
  });

  group('Failure Handling, Cart Editing & Regression Checks', () {
    test(
      '19: If inventory update fails (missing product), no misleading history record is created',
      () async {
        await seedEnvironment(
          manageInventoryStorage: false,
          products: [],
        );

        PurchaseActionProvider().addItemToList(
          item: PurchaseListItem(
            itemName: 'Nonexistent Product',
            itemUuid: 'missing-prod-uuid',
            storageItemUuid: null,
            unit: 'Piece',
            unitUuid: 'u-piece',
            unitsList: [],
            quantity: 10,
            originalPrice: 100,
            customPrice: null,
            totalPrice: 1000,
            isGroup: false,
            qttyPerGroup: null,
          ),
        );

        await PurchaseActionProvider().createPurchaseAction();

        // No history created for an inventory operation that did not succeed
        expect(ItemHistoriesFunc().getItemHistories(), isEmpty);
        expect(StorageItemHistoriesFunc().getStorageItemHistories(), isEmpty);
      },
    );

    test(
      '20: Updating unit in PurchaseActionProvider.updateItem and existing direct DataProvider/StorageProductProvider updates work properly',
      () async {
        final primaryUnit = ProductUnitsClass(
          uuid: 'u-pc',
          staffUuid: 'staff-1',
          createdAt: DateTime.utc(2026, 1, 1),
          staffName: 'Tester',
          conversion: 1,
          name: 'Piece',
          isPrimary: true,
          productUuid: 'prod-pen',
        );
        final boxUnit = ProductUnitsClass(
          uuid: 'u-box10',
          staffUuid: 'staff-1',
          createdAt: DateTime.utc(2026, 1, 1),
          staffName: 'Tester',
          conversion: 10,
          name: 'Box',
          isPrimary: false,
          productUuid: 'prod-pen',
        );

        final pen = makeProduct(
          uuid: 'prod-pen',
          name: 'Ballpoint Pen',
          unit: 'Piece',
          quantity: 50,
          unitsList: [primaryUnit, boxUnit],
        );

        await seedEnvironment(
          manageInventoryStorage: false,
          products: [pen],
        );

        // Add initially as 2 Pieces, then edit in cart to 2 Boxes (20 Pieces)
        PurchaseActionProvider().addItemToList(
          item: PurchaseListItem(
            itemName: pen.name,
            itemUuid: pen.uuid,
            storageItemUuid: null,
            unit: primaryUnit.name,
            unitUuid: primaryUnit.uuid,
            unitsList: pen.getUnitListFinal(),
            quantity: 2,
            originalPrice: 50,
            customPrice: null,
            totalPrice: 100,
            isGroup: false,
            qttyPerGroup: 10,
          ),
        );

        PurchaseActionProvider().updateItem(
          item: PurchaseListItem(
            itemName: pen.name,
            itemUuid: pen.uuid,
            storageItemUuid: null,
            unit: boxUnit.name,
            unitUuid: boxUnit.uuid,
            unitsList: pen.getUnitListFinal(),
            quantity: 2,
            originalPrice: 50,
            customPrice: null,
            totalPrice: 1000,
            isGroup: true,
            qttyPerGroup: 10,
          ),
        );

        expect(
          PurchaseActionProvider().itemUnit(
            purchaseItem: PurchaseActionProvider().purchaseListItems.first,
          ),
          'Box',
        );

        await PurchaseActionProvider().createPurchaseAction();

        // 50 + (2 * 10) = 70 Pieces
        expect(
          ProductsFunc().getSingleProduct(uuid: 'prod-pen')!.quantity,
          70,
        );

        // Direct inventory adjustment via DataProvider.updateProduct still works as expected
        final currentPen = ProductsFunc().getSingleProduct(uuid: 'prod-pen')!;
        final adjustedPen = currentPen.copyWith(quantity: 75);
        await DataProvider().updateProduct(
          product: adjustedPen,
          isQuantityUpdate: true,
          includeQuantity: false,
          quantityChange: 5,
          isIncrement: true,
          itemHistory: ItemHistory(
            shopId: 101,
            title: 'Manual Stock Adjustment',
            desc: 'Manual Stock Adjustment',
            event: ItemHistoryEventClass.quantityUpdatedIncrease,
            source: ItemHistoryEventClass.manualSource,
            destination: ItemHistoryEventClass.productDestination,
            oldValue: '70',
            newValue: '75',
            quantityChange: 5,
            isIncreased: true,
            isManaged: true,
            unit: 'Piece',
            primaryUnit: 'Piece',
          ),
        );

        expect(
          ProductsFunc().getSingleProduct(uuid: 'prod-pen')!.quantity,
          75,
        );
        expect(ItemHistoriesFunc().getItemHistories().length, 2);
      },
    );
  });
}
