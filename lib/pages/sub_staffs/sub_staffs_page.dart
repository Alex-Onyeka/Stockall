import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/sub_staffs/platforms/sub_staffs_page_desktop.dart';
import 'package:stockall/pages/sub_staffs/platforms/sub_staffs_page_mobile.dart';

class SubStaffsPage extends StatelessWidget {
  const SubStaffsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= mobileScreen) {
          return SubStaffsPageMobile();
        } else {
          return SubStaffsPageDesktop();
        }
      },
    );
  }
}
