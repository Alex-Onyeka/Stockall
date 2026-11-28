import 'package:flutter/material.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/payment_type_button.dart';
import 'package:stockall/components/cart_queue/cart_queue_desktop.dart';
import 'package:stockall/components/drafts/drafts_list_sheet.dart';
import 'package:stockall/components/lan_stock_banner.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/my_calculator_desktop.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/custom_printing_page/components/custom_label_print_widget.dart';
import 'package:stockall/pages/custom_printing_page/components/custom_receipt_print_widget.dart';
import 'package:stockall/pages/products/product_details/platforms/components/item_comment_widget.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/components/project_display_widget.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/components/sub_staff_selection_widget.dart';
import 'package:stockall/pages/sales/make_sales/page2/components/customer_selection_widget.dart';
import 'package:stockall/pages/sales/make_sales/page2/components/set_custom_receipt_created_date_widget.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';

class MakeSalesDesktopTwo extends StatefulWidget {
  // final double totalAmount;
  final TextEditingController searchController;
  final TextEditingController cashController;
  final TextEditingController bankController;
  final TextEditingController accountController;
  final TextEditingController customerController;
  final TextEditingController partPaymentController;
  final TextEditingController commentController;
  const MakeSalesDesktopTwo({
    super.key,
    required this.searchController,
    required this.bankController,
    required this.accountController,
    required this.cashController,
    required this.customerController,
    // required this.totalAmount,
    required this.partPaymentController,
    required this.commentController,
  });

  @override
  State<MakeSalesDesktopTwo> createState() =>
      _MakeSalesDesktopTwoState();
}

