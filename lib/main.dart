import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/local_database/main_database.dart';
import 'package:stockall/local_database/visibility_box/visibility_box.dart';
import 'package:stockall/pages/alt_display/alt_display.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/authentication/forgot_password_page/enter_new_password/enter_new_password.dart';
import 'package:stockall/pages/authentication/launch_screen/launch_screen.dart';
import 'package:stockall/pages/authentication/login/login_page.dart';
import 'package:stockall/pages/authentication/splash_screens/splash_screen.dart';
import 'package:stockall/pages/authentication/translations/translation_provider.dart';
import 'package:stockall/pages/profile/delete_account/delete_account.dart';
import 'package:stockall/pages/subscription_page/subscription_page.dart';
import 'package:stockall/providers/app_version_provider.dart';
import 'package:stockall/providers/comp_provider.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/customers_provider.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/department_provider.dart';
import 'package:stockall/providers/events_log_provider.dart';
import 'package:stockall/providers/expenses_provider.dart';
import 'package:stockall/providers/inventory_updates_provider.dart';
import 'package:stockall/providers/invoices_provider.dart';
import 'package:stockall/providers/multi_display_provider.dart';
import 'package:stockall/providers/nav_provider.dart';
import 'package:stockall/providers/notifications_provider.dart';
// import 'package:stockall/providers/product_suggestions_provider.dart';
import 'package:stockall/providers/receipts_provider.dart';
import 'package:stockall/providers/report_provider.dart';
import 'package:stockall/providers/sales_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/sub_payment_provider.dart';
import 'package:stockall/providers/subscription_provider.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/providers/user_provider.dart';
import 'package:stockall/providers/validate_input_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:stockall/services/payment_result_page.dart/payment_result_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

// Stopwatch stopwatch = Stopwatch();

void main(List<String> args) async {
  if (args.length >= 3) {
    final windowId = int.tryParse(args[1]);
    final argument = args[2];
    // print(windowId);
    // print(argument);

    try {
      final decoded = jsonDecode(argument);
      if (decoded['type'] == 'alt') {
        runApp(
          MyAppAlt(
            home: AltDisplay(
              windowId: windowId ?? -1,
              cartId: decoded['cart_id'],
            ),
          ),
        );
      }
    } catch (e) {
      print('An Error Occoured: $e');
    }
  } else {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: true,
        statusBarBrightness: Brightness.light,
      ),
    );
    // Lock to portrait only
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    await MainDatabase().initHive();
    if (returnShopProvider().isDesktop()) {
      await windowManager.ensureInitialized();
      maxWindow();
      print("Maximize In Main Dot Dart");
    }
    // print('Main started with args: $args');
    runApp(MyApp(home: BasePage()));
  }
}

Timer? timer;

void maxWindow() {
  if (returnShopProvider().isDesktop()) {
    timer = Timer.periodic(Duration(seconds: 1), (
      timer,
    ) async {
      var isMax = await windowManager.isMaximized();
      if (!isMax) {
        await windowManager.maximize();
        print("Maximize In Emp Auth Page");
      } else {
        timer.cancel();
        print('Timer Cancelled');
      }
    });
  }
}

TempUserClass currentUser() {
  return UserProvider().currentUserMain!;
}

TempUserClass userGeneral(
  BuildContext context, {
  bool listen = true,
}) {
  return returnUserProvider(
        context,
        listen: listen,
      ).currentUserMain ??
      TempUserClass(
        password: 'password',
        name: 'name',
        email: 'email',
        role: 'Owner',
        authUserId: 'dfsgdhjfh',
        departmentUuids: [],
      );
}

int shopId() {
  var tempId = returnShopProvider().userShop()!.shopId!;

  return tempId;
}

ReportProvider returnReportProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<ReportProvider>(
    context,
    listen: listen,
  );
}

ExpensesProvider returnExpensesProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<ExpensesProvider>(
    context,
    listen: listen,
  );
}

AuthService returnAuth(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<AuthService>(context, listen: listen);
}

NotificationProvider returnNotificationProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<NotificationProvider>(
    context,
    listen: listen,
  );
}

ReceiptsProvider returnReceiptProviderSingle() {
  return ReceiptsProvider();
}

ReceiptsProvider returnReceiptProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<ReceiptsProvider>(
    context,
    listen: listen,
  );
}

InvoicesProvider returnInvoicesProvider({
  BuildContext? context,
}) {
  if (context == null) {
    return InvoicesProvider();
  } else {
    return Provider.of<InvoicesProvider>(context);
  }
}

InventoryUpdatesProvider returnInventoryUpdatesProvider({
  BuildContext? context,
}) {
  if (context == null) {
    return InventoryUpdatesProvider();
  } else {
    return Provider.of<InventoryUpdatesProvider>(context);
  }
}

