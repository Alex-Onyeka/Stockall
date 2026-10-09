import 'package:flutter/material.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_account_details_section_widget.dart';

class PaymentTypeButton extends StatefulWidget {
  final int index;
  final Function()? action;
  // Called with the split after "pay remainder with Cash / Bank".
  final Function(List<PaymentEntry>)? onSplitPayments;
  const PaymentTypeButton({
    super.key,
    required this.index,
    this.action,
    this.onSplitPayments,
  });

  @override
  State<PaymentTypeButton> createState() =>
      _PaymentTypeButtonState();
}

class _PaymentTypeButtonState
    extends State<PaymentTypeButton> {
  TextEditingController topUpController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    TempCustomersClass? customersClass;
    if (widget.index == 3) {
      if (returnSalesProviderContext(
            context,
          ).currentCart().selectedCustomer !=
          null) {
        var customerUuid =
            returnSalesProviderContext(
              context,
            ).currentCart().selectedCustomer;
        List<TempCustomersClass> customers =
            returnCustomersSingle().customers
                .where((item) => item.uuid == customerUuid)
                .toList();
        if (customers.isNotEmpty) {
          customersClass = customers.first;
        }
      }
    }
    var theme = returnTheme(context);
    void selectOptionAction() {
      if (returnSalesProvider()
                  .currentCart()
                  .cartItemTypeIndex ==
              2 &&
          (widget.index == 2 || widget.index == 3)) {
        return;
      } else {
        returnSalesProvider().changePaymentMethod(
          index: widget.index,
          context: context,
        );
        widget.action != null ? widget.action!() : {};
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 5.0,
          ),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              onTap: () {
                selectOptionAction();
              },
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    7,
                    10,
                    7,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color:
                                  returnSalesProviderContext(
                                                    context,
                                                  )
                                                  .currentCart()
                                                  .cartItemTypeIndex ==
                                              2 &&
                                          widget.index == 2
                                      ? Colors.grey
                                      : null,
                            ),
                            "${returnSalesProviderContext(context).returnPaymentMethodSalesPage(widget.index)['method']}${customersClass != null ? " (${formatMoneyBig(amount: customersClass.getBalance(), context: context)})" : ''}",
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.normal,
                              color:
                                  returnSalesProviderContext(
                                                    context,
                                                  )
                                                  .currentCart()
                                                  .cartItemTypeIndex ==
                                              2 &&
                                          widget.index == 2
                                      ? Colors.grey
                                      : theme
                                          .lightModeColor
                                          .secColor200,
                            ),
                            returnSalesProviderContext(
                              context,
                            ).returnPaymentMethodSalesPage(
                              widget.index,
                            )['subText'],
                          ),
                        ],
                      ),
                      Checkbox(
                        activeColor:
                            returnSalesProviderContext(
                                              context,
                                            )
                                            .currentCart()
                                            .cartItemTypeIndex ==
                                        2 &&
                                    widget.index == 2
                                ? Colors.grey
                                : theme
                                    .lightModeColor
                                    .prColor250,
                        shape: CircleBorder(
                          side: BorderSide(),
                        ),
                        side: BorderSide(
                          width: 1,
                          color:
                              theme
                                  .lightModeColor
                                  .secColor200,
                        ),
                        value:
                            returnSalesProviderContext(
                              context,
                            ).currentCart().paymentMethod ==
                            widget.index,
                        onChanged: (value) {
                          selectOptionAction();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible:
              widget.index == 3 &&
              returnSalesProviderContext(
                    context,
                  ).currentCart().paymentMethod ==
                  3 &&
              !returnSalesProviderContext(
                context,
              ).isBalanceSufficient(),
          child: Container(
            padding: EdgeInsetsGeometry.only(
              top: 10,
              bottom: 10,
              left: 10,
              right: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                ),
                left: BorderSide(
                  color: Colors.grey.shade300,
                ),
                right: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
            ),
            child: Column(
              spacing: 10,
              children: [
                Row(
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      'Insufficient Balance. Top Up;',
                    ),
                  ],
                ),
                Visibility(
                  visible:
                      (returnSalesProviderContext(
                                context,
                              ).availableAccountBalance() ??
                              0) >
                          0,
                  child: Column(
                    spacing: 5,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
                        ),
                        'Or pay ${formatMoneyMid(amount: returnSalesProviderContext(context).availableAccountBalance() ?? 0, context: context)} from the account and the remaining ${formatMoneyMid(amount: returnSalesProviderContext(context).calcFinalTotal() - (returnSalesProviderContext(context).availableAccountBalance() ?? 0), context: context)} with;',
                      ),
                      Row(
                        spacing: 5,
                        children: [
                          Expanded(
                            child: _RemainderButton(
                              title: 'Cash',
                              onTap: () async {
                                var payments =
                                    await returnSalesProvider()
                                        .splitRemainderWith(
                                          PaymentMethods.cash,
                                        );
                                widget.onSplitPayments != null
                                    ? widget.onSplitPayments!(
                                      payments,
                                    )
                                    : {};
                              },
                            ),
                          ),
                          Expanded(
                            child: _RemainderButton(
                              title: 'Bank',
                              onTap: () async {
                                var payments =
                                    await returnSalesProvider()
                                        .splitRemainderWith(
                                          PaymentMethods.bank,
                                        );
                                widget.onSplitPayments != null
                                    ? widget.onSplitPayments!(
                                      payments,
                                    )
                                    : {};
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: authorization(
                    authorized:
                        Authorizations()
                            .creditCustomersAccount,
                  ),
                  child: Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        child: SizedBox(
                          child: MoneyTextfield(
                            title: 'title',
                            hint: 'Enter Amount',
                            controller: topUpController,
                            theme: theme,
                            autoFocus: true,
                            onSubmitted: (p0) async {
                              if (returnSalesProvider()
                                      .currentCart()
                                      .getCustomer() !=
                                  null) {
                                await topUpAction(
                                  popSecondContext: false,
                                  context: context,
                                  theme: theme,
                                  moneyTextField:
                                      topUpController,
                                  customer:
                                      returnSalesProvider()
                                          .currentCart()
                                          .getCustomer()!,
                                );
                                widget.action != null
                                    ? widget.action!()
                                    : {};
                              }
                            },
                            showTitle: false,
                          ),
                        ),
                      ),
                      Material(
                        type: MaterialType.transparency,
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(3),
                            gradient:
                                theme
                                    .lightModeColor
                                    .prGradient,
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                          child: InkWell(
                            mouseCursor:
                                SystemMouseCursors.click,
                            onTap: () async {
                              if (returnSalesProvider()
                                      .currentCart()
                                      .getCustomer() !=
                                  null) {
                                await topUpAction(
                                  popSecondContext: false,
                                  context: context,
                                  theme: theme,
                                  moneyTextField:
                                      topUpController,
                                  customer:
                                      returnSalesProvider()
                                          .currentCart()
                                          .getCustomer()!,
                                );
                                widget.action != null
                                    ? widget.action!()
                                    : {};
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 15,
                              ),
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.normal,
                                  color: Colors.white,
                                ),
                                'Top Up',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RemainderButton extends StatelessWidget {
  final String title;
  final Function() onTap;
  const _RemainderButton({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: Colors.white,
          border: Border.all(color: Colors.grey),
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 15,
            ),
            child: Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                fontWeight: FontWeight.bold,
              ),
              title,
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentTypeDropdown extends StatefulWidget {
  final TextEditingController cashController;
  final TextEditingController bankController;
  final TextEditingController accountController;
  const PaymentTypeDropdown({
    super.key,
    required this.bankController,
    required this.cashController,
    required this.accountController,
  });

  @override
  State<PaymentTypeDropdown> createState() =>
      _PaymentTypeDropdownState();
}

class _PaymentTypeDropdownState
    extends State<PaymentTypeDropdown> {
  bool isOpen = false;

  void toggleIsOpen() {
    setState(() {
      isOpen = !isOpen;
    });
  }

  bool isUpdating = false;

  @override
  Widget build(BuildContext context) {
    TempCustomersClass? customersClass;
    if (returnSalesProviderContext(
          context,
        ).currentCart().paymentMethod ==
        3) {
      if (returnSalesProviderContext(
            context,
          ).currentCart().selectedCustomer !=
          null) {
        var customerUuid =
            returnSalesProviderContext(
              context,
            ).currentCart().selectedCustomer;
        List<TempCustomersClass> customers =
            returnCustomersSingle().customers
                .where((item) => item.uuid == customerUuid)
                .toList();
        if (customers.isNotEmpty) {
          customersClass = customers.first;
        }
      }
    }
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: [
          Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              onTap: () {
                toggleIsOpen();
              },
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    7,
                    10,
                    7,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            "${returnSalesProviderContext(context).returnPaymentMethodSalesPage(returnSalesProviderContext(context).currentCart().paymentMethod)['method']}${customersClass != null ? " (${formatMoneyBig(amount: customersClass.getBalance(), context: context)})" : ''}",
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.normal,
                            ),
                            returnSalesProviderContext(
                              context,
                            ).selectedPaymentMethod()['subText'],
                          ),
                        ],
                      ),
                      Icon(
                        size: 30,
                        isOpen
                            ? Icons
                                .keyboard_arrow_up_rounded
                            : Icons
                                .keyboard_arrow_down_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: isOpen,
            child: PaymentMethodSection(
              bankController: widget.bankController,
              cashController: widget.cashController,
              accountController: widget.accountController,
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodSection extends StatefulWidget {
  final TextEditingController cashController;
  final TextEditingController bankController;
  final TextEditingController accountController;

  const PaymentMethodSection({
    super.key,
    required this.cashController,
    required this.bankController,
    required this.accountController,
  });

  @override
  State<PaymentMethodSection> createState() =>
      _PaymentMethodSectionState();
}

class _PaymentMethodSectionState
    extends State<PaymentMethodSection> {
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Restore a saved split (edited receipt, remainder shortcut, or a
    // section that was collapsed) if it still matches the cart total.
    var saved =
        returnSalesProvider().currentCart().splitPayments;
    if (returnSalesProvider().currentCart().paymentMethod ==
            2 &&
        saved != null &&
        (PaymentBreakdown(saved).total -
                    returnSalesProvider().calcFinalTotal())
                .abs() <=
            PaymentBreakdown.tolerance) {
      _writeControllers(PaymentBreakdown(saved));
    }
  }

  double _amount(TextEditingController controller) {
    return double.tryParse(
          controller.text.replaceAll(',', ''),
        ) ??
        0;
  }

  PaymentBreakdown _currentBreakdown() {
    return PaymentBreakdown.fromAmounts(
      cash: _amount(widget.cashController),
      bank: _amount(widget.bankController),
      account:
          returnSalesProvider().canUseAccount()
              ? _amount(widget.accountController)
              : 0,
    );
  }

  void _writeControllers(PaymentBreakdown breakdown) {
    widget.cashController.text = breakdown.cash
        .toStringAsFixed(2);
    widget.bankController.text = breakdown.bank
        .toStringAsFixed(2);
    widget.accountController.text = breakdown.account
        .toStringAsFixed(2);
  }

  void _applyPayments(List<PaymentEntry> payments) {
    _writeControllers(PaymentBreakdown(payments));
    setState(() {});
  }

  void _showAlert(String title, String message) {
    var theme = returnTheme(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return InfoAlert(
          theme: theme,
          message: message,
          title: title,
        );
      },
    );
  }

  // Keeps the three fields adding up to the total. The edited field wins;
  // the remainder goes to Cash, or to Bank when Cash is being edited.
  void _rebalance(String edited, String value) {
    if (isUpdating) return;
    isUpdating = true;

    double total = returnSalesProvider().calcFinalTotal();
    bool useAccount = returnSalesProvider().canUseAccount();
    Map<String, double> amounts = {
      PaymentMethods.cash: _amount(widget.cashController),
      PaymentMethods.bank: _amount(widget.bankController),
      PaymentMethods.account:
          useAccount ? _amount(widget.accountController) : 0,
    };
    double editedAmount =
        double.tryParse(value.replaceAll(',', '')) ?? 0;
    if (editedAmount < 0) {
      editedAmount = 0;
    }

    bool clamped = false;
    if (editedAmount > total) {
      _showAlert(
        'Overpayment',
        '$edited cannot exceed total amount.',
      );
      editedAmount = total;
      clamped = true;
    }
    if (edited == PaymentMethods.account) {
      double balance =
          returnSalesProvider().availableAccountBalance() ?? 0;
      if (balance < 0) {
        balance = 0;
      }
      if (editedAmount > balance) {
        _showAlert(
          'Insufficient Balance',
          'Customer Account cannot exceed the customer\'s balance of ${formatMoneyMid(amount: balance, context: context)}.',
        );
        editedAmount = balance;
        clamped = true;
      }
    }
    amounts[edited] = editedAmount;

    String target =
        edited == PaymentMethods.cash
            ? PaymentMethods.bank
            : PaymentMethods.cash;
    String other =
        PaymentMethods.all
            .where((m) => m != edited && m != target)
            .first;
    double rest = total - editedAmount - amounts[other]!;
    if (rest < 0) {
      amounts[other] = (amounts[other]! + rest) < 0
          ? 0
          : amounts[other]! + rest;
      rest = 0;
    }
    amounts[target] = rest;

    var breakdown = PaymentBreakdown.fromAmounts(
      cash: amounts[PaymentMethods.cash]!,
      bank: amounts[PaymentMethods.bank]!,
      account: amounts[PaymentMethods.account]!,
    );
    if (clamped) {
      _writeControllers(breakdown);
    } else {
      // Leave the field being typed in untouched.
      if (edited != PaymentMethods.cash) {
        widget.cashController.text = breakdown.cash
            .toStringAsFixed(2);
      }
      if (edited != PaymentMethods.bank) {
        widget.bankController.text = breakdown.bank
            .toStringAsFixed(2);
      }
      if (edited != PaymentMethods.account) {
        widget.accountController.text = breakdown.account
            .toStringAsFixed(2);
      }
    }
    returnSalesProvider().setSplitPayments(breakdown.compact);

    isUpdating = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    bool showAccount =
        returnSalesProviderContext(context).canUseAccount();
    double remaining =
        returnSalesProviderContext(context).calcFinalTotal() -
        _currentBreakdown().total;
    return Column(
      children: [
        Divider(color: Colors.grey.shade300),
        Column(
          children: [
            Row(
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'Select Payment Method',
                ),
              ],
            ),
            SizedBox(height: 5),
            PaymentTypeButton(index: 0),
            PaymentTypeButton(index: 1),
            Visibility(
              visible: showAccount,
              child: PaymentTypeButton(
                index: 3,
                action: () {
                  setState(() {});
                },
                onSplitPayments: _applyPayments,
              ),
            ),
            PaymentTypeButton(index: 2),
          ],
        ),
        SizedBox(height: 20),
        Visibility(
          visible:
              returnSalesProviderContext(
                context,
              ).currentCart().paymentMethod ==
              2,
          child: Column(
            spacing: 10,
            children: [
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: EditCartTextField(
                      title: 'Cash',
                      hint: 'Cash Amount',
                      controller: widget.cashController,
                      theme: theme,
                      onChanged: (value) {
                        _rebalance(PaymentMethods.cash, value);
                      },
                    ),
                  ),
                  Expanded(
                    child: EditCartTextField(
                      title: 'Bank',
                      hint: 'Bank Amount',
                      controller: widget.bankController,
                      theme: theme,
                      onChanged: (value) {
                        _rebalance(PaymentMethods.bank, value);
                      },
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: showAccount,
                child: EditCartTextField(
                  title:
                      'Customer Account (${formatMoneyMid(amount: returnSalesProviderContext(context).availableAccountBalance() ?? 0, context: context)})',
                  hint: 'Account Amount',
                  controller: widget.accountController,
                  theme: theme,
                  onChanged: (value) {
                    _rebalance(PaymentMethods.account, value);
                  },
                ),
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b3.fontSize,
                    ),
                    'Remaining:',
                  ),
                  Text(
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                      color:
                          remaining.abs() >
                                  PaymentBreakdown.tolerance
                              ? Colors.red
                              : null,
                    ),
                    formatMoneyMid(
                      amount:
                          remaining.abs() >
                                  PaymentBreakdown.tolerance
                              ? remaining
                              : 0,
                      context: context,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
