import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/pages/authentication/verify_phone/platforms/verify_phone_desktop.dart';
import 'package:stockall/pages/authentication/verify_phone/platforms/verify_phone_mobile.dart';
import 'package:stockall/providers/theme_provider.dart';

class VerifyPhone extends StatefulWidget {
  final String number;
  const VerifyPhone({super.key, required this.number});

  @override
  State<VerifyPhone> createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  List<Widget> circles = [
    Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.pink,
        shape: BoxShape.circle,
      ),
    ),
    Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(253, 200, 48, 1),
            Color.fromRGBO(243, 115, 53, 1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ),
    Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color.fromRGBO(82, 213, 186, 1),
      ),
    ),
    Container(
      height: 15,
      width: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(25, 43, 117, 1),
            Color.fromRGBO(47, 80, 219, 1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ),
    Container(
      height: 15,
      width: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.amber,
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return VerifyPhoneMobile(
            circles: circles,
            theme: theme,
            number: widget.number,
          );
        } else {
          return VerifyPhoneDesktop(
            number: widget.number,
            circles: circles,
            theme: theme,
          );
        }
      },
    );
  }
}
