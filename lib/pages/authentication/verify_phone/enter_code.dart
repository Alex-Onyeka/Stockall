import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storrec/pages/authentication/verify_phone/platforms/enter_code_desktop.dart';
import 'package:storrec/pages/authentication/verify_phone/platforms/enter_code_mobile.dart';
import 'package:storrec/providers/theme_provider.dart';

class EnterCode extends StatelessWidget {
  final String number;
  const EnterCode({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return EnterCodeMobile(
                number: number,
                themeProvider: themeProvider,
              );
            } else {
              return EnterCodeDesktop(
                number: number,
                themeProvider: themeProvider,
              );
            }
          },
        ),
      ),
    );
  }
}
