import 'package:flutter/material.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/payment_entry/payment_method.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/alert_dialogues/manage_payment_methods_dialog.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
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
      displayMethodTitle = selectedBank;
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b4
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                                color:
                                    returnSalesProviderContext(
                                                      context,
                                                    )
                                                    .currentCart()
                                                    .cartItemTypeIndex ==
                                                2 &&
                                            widget.index ==
                                                2
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
                                        .b5
                                        .fontSize,
                                fontWeight:
                                    FontWeight.normal,
                                color:
                                    returnSalesProviderContext(
                                                      context,
                                                    )
                                                    .currentCart()
                                                    .cartItemTypeIndex ==
                                                2 &&
                                            widget.index ==
                                                2
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
                      ),
                      const SizedBox(width: 8),
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
                          avatar: Icon(
                            bMethod.icon,
                            size: 16,
                            color:
                                isSelected
                                    ? Colors.white
                                    : theme
                                        .lightModeColor
                                        .prColor250,
                          ),
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
                          mouseCursor:
                              SystemMouseCursors.click,
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
                            ? '+ Add Channel'
                            : 'Manage Channels',
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
      displayMethodTitle = selectedBank;
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
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
                              "$displayMethodTitle${customersClass != null ? " (${formatMoneyBig(amount: customersClass.getBalance(), context: context)})" : ''}",
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b5
                                        .fontSize,
                                fontWeight:
                                    FontWeight.normal,
                              ),
                              returnSalesProviderContext(
                                context,
                              ).selectedPaymentMethod()['subText'],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        size: 26,
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

class _AvailableMethod {
  final String name;
  final IconData icon;
  final String label;
  final String? typeLabel;

  const _AvailableMethod({
    required this.name,
    required this.icon,
    required this.label,
    this.typeLabel,
  });
}

