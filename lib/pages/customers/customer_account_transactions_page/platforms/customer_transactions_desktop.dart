import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customer_account_receipts/customer_account_receipts.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_transactions_section.dart';
import 'package:stockall/pages/products/item_history_page/platforms/item_history_desktop.dart';

class CustomerTransactionsDesktop extends StatefulWidget {
  final String? customerUuid;
  const CustomerTransactionsDesktop({
    super.key,
    this.customerUuid,
  });

  @override
  State<CustomerTransactionsDesktop> createState() =>
      _CustomerTransactionsDesktopState();
}

class _CustomerTransactionsDesktopState
    extends State<CustomerTransactionsDesktop> {
  bool isLoading = false;
  bool showSuccess = false;
  bool setDate = false;

  TextEditingController searchController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    List<CustomerAccountReceipts>? accountReceipts =
        returnCustomerAccountReceiptsProvider(
          context: context,
        ).returnCustomerAccountReceiptsByDayOrWeek().where((
          accountReceipt,
        ) {
          if (widget.customerUuid != null) {
            return accountReceipt.customerUuid ==
                    widget.customerUuid &&
                (accountReceipt.customerName
                            ?.toLowerCase()
                            .contains(
                              searchController.text
                                  .toLowerCase(),
                            ) ==
                        true ||
                    accountReceipt.staffName
                            ?.toLowerCase()
                            .contains(
                              searchController.text
                                  .toLowerCase(),
                            ) ==
                        true ||
                    accountReceipt.title
                            ?.toLowerCase()
                            .contains(
                              searchController.text
                                  .toLowerCase(),
                            ) ==
                        true);
          } else {
            return (accountReceipt.customerName
                        ?.toLowerCase()
                        .contains(
                          searchController.text
                              .toLowerCase(),
                        ) ==
                    true ||
                accountReceipt.staffName
                        ?.toLowerCase()
                        .contains(
                          searchController.text
                              .toLowerCase(),
                        ) ==
                    true ||
                accountReceipt.title
                        ?.toLowerCase()
                        .contains(
                          searchController.text
                              .toLowerCase(),
                        ) ==
                    true);
          }
        }).toList();
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
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      39,
                      4,
                      1,
                      41,
                    ),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Scaffold(
                appBar: appBar(
                  context: context,
                  title: 'Item History',
                  widget: Row(
                    spacing: 3,
                    children: [
                      InkWell(
                        mouseCursor:
                            SystemMouseCursors.click,
                        onTap: () {
                          returnCustomerAccountReceiptsProvider()
                              .getCustomerAccountReceipts(
                                shopId(),
                              );
                        },
                        child: Container(
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
                                'Refresh',
                              ),
                              Icon(size: 17, Icons.refresh),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations().viewDate,
                        ),
                        child: InkWell(
                          mouseCursor:
                              SystemMouseCursors.click,
                          onTap: () {
                            if (returnCustomerAccountReceiptsProvider()
                                        .dateSet !=
                                    null ||
                                returnCustomerAccountReceiptsProvider()
                                        .rangeStartDate !=
                                    null) {
                              returnCustomerAccountReceiptsProvider()
                                  .clearDate();
                            } else {
                              mainDatePicker(
                                context: context,
                                theme: theme,
                                singleDate: (date) {
                                  returnCustomerAccountReceiptsProvider()
                                      .setDate(date!);
                                },
                                rangeDate: (
                                  firstDate,
                                  lastDate,
                                ) {
                                  returnCustomerAccountReceiptsProvider()
                                      .setRange(
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
                                  returnCustomerAccountReceiptsProvider(
                                                context:
                                                    context,
                                              ).dateSet !=
                                              null ||
                                          returnCustomerAccountReceiptsProvider(
                                                context:
                                                    context,
                                              ).rangeStartDate !=
                                              null
                                      ? 'Clear'
                                      : 'Date',
                                ),
                                Icon(
                                  size: 16,
                                  returnCustomerAccountReceiptsProvider(
                                                context:
                                                    context,
                                              ).dateSet !=
                                              null ||
                                          returnCustomerAccountReceiptsProvider(
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
                    ],
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (accountReceipts.isEmpty) {
                              return Center(
                                child: EmptyWidgetDisplayOnly(
                                  title: 'No Events Found',
                                  subText:
                                      'No event has been created for this date.',
                                  theme: theme,
                                  height: 30,
                                  altAction: () {
                                    returnCustomerAccountReceiptsProvider()
                                        .getCustomerAccountReceipts(
                                          shopId(),
                                        );
                                  },
                                  altActionText: 'Reload',
                                  icon: Icons.clear,
                                ),
                              );
                            } else {
                              return ListView(
                                children:
                                    accountReceipts
                                        .map(
                                          (item) => Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  vertical:
                                                      4.0,
                                                ),
                                            child: CustomerTransactionList(
                                              theme: theme,
                                              accountReceipt:
                                                  item,
                                            ),
                                          ),
                                        )
                                        .toList(),
                              );
                            }
                          },
                        ),
                      ),
                      SearchFilterWidgetHistory(
                        searchController: searchController,
                        onChanged: (value) {
                          setState(() {});
                        },
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

// }
