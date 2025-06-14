import 'package:flutter/material.dart';
import 'package:stockall/local_database/local_user/local_user_database.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/home/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    print('LaunchScreen Init: ${DateTime.now()}');
    super.initState();
    _initSupabase();
  }

  Future<void> _initSupabase() async {
    try {
      await Supabase.initialize(
        url: 'https://jlwizkdhjazpbllpvtgo.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impsd2l6a2RoamF6cGJsbHB2dGdvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5ODU2NzEsImV4cCI6MjA2MDU2MTY3MX0.M3ajvwom-Jj6SfTgATbjwYKtQ1_L4XXo0wcsFcok108',
      );

      // Optionally: check for session or auth status
      final session =
          Supabase.instance.client.auth.currentSession;
      await LocalUserDatabase().init();

      // Then go to main app
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) =>
                    session != null
                        ? const Home()
                        : const AuthScreensPage(),
          ),
        );
      }
    } catch (e) {
      // You can show a retry button or an error
      debugPrint('Failed to init Supabase: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to connect. Check your network.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('LaunchScreen Build: ${DateTime.now()}');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child:
        // Image.asset(
        //   'assets/images/small_images/shop_icon.png',
        //   width: 170, // Adjust size as needed
        // ),
        returnCompProvider(
          context,
          listen: false,
        ).showLoader('Loading'),
      ),
    );
  }
}
