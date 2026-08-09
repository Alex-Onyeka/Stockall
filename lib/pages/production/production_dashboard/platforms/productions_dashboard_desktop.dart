import 'package:flutter/material.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/materials_usage_page.dart';
import 'package:stockall/pages/production/production_dashboard/components/production_total_tab.dart';
import 'package:stockall/pages/production/production_dashboard/components/productions_record_tile.dart';
import 'package:stockall/pages/production/production_dashboard/productions_dashboard.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/create_production/create_production.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_records_list/production_records_list.dart';
import 'package:stockall/pages/production/production_items/production_item_history_page/production_item_history_page.dart';
import 'package:stockall/pages/production/production_items/production_items_page.dart';

class ProductionsDashboardDesktop extends StatefulWidget {
  const ProductionsDashboardDesktop({super.key});

  @override
  State<ProductionsDashboardDesktop> createState() =>
      _ProductionsDashboardDesktopState();
}

class _ProductionsDashboardDesktopState
    extends State<ProductionsDashboardDesktop> {
  @override
  Widget build(BuildContext context) {
    var recordsProv = returnProductionRecordsProvider();
    var itemsHistoryProv =
        returnProductionItemHistoryProvider();
    var productionItemsProv =
        returnProductionItemsProvider();
    var theme = returnTheme(context);
    return DesktopCenterContainer(
      width: 900,
      mainWidget: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: 15),
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
                    'Manage Productions',
                  ),
                  Text(
                    style:
                        theme
                            .mobileTexts
                            .b3
                            .textStyleNormal,
                    "Create, Manage and Track Your Productions",
                  ),
                ],
              ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    refreshProductionDashboard();
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 15),
                    padding: EdgeInsets.only(
                      right: 10,
                      left: 10,
                      top: 5,
                      bottom: 5,
                    ),
                    decoration: BoxDecoration(),
                    child: Row(
                      spacing: 3,
                      children: [
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                          ),
                          'Refresh',
                        ),
                        Icon(size: 17, Icons.refresh),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 25),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      10,
                      10,
                      10,
                      0,
                    ),
                    child: Column(
                      spacing: 10,
                      children: [
                        Row(
                          spacing: 10,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              child: ProductionTotalTab(
                                entries:
                                    recordsProv
                                        .returnProductionRecordsByDayOrWeek()
                                        .length,
                                title: 'Produced Today',
                                action: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ProductionRecordsList();
                                      },
                                    ),
                                  );
                                },
                                number: recordsProv
                                    .getTotalProducedInProduction(
                                      records: null,
                                    ),
                                icon:
                                    Icons
                                        .view_in_ar_rounded,
                                color:
                                    theme
                                        .lightModeColor
                                        .prColor250,
                                theme: theme,
                              ),
                            ),
                            Expanded(
                              child: ProductionTotalTab(
                                entries:
                                    itemsHistoryProv
                                        .returnTransferedTodayHistories()
                                        .length,
                                title: 'Transfered Out',
                                number: itemsHistoryProv
                                    .getTotalTransferedOut(
                                      itemHistories: null,
                                    ),
                                icon:
                                    Icons
                                        .rotate_left_rounded,
                                action: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ProductionItemHistoryPage(
                                          fromProductionItemDetails:
                                              false,
                                          viewTransferedOut:
                                              true,
                                        );
                                      },
                                    ),
                                  );
                                },
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              child: ProductionTotalTab(
                                entries:
                                    productionItemsProv
                                        .returnRemainingProductionItems()
                                        .length,
                                title: 'Remaining Items',
                                action: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ProductionItemsPage(
                                          seeRemainingItems:
                                              true,
                                        );
                                      },
                                    ),
                                  );
                                },
                                number:
                                    productionItemsProv
                                        .getTotalRemainingItems(),
                                icon: Icons.api_rounded,
                                color:
                                    theme
                                        .lightModeColor
                                        .prColor250,
                                theme: theme,
                              ),
                            ),
                            Expanded(
                              child: ProductionTotalTab(
                                color:
                                    theme
                                        .lightModeColor
                                        .tertColor200,
                                entries:
                                    recordsProv
                                        .returnAllProductionRecordMaterials(
                                          productionRecords:
                                              null,
                                        )
                                        .length,
                                title: 'Materials Used',
                                number: recordsProv
                                    .getTotalMaterialsUsed(
                                      productionRecords:
                                          null,
                                    ),
                                icon:
                                    Icons
                                        .app_registration_rounded,
                                action: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return MaterialsUsagePage(
                                          fromMaterialUsagePage:
                                              false,
                                        );
                                      },
                                    ),
                                  );
                                },
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
                  Visibility(
                    visible: authorization(
                      authorized:
                          Authorizations()
                              .addProductionRecords,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 500,
                          ),
                          child: MainButtonP(
                            themeProvider: theme,
                            action: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return CreateProduction();
                                  },
                                ),
                              );
                            },
                            text: 'RECORD PRODUCTION',
                          ),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.grey.shade400,
                    thickness: 0.3,
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(
                      10,
                      5,
                      10,
                      10,
                    ),
                    child: Row(
                      spacing: 10,
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          'Recent Productions',
                        ),
                        Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ProductionRecordsList();
                                  },
                                ),
                              );
                            },
                            mouseCursor:
                                SystemMouseCursors.click,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 12,
                                  ),
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                spacing: 5,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.normal,
                                      color:
                                          theme
                                              .lightModeColor
                                              .secColor200,
                                    ),
                                    'View All',
                                  ),
                                  Icon(
                                    size: 16,
                                    color:
                                        theme
                                            .lightModeColor
                                            .secColor200,
                                    Icons
                                        .arrow_forward_ios_rounded,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      if (recordsProv
                          .returnProductionRecordsByDayOrWeek()
                          .isEmpty) {
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: Material(
                              type:
                                  MaterialType.transparency,
                              child: EmptyWidgetDisplayOnly(
                                title:
                                    'No Production Recorded',
                                subText:
                                    'No Production has been recorded for today.',
                                theme: theme,
                                height: 0,
                                // icon: Icons.clear,
                                altAction: () {
                                  refreshProductionDashboard();
                                },
                                altActionText: 'Refresh',
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Column(
                          spacing: 5,
                          children:
                              (recordsProv
                                              .returnProductionRecordsByDayOrWeek()
                                              .length >
                                          5
                                      ? recordsProv
                                          .returnProductionRecordsByDayOrWeek()
                                          .sublist(0, 5)
                                      : recordsProv
                                          .returnProductionRecordsByDayOrWeek())
                                  .map(
                                    (item) =>
                                        ProductionsRecordTile(
                                          productionRecord:
                                              item,
                                        ),
                                  )
                                  .toList(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
