// import 'package:flutter/material.dart';
// import 'package:stockall/components/major/empty_widget_display.dart';
// import 'package:stockall/main.dart';
// import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
// import 'package:stockall/pages/home/home.dart';
// import 'package:stockall/services/auth_service.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class BasePage extends StatelessWidget {
//   const BasePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<AuthState>(
//       stream:
//           Supabase.instance.client.auth.onAuthStateChange,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState ==
//             ConnectionState.waiting) {
//           return returnCompProvider(
//             context,
//             listen: false,
//           ).showLoader('Loading');
//           // return CircularProgressIndicator();
//         } else if (snapshot.hasError) {
//           return Scaffold(
//             body: EmptyWidgetDisplay(
//               title: 'An Error Occured',
//               subText:
//                   'An error occured while loading your data. Please check your internet and try again',
//               theme: returnTheme(context),
//               height: 35,
//               icon: Icons.clear,
//               buttonText: 'Log Out',
//               action: () {
//                 AuthService().signOut();
//               },
//             ),
//           );
//         }

//         final session =
//             snapshot.hasData
//                 ? snapshot.data!.session
//                 : null;

//         if (session != null) {
//           return const Home();
//         } else {
//           return const AuthScreensPage();
//         }
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/authentication/launch_screen/launch_screen.dart';
import 'package:stockall/pages/home/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  // bool isLoading = true;
  void switchLoading() {
    Future.delayed(Duration(seconds: 2), () {
      if (context.mounted) {
        returnNavProvider(
          context,
          listen: false,
        ).offLoading();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switchLoading();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final session =
        Supabase.instance.client.auth.currentSession;
    // return LaunchScreen();
    if (session != null) {
      // User is logged in
      if (returnNavProvider(context).isLoadingMain) {
        return LaunchScreen();
      } else {
        return const Home();
      }
    } else {
      // Not logged in
      return const AuthScreensPage();
    }
  }
}
