import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customer_account_receipts/customer_account_receipts.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customer_account_transactions_page/customer_transactions_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class CustomerTransactionsSection extends StatelessWidget {
  final String customerUuid;
  const CustomerTransactionsSection({
    super.key,
    required this.customerUuid,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    // List<CustomerAccountReceipts> tempReceipts
    List<CustomerAccountReceipts> accountReceipts =
        returnCustomerAccountReceiptsProvider(
                      context: context,
                    )
                    .getACustomerReceipts(
                      customerUuid: customerUuid,
                    )
                    .where((item) {
                      var shop =
                          returnShopProvider(
                            context: context,
                          ).userShop()!;
                      if (shop.manageCustomerAccount !=
                          true) {
                        return item.isBalance == false;
                      } else if (shop
                              .manageCustomerReward !=
                          true) {
                        return item.isBalance == true;
                      } else {
                        return true;
                      }
                    })
                    .length >
                5
            ? returnCustomerAccountReceiptsProvider(
                  context: context,
                )
                .getACustomerReceipts(
                  customerUuid: customerUuid,
                )
                .where((item) {
                  var shop =
                      returnShopProvider(
                        context: context,
                      ).userShop()!;
                  if (shop.manageCustomerAccount != true) {
                    return item.isBalance == false;
                  } else if (shop.manageCustomerReward !=
                      true) {
                    return item.isBalance == true;
                  } else {
                    return true;
                  }
                })
                .toList()
                .sublist(0, 4)
            : returnCustomerAccountReceiptsProvider(
                  context: context,
                )
                .getACustomerReceipts(
                  customerUuid: customerUuid,
                )
                .where((item) {
                  var shop =
                      returnShopProvider(
                        context: context,
                      ).userShop()!;
                  if (shop.manageCustomerAccount != true) {
                    return item.isBalance == false;
                  } else if (shop.manageCustomerReward !=
                      true) {
                    return item.isBalance == true;
                  } else {
                    return true;
                  }
                })
                .toList();
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(26, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 5,
                children: [
                  Container(
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                    ),
                    child: Icon(
                      size: 16,
                      Icons.control_point_duplicate_sharp,
                    ),
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    'Today\'s Transactions'.toUpperCase(),
                  ),
                ],
              ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return CustomerTransactionsPage(
                            customerUuid: customerUuid,
                          );
                        },
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                    child: Row(
                      spacing: 5,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                          ),
                          'View All',
                        ),
                        Icon(
                          size: 14,
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey.shade300, height: 25),
          Builder(
            builder: (context) {
              if (accountReceipts.isEmpty) {
                return Center(
                  child: EmptyWidgetDisplayOnly(
                    title: 'Empty List',
                    subText:
                        'No Transactions Found for Today',
                    theme: theme,
                    height: 15,
                    icon: Icons.clear,
                  ),
                );
              } else {
                return Column(
                  spacing: 5,
                  children:
                      accountReceipts
                          .map(
                            (item) =>
                                CustomerTransactionList(
                                  theme: theme,
                                  accountReceipt: item,
                                ),
                          )
                          .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class CustomerTransactionList extends StatelessWidget {
  final CustomerAccountReceipts accountReceipt;
  const CustomerTransactionList({
    super.key,
    required this.theme,
    required this.accountReceipt,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(2),
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(2),
          onTap: () {
            showDialog(
              context: context,
              builder: (firstContext) {
                return DialogTemplate(
                  theme: theme,
                  message: 'View This Transaction Details',
                  title: 'Transaction Details',
                  action: () {
                    showDialog(
                      context: context,
                      builder: (confirmContext) {
                        return ConfirmationAlert(
                          theme: theme,
                          message:
                              'You are about to Delete this Transaction. This will Update The Customers Balance. Are you sure you want to Proceed?',
                          title: 'Delete Transaction.',
                          action: () {
                            Navigator.of(
                              confirmContext,
                            ).pop();
                            Navigator.of(
                              firstContext,
                            ).pop();
                            returnCustomerAccountReceiptsProvider()
                                .deleteCustomerAccountReceipts(
                                  customerReceipts: [
                                    accountReceipt,
                                  ],
                                  updateCustomerBalance:
                                      true,
                                );
                          },
                        );
                      },
                    );
                  },
                  actionButtonText: 'Delete',
                  topRightWidget: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      mouseCursor: SystemMouseCursors.click,
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Icon(Icons.clear),
                      ),
                    ),
                  ),
                  showBottomActionButtons:
                      accountReceipt.isBalance == true &&
                      authorization(
                        authorized:
                            Authorizations()
                                .deleteCustomersTransactions,
                      ),
                  widget: SizedBox(
                    height: screenHeight(context) - 220,
                    child:
                        CustomterTransactionDetailsWidget(
                          accountReceipt: accountReceipt,
                        ),
                  ),
                );
              },
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 10,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        spacing: 6,
                        children: [
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  accountReceipt.isAdd
                                      ? Colors
                                          .green
                                          .shade100
                                      : Colors.red.shade100,
                            ),
                            child: Icon(
                              size: 12,
                              color:
                                  accountReceipt.isAdd
                                      ? Colors.green
                                      : Colors.red,
                              accountReceipt.isAdd
                                  ? Icons.add
                                  : Icons.remove,
                            ),
                          ),
                          Expanded(
                            child: Row(
                              spacing: 3,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  accountReceipt.title ??
                                      'Not Set',
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  '-',
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  formatMoneyBig(
                                    amount:
                                        accountReceipt
                                            .amount ??
                                        0,
                                    context: context,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Visibility(
                          visible:
                              screenWidth(context) >
                              tabletScreenSmall,
                          child: Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.normal,
                            ),
                            formatDateTime(
                              accountReceipt.createdAt ??
                                  DateTime.now(),
                            ),
                          ),
                        ),
                        Icon(
                          size: 12,
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
                // Visibility(
                //   visible:
                //       screenWidth(context) <=
                //       tabletScreenSmall,
                //   child: Padding(
                //     padding: const EdgeInsets.only(
                //       top: 2.0,
                //     ),
                //     child: Row(
                //       mainAxisAlignment:
                //           MainAxisAlignment.end,
                //       children: [
                //         Text(
                //           style: TextStyle(
                //             fontSize:
                //                 theme
                //                     .mobileTexts
                //                     .b4
                //                     .fontSize,
                //             fontWeight: FontWeight.normal,
                //           ),
                //           formatDateTime(
                //             accountReceipt.createdAt ??
                //                 DateTime.now(),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomterTransactionDetailsWidget
    extends StatefulWidget {
  final CustomerAccountReceipts accountReceipt;

  const CustomterTransactionDetailsWidget({
    super.key,
    required this.accountReceipt,
  });

  @override
  State<CustomterTransactionDetailsWidget> createState() =>
      _CustomterTransactionDetailsWidgetState();
}

class _CustomterTransactionDetailsWidgetState
    extends State<CustomterTransactionDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        spacing: 10,
        children: [
          Divider(height: 1),
          Expanded(
            child: ListView(
              children: [
                CustomterTransactionSectionWidget(
                  title: 'Title',
                  message:
                      widget.accountReceipt.title ??
                      'Not Set',
                ),
                CustomterTransactionSectionWidget(
                  title: 'Amount',
                  message: formatMoneyBig(
                    amount:
                        widget.accountReceipt.amount ?? 0,
                    context: context,
                  ),
                ),
                CustomterTransactionSectionWidget(
                  title: 'Old Balance',
                  message: formatMoneyBig(
                    amount:
                        widget.accountReceipt.oldBalance ??
                        0,
                    context: context,
                  ),
                ),
                CustomterTransactionSectionWidget(
                  title: 'New Balance',
                  message: formatMoneyBig(
                    amount:
                        widget.accountReceipt.newBalance ??
                        0,
                    context: context,
                  ),
                ),
                CustomterTransactionSectionWidget(
                  title: 'Customer Name',
                  message:
                      widget.accountReceipt.customerName ??
                      'Not Set',
                ),
                CustomterTransactionSectionWidget(
                  title: 'Date/Time',
                  message: formatDateWithTime(
                    widget.accountReceipt.createdAt ??
                        DateTime.now(),
                  ),
                ),
                CustomterTransactionSectionWidget(
                  title: 'Transaction Type',
                  message:
                      widget.accountReceipt.isBalance ==
                              true
                          ? 'Account Balance'
                          : 'Reward Earnings',
                ),
                CustomterTransactionSectionWidget(
                  title: 'Transaction Action',
                  message:
                      widget.accountReceipt.isAdd
                          ? 'Top Up'
                          : 'Deducted',
                ),

                CustomterTransactionSectionWidget(
                  title: 'Comment',
                  message:
                      widget.accountReceipt.comment ==
                                  null ||
                              widget
                                      .accountReceipt
                                      .comment
                                      ?.isEmpty ==
                                  true
                          ? 'Not Set'
                          : widget.accountReceipt.comment ??
                              '',
                ),
                CustomterTransactionSectionWidget(
                  title: 'Staff Name',
                  message:
                      widget.accountReceipt.staffName ??
                      'Not Set',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomterTransactionSectionWidget
    extends StatelessWidget {
  final String title;
  final String message;
  const CustomterTransactionSectionWidget({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsetsGeometry.fromLTRB(
              10,
              7,
              10,
              5,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
              color: Colors.grey.shade200,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                    '$title:',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsetsGeometry.fromLTRB(
              10,
              5,
              10,
              10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.grey.shade100,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade700,
                    ),
                    message,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