TempShopClass? shop(BuildContext context) {
  return returnShopProvider(context: context).userShop();
}

UserProvider returnUserProviderSingle() {
  return UserProvider();
}

UserProvider returnUserProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<UserProvider>(context, listen: listen);
}

ShopProvider returnShopProvider({BuildContext? context}) {
  if (context == null) {
    return ShopProvider();
  } else {
    return Provider.of<ShopProvider>(context);
  }
}

ValidateInputProvider returnValidate(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<ValidateInputProvider>(
    context,
    listen: listen,
  );
}

ThemeProvider returnTheme(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<ThemeProvider>(
    context,
    listen: listen,
  );
}

DataProvider returnData({BuildContext? context}) {
  if (context == null) {
    return DataProvider();
  } else {
    return Provider.of<DataProvider>(context);
  }
}

CustomersProvider returnCustomers(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<CustomersProvider>(
    context,
    listen: listen,
  );
}

SubscriptionProvider returnSubcsription(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<SubscriptionProvider>(
    context,
    listen: listen,
  );
}

NavProvider returnNavProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<NavProvider>(context, listen: listen);
}

CompProvider returnCompProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<CompProvider>(context, listen: listen);
}

SalesProvider returnSalesProvider() {
  return SalesProvider();
}

SalesProvider returnSalesProviderContext(
  BuildContext context,
) {
  return Provider.of<SalesProvider>(context);
}

TranslationProvider returnTranslationProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<TranslationProvider>(
    context,
    listen: listen,
  );
}

ConnectivityProvider returnConnectivityProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<ConnectivityProvider>(
    context,
    listen: listen,
  );
}

SubPaymentProvider returnSubPaymentProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<SubPaymentProvider>(
    context,
    listen: listen,
  );
}

AppVersionProvider returnAppVersionProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<AppVersionProvider>(
    context,
    listen: listen,
  );
}

MultiDisplayProvider returnMultiDisplayProvider() {
  return MultiDisplayProvider();
}

MultiDisplayProvider returnMultiDisplayProviderContext(
  BuildContext context,
) {
  return Provider.of<MultiDisplayProvider>(context);
}

EventsLogProvider returnEventsLogProvider({
  BuildContext? context,
}) {
  if (context == null) {
    return EventsLogProvider();
  } else {
    return Provider.of<EventsLogProvider>(context);
  }
}

DepartmentProvider returnDepartmentProvider({
  BuildContext? context,
}) {
  if (context == null) {
    return DepartmentProvider();
  } else {
    return Provider.of<DepartmentProvider>(context);
  }
}

Widget colorWidget(
  Widget widget,
  bool isPrimary,
  BuildContext context,
) {
  return Builder(
    builder: (context) {
      final colors =
          isPrimary
              ? Provider.of<ThemeProvider>(
                context,
              ).lightModeColor.prGradientColors
              : Provider.of<ThemeProvider>(
                context,
              ).lightModeColor.secGradientColors;

      return ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: colors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcIn,
        child: widget,
      );
    },
  );
}

class MyApp extends StatelessWidget {
  final Widget home;
  const MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SalesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CompProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NavProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DataProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CustomersProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ValidateInputProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ShopProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReceiptsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => InvoicesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => VisibilityBox(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpensesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TranslationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ConnectivityProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SubscriptionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SubPaymentProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AppVersionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MultiDisplayProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => EventsLogProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DepartmentProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => InventoryUpdatesProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Stockall Business Dashboard',
        initialRoute: "/",
        routes: {
          '/': (context) => home,
          '/launch': (context) => LaunchScreen(),
          // '/forgot-password':
          //     (context) => ForgotPasswordPage(),
          '/login': (context) => LoginPage(),
          '/splash': (context) => SplashScreen(),
          '/reset-password':
              (context) => EnterNewPassword(),
          '/subscription': (context) => SubscriptionPage(),
          '/delete-account': (context) => DeleteAccount(),
          '/payment-result':
              (context) => PaymentResultPage(),
          '/subscription-page':
              (context) => SubscriptionPage(),
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              systemStatusBarContrastEnforced: true,
            ),
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            toolbarHeight: 80,
          ),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Plus Jakarta Sans',
          primaryColor: const Color.fromRGBO(
            25,
            43,
            117,
            1,
          ),
        ),
      ),
    );
  }
}

class MyAppAlt extends StatelessWidget {
  final Widget home;
  const MyAppAlt({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Stockall Business Dashboard',
        home: home,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              systemStatusBarContrastEnforced: true,
            ),
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            toolbarHeight: 80,
          ),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Plus Jakarta Sans',
          primaryColor: const Color.fromRGBO(
            25,
            43,
            117,
            1,
          ),
        ),
      ),
    );
  }
}
