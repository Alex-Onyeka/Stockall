import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/materials_page/materials_details/platforms/materials_details_desktop.dart';
import 'package:stockall/pages/production/materials_page/materials_details/platforms/materials_details_mobile.dart';

class MaterialsDetailsPage extends StatefulWidget {
  final String materialUuid;
  const MaterialsDetailsPage({
    super.key,
    required this.materialUuid,
  });

  @override
  State<MaterialsDetailsPage> createState() =>
      _MaterialsDetailsPageState();
}

class _MaterialsDetailsPageState
    extends State<MaterialsDetailsPage> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreenSmall) {
          return MaterialsDetailsMobile(
            theme: theme,
            materialUuid: widget.materialUuid,
          );
        } else {
          return MaterialsDetailsDesktop(
            theme: theme,
            materialUuid: widget.materialUuid,
          );
        }
      },
    );
  }
}
