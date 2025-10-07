import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/platforms/report_desktop.dart';
import 'package:stockall/pages/report/platforms/report_mobile.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  void initState() {
    super.initState();
    returnNavProvider(context, listen: false).navigate(6);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await returnNavProvider(
        context,
        listen: false,
      ).validate(context);
      setState(() {
        // stillLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return ReportMobile();
        } else {
          return ReportDesktop();
        }
      },
    );
  }
}
