import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/payment_type_button.dart';
import 'package:stockall/components/cart_queue/cart_queue_desktop.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/my_calculator_desktop.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/components/item_comment_widget.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/components/project_display_widget.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/components/sub_staff_selection_widget.dart';
import 'package:stockall/pages/sales/make_sales/page2/components/customer_selection_widget.dart';
import 'package:stockall/pages/sales/make_sales/page2/components/set_custom_receipt_created_date_widget.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class MakeSalesDesktopTwo extends StatefulWidget {
  final double totalAmount;
  final TextEditingController searchController;
  final TextEditingController cashController;
  final TextEditingController bankController;
  final TextEditingController customerController;
  final TextEditingController partPaymentController;
  final TextEditingController commentController;
  const MakeSalesDesktopTwo({
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
                body: Row(
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
                                        Divider(
                                          color:
                                              Colors
                                                  .grey
                                                  .shade300,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
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
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Create Invoice (Credit Sale)',
                                            ),
                                          ],
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
                                                    FontWeight
                                                        .normal,
                                              ),
                                              'Is this Sale On Credit (Invoice?',
                                            ),
                                            InkWell(
                                              mouseCursor:
                                                  SystemMouseCursors
                                                      .click,
                                              onTap: () async {
                                                if (returnSalesProvider()
                                                        .currentCart()
                                                        .cartItemTypeIndex ==
                                                    2) {
                                                  returnSalesProvider().switchInvoiceSale(
                                                    context:
                                                        context,
                                                    value:
                                                        1,
                                                  );
                                                } else {
                                                  returnSalesProvider().switchInvoiceSale(
                                                    context:
                                                        context,
                                                    value:
                                                        2,
                                                  );
                                                }
                                                returnSalesProvider()
                                                    .changePaymentMethod(
                                                      context:
                                                          context,
                                                      index:
                                                          0,
                                                    );
                                                widget
                                                    .partPaymentController
                                                    .clear();
                                              },
                                              child: Container(
                                                width: 50,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      10,
                                                  vertical:
                                                      5,
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
                                                                ).currentCart().cartItemTypeIndex ==
                                                                2
                                                            ? theme.lightModeColor.prColor250
                                                            : Colors.grey,
                                                  ),
                                                  color:
                                                      returnSalesProviderContext(context).currentCart().cartItemTypeIndex ==
                                                              2
                                                          ? theme.lightModeColor.prColor250
                                                          : Colors.grey.shade200,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      returnSalesProviderContext(context).currentCart().cartItemTypeIndex ==
                                                              2
                                                          ? MainAxisAlignment.end
                                                          : MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(
                                                            5,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.circle,
                                                        color:
                                                            returnSalesProviderContext(
                                                                      context,
                                                                    ).currentCart().cartItemTypeIndex ==
                                                                    2
                                                                ? Colors.white
                                                                : Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Divider(
                                          color:
                                              Colors
                                                  .grey
                                                  .shade300,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),

                                        Visibility(
                                          visible:
                                              returnSalesProviderContext(
                                                    context,
                                                  )
                                                  .currentCart()
                                                  .cartItemTypeIndex ==
                                              2,
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
                                                theme:
                                                    theme,
                                                onChanged: (
                                                  value,
                                                ) {
                                                  if (value
                                                          .isNotEmpty &&
                                                      (double.tryParse(
                                                                value.replaceAll(
                                                                  ',',
                                                                  '',
                                                                ),
                                                              ) ??
                                                              0) >=
                                                          returnSalesProvider().calcFinalTotal()) {
                                                    widget
                                                        .partPaymentController
                                                        .text = '0';
                                                  }
                                                },
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Divider(
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade300,
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
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
                                                        theme.mobileTexts.b1.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  'Select Payment Method',
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            PaymentTypeButton(
                                              index: 0,
                                            ),
                                            PaymentTypeButton(
                                              index: 1,
                                            ),
                                            Visibility(
                                              visible:
                                                  GeneralSettingsAuthAction().manageCustomersAccountAndPoints(
                                                        context:
                                                            null,
                                                      ) ==
                                                      true &&
                                                  returnShopProvider()
                                                          .userShop()
                                                          ?.manageCustomerAccount ==
                                                      true &&
                                                  returnSalesProviderContext(
                                                        context,
                                                      ).currentCart().selectedCustomer !=
                                                      null,
                                              child: PaymentTypeButton(
                                                index: 3,
                                                action: () {
                                                  setState(
                                                    () {},
                                                  );
                                                },
                                              ),
                                            ),
                                            PaymentTypeButton(
                                              index: 2,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
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
                                                  MainAxisAlignment
                                                      .center,
                                              children: [
                                                Expanded(
                                                  child: EditCartTextField(
                                                    title:
                                                        'Cash',
                                                    hint:
                                                        'Cash Amount',
                                                    controller:
                                                        widget.cashController,
                                                    theme:
                                                        theme,
                                                    onChanged: (
                                                      value,
                                                    ) {
                                                      if (isUpdating)
                                                        // ignore: curly_braces_in_flow_control_structures
                                                        return;
                                                      isUpdating =
                                                          true;

                                                      double
                                                      cash =
                                                          double.tryParse(
                                                            value.replaceAll(
                                                              ',',
                                                              '',
                                                            ),
                                                          ) ??
                                                          0;
                                                      if (cash >
                                                          widget.totalAmount) {
                                                        showDialog(
                                                          context:
                                                              context,
                                                          builder: (
                                                            context,
                                                          ) {
                                                            var theme = Provider.of<
                                                              ThemeProvider
                                                            >(
                                                              context,
                                                            );
                                                            return InfoAlert(
                                                              theme:
                                                                  theme,
                                                              message:
                                                                  'Cash cannot exceed total amount.',
                                                              title:
                                                                  'Overpayment',
                                                            );
                                                          },
                                                        );
                                                        // Reset to max allowed
                                                        widget.cashController.text = widget.totalAmount.toStringAsFixed(
                                                          2,
                                                        );
                                                        widget.bankController.text =
                                                            '0.00';
                                                      } else {
                                                        double
                                                        bank =
                                                            widget.totalAmount -
                                                            cash;
                                                        widget.bankController.text = bank.toStringAsFixed(
                                                          2,
                                                        );
                                                      }

                                                      isUpdating =
                                                          false;
                                                    },
                                                  ),
                                                ),
                                                Expanded(
                                                  child: EditCartTextField(
                                                    title:
                                                        'Bank',
                                                    hint:
                                                        'Bank Amount',
                                                    controller:
                                                        widget.bankController,
                                                    theme:
                                                        theme,
                                                    onChanged: (
                                                      value,
                                                    ) {
                                                      if (isUpdating)
                                                        // ignore: curly_braces_in_flow_control_structures
                                                        return;
                                                      isUpdating =
                                                          true;

                                                      double
                                                      bank =
                                                          double.tryParse(
                                                            value.replaceAll(
                                                              ',',
                                                              '',
                                                            ),
                                                          ) ??
                                                          0;
                                                      if (bank >
                                                          widget.totalAmount) {
                                                        showDialog(
                                                          context:
                                                              context,
                                                          builder: (
                                                            context,
                                                          ) {
                                                            var theme = Provider.of<
                                                              ThemeProvider
                                                            >(
                                                              context,
                                                            );
                                                            return InfoAlert(
                                                              theme:
                                                                  theme,
                                                              message:
                                                                  'Bank cannot exceed total amount.',
                                                              title:
                                                                  'Overpayment',
                                                            );
                                                          },
                                                        );
                                                        widget.bankController.text = widget.totalAmount.toStringAsFixed(
                                                          2,
                                                        );
                                                        widget.cashController.text =
                                                            '0.00';
                                                      } else {
                                                        double
                                                        cash =
                                                            widget.totalAmount -
                                                            bank;
                                                        widget.cashController.text = cash.toStringAsFixed(
                                                          2,
                                                        );
                                                      }

                                                      isUpdating =
                                                          false;
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
                                      returnShopProvider()
                                              .userShop()
                                              ?.manageCustomerReward ==
                                          true &&
                                      returnSalesProviderContext(
                                                context,
                                              )
                                              .currentCart()
                                              .selectedCustomer !=
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
                                      BuildContext
                                      safeContext = context;
                                      if (returnSalesProvider()
                                                  .currentCart()
                                                  .cartItemTypeIndex ==
                                              2 &&
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
                                      } else if (returnSalesProvider()
                                                  .currentCart()
                                                  .paymentMethod ==
                                              3 &&
                                          !returnSalesProvider()
                                              .isBalanceSufficient()) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            erroContext,
                                          ) {
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
                                          context:
                                              safeContext,
                                          builder: (_) {
                                            return ConfirmationAlert(
                                              theme: theme,
                                              message:
                                                  returnSalesProvider()
                                                          .currentCart()
                                                          .isReceiptEdit
                                                      ? "You are about to update this sales Receipt, are you sure you want to Proceed?"
                                                      : returnSalesProvider().currentCart().cartItemTypeIndex ==
                                                          2
                                                      ? 'You are about to record a Sale on Credit, are you sure you want to proceed?'
                                                      : 'You are about to record a Sale, are you sure you want to proceed?',
                                              title:
                                                  returnSalesProvider()
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
                                                var res = await returnSalesProvider().checkoutMain(
                                                  customerBalance:
                                                      returnSalesProvider().returnPaymentMethod() ==
                                                              'Account'
                                                          ? returnSalesProvider().calcFinalTotal()
                                                          : 0,
                                                  context:
                                                      context,
                                                  salesCartItem:
                                                      returnSalesProvider()
                                                          .currentCart(),
                                                  shopId:
                                                      returnShopProvider()
                                                          .userShop()!
                                                          .shopId!,
                                                  bank:
                                                      returnSalesProvider().returnPaymentMethod() ==
                                                              'Split'
                                                          ? double.tryParse(
                                                                widget.bankController.text.replaceAll(
                                                                  ',',
                                                                  '',
                                                                ),
                                                              ) ??
                                                              0
                                                          : returnSalesProvider().returnPaymentMethod() ==
                                                              'Bank'
                                                          ? returnSalesProvider().calcFinalTotal()
                                                          : 0,
                                                  cashAlt:
                                                      returnSalesProvider().returnPaymentMethod() ==
                                                              'Split'
                                                          ? double.tryParse(
                                                                widget.cashController.text.replaceAll(
                                                                  ',',
                                                                  '',
                                                                ),
                                                              ) ??
                                                              0
                                                          : returnSalesProvider().returnPaymentMethod() ==
                                                              'Cash'
                                                          ? returnSalesProvider().calcFinalTotal()
                                                          : 0,
                                                  paymentMethod:
                                                      returnSalesProvider()
                                                          .returnPaymentMethod(),
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
