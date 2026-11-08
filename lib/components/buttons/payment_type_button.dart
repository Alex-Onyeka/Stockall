import 'package:flutter/material.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/payment_entry/payment_method.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/alert_dialogues/manage_payment_methods_dialog.dart';
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
  void dispose() {
    topUpController.dispose();
    super.dispose();
  }

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

    final selectedBank =
        returnSalesProviderContext(
          context,
        ).currentCart().selectedBankName;
    String displayMethodTitle =
        returnSalesProviderContext(
          context,
        ).returnPaymentMethodSalesPage(
          widget.index,
        )['method'];
    if (widget.index == 1 && selectedBank != null) {
      displayMethodTitle =
          'Pay with Transfer / Atm ($selectedBank)';
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
                            "$displayMethodTitle${customersClass != null ? " (${formatMoneyBig(amount: customersClass.getBalance(), context: context)})" : ''}",
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
        // Bank Selection Section (Index 1)
        Visibility(
          visible:
              widget.index == 1 &&
              returnSalesProviderContext(
                    context,
                  ).currentCart().paymentMethod ==
                  1,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
              color: Colors.grey.shade50,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (returnShopProvider(
                  context: context,
                ).getCustomPaymentMethods().isNotEmpty) ...[
                  Text(
                    'Select Bank Account:',
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      ...returnShopProvider(
                        context: context,
                      ).getCustomPaymentMethods().map((
                        bMethod,
                      ) {
                        final isSelected =
                            returnSalesProviderContext(
                                  context,
                                )
                                .currentCart()
                                .selectedBankName ==
                            bMethod.displayName;
                        return ChoiceChip(
                          label: Text(
                            bMethod.displayName,
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.black87,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor:
                              theme
                                  .lightModeColor
                                  .prColor250,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(6),
                            side: BorderSide(
                              color:
                                  isSelected
                                      ? theme
                                          .lightModeColor
                                          .prColor250
                                      : Colors
                                          .grey
                                          .shade300,
                            ),
                          ),
                          onSelected: (val) {
                            returnSalesProvider()
                                .setSelectedBankName(
                                  val
                                      ? bMethod.displayName
                                      : null,
                                );
                            setState(() {});
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: Icon(
                        Icons.add_circle_outline,
                        size: 16,
                        color:
                            theme.lightModeColor.prColor250,
                      ),
                      label: Text(
                        returnShopProvider(context: context)
                                .getCustomPaymentMethods()
                                .isEmpty
                            ? '+ Add Bank Account'
                            : 'Manage Accounts',
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
                          color:
                              theme
                                  .lightModeColor
                                  .prColor250,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) =>
                                  const ManagePaymentMethodsDialog(),
                        ).then((_) {
                          setState(() {});
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Customer Account Section (Index 3)
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
                                          PaymentMethods
                                              .cash,
                                        );
                                widget.onSplitPayments !=
                                        null
                                    ? widget
                                        .onSplitPayments!(
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
                                          PaymentMethods
                                              .bank,
                                        );
                                widget.onSplitPayments !=
                                        null
                                    ? widget
                                        .onSplitPayments!(
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
    final selectedBank =
        returnSalesProviderContext(
          context,
        ).currentCart().selectedBankName;
    String displayMethodTitle =
        returnSalesProviderContext(
          context,
        ).returnPaymentMethodSalesPage(
          returnSalesProviderContext(
            context,
          ).currentCart().paymentMethod,
        )['method'];
    if (returnSalesProviderContext(
              context,
            ).currentCart().paymentMethod ==
            1 &&
        selectedBank != null) {
      displayMethodTitle =
          'Pay with Transfer / Atm ($selectedBank)';
    }

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
                            "$displayMethodTitle${customersClass != null ? " (${formatMoneyBig(amount: customersClass.getBalance(), context: context)})" : ''}",
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
  final Map<String, TextEditingController>
  _customBankControllers = {};

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

  @override
  void dispose() {
    for (final controller
        in _customBankControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double _amount(TextEditingController controller) {
    return double.tryParse(
          controller.text.replaceAll(',', ''),
        ) ??
        0;
  }

  TextEditingController _getCustomBankController(
    String method,
  ) {
    if (!_customBankControllers.containsKey(method)) {
      _customBankControllers[method] =
          TextEditingController(text: '0');
    }
    return _customBankControllers[method]!;
  }

  PaymentBreakdown _currentBreakdown() {
    final customBanks =
        returnShopProvider().getCustomPaymentMethods();
    if (customBanks.isNotEmpty) {
      final entries = <PaymentEntry>[
        PaymentEntry(
          method: PaymentMethods.cash,
          amount: _amount(widget.cashController),
        ),
        for (final PaymentMethod b in customBanks)
          PaymentEntry(
            method: b.displayName,
            amount: _amount(
              _getCustomBankController(b.displayName),
            ),
          ),
        if (returnSalesProvider().canUseAccount())
          PaymentEntry(
            method: PaymentMethods.account,
            amount: _amount(widget.accountController),
          ),
      ];
      return PaymentBreakdown(entries);
    }
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

    for (final entry in breakdown.entries) {
      if (entry.method != PaymentMethods.cash &&
          entry.method != PaymentMethods.account) {
        _getCustomBankController(entry.method).text = entry
            .amount
            .toStringAsFixed(2);
      }
    }
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

  // Handles dynamic changes across any payment method field in split mode
  void _onDynamicFieldChanged(String method, String value) {
    if (isUpdating) return;
    isUpdating = true;

    final total = returnSalesProvider().calcFinalTotal();
    final customBanks =
        returnShopProvider().getCustomPaymentMethods();
    final useAccount =
        returnSalesProvider().canUseAccount();

    double editedAmount =
        double.tryParse(value.replaceAll(',', '')) ?? 0;
    if (editedAmount < 0) editedAmount = 0;

    if (editedAmount > total) {
      _showAlert(
        'Overpayment',
        '$method cannot exceed total amount.',
      );
      editedAmount = total;
    }

    if (method == PaymentMethods.account) {
      double balance =
          returnSalesProvider().availableAccountBalance() ??
          0;
      if (balance < 0) balance = 0;
      if (editedAmount > balance) {
        _showAlert(
          'Insufficient Balance',
          'Customer Account cannot exceed the customer\'s balance of ${formatMoneyMid(amount: balance, context: context)}.',
        );
        editedAmount = balance;
      }
    }

    if (customBanks.isNotEmpty) {
      double totalBank = 0;
      for (final PaymentMethod b in customBanks) {
        totalBank +=
            _amount(_getCustomBankController(b.displayName));
      }
      widget.bankController.text = totalBank
          .toStringAsFixed(2);
    }

    final entries = <PaymentEntry>[
      PaymentEntry(
        method: PaymentMethods.cash,
        amount: _amount(widget.cashController),
      ),
      if (customBanks.isNotEmpty)
        for (final PaymentMethod b in customBanks)
          PaymentEntry(
            method: b.displayName,
            amount: _amount(
              _getCustomBankController(b.displayName),
            ),
          )
      else
        PaymentEntry(
          method: PaymentMethods.bank,
          amount: _amount(widget.bankController),
        ),
      if (useAccount)
        PaymentEntry(
          method: PaymentMethods.account,
          amount: _amount(widget.accountController),
        ),
    ];

    returnSalesProvider().setSplitPayments(
      PaymentBreakdown(entries).compact,
    );

    isUpdating = false;
    setState(() {});
  }

  // Keeps the three fields adding up to the total when no custom banks are set.
  void _rebalance(String edited, String value) {
    final customBanks =
        returnShopProvider().getCustomPaymentMethods();
    if (customBanks.isNotEmpty) {
      _onDynamicFieldChanged(edited, value);
      return;
    }

    if (isUpdating) return;
    isUpdating = true;

    double total = returnSalesProvider().calcFinalTotal();
    bool useAccount = returnSalesProvider().canUseAccount();
    Map<String, double> amounts = {
      PaymentMethods.cash: _amount(widget.cashController),
      PaymentMethods.bank: _amount(widget.bankController),
      PaymentMethods.account:
          useAccount
              ? _amount(widget.accountController)
              : 0,
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
          returnSalesProvider().availableAccountBalance() ??
          0;
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
      amounts[other] =
          (amounts[other]! + rest) < 0
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
    returnSalesProvider().setSplitPayments(
      breakdown.compact,
    );

    isUpdating = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    bool showAccount =
        returnSalesProviderContext(context).canUseAccount();
    final customBanks =
        returnShopProvider(
          context: context,
        ).getCustomPaymentMethods();
    double remaining =
        returnSalesProviderContext(
          context,
        ).calcFinalTotal() -
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
              if (customBanks.isEmpty)
                Row(
                  spacing: 10,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: EditCartTextField(
                        title: 'Cash',
                        hint: 'Cash Amount',
                        controller: widget.cashController,
                        theme: theme,
                        onChanged: (value) {
                          _rebalance(
                            PaymentMethods.cash,
                            value,
                          );
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
                          _rebalance(
                            PaymentMethods.bank,
                            value,
                          );
                        },
                      ),
                    ),
                  ],
                )
              else
                Column(
                  spacing: 10,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: EditCartTextField(
                            title: 'Cash',
                            hint: 'Cash Amount',
                            controller:
                                widget.cashController,
                            theme: theme,
                            onChanged: (value) {
                              _onDynamicFieldChanged(
                                PaymentMethods.cash,
                                value,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    ...customBanks.map((bMethod) {
                      final name = bMethod.displayName;
                      return Row(
                        children: [
                          Expanded(
                            child: EditCartTextField(
                              title: name,
                              hint: '$name Amount',
                              controller:
                                  _getCustomBankController(
                                    name,
                                  ),
                              theme: theme,
                              onChanged: (value) {
                                _onDynamicFieldChanged(
                                  name,
                                  value,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }),
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
                    _rebalance(
                      PaymentMethods.account,
                      value,
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                    ),
                    'Remaining:',
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: Icon(
                      Icons.settings_outlined,
                      size: 15,
                      color:
                          theme.lightModeColor.prColor250,
                    ),
                    label: Text(
                      'Manage Bank Accounts',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        color:
                            theme.lightModeColor.prColor250,
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) =>
                                const ManagePaymentMethodsDialog(),
                      ).then((_) {
                        setState(() {});
                      });
                    },
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
