import 'package:flutter/material.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/invoices/invoice_list/platforms/invoice_list_mobile.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/components/materials_usage_tile.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/create_materials_usage/create_materials_usage_page.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/platforms/materials_usage_desktop.dart';

class MaterialsUsageMobile extends StatefulWidget {
  final String? materialUuid;
  const MaterialsUsageMobile({
    super.key,
    this.materialUuid,
  });

  @override
  State<MaterialsUsageMobile> createState() =>
      _MaterialsUsageMobileState();
}

class _MaterialsUsageMobileState
    extends State<MaterialsUsageMobile> {
  @override
  Widget build(BuildContext context) {
    var materialUsageProv = returnMaterialsUsageProvider();
    var records =
        returnMaterialsUsageProvider(context: context)
            .returnOwnProductionMaterialsUsageByDayOrWeek()
            .where((item) {
              if (widget.materialUuid != null) {
                return item.materialUuid ==
                    widget.materialUuid;
              } else {
                return true;
              }
            })
            .toList();
    var theme = returnTheme(context);
    return GestureDetector(
      onTap: () {
        materialUsageProv.clearDate();
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
                  if (materialUsageProv.dateSet != null ||
                      materialUsageProv.rangeStartDate !=
                          null) {
                    materialUsageProv.clearDate();
                  } else {
                    mainDatePicker(
                      context: context,
                      theme: theme,
                      singleDate: (date) {
                        materialUsageProv.setDate(date!);
                      },
                      rangeDate: (firstDate, lastDate) {
                        materialUsageProv.setRange(
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
                        returnMaterialsUsageProvider(
                                      context: context,
                                    ).dateSet !=
                                    null ||
                                returnMaterialsUsageProvider(
                                      context: context,
                                    ).rangeStartDate !=
                                    null
                            ? 'Clear'
                            : 'Date',
                      ),
                      Icon(
                        size: 16,
                        returnMaterialsUsageProvider(
                                      context: context,
                                    ).dateSet !=
                                    null ||
                                returnMaterialsUsageProvider(
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
                    Authorizations().addMaterialsUsage,
              ) &&
              widget.materialUuid == null,
          child: FloatingActionButtonMain(
            action: () {
              GeneralSettingsAuthAction().manageProductions(
                context: context,
                action: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return CreateMaterialsUsagePage();
                      },
                    ),
                  );
                },
              );
            },
            color: theme.lightModeColor.secColor100,
            text: 'Record Usage',
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
                          title: 'Total Used',
                          value:
                              materialUsageProv
                                  .getTotalMaterialsUsed(),
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
                            'You don\'t have any Usaged under this category',
                        icon: Icons.clear,
                        theme: theme,
                        height: 35,
                        altAction: () {
                          getMaterialUsage();
                        },
                        altActionText: 'Refresh',
                      );
                    } else {
                      return RefreshIndicator(
                        onRefresh: getMaterialUsage,
                        backgroundColor: Colors.white,
                        color:
                            theme.lightModeColor.prColor300,
                        displacement: 10,
                        child: ListView(
                          children:
                              records
                                  .map(
                                    (
                                      item,
                                    ) => MaterialsUsageTile(
                                      materialsUsage: item,
                                      fromDetails: false,
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
