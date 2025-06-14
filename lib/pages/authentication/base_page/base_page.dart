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
import 'package:stockall/local_database/local_user/local_user_database.dart';
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
    Future.delayed(Duration(milliseconds: 500), () {
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
      // _initializeSupabase();
      setState(() {});
    });
  }

  // Future<void> _initializeSupabase() async {
  //   await Supabase.initialize(
  //     url: 'https://jlwizkdhjazpbllpvtgo.supabase.co',
  //     anonKey:
  //         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impsd2l6a2RoamF6cGJsbHB2dGdvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5ODU2NzEsImV4cCI6MjA2MDU2MTY3MX0.M3ajvwom-Jj6SfTgATbjwYKtQ1_L4XXo0wcsFcok108',
  //   );
  //   await LocalUserDatabase().init();
  //   switchLoading();
  // }

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