class _PaymentMethodSectionState
    extends State<PaymentMethodSection> {
  bool isUpdating = false;

  /// Keys of the methods in the split: Cash, Bank and Customer
  /// Account by their constant, a custom method by its uuid (two
  /// methods at one bank share a label but never a key). A saved
  /// label no custom method matches is kept as its own key.
  final List<String> _activeMethods = [];
  final Map<String, TextEditingController>
  _customBankControllers = {};

  bool _isFixedMethod(String method) =>
      method == PaymentMethods.cash ||
      method == PaymentMethods.bank ||
      method == PaymentMethods.account;

  /// The label saved for [key]: the method's bank name.
  String _labelForKey(String key) => PaymentMethod.labelForKey(
    key,
    returnShopProvider().getCustomPaymentMethods(),
  );

  /// Keys for saved [entries], in order (older "Bank (account)"
  /// labels match too, see [PaymentMethod.keysForEntries]).
  List<String> _keysForEntries(List<PaymentEntry> entries) =>
      PaymentMethod.keysForEntries(
        entries,
        returnShopProvider().getCustomPaymentMethods(),
      );

  @override
  void initState() {
    super.initState();
    // Restore a saved split (edited receipt, remainder shortcut, or a
    // section that was collapsed) if it still matches the cart total.
    var saved =
        returnSalesProvider().currentCart().splitPayments;
    if (saved != null && saved.isNotEmpty) {
      for (final key in _keysForEntries(saved)) {
        if (!_activeMethods.contains(key)) {
          _activeMethods.add(key);
        }
      }
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

  TextEditingController _getControllerFor(String method) {
    if (method == PaymentMethods.cash)
      return widget.cashController;
    if (method == PaymentMethods.bank)
      return widget.bankController;
    if (method == PaymentMethods.account)
      return widget.accountController;
    if (!_customBankControllers.containsKey(method)) {
      _customBankControllers[method] =
          TextEditingController(text: '0');
    }
    return _customBankControllers[method]!;
  }

  PaymentBreakdown _currentBreakdown() {
    final entries = <PaymentEntry>[
      for (final method in _activeMethods)
        PaymentEntry(
          method: _labelForKey(method),
          amount: _amount(_getControllerFor(method)),
        ),
    ];
    return PaymentBreakdown(entries);
  }

  void _writeControllers(PaymentBreakdown breakdown) {
    widget.cashController.text = breakdown.cash
        .toStringAsFixed(2);
    widget.bankController.text = breakdown.bank
        .toStringAsFixed(2);
    widget.accountController.text = breakdown.account
        .toStringAsFixed(2);

    final keys = _keysForEntries(breakdown.entries);
    for (var i = 0; i < breakdown.entries.length; i++) {
      final entry = breakdown.entries[i];
      if (!_isFixedMethod(entry.method)) {
        _getControllerFor(keys[i]).text = entry.amount
            .toStringAsFixed(2);
      }
    }
  }

  void _applyPayments(List<PaymentEntry> payments) {
    for (final key in _keysForEntries(payments)) {
      if (!_activeMethods.contains(key)) {
        _activeMethods.add(key);
      }
    }
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

  void _onFieldChanged(String method, String value) {
    if (isUpdating) return;
    isUpdating = true;

    final total = returnSalesProvider().calcFinalTotal();
    double editedAmount =
        double.tryParse(value.replaceAll(',', '')) ?? 0;
    if (editedAmount < 0) editedAmount = 0;

    if (editedAmount > total) {
      _showAlert(
        'Overpayment',
        '${_labelForKey(method)} cannot exceed total amount.',
      );
      editedAmount = total;
      _getControllerFor(method).text = editedAmount
          .toStringAsFixed(2);
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
        _getControllerFor(method).text = editedAmount
            .toStringAsFixed(2);
      }
    }

    // Update aggregate bankController if any custom bank was edited
    final customBanks =
        returnShopProvider().getCustomPaymentMethods();
    if (customBanks.isNotEmpty) {
      double totalBank = 0;
      for (final PaymentMethod b in customBanks) {
        if (_activeMethods.contains(b.uuid)) {
          totalBank += _amount(_getControllerFor(b.uuid));
        }
      }
      widget.bankController.text = totalBank
          .toStringAsFixed(2);
    }

    final entries = <PaymentEntry>[
      for (final m in _activeMethods)
        PaymentEntry(
          method: _labelForKey(m),
          amount: _amount(_getControllerFor(m)),
        ),
    ];

    returnSalesProvider().setSplitPayments(
      PaymentBreakdown(entries).compact,
    );

    isUpdating = false;
    setState(() {});
  }

  void _addMethod(String method) {
    if (_activeMethods.contains(method)) return;
    setState(() {
      _activeMethods.add(method);
      final total = returnSalesProvider().calcFinalTotal();
      double currentSum = 0;
      for (final m in _activeMethods) {
        if (m != method) {
          currentSum += _amount(_getControllerFor(m));
        }
      }
      double rem = total - currentSum;
      if (rem < 0) rem = 0;

      if (method == PaymentMethods.account) {
        double balance =
            returnSalesProvider()
                .availableAccountBalance() ??
            0;
        if (balance < 0) balance = 0;
        if (rem > balance) rem = balance;
      }

      _getControllerFor(method).text =
          rem > 0 ? rem.toStringAsFixed(2) : '';
    });
    _onFieldChanged(method, _getControllerFor(method).text);
  }

  void _removeMethod(String method) {
    setState(() {
      _activeMethods.remove(method);
      _getControllerFor(method).text = '0';
    });
    _onFieldChanged(method, '0');
  }

  List<_AvailableMethod> _getAvailableMethods() {
    final list = <_AvailableMethod>[];
    final customBanks =
        returnShopProvider().getCustomPaymentMethods();
    final canUseAccount =
        returnSalesProvider().canUseAccount();

    if (!_activeMethods.contains(PaymentMethods.cash)) {
      list.add(
        const _AvailableMethod(
          name: PaymentMethods.cash,
          icon: Icons.payments_outlined,
          label: 'Cash',
        ),
      );
    }

    if (customBanks.isNotEmpty) {
      for (final b in customBanks) {
        if (!_activeMethods.contains(b.uuid)) {
          list.add(
            _AvailableMethod(
              name: b.uuid,
              icon: b.icon,
              label: b.displayName,
              typeLabel: b.typeLabel,
            ),
          );
        }
      }
    } else {
      if (!_activeMethods.contains(PaymentMethods.bank)) {
        list.add(
          const _AvailableMethod(
            name: PaymentMethods.bank,
            icon: Icons.account_balance_outlined,
            label: 'Bank',
          ),
        );
      }
    }

    if (canUseAccount &&
        !_activeMethods.contains(PaymentMethods.account)) {
      final balance =
          returnSalesProvider().availableAccountBalance() ??
          0;
      list.add(
        _AvailableMethod(
          name: PaymentMethods.account,
          icon: Icons.person_outline_rounded,
          label:
              'Customer Account (${formatMoneyMid(amount: balance, context: context)})',
        ),
      );
    }

    return list;
  }

  String _getFieldTitle(String method) {
    if (method == PaymentMethods.cash) return 'Cash';
    if (method == PaymentMethods.bank) return 'Bank';
    if (method == PaymentMethods.account) {
      final balance =
          returnSalesProvider().availableAccountBalance() ??
          0;
      return 'Customer Account (${formatMoneyMid(amount: balance, context: context)})';
    }
    return _labelForKey(method);
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    bool showAccount =
        returnSalesProviderContext(context).canUseAccount();
    double remaining =
        returnSalesProviderContext(
          context,
        ).calcFinalTotal() -
        _currentBreakdown().total;

    return Column(
      children: [
        if (screenWidth(context) > mobileScreen) ...[
          Divider(color: Colors.grey.shade300),
        ],
        Column(
          children: [
            if (screenWidth(context) > mobileScreen) ...[
              Row(
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    'Select Payment Method',
                  ),
                ],
              ),
              const SizedBox(height: 5),
            ],
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
        const SizedBox(height: 5),
        Visibility(
          visible:
              returnSalesProviderContext(
                context,
              ).currentCart().paymentMethod ==
              2,
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
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                if (_activeMethods.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    // decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.circular(6),
                    //   border: Border.all(
                    //     color: Colors.grey.shade200,
                    //   ),
                    //   color: Colors.grey.shade50,
                    // ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.call_split_rounded,
                          size: 28,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No payment methods selected yet.',
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Click "+ Add Payment Method" below to select which channels to split between.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      for (final method
                          in _activeMethods) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: EditCartTextField(
                                  title: _getFieldTitle(
                                    method,
                                  ),
                                  hint: 'Amount',
                                  controller:
                                      _getControllerFor(
                                        method,
                                      ),
                                  theme: theme,
                                  onChanged:
                                      (value) =>
                                          _onFieldChanged(
                                            method,
                                            value,
                                          ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.only(
                                      top: 18,
                                    ),
                                child: IconButton(
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  visualDensity:
                                      VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints:
                                      const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  tooltip: 'Remove $method',
                                  onPressed:
                                      () => _removeMethod(
                                        method,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    final available =
                        _getAvailableMethods();
                    if (available.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          color: Colors.grey.shade100,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'All available payment methods added',
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b4
                                        .fontSize,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return PopupMenuButton<String>(
                      tooltip:
                          'Add payment method to split',
                      onSelected:
                          (method) => _addMethod(method),
                      itemBuilder: (context) {
                        return available.map((m) {
                          return PopupMenuItem<String>(
                            value: m.name,
                            child: Row(
                              children: [
                                Icon(
                                  m.icon,
                                  size: 18,
                                  color:
                                      theme
                                          .lightModeColor
                                          .prColor250,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    m.label,
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                  ),
                                ),
                                if (m.typeLabel !=
                                    null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors
                                              .grey
                                              .shade200,
                                      borderRadius:
                                          BorderRadius.circular(
                                            4,
                                          ),
                                    ),
                                    child: Text(
                                      m.typeLabel!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight:
                                            FontWeight.bold,
                                        color:
                                            Colors
                                                .grey
                                                .shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                theme
                                    .lightModeColor
                                    .prColor250,
                          ),
                          borderRadius:
                              BorderRadius.circular(6),
                          color: theme
                              .lightModeColor
                              .prColor250
                              .withValues(alpha: 0.05),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 16,
                              color:
                                  theme
                                      .lightModeColor
                                      .prColor250,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+ Add Payment Method',
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b4
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                                color:
                                    theme
                                        .lightModeColor
                                        .prColor250,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  spacing: 5,
                  children: [
                    Row(
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
                          'Remaining:',
                        ),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color:
                                remaining.abs() >
                                        PaymentBreakdown
                                            .tolerance
                                    ? Colors.red
                                    : Colors.green.shade700,
                          ),
                          formatMoneyMid(
                            amount:
                                remaining.abs() >
                                        PaymentBreakdown
                                            .tolerance
                                    ? remaining
                                    : 0,
                            context: context,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: Icon(
                            Icons.settings_outlined,
                            size: 15,
                            color:
                                theme
                                    .lightModeColor
                                    .prColor250,
                          ),
                          label: Text(
                            'Manage Channels',
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              color:
                                  theme
                                      .lightModeColor
                                      .prColor250,
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
