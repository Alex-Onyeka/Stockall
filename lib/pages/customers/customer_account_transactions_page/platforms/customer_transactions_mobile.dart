import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customer_account_receipts/customer_account_receipts.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_transactions_section.dart';
import 'package:stockall/pages/products/item_history_page/platforms/item_history_desktop.dart';

class CustomerTransactionsMobile extends StatefulWidget {
  final String? customerUuid;
  const CustomerTransactionsMobile({
    super.key,
    required this.customerUuid,
  });

  @override
  State<CustomerTransactionsMobile> createState() =>
      CustomerTransactionsMobileState();
}

class CustomerTransactionsMobileState
    extends State<CustomerTransactionsMobile> {
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

  @override
  void initState() {
    super.initState();
  }

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
      appBar: appBar(
        context: context,
        title: 'Transactions',
        widget: Visibility(
          visible: authorization(
            authorized: Authorizations().viewDate,
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
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
                    rangeDate: (firstDate, lastDate) {
                      returnCustomerAccountReceiptsProvider()
                          .setRange(
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
                      returnCustomerAccountReceiptsProvider(
                                    context: context,
                                  ).dateSet !=
                                  null ||
                              returnCustomerAccountReceiptsProvider(
                                    context: context,
                                  ).rangeStartDate !=
                                  null
                          ? 'Clear'
                          : 'Date',
                    ),
                    Icon(
                      size: 16,
                      returnCustomerAccountReceiptsProvider(
                                    context: context,
                                  ).dateSet !=
                                  null ||
                              returnCustomerAccountReceiptsProvider(
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            Expanded(
              child: Builder(
                builder: (context) {
                  if (accountReceipts.isEmpty) {
                    return Center(
                      child: EmptyWidgetDisplayOnly(
                        title: 'No Transactions Found',
                        subText:
                            'No Transactions has been created for this date.',
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
                    return RefreshIndicator(
                      backgroundColor: Colors.white,
                      color: Colors.amber,
                      displacement: 10,
                      strokeWidth: 1.5,
                      onRefresh: () {
                        return returnCustomerAccountReceiptsProvider()
                            .getCustomerAccountReceipts(
                              shopId(),
                            );
                      },
                      child: ListView(
                        children:
                            accountReceipts
                                .map(
                                  (item) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                    child:
                                        CustomerTransactionList(
                                          theme: theme,
                                          accountReceipt:
                                              item,
                                        ),
                                  ),
                                )
                                .toList(),
                      ),
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
    );
  }
}
