import 'package:flutter/material.dart';
import 'package:stockitt/components/alert_dialogues/info_alert.dart';
import 'package:stockitt/providers/theme_provider.dart';

class ValidateInputProvider extends ChangeNotifier {
  ThemeProvider themeProvider = ThemeProvider();

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    );
    return emailRegex.hasMatch(email);
  }

  void checkInputs({
    required bool conditionsFirst,
    required BuildContext context,
    required bool conditionsSecond,
    required bool conditionsThree,
    required bool conditionsFour,
    required Function() action,
  }) {
    // var theme = returnTheme(context);
    if (conditionsFirst) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: themeProvider,
            message: 'Please fill out all Fields',
            title: 'Empty Input',
          );
        },
      );
    } else if (!conditionsSecond) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: themeProvider,
            message:
                'Email Address is Badly Formatted. Please Enter a Valid Email Address',
            title: 'Invalid Email',
          );
        },
      );
    } else if (conditionsThree) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: themeProvider,
            message:
                'The two Password fields does not match',
            title: 'Password Mismatch',
          );
        },
      );
    } else if (conditionsFour) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: themeProvider,
            message:
                'An Error Occured... Please check your input fields try again.',
            title: 'An Error Occoured',
          );
        },
      );
    } else {
      action();
    }
  }
}
