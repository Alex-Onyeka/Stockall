import 'package:flutter/material.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/main.dart';

class ReferralsMobile extends StatelessWidget {
  const ReferralsMobile({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Column(
        children: [
          TopBanner(
            subTitle: 'Manage Referrals and receive bonus',
            title: 'Referrals',
            theme: theme,
            bottomSpace: 60,
            topSpace: 30,
            isMain: true,
            iconData: Icons.share,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: EmptyWidgetDisplayOnly(
                    title: 'Coming Soon',
                    subText: 'Currently not available.',
                    theme: theme,
                    height: 30,
                    icon: Icons.clear,
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
