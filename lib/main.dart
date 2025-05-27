import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/classes/temp_shop_class.dart';
import 'package:stockitt/classes/temp_user_class.dart';
import 'package:stockitt/local_database/local_user/local_user_database.dart';
import 'package:stockitt/pages/authentication/base_page/base_page.dart';
import 'package:stockitt/pages/authentication/launch_screen/launch_screen.dart';
import 'package:stockitt/pages/authentication/splash_screens/splash_screen.dart';
import 'package:stockitt/providers/comp_provider.dart';
import 'package:stockitt/providers/customers_provider.dart';
import 'package:stockitt/providers/data_provider.dart';
import 'package:stockitt/providers/nav_provider.dart';
import 'package:stockitt/providers/notifications_provider.dart';
import 'package:stockitt/providers/receipts_provider.dart';
import 'package:stockitt/providers/sales_provider.dart';
import 'package:stockitt/providers/shop_provider.dart';
import 'package:stockitt/providers/theme_provider.dart';
import 'package:stockitt/providers/user_provider.dart';
import 'package:stockitt/providers/validate_input_provider.dart';
import 'package:stockitt/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.white, // or any color
      statusBarIconBrightness:
          Brightness.dark, // for Android
      systemNavigationBarContrastEnforced: true,
      statusBarBrightness: Brightness.light, // for iOS
    ),
  );

  setUrlStrategy(
    PathUrlStrategy(),
  ); // Optional: For clean URLs

  Hive.registerAdapter(TempUserClassAdapter());
  await LocalUserDatabase().init();
  await Supabase.initialize(
    url: 'https://jlwizkdhjazpbllpvtgo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impsd2l6a2RoamF6cGJsbHB2dGdvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5ODU2NzEsImV4cCI6MjA2MDU2MTY3MX0.M3ajvwom-Jj6SfTgATbjwYKtQ1_L4XXo0wcsFcok108',
  );

  runApp(
    MultiProvider(
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
          create: (_) => LocalUserDatabase(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

String userId() {
  return 'user_001';
}

String userIdMain() {
  return AuthService().currentUser!.id;
}

int shopId(BuildContext context) {
  var tempId =
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!;

  return tempId;
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

// EmployeeProvider returnEmployeeProvider(
//   BuildContext context, {
//   bool listen = true,
// }) {
//   return Provider.of<EmployeeProvider>(
//     context,
//     listen: listen,
//   );
// }

LocalUserDatabase returnLocalDatabase(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<LocalUserDatabase>(
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

TempShopClass currentShop(BuildContext context) {
  return returnShopProvider(
    context,
    listen: false,
  ).shops.firstWhere(
    (element) => element.userId == userIdMain(),
  );
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

ThemeProvider returnTheme(BuildContext context) {
  return Provider.of<ThemeProvider>(context);
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
    return MaterialApp(
      initialRoute: "/",
      routes: {
        '/base': (context) => BasePage(),
        '/': (context) => LaunchScreen(),
        "/splash": (context) => SplashScreen(),
      },
      //
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
        primaryColor: const Color.fromRGBO(25, 43, 117, 1),
      ),
    );
  }
}
