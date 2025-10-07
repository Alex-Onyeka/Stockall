import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/shop_setup/banner_screen/copy_staff_id/copy_staff_id_desktop.dart';
import 'package:stockall/pages/shop_setup/banner_screen/copy_staff_id/copy_staff_id_mobile.dart';

class CopyStaffId extends StatefulWidget {
  const CopyStaffId({super.key});

  @override
  State<CopyStaffId> createState() => _CopyStaffIdState();
}

class _CopyStaffIdState extends State<CopyStaffId> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < mobileScreen) {
            return CopyStaffIdMobile();
          } else {
            return CopyStaffIdDesktop();
          }
        },
      ),
    );
  }
}
