import 'package:flutter/material.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/components/production_page_list_tile_widget.dart';
import 'package:stockall/pages/production/materials_page/materials_page.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/materials_usage_page.dart';
import 'package:stockall/pages/production/production_dashboard/productions_dashboard.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_records_list/production_records_list.dart';
import 'package:stockall/pages/production/production_items/production_items_page.dart';
import 'package:stockall/pages/production/settings/production_settings_page.dart';

class ProductionPageDesktop extends StatefulWidget {
  const ProductionPageDesktop({super.key});

  @override
  State<ProductionPageDesktop> createState() =>
      _ProductionPageDesktopState();
}

class _ProductionPageDesktopState
    extends State<ProductionPageDesktop> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return DesktopCenterContainer(
      width: 900,
      mainWidget: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: 5),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 20,
                    ),
                    child: Icon(
                      color: Colors.grey,
                      size: 20,
                      Icons.arrow_back_ios_new_rounded,
                    ),
                  ),
                ),
              ),
              Column(
                spacing: 2,
                children: [
                  Text(
                    style: TextStyle(
                      color:
                          theme
                              .lightModeColor
                              .shadesColorBlack,
                      fontSize:
                          theme.mobileTexts.h4.fontSize,
                      fontWeight:
                          theme
                              .mobileTexts
                              .h4
                              .fontWeightBold,
                    ),
                    'Production',
                  ),
                  Text(
                    style:
                        theme
                            .mobileTexts
                            .b3
                            .textStyleNormal,
                    "Manage Your Items Production",
                  ),
                ],
              ),
              Opacity(
                opacity: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 20,
                  ),
                  child: Icon(
                    color: Colors.grey,
                    size: 20,
                    Icons.arrow_back_ios_new_rounded,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                ProductionPageListTileWidget(
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: ((context) {
                          return ProductionsDashboard();
                        }),
                      ),
                    );
                  },
                  icon: Icons.view_in_ar_rounded,
                  isActive: true,
                  subText: 'Create and Track Productions',
                  title: 'Productions',
                ),
                ProductionPageListTileWidget(
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: ((context) {
                          return ProductionRecordsList();
                        }),
                      ),
                    );
                  },
                  icon: Icons.receipt,
                  isActive: true,
                  subText:
                      'View Production Records You Created.',
                  title: 'Production Records',
                ),
                ProductionPageListTileWidget(
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: ((context) {
                          return ProductionItemsPage();
                        }),
                      ),
                    );
                  },
                  icon: Icons.api_rounded,
                  isActive: true,
                  subText:
                      'Create and Manage Produced Items',
                  title: 'Production Items',
                ),
                ProductionPageListTileWidget(
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: ((context) {
                          return MaterialsPage();
                        }),
                      ),
                    );
                  },
                  icon: Icons.app_registration_rounded,
                  isActive: true,
                  subText:
                      'Create and Manager Production Raw Materials',
                  title: 'Production Materials',
                ),
                ProductionPageListTileWidget(
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: ((context) {
                          return MaterialsUsagePage();
                        }),
                      ),
                    );
                  },
                  icon: Icons.border_horizontal_rounded,
                  isActive: true,
                  subText:
                      'Track How materials are used for Productions.',
                  title: 'Materials Usage Records',
                ),
                ProductionPageListTileWidget(
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: ((context) {
                          return ProductionSettingsPage();
                        }),
                      ),
                    );
                  },
                  icon: Icons.settings,
                  isActive: true,
                  subText: 'Manage Settings for Production',
                  title: 'Settings',
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
