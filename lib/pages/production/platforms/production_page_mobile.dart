import 'package:flutter/material.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/components/production_page_list_tile_widget.dart';
import 'package:stockall/pages/production/materials_page/materials_page.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/materials_usage_page.dart';
import 'package:stockall/pages/production/production_dashboard/productions_dashboard.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_records_list/production_records_list.dart';
import 'package:stockall/pages/production/production_items/production_items_page.dart';
import 'package:stockall/pages/production/settings/production_settings_page.dart';

class ProductionPageMobile extends StatefulWidget {
  const ProductionPageMobile({super.key});

  @override
  State<ProductionPageMobile> createState() =>
      _ProductionPageMobileState();
}

class _ProductionPageMobileState
    extends State<ProductionPageMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Production',
        backAction: () {
          Navigator.of(context).pop();
        },
        // widget: Padding(
        //   padding: const EdgeInsets.only(right: 10.0),
        //   child: CreateCategoryWidget(),
        // ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            // horizontal: 15.0,
          ),
          child: Column(
            children: [
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
                      subText:
                          'Create and Track Productions',
                      title: 'Productions Dashboard',
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
                    Visibility(
                      visible:
                          shop(
                            context,
                          )?.manageProductionItems ==
                          true,
                      child: ProductionPageListTileWidget(
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
                      subText:
                          'Manage Settings for Production',
                      title: 'Settings',
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