class _MakeSalesDesktopTwoState
    extends State<MakeSalesDesktopTwo> {
  bool isUpdating = false;
  bool isLoading = false;
  bool showSuccess = false;
  final discountPercentController = TextEditingController();
  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.cashController.text =
        returnSalesProvider().calcFinalTotal().toString();

    widget.bankController.text = '0';
    widget.accountController.text = '0';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      commentController.text =
          returnSalesProvider().currentCart().comment ?? '';
      setState(() {});
    });
  }

  double _amount(TextEditingController controller) {
    return double.tryParse(
          controller.text.replaceAll(',', ''),
        ) ??
        0;
  }

  List<PaymentEntry> _resolvePayments() {
    return returnSalesProvider().resolvePayments(
      cash: _amount(widget.cashController),
      bank: _amount(widget.bankController),
      account: _amount(widget.accountController),
      splitPayments:
          returnSalesProvider().currentCart().splitPayments,
      selectedBankMethod:
          returnSalesProvider()
              .currentCart()
              .selectedBankName,
    );
  }

  // Only Real Sales pay at checkout; invoices and orders are unchanged.
  String? _paymentError() {
    if (returnSalesProvider()
            .currentCart()
            .cartItemTypeIndex !=
        1) {
      return null;
    }
    return returnSalesProvider().validatePayments(
      _resolvePayments(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backGroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            color: const Color.fromARGB(201, 255, 255, 255),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      46,
                      0,
                      0,
                      0,
                    ),
                    blurRadius: 10,
                    spreadRadius: 5,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Scaffold(
                body: LanStockBanner(
                  child: Row(
                  children: [
                    Visibility(
                      visible:
                          screenWidth(context) >
                          tabletScreen,
                      child: Expanded(
                        flex: 4,
                        child: MyCalculatorDesktop(),
                      ),
                    ),
                    Visibility(
                      visible:
                          screenWidth(context) >
                          tabletScreen,
                      child: SizedBox(width: 15),
                    ),
                    Expanded(
                      flex: 10,
                      child: DesktopPageContainer(
                        widget: Scaffold(
                          appBar: appBar(
                            context: context,
                            title: 'Select Payment Method',
                          ),
                          body: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        CustomerSelectionWidget(
                                          refreshAction:
                                              () {
                                                setState(
                                                  () {},
                                                );
                                              },
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        SetCustomReceiptCreatedDateWidget(),
                                        Visibility(
                                          visible:
                                              !returnSalesProviderContext(
                                                    context,
                                                  )
                                                  .currentCart()
                                                  .isReceiptEdit,
                                          child: Column(
                                            children: [
                                              Visibility(
                                                visible:
                                                    returnSalesProviderContext(
                                                      context,
                                                    ).currentCart().cartItemTypeIndex ==
                                                    2,
                                                child: Column(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        SizedBox(
                                                          height:
                                                              10,
                                                        ),
                                                        Divider(
                                                          color:
                                                              Colors.grey.shade300,
                                                        ),
                                                        SizedBox(
                                                          height:
                                                              10,
                                                        ),
                                                      ],
                                                    ),
                                                    MoneyTextfield(
                                                      title:
                                                          'Make Part Payment (Optional)',
                                                      hint:
                                                          'Enter Amount (Optional)',
                                                      controller:
                                                          widget.partPaymentController,
                                                      theme:
                                                          theme,
                                                      onChanged: (
                                                        value,
                                                      ) {
                                                        if (value.isNotEmpty &&
                                                            (double.tryParse(
                                                                      value.replaceAll(
                                                                        ',',
                                                                        '',
                                                                      ),
                                                                    ) ??
                                                                    0) >=
                                                                returnSalesProvider().calcFinalTotal()) {
                                                          widget.partPaymentController.text = '0';
                                                        }
                                                      },
                                                    ),
                                                    // SizedBox(
                                                    //   height:
                                                    //       10,
                                                    // ),
                                                    // Divider(
                                                    //   color:
                                                    //       Colors.grey.shade300,
                                                    // ),
                                                    SizedBox(
                                                      height:
                                                          10,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Visibility(
                                          visible:
                                              currentCart(
                                                context:
                                                    context,
                                              ).cartItemTypeIndex !=
                                              3,
                                          child: PaymentMethodSection(
                                            bankController:
                                                widget
                                                    .bankController,
                                            cashController:
                                                widget
                                                    .cashController,
                                            accountController:
                                                widget
                                                    .accountController,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 150,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      flex:
                          screenWidth(context) <
                                  tabletScreen
                              ? 6
                              : 5,
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                                15,
                                20,
                                15,
                                15,
                              ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.start,
                              children: [
                                SizedBox(height: 5),
                                ProjectDisplayWidget(),
                                Container(
                                  height: 40,
                                  padding:
                                      EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 5,
                                      ),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(
                                          8,
                                        ),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      CartQueueDesktop(
                                        theme: theme,
                                      ),
                                      SizedBox(width: 10),
                                      Visibility(
                                        child: SubWrapper(
                                          isVisible:
                                              !SalesAuthAction()
                                                  .numberOfCartsAction(
                                                    context:
                                                        context,
                                                  ),
                                          mainWidget: Material(
                                            color:
                                                Colors
                                                    .transparent,
                                            child: Ink(
                                              decoration: BoxDecoration(
                                                color:
                                                    theme
                                                        .lightModeColor
                                                        .prColor300,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      5,
                                                    ),
                                              ),
                                              child: InkWell(
                                                mouseCursor:
                                                    SystemMouseCursors
                                                        .click,
                                                onTap: () {
                                                  returnSalesProvider().addNewCart(
                                                    context,
                                                    TempCart(
                                                      tempCartItems:
                                                          null,
                                                      timeOfDay:
                                                          null,
                                                      comment:
                                                          null,
                                                      hasPrintedDocket:
                                                          false,
                                                      subStaffName:
                                                          null,
                                                      customDate:
                                                          null,
                                                      departmentName:
                                                          null,
                                                      departmentUuid:
                                                          null,
                                                      staffId:
                                                          currentUser().userId,
                                                      staffName:
                                                          "${currentUser().name} ${currentUser().lastName}",
                                                      cartItems:
                                                          [],
                                                      cartItemTypeIndex:
                                                          1,
                                                      orderUuidEdit:
                                                          null,
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                      EdgeInsets.all(
                                                        4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    color:
                                                        Colors.white,
                                                    size:
                                                        15,
                                                    Icons
                                                        .add,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SubStaffSelectionWidget(),
                                SizedBox(height: 10),
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
                                                        theme.mobileTexts.b4.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    // fontWeight: FontWeight.bold,
                                                  ),
                                                  ' (${returnSalesProviderContext(context).currentCart().discount}%)',
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
                                            // fontWeight: FontWeight.bold,
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
                                Visibility(
                                  visible:
                                      GeneralSettingsAuthAction()
                                          .manageCustomersAccountAndPoints(
                                            context: null,
                                          ) &&
                                      shop(
                                            context,
                                          )?.manageCustomerReward ==
                                          true &&
                                      currentCart(
                                            context:
                                                context,
                                          ).selectedCustomer !=
                                          null &&
                                      currentCart(
                                            context:
                                                context,
                                          ).cartItemTypeIndex !=
                                          3,
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
                                                'Cashback:',
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
                                                ' (${returnShopProvider().userShop()?.customerPercentageReward ?? 0}%)',
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
                                            formatMoney(
                                              returnSalesProviderContext(
                                                context,
                                              ).calcCashBackReward(),
                                              context,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
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
                                      formatMoneyBig(
                                        amount:
                                            returnSalesProviderContext(
                                              context,
                                            ).calcFinalTotal(),
                                        context: context,
                                      ),
                                    ),
                                  ],
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
                                      if (returnSalesProvider()
                                              .currentCart()
                                              .cartItemTypeIndex ==
                                          4) {
                                        saveDraftAction(
                                          context,
                                        );
                                        return;
                                      }
                                      BuildContext
                                      safeContext = context;
                                      if ((returnSalesProvider()
                                                      .currentCart()
                                                      .cartItemTypeIndex ==
                                                  2 ||
                                              returnSalesProvider()
                                                      .currentCart()
                                                      .cartItemTypeIndex ==
                                                  3) &&
                                          returnSalesProvider()
                                                  .currentCart()
                                                  .selectedCustomerName ==
                                              null) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return InfoAlert(
                                              theme: theme,
                                              message:
                                                  'You need to select a Customer before you can create an invoice.',
                                              title:
                                                  'Customer not Set',
                                            );
                                          },
                                        );
                                      } else if (_paymentError() !=
                                          null) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            erroContext,
                                          ) {
                                            return InfoAlert(
                                              theme: theme,
                                              message:
                                                  _paymentError()!,
                                              title:
                                                  'Check Payment',
                                            );
                                          },
                                        );
                                      } else if (returnSalesProvider()
                                              .checkoutStockConflict() !=
                                          null) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            errorContext,
                                          ) {
                                            return InfoAlert(
                                              theme: theme,
                                              message:
                                                  returnSalesProvider()
                                                      .checkoutStockConflict()!,
                                              title:
                                                  'Not Enough Stock',
                                            );
                                          },
                                        );
                                      } else {
                                        showDialog(
                                          context:
                                              safeContext,
                                          builder: (_) {
                                            return ConfirmationAlert(
                                              theme: theme,
                                              message:
                                                  returnSalesProvider().currentCart().invoiceUuidEdit !=
                                                          null
                                                      ? "You are about to update this Invoice, are you sure you want to Proceed?"
                                                      : returnSalesProvider().currentCart().orderUuidEdit !=
                                                          null
                                                      ? "You are about to update this Order, are you sure you want to Proceed?"
                                                      : returnSalesProvider()
                                                          .currentCart()
                                                          .isReceiptEdit
                                                      ? "You are about to update this sales Receipt, are you sure you want to Proceed?"
                                                      : returnSalesProvider().currentCart().cartItemTypeIndex ==
                                                          2
                                                      ? 'You are about to record a Sale on Credit, are you sure you want to proceed?'
                                                      : 'You are about to record a Sale, are you sure you want to proceed?',
                                              title:
                                                  returnSalesProvider().currentCart().invoiceUuidEdit !=
                                                          null
                                                      ? 'Update Invoice?'
                                                      : returnSalesProvider().currentCart().orderUuidEdit !=
                                                          null
                                                      ? 'Update Order?'
                                                      : returnSalesProvider()
                                                          .currentCart()
                                                          .isReceiptEdit
                                                      ? 'Update Receipt?'
                                                      : returnSalesProvider().currentCart().cartItemTypeIndex ==
                                                          2
                                                      ? 'Sell on Credit?'
                                                      : 'Are you sure?',
                                              action: () async {
                                                setState(() {
                                                  isLoading =
                                                      true;
                                                });
                                                if (safeContext
                                                    .mounted) {
                                                  Navigator.of(
                                                    safeContext,
                                                  ).pop();
                                                }
                                                returnSalesProvider().setComment(
                                                  comment:
                                                      commentController
                                                          .text,
                                                );
                                                // Captured before checkout clears the cart.
                                                final draftUuid =
                                                    returnSalesProvider()
                                                        .currentCart()
                                                        .draftUuid;
                                                var res = await returnSalesProvider().checkoutMain(
                                                  payments:
                                                      _resolvePayments(),
                                                  context:
                                                      context,
                                                  salesCartItem:
                                                      returnSalesProvider()
                                                          .currentCart(),
                                                  shopId:
                                                      returnShopProvider()
                                                          .userShop()!
                                                          .shopId!,
                                                  partPayment: double.tryParse(
                                                    widget
                                                        .partPaymentController
                                                        .text
                                                        .replaceAll(
                                                          ',',
                                                          '',
                                                        ),
                                                  ),
                                                );
                                                if (res !=
                                                    null) {
                                                  await returnDraftsProvider()
                                                      .completeDraft(
                                                        draftUuid,
                                                      );
                                                }
                                                setState(() {
                                                  isLoading =
                                                      false;
                                                  showSuccess =
                                                      true;
                                                });

                                                await Future.delayed(
                                                  Duration(
                                                    seconds:
                                                        3,
                                                  ),
                                                  () {},
                                                );
                                                if (context
                                                    .mounted) {
                                                  if (res ==
                                                      null) {
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
                                                      (
                                                        route,
                                                      ) =>
                                                          false,
                                                    );
                                                  }
                                                }
                                                setState(() {
                                                  showSuccess =
                                                      false;
                                                });
                                              },
                                            );
                                          },
                                        );
                                      }
                                    },
                                    text:
                                        currentCart(
                                                  context:
                                                      context,
                                                ).cartItemTypeIndex ==
                                                4
                                            ? 'Save Draft'
                                            : returnSalesProviderContext(
                                                      context,
                                                    )
                                                    .currentCart()
                                                    .invoiceUuidEdit !=
                                                null
                                            ? 'Update Invoice'
                                            : returnSalesProviderContext(
                                                      context,
                                                    )
                                                    .currentCart()
                                                    .orderUuidEdit !=
                                                null
                                            ? 'Update Order'
                                            : returnSalesProviderContext(
                                                  context,
                                                )
                                                .currentCart()
                                                .isReceiptEdit
                                            ? 'Update Receipt'
                                            : 'Check Out',
                                  ),
                                ),
                                SizedBox(height: 10),
                                Column(
                                  spacing: 10,
                                  children: [
                                    ItemCommentWidget(
                                      commentController:
                                          commentController,
                                      onTapOutside: (
                                        pointerDownEvent,
                                      ) {
                                        returnSalesProvider()
                                            .setComment(
                                              comment:
                                                  commentController
                                                      .text,
                                            );
                                      },
                                    ),
                                    Row(
                                      spacing: 5,
                                      children: [
                                        Expanded(
                                          child: PrintSalesCommentButton(
                                            title:
                                                'Print Sticker',
                                            widget: CustomLabelPrintWidget(
                                              mainText:
                                                  commentController
                                                          .text
                                                          .isNotEmpty
                                                      ? commentController
                                                          .text
                                                          .trim()
                                                      : null,
                                            ),
                                          ),
                                        ),

                                        Expanded(
                                          child: PrintSalesCommentButton(
                                            title:
                                                'Print Comment',
                                            widget: CustomReceiptPrintWidget(
                                              mainText:
                                                  commentController
                                                          .text
                                                          .isNotEmpty
                                                      ? commentController
                                                          .text
                                                          .trim()
                                                      : null,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ),
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
      ),
    );
  }
}

class PrintSalesCommentButton extends StatelessWidget {
  final String title;
  final Widget widget;
  const PrintSalesCommentButton({
    super.key,
    required this.title,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: Colors.grey.shade200,
        ),
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (firstContext) {
                return DialogTemplate(
                  theme: theme,
                  message: 'message',
                  title: 'title',
                  action: () {},
                  showTopSection: false,
                  showBottomActionButtons: false,
                  widget: SizedBox(
                    height: screenHeight(context) - 200,
                    child: widget,
                  ),
                );
              },
            );
          },
          mouseCursor: SystemMouseCursors.click,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 10,
            ),
            child: Center(
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
      ),
    );
  }
}
