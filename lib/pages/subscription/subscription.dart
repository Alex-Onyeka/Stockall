import 'package:flutter/material.dart';
import 'package:stockall/constants/app_bar.dart';

class Subscription extends StatelessWidget {
  const Subscription({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Choose your Plan',
      ),
    );
  }
}
