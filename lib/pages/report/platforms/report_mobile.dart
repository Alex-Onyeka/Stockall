import 'package:flutter/material.dart';
import 'package:stockitt/components/major/empty_widget_display_only.dart';
import 'package:stockitt/components/major/top_banner.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';

class ReportMobile extends StatelessWidget {
  const ReportMobile({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Column(
        children: [
          TopBanner(
            subTitle: 'Manage your business from report',
            title: 'Reports',
            theme: theme,
            bottomSpace: 40,
            topSpace: 30,
            isMain: true,
            iconSvg: reportIconSvg,
          ),
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 30.0,
                    ),
                    child: EmptyWidgetDisplayOnly(
                      title: 'Comming Soon',
                      subText:
                          'This feature is not yet available... Our group of dedicated professional engineers are working on it.',
                      theme: theme,
                      height: 30,
                      icon: Icons.clear,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
