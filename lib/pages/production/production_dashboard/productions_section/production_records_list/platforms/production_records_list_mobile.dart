import 'package:flutter/material.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/invoices/invoice_list/platforms/invoice_list_mobile.dart';
import 'package:stockall/pages/production/production_dashboard/components/productions_record_tile.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/create_production/create_production.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_records_list/platforms/production_records_list_desktop.dart';

class ProductionRecordsListMobile extends StatefulWidget {
  final String? productionItemUuid;
  const ProductionRecordsListMobile({
    super.key,
    this.productionItemUuid,
  });

  @override
  State<ProductionRecordsListMobile> createState() =>
      _ProductionRecordsListMobileState();
}

class _ProductionRecordsListMobileState
    extends State<ProductionRecordsListMobile> {
  @override
  Widget build(BuildContext context) {
    var productionProv = returnProductionRecordsProvider();
    var records =
        returnProductionRecordsProvider(context: context)
            .returnProductionRecordsByDayOrWeek()
            .where((item) {
              if (widget.productionItemUuid != null) {
                return item.itemUuid ==
                    widget.productionItemUuid;
              } else {
                return true;
              }
            })
            .toList();
    var theme = returnTheme(context);
    return GestureDetector(
      onTap: () {
        productionProv.clearDate();
      },
      child: Scaffold(
        appBar: appBar(
          context: context,
          title: 'Records',
          widget: Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Visibility(
              visible: authorization(
                authorized: Authorizations().viewDate,
              ),
              child: InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  if (productionProv.dateSet != null ||
                      productionProv.rangeStartDate !=
                          null) {
                    productionProv.clearDate();
                  } else {
                    mainDatePicker(
                      context: context,
                      theme: theme,
                      singleDate: (date) {
                        productionProv.setDate(date!);
                      },
                      rangeDate: (firstDate, lastDate) {
                        productionProv.setRange(
                          firstDate!,
                          lastDate ?? DateTime.now(),
                        );
                      },
                    );
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(right: 5),
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
                              theme.mobileTexts.b3.fontSize,
                        ),
                        returnProductionRecordsProvider(
                                      context: context,
                                    ).dateSet !=
                                    null ||
                                returnProductionRecordsProvider(
                                      context: context,
                                    ).rangeStartDate !=
                                    null
                            ? 'Clear'
                            : 'Date',
                      ),
                      Icon(
                        size: 16,
                        returnProductionRecordsProvider(
                                      context: context,
                                    ).dateSet !=
                                    null ||
                                returnProductionRecordsProvider(
                                      context: context,
                                    ).rangeStartDate !=
                                    null
                            ? Icons.clear
                            : Icons.date_range_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: Visibility(
          visible:
              authorization(
                authorized:
                    Authorizations().addProductionRecords,
              ) &&
              widget.productionItemUuid == null,
          child: FloatingActionButtonMain(
            action: () {
              GeneralSettingsAuthAction().manageProductions(
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
                          value: records.length.toDouble(),
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
                            'You don\'t have any Sales under this category',
                        icon: Icons.clear,
                        theme: theme,
                        height: 35,
                        altAction: () {
                          getProductionRecords();
                        },
                        altActionText: 'Refresh',
                      );
                    } else {
                      return RefreshIndicator(
                        onRefresh: getProductionRecords,
                        backgroundColor: Colors.white,
                        color:
                            theme.lightModeColor.prColor300,
                        displacement: 10,
                        child: ListView(
                          children:
                              records
                                  .map(
                                    (item) =>
                                        ProductionsRecordTile(
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
    );
  }
}
