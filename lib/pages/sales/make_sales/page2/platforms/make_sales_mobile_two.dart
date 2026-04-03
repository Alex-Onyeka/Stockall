import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/payment_type_button.dart';
import 'package:stockall/components/cart_queue/cart_queue_mobile.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customers_list/customer_list.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/make_sales_desktop.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/make_sales_mobile.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class MakeSalesMobileTwo extends StatefulWidget {
  final double totalAmount;
  final TextEditingController searchController;
  final TextEditingController cashController;
  final TextEditingController bankController;
  final TextEditingController customerController;
  final TextEditingController partPaymentController;
  const MakeSalesMobileTwo({
    super.key,
    required this.searchController,
    required this.bankController,
    required this.cashController,
    required this.customerController,
    required this.totalAmount,
    required this.partPaymentController,
  });

  @override
  State<MakeSalesMobileTwo> createState() =>
      _MakeSalesMobileTwoState();
}

class _MakeSalesMobileTwoState
    extends State<MakeSalesMobileTwo> {
  bool isUpdating = false;
  bool isLoading = false;
  bool showSuccess = false;
  final discountPercentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.cashController.text =
        widget.totalAmount.toString();

    widget.bankController.text = '0';
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          appBar: appBar(
            context: context,
            title: 'Select Payment Method',
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Row(
                          spacing: 5,
                          children: [
                            Expanded(
                              child: CartQueueMobile(
                                isFirst: false,
                              ),
                            ),
                            SubStaffToggleButtonMobile(
                              isFirst: false,
                            ),
                          ],
                        ),
                        Visibility(
                          visible:
                              returnSalesProviderContext(
                                context,
                              ).isSubStaffSelectionMobileOpen,
                          child: Column(
                            children: [
                              SizedBox(height: 2),
                              SubStaffSelectionWidget(),
                            ],
                          ),
                        ),
                        SizedBox(height: 13),
                        Builder(
                          builder: (context) {
                            if (returnSalesProviderContext(
                                      context,
                                    )
                                    .currentCart()
                                    .selectedCustomer ==
                                null) {
                              return SubWrapper(
                                isVisible:
                                    !SalesAuthAction()
                                        .addCustomItemToCartAction(
                                          context: context,
                                        ),
                                mainWidget: Material(
                                  color: Colors.transparent,
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(
                                            5,
                                          ),
                                      border: Border.all(
                                        color:
                                            Colors
                                                .grey
                                                .shade400,
                                        width: 1,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        SalesAuthAction().addCustomItemToCartAction(
                                          context: context,
                                          action: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (
                                                  context,
                                                ) {
                                                  return CustomerList(
                                                    isSales:
                                                        true,
                                                  );
                                                },
                                              ),
                                            ).then((_) {
                                              setState(
                                                () {},
                                              );
                                            });
                                          },
                                        );
                                      },
                                      borderRadius:
                                          BorderRadius.circular(
                                            5,
                                          ),
                                      child: Container(
                                        padding:
                                            EdgeInsets.only(
                                              left: 20,
                                              right: 15,
                                              bottom: 12,
                                              top: 12,
                                            ),

                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                color:
                                                    Colors
                                                        .grey,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Select Customer ${returnSalesProviderContext(context).currentCart().isInvoice ? '' : '(Optional)'}',
                                            ),
                                            Icon(
                                              color:
                                                  Colors
                                                      .grey,
                                              size: 20,
                                              Icons
                                                  .arrow_forward_ios_rounded,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 5,
                                    ),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(
                                        10,
                                      ),
                                  color:
                                      Colors.grey.shade200,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Row(
                                      spacing: 10,
                                      children: [
                                        Icon(Icons.person),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                              ),
                                              'Selected Customer:',
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b1
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              returnCustomers(
                                                    context,
                                                    listen:
                                                        false,
                                                  )
                                                  .getCustomerByIdMain(
                                                    returnSalesProviderContext(
                                                          context,
                                                        ).currentCart().selectedCustomer ??
                                                        '',
                                                  )!
                                                  .name,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Visibility(
                                      visible:
                                          (returnSalesProvider()
                                                          .currentCart()
                                                          .isReceiptEdit &&
                                                      returnSalesProvider().currentCart().invoiceUuidEdit !=
                                                          null) ==
                                                  true
                                              ? false
                                              : true,
                                      child: IconButton(
                                        onPressed: () {
                                          returnCustomers(
                                            context,
                                            listen: false,
                                          ).clearSelectedCustomer(
                                            context,
                                          );
                                          setState(() {});
                                        },
                                        icon: Icon(
                                          Icons.clear,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        Divider(
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b1
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Change Sale Type',
                            ),
                          ],
                        ),
                        // SizedBox(height: 5),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight:
                                    FontWeight.normal,
                              ),
                              'Is this Sale On Credit?',
                            ),
                            InkWell(
                              onTap: () async {
                                if (returnSalesProvider()
                                    .currentCart()
                                    .isInvoice) {
                                  returnSalesProvider()
                                      .switchInvoiceSale(
                                        context: context,
                                        value: false,
                                      );
                                } else {
                                  returnSalesProvider()
                                      .switchInvoiceSale(
                                        context: context,
                                        value: true,
                                      );
                                }
                                returnSalesProvider()
                                    .changeMethod(
                                      context: context,
                                      index: 0,
                                    );
                                widget.partPaymentController
                                    .clear();
                              },
                              child: Container(
                                width: 50,
                                padding:
                                    EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(
                                        20,
                                      ),
                                  border: Border.all(
                                    color:
                                        returnSalesProviderContext(
                                                  context,
                                                )
                                                .currentCart()
                                                .isInvoice
                                            ? theme
                                                .lightModeColor
                                                .prColor250
                                            : Colors.grey,
                                  ),
                                  color:
                                      returnSalesProviderContext(
                                                context,
                                              )
                                              .currentCart()
                                              .isInvoice
                                          ? theme
                                              .lightModeColor
                                              .prColor250
                                          : Colors
                                              .grey
                                              .shade200,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      returnSalesProviderContext(
                                                context,
                                              )
                                              .currentCart()
                                              .isInvoice
                                          ? MainAxisAlignment
                                              .end
                                          : MainAxisAlignment
                                              .start,
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        shape:
                                            BoxShape.circle,
                                        color:
                                            returnSalesProviderContext(
                                                      context,
                                                    )
                                                    .currentCart()
                                                    .isInvoice
                                                ? Colors
                                                    .white
                                                : Colors
                                                    .grey
                                                    .shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 10),
                        Visibility(
                          visible:
                              returnSalesProviderContext(
                                context,
                              ).currentCart().isInvoice,
                          child: Column(
                            children: [
                              MoneyTextfield(
                                title:
                                    'Make Part Payment (Optional)',
                                hint:
                                    'Enter Amount (Optional)',
                                controller:
                                    widget
                                        .partPaymentController,
                                theme: theme,
                                onChanged: (value) {
                                  if (value.isNotEmpty &&
                                      (double.tryParse(
                                                value
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              ) ??
                                              0) >=
                                          returnSalesProvider()
                                              .calcFinalTotal()) {
                                    widget
                                        .partPaymentController
                                        .text = '0';
                                  }
                                },
                              ),
                              SizedBox(height: 10),
                              Divider(
                                color: Colors.grey.shade300,
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b1
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  'Select Payment Method',
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            PaymentTypeButton(index: 0),
                            PaymentTypeButton(index: 1),
                            PaymentTypeButton(index: 2),
                          ],
                        ),
                        SizedBox(height: 20),
                        Visibility(
                          visible:
                              returnSalesProviderContext(
                                    context,
                                  )
                                  .currentCart()
                                  .paymentMethod ==
                              2,
                          child: SizedBox(
                            // width: 300,
                            // height: 200,
                            child: Row(
                              spacing: 10,
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: EditCartTextField(
                                    title: 'Cash',
                                    hint: 'Cash Amount',
                                    controller:
                                        widget
                                            .cashController,
                                    theme: theme,
                                    onChanged: (value) {
                                      if (isUpdating)
                                        // ignore: curly_braces_in_flow_control_structures
                                        return;
                                      isUpdating = true;

                                      double cash =
                                          double.tryParse(
                                            value
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ) ??
                                          0;
                                      if (cash >
                                          widget
                                              .totalAmount) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            var theme =
                                                Provider.of<
                                                  ThemeProvider
                                                >(context);
                                            return InfoAlert(
                                              theme: theme,
                                              message:
                                                  'Cash cannot exceed total amount.',
                                              title:
                                                  'Overpayment',
                                            );
                                          },
                                        );
                                        // Reset to max allowed
                                        widget
                                            .cashController
                                            .text = widget
                                            .totalAmount
                                            .toStringAsFixed(
                                              2,
                                            );
                                        widget
                                            .bankController
                                            .text = '0.00';
                                      } else {
                                        double bank =
                                            widget
                                                .totalAmount -
                                            cash;
                                        widget
                                            .bankController
                                            .text = bank
                                            .toStringAsFixed(
                                              2,
                                            );
                                      }

                                      isUpdating = false;
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: EditCartTextField(
                                    title: 'Bank',
                                    hint: 'Bank Amount',
                                    controller:
                                        widget
                                            .bankController,
                                    theme: theme,
                                    onChanged: (value) {
                                      if (isUpdating)
                                        // ignore: curly_braces_in_flow_control_structures
                                        return;
                                      isUpdating = true;

                                      double bank =
                                          double.tryParse(
                                            value
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ) ??
                                          0;
                                      if (bank >
                                          widget
                                              .totalAmount) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            var theme =
                                                Provider.of<
                                                  ThemeProvider
                                                >(context);
                                            return InfoAlert(
                                              theme: theme,
                                              message:
                                                  'Bank cannot exceed total amount.',
                                              title:
                                                  'Overpayment',
                                            );
                                          },
                                        );
                                        widget
                                            .bankController
                                            .text = widget
                                            .totalAmount
                                            .toStringAsFixed(
                                              2,
                                            );
                                        widget
                                            .cashController
                                            .text = '0.00';
                                      } else {
                                        double cash =
                                            widget
                                                .totalAmount -
                                            bank;
                                        widget
                                            .cashController
                                            .text = cash
                                            .toStringAsFixed(
                                              2,
                                            );
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
                    ),
                  ),
                ),
                Material(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Visibility(
                        visible:
                            returnSalesProviderContext(
                                  context,
                                )
                                .currentCart()
                                .cartItems
                                .isNotEmpty,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b4
                                              .fontSize,
                                      // fontWeight: FontWeight.bold,
                                    ),
                                    'Subtotal',
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b4
                                              .fontSize,
                                      // fontWeight: FontWeight.bold,
                                    ),
                                    formatMoneyBig(
                                      amount:
                                          returnSalesProviderContext(
                                            context,
                                          ).calcSubTotal(),
                                      context: context,
                                    ),
                                  ),
                                ],
                              ),
                              Visibility(
                                visible:
                                    returnSalesProviderContext(
                                              context,
                                            )
                                            .currentCart()
                                            .discount !=
                                        null ||
                                    returnSalesProviderContext(
                                              context,
                                            )
                                            .currentCart()
                                            .fixedDiscount !=
                                        null,
                                child: Column(
                                  children: [
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b4
                                                        .fontSize,
                                                // fontWeight: FontWeight.bold,
                                              ),
                                              'Discount',
                                            ),
                                            Visibility(
                                              visible:
                                                  returnSalesProviderContext(
                                                    context,
                                                  ).currentCart().discount !=
                                                  null,
                                              child: Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b4
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                                ' (${returnSalesProviderContext(context).currentCart().discount?.toString()}%)',
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b4
                                                    .fontSize,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                          '- ${formatMoney(returnSalesProviderContext(context).calcDiscountMain(), context)}',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                children: [
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b4
                                                      .fontSize,
                                              // fontWeight: FontWeight.bold,
                                            ),
                                            'VAT',
                                          ),
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
                                              // fontWeight: FontWeight.bold,
                                            ),
                                            ' (${returnShopProvider().getVat()}%)',
                                          ),
                                        ],
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b4
                                                  .fontSize,
                                        ),
                                        formatMoney(
                                          returnSalesProviderContext(
                                            context,
                                          ).calcVatAmount(),
                                          context,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Total',
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    formatMoneyMid(
                                      amount:
                                          returnSalesProviderContext(
                                            context,
                                          ).calcFinalTotal(),
                                      context: context,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Visibility(
                        visible:
                            returnSalesProviderContext(
                                  context,
                                )
                                .currentCart()
                                .cartItems
                                .isNotEmpty,
                        child: MainButtonP(
                          themeProvider: theme,
                          action: () {
                            BuildContext safeContext =
                                context;
                            if (returnSalesProvider()
                                    .currentCart()
                                    .isInvoice &&
                                returnSalesProvider()
                                        .currentCart()
                                        .selectedCustomer ==
                                    null) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return InfoAlert(
                                    theme: theme,
                                    message:
                                        'You need to select a Customer before you can create an invoice.',
                                    title:
                                        'Customer not Set',
                                  );
                                },
                              );
                            } else {
                              showDialog(
                                context: safeContext,
                                builder: (_) {
                                  return ConfirmationAlert(
                                    theme: theme,
                                    message:
                                        returnSalesProvider()
                                                .currentCart()
                                                .isReceiptEdit
                                            ? "You are about to update this sales Receipt, are you sure you want to Proceed?"
                                            : returnSalesProvider()
                                                .currentCart()
                                                .isInvoice
                                            ? 'You are about to record a Sale on Credit, are you sure you want to proceed?'
                                            : 'You are about to record a Sale, are you sure you want to proceed?',
                                    title:
                                        returnSalesProvider()
                                                .currentCart()
                                                .isReceiptEdit
                                            ? 'Update Receipt?'
                                            : returnSalesProvider()
                                                .currentCart()
                                                .isInvoice
                                            ? 'Sell on Credit?'
                                            : 'Are you sure?',
                                    action: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      if (safeContext
                                          .mounted) {
                                        Navigator.of(
                                          safeContext,
                                        ).pop();
                                      }
                                      var res = await returnSalesProvider().checkoutMain(
                                        context: context,
                                        salesCartItem:
                                            returnSalesProvider()
                                                .currentCart(),
                                        // staffId:
                                        //     AuthService()
                                        //         .currentUser!,
                                        // staffName:
                                        //     returnUserProvider(
                                        //           context,
                                        //           listen:
                                        //               false,
                                        //         )
                                        //         .currentUserMain!
                                        //         .name,
                                        shopId:
                                            returnShopProvider()
                                                .userShop()!
                                                .shopId!,
                                        bank:
                                            returnSalesProvider()
                                                        .returnPaymentMethod() ==
                                                    'Split'
                                                ? double.tryParse(
                                                      widget.bankController.text.replaceAll(
                                                        ',',
                                                        '',
                                                      ),
                                                    ) ??
                                                    0
                                                : returnSalesProvider()
                                                        .returnPaymentMethod() ==
                                                    'Bank'
                                                ? returnSalesProvider()
                                                    .calcFinalTotal()
                                                : 0,
                                        cashAlt:
                                            returnSalesProvider()
                                                        .returnPaymentMethod() ==
                                                    'Split'
                                                ? double.tryParse(
                                                      widget.cashController.text.replaceAll(
                                                        ',',
                                                        '',
                                                      ),
                                                    ) ??
                                                    0
                                                : returnSalesProvider()
                                                        .returnPaymentMethod() ==
                                                    'Bank'
                                                ? 0
                                                : returnSalesProvider()
                                                    .calcFinalTotal(),
                                        paymentMethod:
                                            returnSalesProvider()
                                                .returnPaymentMethod(),

                                        partPayment:
                                            double.tryParse(
                                              widget
                                                  .partPaymentController
                                                  .text
                                                  .replaceAll(
                                                    ',',
                                                    '',
                                                  ),
                                            ),
                                      );

                                      setState(() {
                                        isLoading = false;
                                        showSuccess = true;
                                      });

                                      await Future.delayed(
                                        Duration(
                                          seconds: 3,
                                        ),
                                        () {},
                                      );
                                      if (context.mounted) {
                                        if (res == null) {
                                          showDialog(
                                            context:
                                                context,
                                            builder: (
                                              context,
                                            ) {
                                              return InfoAlert(
                                                theme:
                                                    theme,
                                                message:
                                                    'An Error occoured while processing this sale. Please try again later.',
                                                title:
                                                    'Failed Sale!',
                                              );
                                            },
                                          );
                                        } else {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return ReceiptPage(
                                                  response:
                                                      res,
                                                  isMain:
                                                      true,
                                                );
                                              },
                                            ),
                                            (route) =>
                                                false,
                                          );
                                        }
                                      }
                                      setState(() {
                                        showSuccess = false;
                                      });
                                    },
                                  );
                                },
                              );
                            }
                          },
                          text:
                              returnSalesProviderContext(
                                        context,
                                      )
                                      .currentCart()
                                      .isReceiptEdit
                                  ? 'Update Receipt'
                                  : 'Check Out',
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Visibility(
          visible: isLoading,
          child: returnCompProvider(
            context,
          ).showLoader(message: 'Loading'),
        ),
        Visibility(
          visible: showSuccess,
          child: returnCompProvider(
            context,
          ).showSuccess('Sales Successful'),
        ),
      ],
    );
  }
}
