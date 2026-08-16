import 'package:flutter/material.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/materials_page/materials_page.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/materials_usage_page.dart';
import 'package:stockall/pages/production/production_dashboard/components/production_total_tab.dart';
import 'package:stockall/pages/production/production_dashboard/components/productions_record_tile.dart';
import 'package:stockall/pages/production/production_dashboard/productions_dashboard.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/create_production/create_production.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_records_list/production_records_list.dart';
import 'package:stockall/pages/production/production_items/production_item_history_page/production_item_history_page.dart';
import 'package:stockall/pages/production/production_items/production_items_page.dart';

class ProductionsDashboardMobile extends StatefulWidget {
  const ProductionsDashboardMobile({super.key});

  @override
  State<ProductionsDashboardMobile> createState() =>
      _ProductionsDashboardMobileState();
}

class _ProductionsDashboardMobileState
    extends State<ProductionsDashboardMobile> {
  @override
  Widget build(BuildContext context) {
    var recordsProv = returnProductionRecordsProvider(
      context: context,
    );
    var itemsProv = returnProductionItemHistoryProvider(
      context: context,
    );
    var productionItemsProv = returnProductionItemsProvider(
      context: context,
    );
    var theme = returnTheme(context);
    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Manage Productions',
        backAction: () {
          Navigator.of(context).pop();
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 5.0,
          ),
          child: RefreshIndicator(
            backgroundColor: Colors.white,
            color: Colors.amber,
            displacement: 10,
            strokeWidth: 1.5,
            onRefresh: () {
              return refreshProductionDashboard();
            },
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
                            MainAxisAlignment.spaceBetween,
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
                                  Icons.view_in_ar_rounded,
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
                                  itemsProv
                                      .returnTransferedTodayHistories()
                                      .length,
                              title: 'Transfered Out',
                              number: itemsProv
                                  .getTotalTransferedOut(
                                    itemHistories: null,
                                  ),
                              icon:
                                  Icons.rotate_left_rounded,
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
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                if (shop(
                                      context,
                                    )?.manageProductionItems ==
                                    true) {
                                  return ProductionTotalTab(
                                    entries:
                                        productionItemsProv
                                            .returnRemainingProductionItems()
                                            .length,
                                    title:
                                        'Remaining Items',
                                    action: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (
                                            context,
                                          ) {
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
                                  );
                                } else {
                                  return ProductionTotalTab(
                                    entries:
                                        returnMaterialsProvider()
                                            .materialList()
                                            .length,
                                    title:
                                        'Production Materials',
                                    action: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (
                                            context,
                                          ) {
                                            return MaterialsPage();
                                          },
                                        ),
                                      );
                                    },
                                    number: returnMaterialsProvider()
                                        .materialList()
                                        .map(
                                          (item) =>
                                              (item.quantity ??
                                                  0),
                                        )
                                        .fold(
                                          0,
                                          (a, b) => a + b,
                                        ),
                                    icon:
                                        Icons
                                            .app_registration_rounded,
                                    color:
                                        theme
                                            .lightModeColor
                                            .tertColor200,

                                    theme: theme,
                                  );
                                }
                              },
                            ),
                          ),
                          Expanded(
                            child: ProductionTotalTab(
                              color:
                                  theme
                                      .lightModeColor
                                      .prColor250,
                              entries:
                                  returnMaterialsUsageProvider(
                                        context: context,
                                      )
                                      .returnOwnProductionMaterialsUsageByDayOrWeek()
                                      .length,
                              title: 'Materials Usage',
                              number:
                                  returnMaterialsUsageProvider(
                                    context: context,
                                  ).getTotalMaterialsUsed(),
                              icon:
                                  Icons
                                      .border_horizontal_rounded,
                              action: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return MaterialsUsagePage();
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
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
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: Column(
                    children: [
                      Divider(
                        color: Colors.grey.shade400,
                        thickness: 0.3,
                      ),
                      Padding(
                        padding:
                            EdgeInsetsGeometry.fromLTRB(
                              10,
                              5,
                              10,
                              10,
                            ),
                        child: Row(
                          spacing: 10,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
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
                              type:
                                  MaterialType.transparency,
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
                                    SystemMouseCursors
                                        .click,
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
                                              FontWeight
                                                  .normal,
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
                                      MaterialType
                                          .transparency,
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
                                    altActionText:
                                        'Refresh',
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
                                        (
                                          item,
                                        ) => ProductionsRecordTile(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
