import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_account_details_section_widget.dart';

class PaymentTypeButtonOrder extends StatefulWidget {
  final int index;
  final Orders order;
  final Function()? action;
  final TextEditingController cashController;
  final TextEditingController bankController;

  const PaymentTypeButtonOrder({
    super.key,
    required this.index,
    required this.order,
    required this.cashController,
    required this.bankController,
    this.action,
  });

  @override
  State<PaymentTypeButtonOrder> createState() =>
      _PaymentTypeButtonOrderState();
}

class _PaymentTypeButtonOrderState
    extends State<PaymentTypeButtonOrder> {
  TextEditingController topUpController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    TempCustomersClass? customersClass;
    if (widget.index == 3) {
      var customerUuid = widget.order.customerId;
      List<TempCustomersClass> customers =
          returnCustomersSingle().customers
              .where((item) => item.uuid == customerUuid)
              .toList();
      if (customers.isNotEmpty) {
        customersClass = customers.first;
      }
    }
    var theme = returnTheme(context);
    void selectOptionAction() {
      returnOrdersActionProvider().changePaymentOptions(
        widget.index,
      );
      widget.action != null ? widget.action!() : {};
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
                                  theme
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
                            theme.lightModeColor.prColor250,
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
                            returnOrdersActionProvider(
                              context: context,
                            ).paymentOption ==
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
              returnOrdersActionProvider(
                    context: context,
                  ).paymentOption ==
                  3 &&
              !returnOrdersActionProvider(
                context: context,
              ).isBalanceSufficient(
                customersClass?.uuid ?? '',
              ),
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
                              if (customersClass != null) {
                                await topUpAction(
                                  popSecondContext: false,
                                  context: context,
                                  theme: theme,
                                  moneyTextField:
                                      topUpController,
                                  customer: customersClass,
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
                              if (customersClass != null) {
                                await topUpAction(
                                  popSecondContext: false,
                                  context: context,
                                  theme: theme,
                                  moneyTextField:
                                      topUpController,
                                  customer: customersClass,
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

class PaymentMethodSectionOrder extends StatefulWidget {
  final Orders order;
  final TextEditingController cashController;
  final TextEditingController bankController;

  const PaymentMethodSectionOrder({
    super.key,
    required this.cashController,
    required this.bankController,
    required this.order,
  });

  @override
  State<PaymentMethodSectionOrder> createState() =>
      _PaymentMethodSectionOrderState();
}

class _PaymentMethodSectionOrderState
    extends State<PaymentMethodSectionOrder> {
  bool isUpdating = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
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
            PaymentTypeButtonOrder(
              bankController: widget.bankController,
              cashController: widget.cashController,
              order: widget.order,
              index: 0,
              action: () {
                widget.cashController.clear();
                widget.bankController.clear();
                setState(() {});
              },
            ),
            PaymentTypeButtonOrder(
              bankController: widget.bankController,
              cashController: widget.cashController,
              order: widget.order,
              index: 1,
              action: () {
                widget.cashController.clear();
                widget.bankController.clear();
                setState(() {});
              },
            ),
            Visibility(
              visible:
                  GeneralSettingsAuthAction()
                          .manageCustomersAccountAndPoints(
                            context: null,
                          ) ==
                      true &&
                  returnShopProvider()
                          .userShop()
                          ?.manageCustomerAccount ==
                      true &&
                  widget.order.customerId != null &&
                  authorization(
                    authorized:
                        Authorizations()
                            .makeSalesFromCustomersAccount,
                  ),
              child: PaymentTypeButtonOrder(
                bankController: widget.bankController,
                cashController: widget.cashController,
                order: widget.order,
                index: 3,
                action: () {
                  widget.cashController.clear();
                  widget.bankController.clear();
                  setState(() {});
                },
              ),
            ),
            PaymentTypeButtonOrder(
              bankController: widget.bankController,
              cashController: widget.cashController,
              order: widget.order,
              index: 2,
              action: () {
                widget.cashController.text =
                    returnOrdersActionProvider()
                        .totalOrdersAmount()
                        .toString();
                widget.bankController.clear();
              },
            ),
          ],
        ),
        SizedBox(height: 20),
        Visibility(
          visible:
              returnOrdersActionProvider(
                context: context,
              ).paymentOption ==
              2,
          child: SizedBox(
            // width: 300,
            // height: 200,
            child: Row(
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
                      if (isUpdating)
                        // ignore: curly_braces_in_flow_control_structures
                        return;
                      isUpdating = true;

                      double cash =
                          double.tryParse(
                            value.replaceAll(',', ''),
                          ) ??
                          0;
                      if (cash >
                          returnOrdersActionProvider()
                              .totalOrdersAmount()) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return InfoAlert(
                              theme: theme,
                              message:
                                  'Cash cannot exceed total amount.',
                              title: 'Overpayment',
                            );
                          },
                        );
                        // Reset to max allowed
                        widget.cashController.text =
                            returnOrdersActionProvider()
                                .totalOrdersAmount()
                                .toStringAsFixed(2);
                        widget.bankController.text = '0.00';
                      } else {
                        double bank =
                            returnOrdersActionProvider()
                                .totalOrdersAmount() -
                            cash;
                        widget.bankController.text = bank
                            .toStringAsFixed(2);
                      }

                      isUpdating = false;
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
                      if (isUpdating)
                        // ignore: curly_braces_in_flow_control_structures
                        return;
                      isUpdating = true;

                      double bank =
                          double.tryParse(
                            value.replaceAll(',', ''),
                          ) ??
                          0;
                      if (bank >
                          returnOrdersActionProvider()
                              .totalOrdersAmount()) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return InfoAlert(
                              theme: theme,
                              message:
                                  'Bank cannot exceed total amount.',
                              title: 'Overpayment',
                            );
                          },
                        );
                        widget.bankController.text =
                            returnOrdersActionProvider()
                                .totalOrdersAmount()
                                .toStringAsFixed(2);
                        widget.cashController.text = '0.00';
                      } else {
                        double cash =
                            returnOrdersActionProvider()
                                .totalOrdersAmount() -
                            bank;
                        widget.cashController.text = cash
                            .toStringAsFixed(2);
                      }

                      isUpdating = false;
                    },
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
