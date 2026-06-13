import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/error_log/platforms/error_log_desktop.dart';
import 'package:stockall/pages/report/error_log/platforms/error_log_mobile.dart';

class ErrorLog extends StatefulWidget {
  const ErrorLog({super.key});

  @override
  State<ErrorLog> createState() => _ErrorLogState();
}

class _ErrorLogState extends State<ErrorLog> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return ErrorLogMobile();
        } else {
          return ErrorLogDesktop();
        }
      },
    );
  }
}
