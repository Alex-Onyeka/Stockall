import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customer_account_receipts/customer_account_receipts.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/invoices/invoice_page/invoice_page_desktop.dart';
import 'package:stockall/providers/theme_provider.dart';

class CustomerAccountDetailsSectionWidget
    extends StatefulWidget {
  final TempCustomersClass customer;
  const CustomerAccountDetailsSectionWidget({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerAccountDetailsSectionWidget>
  createState() =>
      _CustomerAccountDetailsSectionWidgetState();
}

class _CustomerAccountDetailsSectionWidgetState
    extends State<CustomerAccountDetailsSectionWidget> {
  final moneyTextField = TextEditingController();
  final commentTextField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    if (returnShopProvider(
              context: context,
            ).userShop()?.manageCustomerAccount ==
            true &&
        returnShopProvider(
              context: context,
            ).userShop()?.manageCustomerReward ==
            true) {
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
          gradient: theme.lightModeColor.prGradient,
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
                        Icons
                            .account_balance_wallet_outlined,
                      ),
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade300,
                      ),
                      'Account Details'.toUpperCase(),
                    ),
                  ],
                ),
              ],
            ),
            Divider(
              color: Colors.grey.shade500,
              height: 25,
            ),
            Column(
              spacing: 15,
              children: [
                Column(
                  spacing: 1,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 20),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .h2
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade200,
                          ),
                          formatMoneyBig(
                            amount:
                                widget.customer
                                    .getBalance(),
                            context: context,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 20),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade400,
                          ),
                          "Reward Earnings:",
                        ),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade300,
                          ),
                          formatMoneyBig(
                            amount:
                                widget
                                    .customer
                                    .cashReward ??
                                0,
                            context: context,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10.0,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(
                                      2,
                                    ),
                                border: Border.all(
                                  color:
                                      Colors.grey.shade400,
                                ),
                                // color: Colors.grey.shade100,
                              ),
                              child: InkWell(
                                onTap: () {
                                  redeemRewardAction(
                                    context: context,
                                    customer:
                                        widget.customer,
                                    theme: theme,
                                  );
                                },
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(
                                        vertical: 2,
                                        horizontal: 6,
                                      ),
                                  child: Row(
                                    spacing: 4,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b4
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          color:
                                              Colors
                                                  .grey
                                                  .shade300,
                                        ),
                                        'Redeem',
                                      ),
                                      Icon(
                                        size: 12,
                                        color:
                                            Colors
                                                .grey
                                                .shade300,
                                        Icons.check,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // SizedBox(height: 5),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start,
                  spacing: 10,
                  children: [
                    SizedBox(width: 10),
                    ActionButtonSmall(
                      isLoading: false,
                      action: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return DialogTemplate(
                              theme: theme,
                              message:
                                  'You are about to Top up this Customers Account Balance.',
                              title:
                                  'Top Up Account Balance',
                              action: () {
                                topUpAction(
                                  context: dialogContext,
                                  customer: widget.customer,
                                  moneyTextField:
                                      moneyTextField,
                                  commentTextField:
                                      commentTextField,
                                  theme: theme,
                                );
                              },
                              widget: Column(
                                spacing: 10,
                                children: [
                                  SizedBox(
                                    height: 40,
                                    // width: 200,
                                    child: MoneyTextfield(
                                      title: 'title',
                                      hint: 'Enter Amount',
                                      controller:
                                          moneyTextField,
                                      theme: theme,
                                      showTitle: false,
                                      autoFocus: true,
                                      onSubmitted: (p0) {
                                        topUpAction(
                                          context:
                                              dialogContext,
                                          customer:
                                              widget
                                                  .customer,
                                          moneyTextField:
                                              moneyTextField,
                                          commentTextField:
                                              commentTextField,
                                          theme: theme,
                                        );
                                      },
                                    ),
                                  ),
                                  GeneralTextfieldOnly(
                                    hint: 'Leave a Comment',
                                    controller:
                                        commentTextField,
                                    minLines: 3,
                                    lines: 5,
                                    theme: theme,
                                    onSubmitted: (value) {
                                      topUpAction(
                                        context:
                                            dialogContext,
                                        customer:
                                            widget.customer,
                                        moneyTextField:
                                            moneyTextField,
                                        commentTextField:
                                            commentTextField,
                                        theme: theme,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ).then((_) {
                          Future.delayed(
                            (Duration(microseconds: 500)),
                            () {
                              commentTextField.clear();
                              moneyTextField.clear();
                            },
                          );
                        });
                      },
                      text: 'Credit',
                      textColor: Colors.grey.shade300,
                      icon: Icon(
                        size: 16,
                        color: Colors.green.shade600,
                        Icons.add,
                      ),
                    ),
                    ActionButtonSmall(
                      isLoading: false,
                      action: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return DialogTemplate(
                              theme: theme,
                              message:
                                  'You are about to Debit this Customers Account Balance.',
                              title:
                                  'Debit Account Balance',
                              action: () {
                                debitAction(
                                  context: dialogContext,
                                  customer: widget.customer,
                                  moneyTextField:
                                      moneyTextField,
                                  commentTextField:
                                      commentTextField,
                                  theme: theme,
                                );
                              },
                              widget: Column(
                                spacing: 10,
                                children: [
                                  SizedBox(
                                    height: 40,
                                    // width: 200,
                                    child: MoneyTextfield(
                                      title: '',
                                      hint: 'Enter Amount',
                                      controller:
                                          moneyTextField,
                                      theme: theme,
                                      showTitle: false,
                                      autoFocus: true,
                                      onChanged: (p0) {
                                        if (widget.customer
                                                .getBalance() <
                                            (double.tryParse(
                                                  moneyTextField
                                                      .text
                                                      .replaceAll(
                                                        ',',
                                                        '',
                                                      ),
                                                ) ??
                                                0)) {
                                          setState(() {
                                            moneyTextField
                                                .text = '0';
                                          });
                                        }
                                      },
                                      onSubmitted: (p0) {
                                        debitAction(
                                          context:
                                              dialogContext,
                                          customer:
                                              widget
                                                  .customer,
                                          moneyTextField:
                                              moneyTextField,
                                          commentTextField:
                                              commentTextField,
                                          theme: theme,
                                        );
                                      },
                                    ),
                                  ),
                                  GeneralTextfieldOnly(
                                    hint: 'Leave a Comment',
                                    controller:
                                        commentTextField,
                                    minLines: 3,
                                    lines: 5,
                                    theme: theme,
                                    onSubmitted: (value) {
                                      debitAction(
                                        context:
                                            dialogContext,
                                        customer:
                                            widget.customer,
                                        moneyTextField:
                                            moneyTextField,
                                        commentTextField:
                                            commentTextField,
                                        theme: theme,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ).then((_) {
                          Future.delayed(
                            (Duration(microseconds: 500)),
                            () {
                              commentTextField.clear();
                              moneyTextField.clear();
                            },
                          );
                        });
                      },
                      text: 'Debit',
                      textColor: Colors.grey.shade300,
                      icon: Icon(
                        size: 16,
                        color: Colors.red.shade400,
                        Icons.remove,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    } else if (returnShopProvider(
              context: context,
            ).userShop()?.manageCustomerAccount ==
            true &&
        returnShopProvider(
              context: context,
            ).userShop()?.manageCustomerReward ==
            false) {
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
          gradient: theme.lightModeColor.prGradient,
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
                        Icons
                            .account_balance_wallet_outlined,
                      ),
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade300,
                      ),
                      'Account Details'.toUpperCase(),
                    ),
                  ],
                ),
              ],
            ),
            Divider(
              color: Colors.grey.shade500,
              height: 25,
            ),
            Column(
              spacing: 15,
              children: [
                Row(
                  children: [
                    SizedBox(width: 20),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.h2.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade200,
                      ),
                      formatMoneyBig(
                        amount:
                            widget.customer.getBalance(),
                        context: context,
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 5),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start,
                  spacing: 10,
                  children: [
                    SizedBox(width: 10),
                    ActionButtonSmall(
                      isLoading: false,
                      action: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return DialogTemplate(
                              theme: theme,
                              message:
                                  'You are about to Top up this Customers Account Balance.',
                              title:
                                  'Top Up Account Balance',
                              action: () {
                                topUpAction(
                                  context: dialogContext,
                                  customer: widget.customer,
                                  moneyTextField:
                                      moneyTextField,
                                  commentTextField:
                                      commentTextField,
                                  theme: theme,
                                );
                              },
                              widget: Column(
                                spacing: 10,
                                children: [
                                  SizedBox(
                                    height: 40,
                                    // width: 200,
                                    child: MoneyTextfield(
                                      title: 'title',
                                      hint: 'Enter Amount',
                                      controller:
                                          moneyTextField,
                                      theme: theme,
                                      showTitle: false,
                                      autoFocus: true,
                                      onSubmitted: (p0) {
                                        topUpAction(
                                          context:
                                              dialogContext,
                                          customer:
                                              widget
                                                  .customer,
                                          moneyTextField:
                                              moneyTextField,
                                          commentTextField:
                                              commentTextField,
                                          theme: theme,
                                        );
                                      },
                                    ),
                                  ),
                                  GeneralTextfieldOnly(
                                    hint: 'Leave a Comment',
                                    controller:
                                        commentTextField,
                                    minLines: 3,
                                    lines: 5,
                                    theme: theme,
                                    onSubmitted: (value) {
                                      topUpAction(
                                        context:
                                            dialogContext,
                                        customer:
                                            widget.customer,
                                        moneyTextField:
                                            moneyTextField,
                                        commentTextField:
                                            commentTextField,
                                        theme: theme,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ).then((_) {
                          Future.delayed(
                            (Duration(microseconds: 500)),
                            () {
                              commentTextField.clear();
                              moneyTextField.clear();
                            },
                          );
                        });
                      },
                      text: 'Credit',
                      textColor: Colors.grey.shade300,
                      icon: Icon(
                        size: 16,
                        color: Colors.green.shade600,
                        Icons.add,
                      ),
                    ),
                    ActionButtonSmall(
                      isLoading: false,
                      action: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return DialogTemplate(
                              theme: theme,
                              message:
                                  'You are about to Debit this Customers Account Balance.',
                              title:
                                  'Debit Account Balance',
                              action: () {
                                debitAction(
                                  context: dialogContext,
                                  customer: widget.customer,
                                  moneyTextField:
                                      moneyTextField,
                                  commentTextField:
                                      commentTextField,
                                  theme: theme,
                                );
                              },
                              widget: Column(
                                spacing: 10,
                                children: [
                                  SizedBox(
                                    height: 40,
                                    // width: 200,
                                    child: MoneyTextfield(
                                      title: '',
                                      hint: 'Enter Amount',
                                      controller:
                                          moneyTextField,
                                      theme: theme,
                                      showTitle: false,
                                      autoFocus: true,
                                      onChanged: (p0) {
                                        if (widget.customer
                                                .getBalance() <
                                            (double.tryParse(
                                                  moneyTextField
                                                      .text
                                                      .replaceAll(
                                                        ',',
                                                        '',
                                                      ),
                                                ) ??
                                                0)) {
                                          setState(() {
                                            moneyTextField
                                                .text = '0';
                                          });
                                        }
                                      },
                                      onSubmitted: (p0) {
                                        debitAction(
                                          context:
                                              dialogContext,
                                          customer:
                                              widget
                                                  .customer,
                                          moneyTextField:
                                              moneyTextField,
                                          commentTextField:
                                              commentTextField,
                                          theme: theme,
                                        );
                                      },
                                    ),
                                  ),
                                  GeneralTextfieldOnly(
                                    hint: 'Leave a Comment',
                                    controller:
                                        commentTextField,
                                    minLines: 3,
                                    lines: 5,
                                    theme: theme,
                                    onSubmitted: (value) {
                                      debitAction(
                                        context:
                                            dialogContext,
                                        customer:
                                            widget.customer,
                                        moneyTextField:
                                            moneyTextField,
                                        commentTextField:
                                            commentTextField,
                                        theme: theme,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ).then((_) {
                          Future.delayed(
                            (Duration(microseconds: 500)),
                            () {
                              commentTextField.clear();
                              moneyTextField.clear();
                            },
                          );
                        });
                      },
                      text: 'Debit',
                      textColor: Colors.grey.shade300,
                      icon: Icon(
                        size: 16,
                        color: Colors.red.shade400,
                        Icons.remove,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    } else {
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
          gradient: theme.lightModeColor.prGradient,
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
                        Icons
                            .account_balance_wallet_outlined,
                      ),
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade300,
                      ),
                      'Reward Earnings'.toUpperCase(),
                    ),
                  ],
                ),
              ],
            ),
            Divider(
              color: Colors.grey.shade500,
              height: 25,
            ),
            Column(
              spacing: 15,
              children: [
                Column(
                  spacing: 1,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 20),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .h2
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade200,
                          ),
                          formatMoneyBig(
                            amount:
                                widget
                                    .customer
                                    .cashReward ??
                                0,
                            context: context,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // SizedBox(height: 5),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start,
                  spacing: 10,
                  children: [
                    SizedBox(width: 10),
                    ActionButtonSmall(
                      isLoading: false,
                      action: () {
                        redeemRewardAction(
                          context: context,
                          customer: widget.customer,
                          theme: theme,
                        );
                      },
                      text: 'Redeem Reward',
                      textColor: Colors.grey.shade300,
                      icon: Icon(
                        size: 16,
                        color: Colors.green.shade600,
                        Icons.check,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}

Future<void> topUpAction({
  required BuildContext context,
  required ThemeProvider theme,
  required TextEditingController moneyTextField,
  TextEditingController? commentTextField,
  required TempCustomersClass customer,
  bool? popSecondContext,
}) async {
  if (moneyTextField.text.isNotEmpty) {
    await showDialog(
      context: context,
      builder: (confirmContext) {
        return ConfirmationAlert(
          theme: theme,
          message:
              'You are about to top up this customers account balance. Are you sure you want to proceed?',
          title: 'Credit Account',
          action: () async {
            double amount =
                double.tryParse(
                  moneyTextField.text.replaceAll(',', ''),
                ) ??
                0;

            CustomerAccountReceipts customerAccountReceipt =
                CustomerAccountReceipts(
                  amount: amount,
                  customerName: customer.name,
                  customerUuid: customer.uuid!,
                  isAdd: true,
                  isBalance: true,
                  receiptUuid: null,
                  oldBalance: customer.balance ?? 0,
                  newBalance:
                      (customer.balance ?? 0) + amount,
                  comment: commentTextField?.text.trim(),
                );
            await returnCustomerAccountReceiptsProvider()
                .createCustomerAccountReceipts(
                  customerAccountReceipt:
                      customerAccountReceipt,
                );
            Navigator.of(confirmContext).pop();
            if (popSecondContext != false) {
              Navigator.of(context).pop();
            }
            Future.delayed(
              (Duration(microseconds: 500)),
              () {
                moneyTextField.clear();
                commentTextField?.clear();
              },
            );
          },
          actionButtonText: 'Credit Account',
        );
      },
    );
  }
}

void debitAction({
  required BuildContext context,
  required ThemeProvider theme,
  required TextEditingController moneyTextField,
  TextEditingController? commentTextField,
  required TempCustomersClass customer,
}) {
  if (moneyTextField.text.isNotEmpty) {
    showDialog(
      context: context,
      builder: (confirmContext) {
        return ConfirmationAlert(
          theme: theme,
          message:
              'You are about to Debit this customers account balance. Are you sure you want to proceed?',
          title: 'Debit Account',
          action: () {
            double amount =
                double.tryParse(
                  moneyTextField.text.replaceAll(',', ''),
                ) ??
                0;
            Navigator.of(confirmContext).pop();
            Navigator.of(context).pop();
            CustomerAccountReceipts customerAccountReceipt =
                CustomerAccountReceipts(
                  amount: amount,
                  customerName: customer.name,
                  customerUuid: customer.uuid!,
                  isAdd: false,
                  isBalance: true,
                  receiptUuid: null,
                  oldBalance: customer.balance ?? 0,
                  newBalance:
                      (customer.balance ?? 0) - amount,
                  comment: commentTextField?.text.trim(),
                );
            returnCustomerAccountReceiptsProvider()
                .createCustomerAccountReceipts(
                  customerAccountReceipt:
                      customerAccountReceipt,
                );
          },
          actionButtonText: 'Debit Account',
        );
      },
    );
  }
}

void redeemRewardAction({
  required BuildContext context,
  required ThemeProvider theme,
  required TempCustomersClass customer,
}) {
  if (customer.cashReward != null &&
      customer.cashReward != 0) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return ConfirmationAlert(
          theme: theme,
          message:
              'You are about to Redeeem the reward of this Customer. This will empty The Earnings Balance of this Customer. Are you sure you want to proceed?',
          title: 'Redeem Reward',
          action: () {
            Navigator.of(context).pop();
            CustomerAccountReceipts customerAccountReceipt =
                CustomerAccountReceipts(
                  amount: customer.cashReward ?? 0,
                  customerName: customer.name,
                  customerUuid: customer.uuid!,
                  isAdd: false,
                  isBalance: false,
                  receiptUuid: null,
                  newBalance: 0,
                  oldBalance: customer.cashReward,
                  title: 'Reward Redeemed',
                );
            returnCustomerAccountReceiptsProvider()
                .createCustomerAccountReceipts(
                  customerAccountReceipt:
                      customerAccountReceipt,
                );
          },
        );
      },
    );
  }
}
