import 'package:flutter/material.dart';
import 'package:stockitt/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockitt/pages/home/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  Session? _session;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final session =
        Supabase.instance.client.auth.currentSession;

    setState(() {
      _session = session;
      _loading = false;
    });

    Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      setState(() {
        _session = data.session;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_session != null) {
      return const Home();
    } else {
      return const AuthScreensPage();
    }
  }
}
