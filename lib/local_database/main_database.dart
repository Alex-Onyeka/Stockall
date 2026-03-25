import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stockall/local_database/app_version/app_version_func.dart';
import 'package:stockall/local_database/barcode_printer_func/barcode_printer_local_func.dart';
import 'package:stockall/local_database/barcode_printer_func/price_and_barcode_local_func.dart';
import 'package:stockall/local_database/barcode_printer_func/price_tag_printer_func.dart';
import 'package:stockall/local_database/category/category_func.dart';
import 'package:stockall/local_database/customers/customer_func.dart';
import 'package:stockall/local_database/department_func/departments_func.dart';
import 'package:stockall/local_database/events_log/events_log_func.dart';
import 'package:stockall/local_database/expenses/expenses_func.dart';
import 'package:stockall/local_database/inventory_updates/inventory_updates_func.dart';
import 'package:stockall/local_database/invoices/invoices_func.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/main_receipt/main_receipt_func.dart';
import 'package:stockall/local_database/notification/notification_func.dart';
import 'package:stockall/local_database/permission/permission_func.dart';
import 'package:stockall/local_database/product_record_func.dart/product_record_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/local_database/shop_logos/shop_logos_func.dart';
import 'package:stockall/local_database/shop_owner/shop_owner_func.dart';
import 'package:stockall/local_database/sub_staff/sub_staff_func.dart';
import 'package:stockall/local_database/subscription/subscription_func.dart';
import 'package:stockall/local_database/users/user_func.dart';
import 'package:stockall/local_database/visibility_box/visibility_box.dart';
import 'package:stockall/main.dart';

class MainDatabase extends ChangeNotifier {
  static final MainDatabase _instance =
      MainDatabase._internal();
  factory MainDatabase() => _instance;
  MainDatabase._internal();

  Future<void> initHive() async {
    if (kIsWeb) {
      await Hive.initFlutter();
    } else {
      final dir = await getApplicationSupportDirectory();
      final stockallDir = Directory('${dir.path}/Stockall');
      if (!await stockallDir.exists()) {
        await stockallDir.create(recursive: true);
      }
      Hive.init(stockallDir.path);
    }
    await PermissionFunc().init();
    await AppVersionFunc().init();
    await UserFunc().init();
    await ShopFunc().init();
    await VisibilityBox().init();
    await CustomerFunc().init();
    await ExpensesFunc().init();
    await NotificationFunc().init();
    await ProductsFunc().init();
    await ProductRecordFunc().init();
    await MainReceiptFunc().init();
    await LoggedInUserFunc().init();
    await ShopLogosFunc().init();
    await CurrentShopFunc().init();
    await SubscriptionFunc().init();
    await ShopOwnerFunc().init();
    await InventoryUpdatesFunc().init();
    await EventsLogFunc().init();
    await InvoicesFunc().init();
    await SubStaffFunc().init();
    if (returnShopProvider().isDesktop()) {
      await BarcodePrinterLocalFunc().init();
      await PriceTagPrinterFunc().init();
      await PriceAndBarcodePrinterLocalFunc().init();
    }
    await DepartmentsFunc().init();
    await CategoryFunc().init();
    print('init Complete');
  }
}

int highestHiveClassIndex = 64;
