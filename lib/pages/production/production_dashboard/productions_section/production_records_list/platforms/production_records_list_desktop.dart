import 'package:flutter/material.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/invoices/invoice_list/platforms/invoice_list_desktop.dart';
import 'package:stockall/pages/production/production_dashboard/components/productions_record_tile.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/create_production/create_production.dart';

class ProductionRecordsListDesktop extends StatefulWidget {
  final String? productionItemUuid;
  final String? productUuid;
  const ProductionRecordsListDesktop({
    super.key,
    this.productionItemUuid,
    this.productUuid,
  });

  @override
  State<ProductionRecordsListDesktop> createState() =>
      _ProductionRecordsListDesktopState();
}

class _ProductionRecordsListDesktopState
    extends State<ProductionRecordsListDesktop> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var productionProv = returnProductionRecordsProvider();
    var records =
        returnProductionRecordsProvider(
          context: context,
        ).returnProductionRecordsByDayOrWeek().where((
          item,
        ) {
          if (widget.productionItemUuid != null) {
            return item.itemUuid ==
                widget.productionItemUuid;
          } else if (widget.productUuid != null) {
            return item.salesItemUuid == widget.productUuid;
          } else {
            return true;
          }
        }).toList();
    var theme = returnTheme(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        spacing: 15,
        children: [
          Container(
            width:
                screenWidth(context) < tabletScreenSmall
                    ? 50
                    : (screenWidth(context) >
                            tabletScreenSmall &&
                        screenWidth(context) <
                            tabletScreen + 100)
                    ? 100
                    : 230,
          ),
          Expanded(
            child: DesktopPageContainer(
              widget: Scaffold(
                appBar: appBar(
                  context: context,
                  title: 'Production Records',
                  widget: Row(
                    spacing: 15,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible:
                            screenWidth(context) >
                            mobileScreen,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            mouseCursor:
                                SystemMouseCursors.click,
                            borderRadius:
                                BorderRadius.circular(10),
                            onTap: () async {
                              getProductionRecords();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(
                                10,
                              ),
                              child: Row(
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
                                          FontWeight.bold,
                                    ),
                                    'Refresh',
                                  ),
                                  Icon(
                                    size: 18,
                                    Icons.refresh_rounded,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 15.0,
                        ),
                        child: Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations().viewDate,
                          ),
                          child: InkWell(
                            mouseCursor:
                                SystemMouseCursors.click,
                            onTap: () {
                              if (productionProv.dateSet !=
                                      null ||
                                  productionProv
                                          .rangeStartDate !=
                                      null) {
                                productionProv.clearDate();
                              } else {
                                mainDatePicker(
                                  context: context,
                                  theme: theme,
                                  singleDate: (date) {
                                    productionProv.setDate(
                                      date!,
                                    );
                                  },
                                  rangeDate: (
                                    firstDate,
                                    lastDate,
                                  ) {
                                    productionProv.setRange(
                                      firstDate!,
                                      lastDate ??
                                          DateTime.now(),
                                    );
                                  },
                                );
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                right: 5,
                              ),
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
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                    ),
                                    returnProductionRecordsProvider(
                                                  context:
                                                      context,
                                                ).dateSet !=
                                                null ||
                                            returnProductionRecordsProvider(
                                                  context:
                                                      context,
                                                ).rangeStartDate !=
                                                null
                                        ? 'Clear'
                                        : 'Date',
                                  ),
                                  Icon(
                                    size: 16,
                                    returnProductionRecordsProvider(
                                                  context:
                                                      context,
                                                ).dateSet !=
                                                null ||
                                            returnProductionRecordsProvider(
                                                  context:
                                                      context,
                                                ).rangeStartDate !=
                                                null
                                        ? Icons.clear
                                        : Icons
                                            .date_range_outlined,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                floatingActionButton: Visibility(
                  visible:
                      authorization(
                        authorized:
                            Authorizations()
                                .addProductionRecords,
                      ) &&
                      widget.productionItemUuid == null,
                  child: FloatingActionButtonMain(
                    action: () {
                      GeneralSettingsAuthAction()
                          .manageProductions(
                            context: context,
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
                          );
                    },
                    color: theme.lightModeColor.secColor100,
                    text: 'Record Production',
                    theme: theme,
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  child: Column(
                    children: [
                      Material(
                        color: Colors.white,
                        child: Column(
                          children: [
                            Row(
                              spacing: 10,
                              children: [
                                ValueSummaryTabSmall(
                                  color: Colors.amber,
                                  isMoney: false,
                                  title: 'Total Produced',
                                  value: productionProv
                                      .getTotalProducedInProduction(
                                        records: records,
                                      ),
                                ),
                                ValueSummaryTabSmall(
                                  value:
                                      records.length
                                          .toDouble(),
                                  title: 'Entries',
                                  color: Colors.green,
                                  isMoney: false,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (records.isEmpty) {
                              return EmptyWidgetDisplayOnly(
                                title: 'Empty List',
                                subText:
                                    'You have not Created any Production Record',
                                icon: Icons.clear,
                                theme: theme,
                                height: 30,
                                altAction: () {
                                  getProductionRecords();
                                },
                                altActionText: 'Refresh',
                              );
                            } else {
                              return RefreshIndicator(
                                onRefresh:
                                    getProductionRecords,
                                backgroundColor:
                                    Colors.white,
                                color:
                                    theme
                                        .lightModeColor
                                        .prColor300,
                                displacement: 10,
                                child: ListView(
                                  children:
                                      records
                                          .map(
                                            (
                                              item,
                                            ) => ProductionsRecordTile(
                                              productionRecord:
                                                  item,
                                            ),
                                          )
                                          .toList(),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width:
                screenWidth(context) < tabletScreenSmall
                    ? 50
                    : (screenWidth(context) >
                            tabletScreenSmall &&
                        screenWidth(context) <
                            tabletScreen + 100)
                    ? 100
                    : 230,
          ),
        ],
      ),
    );
  }
}

Future<void> getProductionRecords() async {
  returnProductionRecordsProvider().getProductionRecords(
    shopId(),
  );
}
