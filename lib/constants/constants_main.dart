import 'package:flutter/material.dart';
import 'package:stockall/main.dart';

const String mainLogoIcon =
    'assets/images/logos/logo_icon.png';

const String logoIconWhite =
    'assets/images/logos/icon_white.png';

const String mainLogo =
    'assets/images/logos/icon_white.png';

const String appMockUp = 'assets/images/logos/App_Png.png';

const String backGroundImage =
    'assets/images/main_images/back_g.jpg';

const String profileIconImage =
    'assets/images/small_images/image_icon.png';

const String shopIconImage =
    'assets/images/small_images/shop_icon.png';

const String cctvImage =
    'assets/images/small_images/cctv.png';

//
//
//
//

//
//
//
//
// J S O N

const String mainLoader =
    'assets/animations/main_loader.json';

const String searchingAnim1 =
    'assets/animations/search_1.json';
const String searchingAnim2 =
    'assets/animations/search_2.json';
const String searchingAnim3 =
    'assets/animations/search_3.json';

const String successAnim =
    'assets/animations/check_animation.json';

const String shopSetup =
    'assets/animations/shop_setup_icon.json';

const String profitAnim = 'assets/animations/profit.json';

const String welcomeRobot =
    'assets/animations/welcome_robot.json';

const String welcomeLady = 'assets/animations/welcome.json';

//
//
//
//

//
//
//
//
// S V G ' S

const String checkIconSvg = 'assets/svgs/check_icon.svg';

const String notifIconSvg = 'assets/svgs/notif_icon.svg';

const String divideIconSvg = 'assets/svgs/divide_icon.svg';

const String customersIconSvg =
    'assets/svgs/customers_icon.svg';

const String pulseIconSvg = 'assets/svgs/pulse_icon.svg';

const String productIconSvg =
    'assets/svgs/product_icon.svg';

const String salesIconSvg = 'assets/svgs/sales_icon.svg';

const String custBookIconSvg =
    'assets/svgs/cust_book_icon.svg';

const String employeesIconSvg =
    'assets/svgs/employees_icon.svg';

const String expensesIconSvg =
    'assets/svgs/expenses_icon.svg';

const String reportIconSvg = 'assets/svgs/report_icon.svg';

const String makeSalesIconSvg =
    'assets/svgs/make_sales_button.svg';

const String nairaIconSvg = 'assets/svgs/naira_icon.svg';

const String addIconSvg = 'assets/svgs/add_icon.svg';

const String editIconSvg = 'assets/svgs/edit_icon.svg';

const String deleteIconSvg = 'assets/svgs/delete_icon.svg';

const String receiptIconSvg =
    'assets/svgs/receipt_icon.svg';

const String plusIconSvg = 'assets/svgs/plus_icon.svg';

const String whatsappIconSvg =
    'assets/svgs/whatsapp_logo_icon.svg';

String currencySymbol({
  required BuildContext context,
  bool? isR,
}) {
  var shopC =
      returnShopProvider(
        context,
        listen: false,
      ).userShop?.currency;
  var iR = isR != null ? true : false;
  if (shopC == '₦' && iR) {
    return 'N';
  } else if (shopC == '₹' && iR) {
    return 'R';
  } else if (shopC == '₺' && iR) {
    return 'L';
  } else {
    return returnShopProvider(
          context,
          listen: false,
        ).userShop?.currency ??
        '';
  }
}

const String appName = 'Stockall';
const String appDesc =
    'Your smart inventory companion. Track stock, manage sales, and grow your business with ease — all in one place. Let\'s simplify your workflow and boost your efficiency. 🚀';

const int currentUpdate = 16;

const double mobileScreenSmall = 500;

const double mobileScreen = 650;

const double tabletScreenSmall = 950;

const double tabletScreen = 1024;
