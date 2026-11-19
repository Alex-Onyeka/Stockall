import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stockall/local_database/app_version/app_version_func.dart';
import 'package:stockall/local_database/barcode_printer_func/barcode_printer_local_func.dart';
import 'package:stockall/local_database/barcode_printer_func/price_and_barcode_local_func.dart';
import 'package:stockall/local_database/barcode_printer_func/price_tag_printer_func.dart';
import 'package:stockall/local_database/cart_func/cart_func.dart';
import 'package:stockall/local_database/category/category_func.dart';
import 'package:stockall/local_database/continuous_print_docket/continuous_print_docket_func.dart';
import 'package:stockall/local_database/countries/countries_func.dart';
import 'package:stockall/local_database/customer_account_receipts/customer_account_receipts_func.dart';
import 'package:stockall/local_database/customers/customer_func.dart';
import 'package:stockall/local_database/department_current/current_department_func.dart';
import 'package:stockall/local_database/department_func/departments_func.dart';
import 'package:stockall/local_database/drafts_func/drafts_func.dart';
import 'package:stockall/local_database/error_log/error_log_func.dart';
import 'package:stockall/local_database/events_log/events_log_func.dart';
import 'package:stockall/local_database/expenses/expense_categories_func.dart';
import 'package:stockall/local_database/expenses/expenses_func.dart';
import 'package:stockall/local_database/floating_button_visibility_box/floating_button_visibility_box.dart';
import 'package:stockall/local_database/hive_adapters_registry.dart';
import 'package:stockall/local_database/inventory_updates/inventory_updates_func.dart';
import 'package:stockall/local_database/invoices/invoices_func.dart';
import 'package:stockall/local_database/item_history/item_histories_func.dart';
import 'package:stockall/local_database/item_purchase_func.dart%20copy/item_purchase_func.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/main_receipt/main_receipt_func.dart';
import 'package:stockall/local_database/materials/materials_func.dart';
import 'package:stockall/local_database/materials_item_history/materials_item_histories_func.dart';
import 'package:stockall/local_database/materials_usage/production_materials_usage_func.dart';
import 'package:stockall/local_database/materials_usage_cart_func/materials_usage_cart_func.dart';
import 'package:stockall/local_database/new_feature_pop_up_func/new_feature_pop_up_func.dart';
import 'package:stockall/local_database/notification/notification_func.dart';
import 'package:stockall/local_database/on_screen_keyboard_pin/on_screen_keyboard_pin_func.dart';
import 'package:stockall/local_database/orders_func/orders_func.dart';
import 'package:stockall/local_database/permission/permission_func.dart';
import 'package:stockall/local_database/product_record_func.dart/product_record_func.dart';
import 'package:stockall/local_database/production_item_history/production_item_histories_func.dart';
import 'package:stockall/local_database/production_items/production_items_func.dart';
import 'package:stockall/local_database/productions/production_records_func.dart';
import 'package:stockall/local_database/productions_cart_func/productions_cart_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/local_database/purchases/purchase_func.dart';
import 'package:stockall/local_database/receipt_printer_func/receipt_printer_func.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/local_database/shop_logos/shop_logos_func.dart';
import 'package:stockall/local_database/shop_owner/shop_owner_func.dart';
import 'package:stockall/local_database/storage_item_history/storage_item_histories_func.dart';
import 'package:stockall/local_database/storage_product/storage_products_func.dart';
import 'package:stockall/local_database/sub_staff/sub_staff_func.dart';
import 'package:stockall/local_database/subscription/subscription_func.dart';
import 'package:stockall/local_database/suppliers_func/suppliers_func.dart';
import 'package:stockall/local_database/users/user_func.dart';
import 'package:stockall/local_database/utility_constants/utility_constants_func.dart';
import 'package:stockall/local_database/visibility_box/visibility_box.dart';
import 'package:stockall/local_database/waybills/waybills_func.dart';
import 'package:stockall/main.dart';

class MainDatabase extends ChangeNotifier {
  static final MainDatabase _instance =
      MainDatabase._internal();
  factory MainDatabase() => _instance;
  MainDatabase._internal();

