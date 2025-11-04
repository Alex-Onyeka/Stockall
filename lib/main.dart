import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/main_database.dart';
import 'package:stockall/local_database/visibility_box/visibility_box.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/authentication/forgot_password_page/enter_new_password/enter_new_password.dart';
import 'package:stockall/pages/authentication/launch_screen/launch_screen.dart';
import 'package:stockall/pages/authentication/login/login_page.dart';
import 'package:stockall/pages/authentication/splash_screens/splash_screen.dart';
import 'package:stockall/pages/authentication/translations/translation_provider.dart';
import 'package:stockall/pages/subscription/subscription.dart';
import 'package:stockall/providers/comp_provider.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/customers_provider.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/expenses_provider.dart';
import 'package:stockall/providers/nav_provider.dart';
import 'package:stockall/providers/notifications_provider.dart';
// import 'package:stockall/providers/product_suggestions_provider.dart';
import 'package:stockall/providers/receipts_provider.dart';
import 'package:stockall/providers/report_provider.dart';
import 'package:stockall/providers/sales_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/providers/user_provider.dart';
import 'package:stockall/providers/validate_input_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setSystemUIOverlayStyle(
  //   SystemUiOverlayStyle(
  //     statusBarColor: Colors.white, // or any color
  //     statusBarIconBrightness:
  //         Brightness.dark, // for Android
  //     systemNavigationBarContrastEnforced: true,
  //     statusBarBrightness: Brightness.light,
  //   ),
  // );
  // // Lock to portrait only
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);

  await Supabase.initialize(
    url: 'https://jlwizkdhjazpbllpvtgo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impsd2l6a2RoamF6cGJsbHB2dGdvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5ODU2NzEsImV4cCI6MjA2MDU2MTY3MX0.M3ajvwom-Jj6SfTgATbjwYKtQ1_L4XXo0wcsFcok108',
  );
  await MainDatabase().initHive();
  runApp(MyApp());
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
      );
}

int shopId(BuildContext context) {
  var tempId =
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!;

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

ReceiptsProvider returnReceiptProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<ReceiptsProvider>(
    context,
    listen: listen,
  );
}

TempShopClass? shop(BuildContext context) {
  return returnShopProvider(
    context,
    listen: false,
  ).userShop;
}

UserProvider returnUserProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<UserProvider>(context, listen: listen);
}

ShopProvider returnShopProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<ShopProvider>(context, listen: listen);
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

DataProvider returnData(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<DataProvider>(context, listen: listen);
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

SalesProvider returnSalesProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<SalesProvider>(
    context,
    listen: listen,
  );
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
  const MyApp({super.key});

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
      ],
      child: MaterialApp(
        initialRoute: "/",
        routes: {
          '/': (context) => BasePage(),
          '/launch': (context) => LaunchScreen(),
          // '/forgot-password':
          //     (context) => ForgotPasswordPage(),
          '/login': (context) => LoginPage(),
          '/splash': (context) => SplashScreen(),
          '/reset-password':
              (context) => EnterNewPassword(),
          '/subscription': (context) => Subscription(),
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

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late Future<bool> connectFuture;
  Future<bool> connect() async {
    return returnConnectivityProvider(
      context,
      listen: false,
    ).isOnline();
  }

  @override
  void initState() {
    super.initState();
    connectFuture = connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: connectFuture,
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator.adaptive(),
              );
            } else {
              return InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return TestPage();
                      },
                    ),
                  );
                },
                child: Text(asyncSnapshot.data.toString()),
              );
            }
          },
        ),
      ),
    );
  }
}
