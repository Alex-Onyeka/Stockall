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
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/components/item_comment_widget.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/components/sub_staff_selection_widget.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/make_sales_mobile.dart';
import 'package:stockall/pages/sales/make_sales/page2/components/customer_selection_widget.dart';
import 'package:stockall/pages/sales/make_sales/page2/components/set_custom_receipt_created_date_widget.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class MakeSalesMobileTwo extends StatefulWidget {
  final double totalAmount;
  final TextEditingController searchController;
  final TextEditingController cashController;
  final TextEditingController bankController;
  final TextEditingController customerController;
  final TextEditingController partPaymentController;
  final TextEditingController commentController;
  const MakeSalesMobileTwo({
    super.key,
    required this.searchController,
    required this.bankController,
    required this.cashController,
    required this.customerController,
    required this.totalAmount,
    required this.partPaymentController,
    required this.commentController,
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
  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.cashController.text =
        widget.totalAmount.toString();

    widget.bankController.text = '0';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      commentController.text =
          returnSalesProvider().currentCart().comment ?? '';
      setState(() {});
    });
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
                        CustomerSelectionWidget(
                          refreshAction: () {
                            setState(() {});
                          },
                        ),
                        SizedBox(height: 10),
                        SetCustomReceiptCreatedDateWidget(),
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
                              'Create Invoice (Credit Sale)',
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
                              'Is this Sale On Credit (Invoice?',
                            ),
                            InkWell(
                              mouseCursor:
                                  SystemMouseCursors.click,
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
                            PaymentTypeDropdown(),
                          ],
                        ),
                        SizedBox(height: 5),
                        ItemCommentWidget(
                          commentController:
                              commentController,
                          onTapOutside: (pointerDownEvent) {
                            returnSalesProvider()
                                .setComment(
                                  comment:
                                      commentController
                                          .text,
                                );
                          },
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
                                        .selectedCustomerName ==
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
                            } else if (returnSalesProvider()
                                        .currentCart()
                                        .paymentMethod ==
                                    3 &&
                                !returnSalesProvider()
                                    .isBalanceSufficient()) {
                              showDialog(
                                context: context,
                                builder: (erroContext) {
                                  return InfoAlert(
                                    theme: theme,
                                    message:
                                        'This Customers Balance is not enough to make this Purchase. Please Select Another Payment Method and Proceed.',
                                    title:
                                        'Insufficient Balance',
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
                                      returnSalesProvider()
                                          .setComment(
                                            comment:
                                                commentController
                                                    .text,
                                          );
                                      var res = await returnSalesProvider().checkoutMain(
                                        customerBalance:
                                            returnSalesProvider()
                                                        .returnPaymentMethod() ==
                                                    'Account'
                                                ? returnSalesProvider()
                                                    .calcFinalTotal()
                                                : 0,
                                        context: context,
                                        salesCartItem:
                                            returnSalesProvider()
                                                .currentCart(),
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
                                                    'Cash'
                                                ? returnSalesProvider()
                                                    .calcFinalTotal()
                                                : 0,
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