  Future<void> _safeInit(
    String name,
    Future<void> Function() initFunc,
  ) async {
    try {
      await initFunc();
    } catch (e, s) {
      await mainLocalLog(
        '❌ Failed to initialize $name: $e',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> initHive() async {
    try {
      if (kIsWeb) {
        await Hive.initFlutter();
      } else {
        final dir = await getApplicationSupportDirectory();
        final stockallDir = Directory(
          '${dir.path}/Stockall',
        );
        if (!await stockallDir.exists()) {
          await stockallDir.create(recursive: true);
        }
        Hive.init(stockallDir.path);
      }
      registerAllHiveAdapters();
      await _safeInit('UserFunc', () => UserFunc().init());
      await _safeInit('ShopFunc', () => ShopFunc().init());
      await _safeInit(
        'PermissionFunc',
        () => PermissionFunc().init(),
      );
      await _safeInit(
        'AppVersionFunc',
        () => AppVersionFunc().init(),
      );
      await _safeInit(
        'OnScreenKeyboardPinFunc',
        () => OnScreenKeyboardPinFunc().init(),
      );
      await _safeInit(
        'UtilityConstantsFunc',
        () => UtilityConstantsFunc().init(),
      );
      await _safeInit(
        'FloatingButtonVisibilityBox',
        () => FloatingButtonVisibilityBox().init(),
      );
      await _safeInit(
        'VisibilityBox',
        () => VisibilityBox().init(),
      );
      await _safeInit(
        'CustomerFunc',
        () => CustomerFunc().init(),
      );
      await _safeInit(
        'CustomerAccountReceiptsFunc',
        () => CustomerAccountReceiptsFunc().init(),
      );
      await _safeInit(
        'ExpensesFunc',
        () => ExpensesFunc().init(),
      );
      await _safeInit(
        'ExpenseCategoriesFunc',
        () => ExpenseCategoriesFunc().init(),
      );
      await _safeInit(
        'NotificationFunc',
        () => NotificationFunc().init(),
      );
      await _safeInit(
        'ProductsFunc',
        () => ProductsFunc().init(),
      );
      await _safeInit(
        'ProductRecordFunc',
        () => ProductRecordFunc().init(),
      );
      await _safeInit(
        'MainReceiptFunc',
        () => MainReceiptFunc().init(),
      );
      await _safeInit(
        'LoggedInUserFunc',
        () => LoggedInUserFunc().init(),
      );
      await _safeInit(
        'ShopLogosFunc',
        () => ShopLogosFunc().init(),
      );
      await _safeInit(
        'CurrentShopFunc',
        () => CurrentShopFunc().init(),
      );
      await _safeInit(
        'SubscriptionFunc',
        () => SubscriptionFunc().init(),
      );
      await _safeInit(
        'ShopOwnerFunc',
        () => ShopOwnerFunc().init(),
      );
      await _safeInit(
        'InventoryUpdatesFunc',
        () => InventoryUpdatesFunc().init(),
      );
      await _safeInit(
        'ItemHistoriesFunc',
        () => ItemHistoriesFunc().init(),
      );
      await _safeInit(
        'QuantityUpdateFunc',
        () => QuantityUpdateFunc().init(),
      );
      await _safeInit(
        'EventsLogFunc',
        () => EventsLogFunc().init(),
      );
      await _safeInit(
        'ErrorLogFunc',
        () => ErrorLogFunc().init(),
      );
      await _safeInit(
        'InvoicesFunc',
        () => InvoicesFunc().init(),
      );
      await _safeInit(
        'SubStaffFunc',
        () => SubStaffFunc().init(),
      );
      if (returnShopProvider().isDesktop()) {
        await _safeInit(
          'BarcodePrinterLocalFunc',
          () => BarcodePrinterLocalFunc().init(),
        );
        await _safeInit(
          'ReceiptPrinterFunc',
          () => ReceiptPrinterFunc().init(),
        );
        await _safeInit(
          'PriceTagPrinterFunc',
          () => PriceTagPrinterFunc().init(),
        );
        await _safeInit(
          'PriceAndBarcodePrinterLocalFunc',
          () => PriceAndBarcodePrinterLocalFunc().init(),
        );
      }
      await _safeInit(
        'DepartmentsFunc',
        () => DepartmentsFunc().init(),
      );
      await _safeInit(
        'CategoryFunc',
        () => CategoryFunc().init(),
      );
      await _safeInit(
        'CurrentDepartmentFunc',
        () => CurrentDepartmentFunc().init(),
      );
      await _safeInit(
        'StorageProductsFunc',
        () => StorageProductsFunc().init(),
      );
      await _safeInit('CartFunc', () => CartFunc().init());
      // Before PurchaseFunc: purchases store TempItemPurchaseRecord
      // items, so its adapter must exist when that box opens.
      await _safeInit(
        'ItemPurchaseFunc',
        () => ItemPurchaseFunc().init(),
      );
      await _safeInit(
        'PurchaseFunc',
        () => PurchaseFunc().init(),
      );
      await _safeInit(
        'SuppliersFunc',
        () => SuppliersFunc().init(),
      );
      await _safeInit(
        'WaybillsFunc',
        () => WaybillsFunc().init(),
      );
      await _safeInit(
        'CountriesFunc',
        () => CountriesFunc().init(),
      );
      await _safeInit(
        'ProductionRecordsFunc',
        () => ProductionRecordsFunc().init(),
      );
      await _safeInit(
        'MaterialsFunc',
        () => MaterialsFunc().init(),
      );
      await _safeInit(
        'MaterialsItemHistoriesFunc',
        () => MaterialsItemHistoriesFunc().init(),
      );
      await _safeInit(
        'ProductionItemsFunc',
        () => ProductionItemsFunc().init(),
      );
      await _safeInit(
        'ProductionItemHistoriesFunc',
        () => ProductionItemHistoriesFunc().init(),
      );
      await _safeInit(
        'ProductionsCartFunc',
        () => ProductionsCartFunc().init(),
      );
      await _safeInit(
        'ProductionMaterialsUsageFunc',
        () => ProductionMaterialsUsageFunc().init(),
      );
      await _safeInit(
        'MaterialsUsageCartFunc',
        () => MaterialsUsageCartFunc().init(),
      );
      await _safeInit(
        'NewFeaturePopUpFunc',
        () => NewFeaturePopUpFunc().init(),
      );
      await _safeInit(
        'OrdersFunc',
        () => OrdersFunc().init(),
      );
      await _safeInit(
        'DraftsFunc',
        () => DraftsFunc().init(),
      );
      await _safeInit(
        'ContinuousPrintDocketFunc',
        () => ContinuousPrintDocketFunc().init(),
      );
      await _safeInit(
        'StorageItemHistoriesFunc',
        () => StorageItemHistoriesFunc().init(),
      );
      await mainLocalLog('init Complete');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Local Db: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }
}

int highestHiveClassIndex = 158;
