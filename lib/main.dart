import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/pages/authentication/splash_screens/splash_screen.dart';
import 'package:stockitt/provider_class.dart';
import 'package:stockitt/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jlwizkdhjazpbllpvtgo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impsd2l6a2RoamF6cGJsbHB2dGdvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5ODU2NzEsImV4cCI6MjA2MDU2MTY3MX0.M3ajvwom-Jj6SfTgATbjwYKtQ1_L4XXo0wcsFcok108',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProviderClass(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Plus Jakarta Sans',
        primaryColor: const Color.fromRGBO(25, 43, 117, 1),
      ),
      home: const SplashScreen(),
    );
  }
}
