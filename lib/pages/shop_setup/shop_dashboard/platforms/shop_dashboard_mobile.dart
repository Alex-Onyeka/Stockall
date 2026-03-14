import 'package:flutter/material.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/subscription/multiple_stores_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/shop_setup/shop_dashboard/components/individual_store_list_widget.dart';
import 'package:stockall/pages/shop_setup/shop_dashboard/components/quick_action_buttons.dart';
import 'package:stockall/pages/shop_setup/shop_dashboard/components/shop_dashboard_total_widget.dart';
import 'package:stockall/pages/shop_setup/shop_setup_one/shop_setup_page.dart';

class ShopDashboardMobile extends StatefulWidget {
  const ShopDashboardMobile({super.key});

  @override
  State<ShopDashboardMobile> createState() =>
      _ShopDashboardMobileState();
}

class _ShopDashboardMobileState
    extends State<ShopDashboardMobile> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      appBar: appBar(
        backAction: () => Navigator.of(context).pop(),
        context: context,
        title: 'Shops Dashboard',
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 20,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            child: Column(
              spacing: 10,
              children: [
                Row(
                  spacing: 5,
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(
                      opacity: 0,
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(size: 18, Icons.refresh),
                      ),
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      'General Summary',
                    ),
                    Builder(
                      builder: (context) {
                        if (returnShopDashboardProvider(
                          context: context,
                        ).isLoading) {
                          return Padding(
                            padding: const EdgeInsets.all(
                              15,
                            ),
                            child: SizedBox(
                              height: 16,
                              width: 16,
                              child:
                                  CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        theme
                                            .lightModeColor
                                            .secColor200,
                                  ),
                            ),
                          );
                        } else {
                          return IconButton(
                            onPressed: () {
                              returnShopDashboardProvider()
                                  .fetchAllData();
                            },
                            icon: Icon(
                              size: 18,
                              Icons.refresh,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                Container(
                  height: 2.5,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: theme.lightModeColor.secColor200,
                  ),
                ),
                // SizedBox(height: 5),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 12,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            'Quick Actions',
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            spacing: 10,
                            children: [
                              QuickActionButtons(
                                icon: Icons.add,
                                action: () {
                                  MultipleStoresAuthAction()
                                      .numberOfStoresAction(
                                        context: context,
                                        action: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return ShopSetupPage();
                                              },
                                            ),
                                          );
                                        },
                                      );
                                },
                                title: 'Create Shop',
                              ),
                              QuickActionButtons(
                                icon:
                                    returnShopDashboardProvider(
                                                  context:
                                                      context,
                                                ).dateSet !=
                                                null ||
                                            returnShopDashboardProvider(
                                                  context:
                                                      context,
                                                ).rangeStartDate !=
                                                null
                                        ? Icons.clear
                                        : Icons
                                            .calendar_month_outlined,
                                action: () {
                                  if (returnShopDashboardProvider()
                                              .dateSet !=
                                          null ||
                                      returnShopDashboardProvider()
                                              .rangeStartDate !=
                                          null) {
                                    returnShopDashboardProvider()
                                        .clearDate();
                                  } else {
                                    mainDatePicker(
                                      context: context,
                                      theme: theme,
                                      singleDate: (date) {
                                        returnShopDashboardProvider()
                                            .setDate(
                                              date ??
                                                  DateTime.now(),
                                            );
                                      },
                                      rangeDate: (
                                        firstDate,
                                        lastDate,
                                      ) {
                                        returnShopDashboardProvider()
                                            .setRange(
                                              firstDate!,
                                              lastDate ??
                                                  DateTime.now(),
                                            );
                                      },
                                    );
                                  }
                                },
                                title:
                                    returnShopDashboardProvider()
                                                    .dateSet !=
                                                null ||
                                            returnShopDashboardProvider()
                                                    .rangeStartDate !=
                                                null
                                        ? 'Clear'
                                        : 'Set Date',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1),
                    Row(
                      children: [
                        Expanded(
                          child: ShopDashboardTotalWidget(
                            gradient:
                                theme
                                    .lightModeColor
                                    .prGradient,
                            title: 'Total Revenue',
                            isMoney: true,
                            value:
                                returnShopDashboardProvider(
                                  context: context,
                                ).returnTotalRevenue(),
                            fontSize:
                                theme
                                    .mobileTexts
                                    .h2
                                    .fontSize,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: ShopDashboardTotalWidget(
                            title: 'Total Expenses',
                            isMoney: true,
                            value:
                                returnShopDashboardProvider(
                                  context: context,
                                ).returnTotalExpenses(),
                          ),
                        ),
                        Expanded(
                          child: ShopDashboardTotalWidget(
                            title: 'Total Profit',
                            isMoney: true,
                            value:
                                returnShopDashboardProvider(
                                  context: context,
                                ).returnProfit(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: ShopDashboardTotalWidget(
                            title: 'Total Sales',
                            isMoney: false,
                            value:
                                returnShopDashboardProvider(
                                      context: context,
                                    )
                                    .returnReceipts()
                                    .length
                                    .toDouble(),
                          ),
                        ),
                        Expanded(
                          child: ShopDashboardTotalWidget(
                            title: 'Total Invoices',
                            isMoney: false,
                            value:
                                returnShopDashboardProvider(
                                      context: context,
                                    )
                                    .returnInvoices()
                                    .length
                                    .toDouble(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: ShopDashboardTotalWidget(
                            title: 'Total Staffs',
                            isMoney: false,
                            value:
                                returnShopDashboardProvider(
                                      context: context,
                                    ).allStaffs.length
                                    .toDouble(),
                          ),
                        ),
                        Expanded(
                          child: ShopDashboardTotalWidget(
                            title: 'Total Customers',
                            isMoney: false,
                            value:
                                returnShopDashboardProvider(
                                      context: context,
                                    ).allCustomers.length
                                    .toDouble(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: ShopDashboardTotalWidget(
                            title: 'Total Items in Stock',
                            isMoney: false,
                            value:
                                returnShopDashboardProvider(
                                  context: context,
                                ).returnAllItems(),
                          ),
                        ),
                        Expanded(
                          child: ShopDashboardTotalWidget(
                            title: 'Total Items Value',
                            isMoney: true,
                            value:
                                returnShopDashboardProvider(
                                  context: context,
                                ).returnAllItemsValeu(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 15,
            ),
            child: Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  spacing: 5,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      'Store List',
                    ),
                  ],
                ),
                Container(
                  height: 2.5,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: theme.lightModeColor.secColor200,
                  ),
                ),
                SizedBox(height: 5),
                Column(
                  children:
                      returnShopProvider(context: context)
                          .userShops
                          .map(
                            (shop) =>
                                IndividualStoreListWidget(
                                  shop: shop,
                                ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
