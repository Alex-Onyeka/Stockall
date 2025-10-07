import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stockall/local_database/customers/customer_func.dart';
import 'package:stockall/local_database/expenses/expenses_func.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/main_receipt/main_receipt_func.dart';
import 'package:stockall/local_database/notification/notification_func.dart';
import 'package:stockall/local_database/product_record_func.dart/product_record_func.dart';
import 'package:stockall/local_database/product_suggestion/product_suggestion_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/local_database/users/user_func.dart';
import 'package:stockall/local_database/visibility_box/visibility_box.dart';

class MainDatabase extends ChangeNotifier {
  static final MainDatabase _instance =
      MainDatabase._internal();
  factory MainDatabase() => _instance;
  MainDatabase._internal();

  Future<void> initHive() async {
    await Hive.initFlutter();
    await UserFunc().init();
    await ShopFunc().init();
    await VisibilityBox().init();
    await CustomerFunc().init();
    await ExpensesFunc().init();
    await NotificationFunc().init();
    await ProductsFunc().init();
    await ProductRecordFunc().init();
    await ProductSuggestionFunc().init();
    await MainReceiptFunc().init();
    await LoggedInUserFunc().init();
    print('init Complete');
  }
}

int highestHiveClassIndex = 28;
