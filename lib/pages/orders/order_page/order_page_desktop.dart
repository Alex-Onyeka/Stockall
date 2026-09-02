import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/orders/invoice_list/order_list_page.dart';
import 'package:stockall/pages/orders/order_page/components/order_item_deliver_list_widget.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/services/auth_service.dart';

class OrderPageDesktop extends StatefulWidget {
  final CheckoutResponse checkoutResponse;
  const OrderPageDesktop({
    super.key,
    required this.checkoutResponse,
  });

  @override
  State<OrderPageDesktop> createState() =>
      _OrderPageDesktopState();
}

class _OrderPageDesktopState
    extends State<OrderPageDesktop> {
  bool isLoading = false;
  bool isDeleteLoading = false;
  bool isPrintLoading = false;
  bool isDownloadLoading = false;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);

    Orders? order = returnOrdersProvider().orders
        .firstWhere(
          (inv) =>
              inv.uuid ==
              widget.checkoutResponse.order?.uuid,
          orElse: () {
            return Orders(
              fixedDiscount: null,
              updatedAt: DateTime.now(),
              vat: 0,
              originalCost: 0,
              generalDiscount: 0,
              subStaffUuid: '',
              orderItems: [],
              comment: null,
              subStaffName: null,
              departmentName:
                  returnDepartmentProvider()
                      .currentDepartment()
                      ?.name,
              departmentUuid:
                  returnDepartmentProvider()
                      .currentDepartment()
                      ?.uuid,
              createdAt: DateTime.now(),
              uuid: '1',
              shopId: shopId(),
              staffId: AuthService().currentUser!,
              staffName: 'Staff Name',
              balance: 0,
              barcode: '',
              customerName: 'Customer Name',
              cartName: 'Cart 1',
            );
          },
        );

    List<OrderItems> orderItems = order.orderItems;

    String? customer;
    TempCustomersClass? customersClass;

    var customers = returnCustomers(context)
        .customersMain()
        .where((c) => c.uuid == order.customerId);
    if (customers.isNotEmpty) {
      customersClass = customers.first;
    } else {
      customer = order.customerName;
    }
    // getSalesRecords();
    return Builder(
      builder: (context) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(
            255,
            253,
            254,
            255,
          ),
          body: Column(
            spacing: 15,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  spacing: 10,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        InkWell(
                          mouseCursor:
                              SystemMouseCursors.click,
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return BasePage();
                                  },
                                ),
                              );
                            }
                          },
                          borderRadius:
                              BorderRadius.circular(30),
                          child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              size: 18,
                              color: Colors.grey.shade700,
                              Icons
                                  .arrow_back_ios_new_outlined,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          spacing: 5,
                          children: [
                            Row(
                              spacing: 2,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                  ),
                                  'Order',
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  "[ #${order.barcode ?? returnOnlyDigits(order.uuid ?? '')} ]",
                                ),
                              ],
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              customersClass?.name ??
                                  customer ??
                                  'Customer Name',
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        // ActionButtonSmall(
                        //   action: () {
                        //     setState(() {});
                        //   },
                        //   text: 'Refresh',
                        // ),
                        ActionButtonSmall(
                          isLoading: isPrintLoading,
                          action: () {
                            showDialog(
                              context: context,
                              builder: (confirmDialog) {
                                return ConfirmationAlert(
                                  theme: theme,
                                  message:
                                      'You are about to Print This Order. Are you sure you want to Proceed?',
                                  title: 'Print Order',
                                  action: () async {
                                    setState(() {
                                      isPrintLoading = true;
                                    });
                                    Navigator.of(
                                      confirmDialog,
                                    ).pop();
                                    if (kIsWeb) {
                                      // downloadPdfWebRollOrder(
                                      //   order: order,
                                      //   staffName:
                                      //       order.staffName,
                                      //   filename:
                                      //       'Stockall_Order_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                      //   context: context,
                                      //   receipts:
                                      //       returnReceiptProviderSingle()
                                      //           .returnOwnReceiptsByDayOrWeek()
                                      //           .where(
                                      //             (rec) =>
                                      //                 rec.orderUuid ==
                                      //                 widget
                                      //                     .checkoutResponse
                                      //                     .order
                                      //                     ?.uuid,
                                      //           )
                                      //           .toList(),
                                      //   records: orderItems,
                                      //   shop:
                                      //       returnShopProvider()
                                      //           .userShop()!,
                                      //   printType:
                                      //       returnShopProvider()
                                      //           .userShop()!
                                      //           .printType!,
                                      // );
                                    } else {
                                      // await generateAndPreviewPdfRollOrder(
                                      //   order: order,
                                      //   printerType:
                                      //       returnShopProvider()
                                      //           .userShop()!
                                      //           .printType ??
                                      //       1,
                                      //   staffName:
                                      //       order.staffName,
                                      //   context: context,
                                      //   receipts:
                                      //       returnReceiptProviderSingle()
                                      //           .returnOwnReceiptsByDayOrWeek()
                                      //           .where(
                                      //             (rec) =>
                                      //                 rec.orderUuid ==
                                      //                 widget
                                      //                     .checkoutResponse
                                      //                     .order
                                      //                     ?.uuid,
                                      //           )
                                      //           .toList(),
                                      //   records: orderItems,

                                      //   shop:
                                      //       returnShopProvider()
                                      //           .userShop()!,
                                      // );
                                    }
                                    setState(() {
                                      isPrintLoading =
                                          false;
                                    });
                                  },
                                );
                              },
                            );
                          },
                          text: 'Print',
                        ),
                        ActionButtonSmall(
                          isLoading: isDownloadLoading,
                          action: () {
                            SalesAuthAction().downloadReceiptAction(
                              context: context,
                              action: () async {
                                // var safeContext = context;

                                showDialog(
                                  context: context,
                                  builder: (confirmDialog) {
                                    return ConfirmationAlert(
                                      theme: theme,
                                      message:
                                          'You are about to download This Order. Are you sure you want to Proceed?',
                                      title:
                                          'Download Order',
                                      action: () async {
                                        setState(() {
                                          isDownloadLoading =
                                              true;
                                        });
                                        Navigator.of(
                                          confirmDialog,
                                        ).pop();
                                        if (kIsWeb) {
                                          // downloadPdfWebOrder(
                                          //   order: order,
                                          //   staffName:
                                          //       order
                                          //           .staffName,
                                          //   filename:
                                          //       'Stockall_Order_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                          //   context:
                                          //       context,
                                          //   receipts:
                                          //       returnReceiptProviderSingle()
                                          //           .returnOwnReceiptsByDayOrWeek()
                                          //           .where(
                                          //             (
                                          //               rec,
                                          //             ) =>
                                          //                 rec.orderUuid ==
                                          //                 widget.checkoutResponse.order?.uuid,
                                          //           )
                                          //           .toList(),
                                          //   records:
                                          //       orderItems,
                                          // );
                                        }
                                        if (!kIsWeb) {
                                          // await generateAndPreviewPdfOrder(
                                          //   order: order,
                                          //   staffName:
                                          //       order
                                          //           .staffName,
                                          //   context:
                                          //       context,
                                          //   receipts:
                                          //       returnReceiptProviderSingle()
                                          //           .returnOwnReceiptsByDayOrWeek()
                                          //           .where(
                                          //             (
                                          //               rec,
                                          //             ) =>
                                          //                 rec.orderUuid ==
                                          //                 widget.checkoutResponse.order?.uuid,
                                          //           )
                                          //           .toList(),
                                          //   records:
                                          //       orderItems,
                                          // );
                                        }
                                        await Future.delayed(
                                          Duration(
                                            seconds: 1,
                                          ),
                                        );
                                        if (context
                                            .mounted) {
                                          actionResultDialog(
                                            context:
                                                context,
                                            message:
                                                'Order Downloaded',
                                            isSuccess: true,
                                          );
                                        }
                                        setState(() {
                                          isDownloadLoading =
                                              false;
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                          text: 'Download',
                        ),
                        Visibility(
                          visible:
                              returnReceiptProvider(context)
                                  .returnOwnReceiptsByDayOrWeek()
                                  .where(
                                    (rec) =>
                                        rec.orderUuid ==
                                        widget
                                            .checkoutResponse
                                            .order
                                            ?.uuid,
                                  )
                                  .isEmpty &&
                              authorization(
                                authorized:
                                    Authorizations()
                                        .updateOrders,
                              ),
                          child: ActionButtonSmall(
                            action: () {
                              showDialog(
                                context: context,
                                builder: (confirmDialog) {
                                  return ConfirmationAlert(
                                    theme: theme,
                                    message:
                                        'You are about to edit this Order. Are you sure you want to proceed?',
                                    title: 'Edit Order',
                                    action: () {
                                      Navigator.of(
                                        confirmDialog,
                                      ).pop();
                                      returnOrdersProvider()
                                          .onEditOrder(
                                            order: order,
                                            context:
                                                context,
                                          );
                                    },
                                  );
                                },
                              );
                            },
                            text: 'Edit',
                          ),
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations()
                                    .deleteOrders,
                          ),
                          child: ActionButtonSmall(
                            isLoading: isDeleteLoading,
                            action: () {
                              showDialog(
                                context: context,
                                builder: (confirmDialog) {
                                  return ConfirmationAlert(
                                    theme: theme,
                                    message:
                                        'You are about to delete this Order, are you sure you want to proceed?',
                                    title: 'Delete Order?',
                                    action: () async {
                                      Navigator.of(
                                        confirmDialog,
                                      ).pop();
                                      setState(() {
                                        isDeleteLoading =
                                            true;
                                      });
                                      var res = await returnOrdersProvider()
                                          .deleteOrder(
                                            order,
                                            orderItems
                                                    .isNotEmpty
                                                ? orderItems
                                                    .map(
                                                      (
                                                        rec,
                                                      ) =>
                                                          rec.productName,
                                                    )
                                                    .toList()
                                                : [],
                                          );
                                      await actionResultDialog(
                                        // ignore: use_build_context_synchronously
                                        context: context,
                                        message:
                                            res == 1
                                                ? 'Deleted Successfully'
                                                : 'Failed',
                                        isSuccess:
                                            res == 1
                                                ? true
                                                : false,
                                      );
                                      setState(() {
                                        isDeleteLoading =
                                            false;
                                      });
                                      if (res == 1 &&
                                          context.mounted) {
                                        if (Navigator.of(
                                          context,
                                        ).canPop()) {
                                          Navigator.of(
                                            context,
                                          ).pop();
                                        } else {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return OrderListPage();
                                              },
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  );
                                },
                              );
                            },
                            text: 'Delete',
                            textColor: Colors.red.shade300,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        spacing: 20,
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      Colors.grey.shade100,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                      3,
                                    ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(
                                          10,
                                          0,
                                          0,
                                          0,
                                        ),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                                color: Colors.white,
                              ),
                              child: Column(
                                spacing: 5,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    spacing: 5,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          spacing: 5,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Cashier:',
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .normal,
                                              ),
                                              order.staffName ??
                                                  'Not Set',
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          spacing: 5,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Date:',
                                            ),
                                            Row(
                                              spacing: 5,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b3.fontSize,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    "${formatDateTime(order.createdAt)}  |  ${formatTime(order.createdAt)}",
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color:
                                        Colors
                                            .grey
                                            .shade200,
                                    height: 50,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    spacing: 10,
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b3
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          'Items',
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b3
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          'Price',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color:
                                        Colors
                                            .grey
                                            .shade400,
                                    height: 5,
                                  ),
                                  Column(
                                    children:
                                        orderItems
                                            .map(
                                              (
                                                record,
                                              ) => Container(
                                                margin:
                                                    EdgeInsets.symmetric(
                                                      vertical:
                                                          4,
                                                    ),
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                      15.0,
                                                      10.0,
                                                      15.0,
                                                      10.0,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade100,
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  spacing:
                                                      10,
                                                  children: [
                                                    Expanded(
                                                      flex:
                                                          10,
                                                      child: Column(
                                                        spacing:
                                                            2,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b3.fontSize,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                            record.productName,
                                                          ),
                                                          Row(
                                                            spacing:
                                                                8,
                                                            children: [
                                                              Row(
                                                                spacing:
                                                                    3,
                                                                children: [
                                                                  Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          theme.mobileTexts.b4.fontSize,
                                                                      fontWeight:
                                                                          FontWeight.normal,
                                                                    ),
                                                                    'Original Qtty: ',
                                                                  ),
                                                                  Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          theme.mobileTexts.b3.fontSize,
                                                                      fontWeight:
                                                                          FontWeight.bold,
                                                                    ),
                                                                    formatLargeNumberDouble(
                                                                      record.quantity,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Visibility(
                                                                visible:
                                                                    (record.quantity >
                                                                        (record.remainingQuantity ??
                                                                            0)),
                                                                child: Row(
                                                                  spacing:
                                                                      3,
                                                                  children: [
                                                                    Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b4.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                      ),
                                                                      '|    Remaining Qtty: ',
                                                                    ),
                                                                    Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b3.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                      formatLargeNumberDouble(
                                                                        record.remainingQuantity ??
                                                                            0,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex:
                                                          5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b3.fontSize,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                            formatMoneyBig(
                                                              amount:
                                                                  (order.fixedDiscount ==
                                                                                  null &&
                                                                              order.generalDiscount ==
                                                                                  null) &&
                                                                          record.discount !=
                                                                              null
                                                                      ? ((record.originalCost ??
                                                                              0) -
                                                                          (record.discountedAmount ??
                                                                              0))
                                                                      : (record.originalCost ??
                                                                          0),
                                                              context:
                                                                  context,
                                                            ),
                                                          ),
                                                          Visibility(
                                                            visible:
                                                                record.discount !=
                                                                    null &&
                                                                !record.customPriceSet &&
                                                                (order.fixedDiscount ==
                                                                        null &&
                                                                    order.generalDiscount ==
                                                                        null),
                                                            child: Text(
                                                              style: TextStyle(
                                                                decoration:
                                                                    TextDecoration.lineThrough,
                                                                fontSize:
                                                                    theme.mobileTexts.b4.fontSize,
                                                                fontWeight:
                                                                    FontWeight.normal,
                                                              ),
                                                              formatMoneyMid(
                                                                amount:
                                                                    record.originalCost!,
                                                                context:
                                                                    context,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                  SizedBox(height: 15),
                                  Divider(
                                    color:
                                        Colors
                                            .grey
                                            .shade400,
                                    height: 5,
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .end,
                                    children: [
                                      SizedBox(
                                        width: 240,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          spacing: 3,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .end,
                                              spacing: 20,
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    'Subtotal:',
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    formatMoneyBig(
                                                      amount:
                                                          order.originalCost ??
                                                          0,
                                                      context:
                                                          context,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Visibility(
                                              visible:
                                                  order
                                                      .vat !=
                                                  null,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .end,
                                                spacing: 20,
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b4.fontSize,
                                                            fontWeight:
                                                                FontWeight.normal,
                                                          ),
                                                          'VAT: ',
                                                        ),
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b4.fontSize,
                                                            fontWeight:
                                                                FontWeight.normal,
                                                          ),
                                                          '[ ${order.vat ?? 0}% ]',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b4.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      formatMoneyBig(
                                                        amount: returnOrdersProvider().getVATForOrder(
                                                          order,
                                                        ),
                                                        context:
                                                            context,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  order.fixedDiscount !=
                                                      null ||
                                                  order.generalDiscount !=
                                                      null,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .end,
                                                spacing: 20,
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b4.fontSize,
                                                            fontWeight:
                                                                FontWeight.normal,
                                                          ),
                                                          'Discount: ',
                                                        ),
                                                        Visibility(
                                                          visible:
                                                              order.generalDiscount !=
                                                              null,
                                                          child: Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b4.fontSize,
                                                              fontWeight:
                                                                  FontWeight.normal,
                                                            ),
                                                            '[ ${order.generalDiscount}% ]',
                                                          ),
                                                        ),
                                                        // Visibility(
                                                        //   visible:
                                                        //       order.fixedDiscount !=
                                                        //       null,
                                                        //   child: Text(
                                                        //     style: TextStyle(
                                                        //       fontSize:
                                                        //           theme.mobileTexts.b4.fontSize,
                                                        //       fontWeight:
                                                        //           FontWeight.normal,
                                                        //     ),
                                                        //     '[ ${order.fixedDiscount} ]',
                                                        //   ),
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b4.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      formatMoneyBig(
                                                        amount: returnOrdersProvider().getDiscountAmountForOrder(
                                                          order,
                                                        ),
                                                        context:
                                                            context,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Divider(
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade200,
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .end,
                                              spacing: 20,
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b3.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    'Total:',
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b2.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    formatMoneyBig(
                                                      amount: returnOrdersProvider().getTotalMainRevenueOrder(
                                                        order:
                                                            order,
                                                      ),
                                                      context:
                                                          context,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 300,
                            padding: EdgeInsets.symmetric(
                              // horizontal: 20,
                              vertical: 10,
                            ),
                            child: Column(
                              spacing: 5,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(
                                    15,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(
                                          5,
                                        ),
                                    border: Border.all(
                                      color:
                                          const Color.fromARGB(
                                            118,
                                            134,
                                            155,
                                            173,
                                          ),
                                    ),
                                    color:
                                        const Color.fromARGB(
                                          31,
                                          173,
                                          182,
                                          209,
                                        ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        50,
                                                    child: Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b4.fontSize,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        // color:
                                                        //     Colors
                                                        //         .green,
                                                      ),
                                                      'Amount:',
                                                    ),
                                                  ),
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      // color:
                                                      //     Colors
                                                      //         .green,
                                                    ),
                                                    formatMoneyMid(
                                                      amount: returnOrdersProvider().getTotalMainRevenueOrder(
                                                        order:
                                                            order,
                                                      ),
                                                      context:
                                                          context,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        50,
                                                    child: Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b4.fontSize,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        // color:
                                                        //     Colors
                                                        //         .green,
                                                      ),
                                                      'Paid:',
                                                    ),
                                                  ),
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      // color:
                                                      //     Colors
                                                      //         .green,
                                                    ),
                                                    formatMoneyMid(
                                                      amount: returnOrdersProvider().getAmountPaid(
                                                        order:
                                                            order,
                                                      ),
                                                      context:
                                                          context,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        50,
                                                    child: Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b4.fontSize,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        // color:
                                                        //     Colors
                                                        //         .green,
                                                      ),
                                                      'Balance:',
                                                    ),
                                                  ),
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      // color:
                                                      //     Colors
                                                      //         .green,
                                                    ),
                                                    formatMoneyMid(
                                                      amount: returnOrdersProvider().getBalance(
                                                        order:
                                                            order,
                                                      ),
                                                      context:
                                                          context,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding:
                                                EdgeInsets.symmetric(
                                                  vertical:
                                                      3,
                                                  horizontal:
                                                      10,
                                                ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    3,
                                                  ),
                                              border: Border.all(
                                                color:
                                                    returnOrdersProvider(
                                                              context:
                                                                  context,
                                                            ).getOrderStatus(
                                                              order:
                                                                  order,
                                                            ) ==
                                                            0
                                                        ? Colors.red
                                                        : returnOrdersProvider(
                                                              context:
                                                                  context,
                                                            ).getOrderStatus(
                                                              order:
                                                                  order,
                                                            ) ==
                                                            1
                                                        ? const Color.fromARGB(
                                                          255,
                                                          255,
                                                          223,
                                                          126,
                                                        )
                                                        : Colors.green,
                                              ),
                                            ),
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
                                                color:
                                                    returnOrdersProvider(
                                                              context:
                                                                  context,
                                                            ).getOrderStatus(
                                                              order:
                                                                  order,
                                                            ) ==
                                                            0
                                                        ? Colors.red
                                                        : returnOrdersProvider(
                                                              context:
                                                                  context,
                                                            ).getOrderStatus(
                                                              order:
                                                                  order,
                                                            ) ==
                                                            1
                                                        ? const Color.fromARGB(
                                                          255,
                                                          245,
                                                          185,
                                                          6,
                                                        )
                                                        : Colors.green,
                                              ),
                                              returnOrdersProvider(
                                                        context:
                                                            context,
                                                      ).getOrderStatus(
                                                        order:
                                                            order,
                                                      ) ==
                                                      0
                                                  ? 'Unpaid'
                                                  : returnOrdersProvider(
                                                        context:
                                                            context,
                                                      ).getOrderStatus(
                                                        order:
                                                            order,
                                                      ) ==
                                                      1
                                                  ? 'Partial'
                                                  : 'Paid',
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Divider(
                                        color:
                                            Colors
                                                .grey
                                                .shade300,
                                        height: 1,
                                      ),
                                      SizedBox(height: 10),
                                      Column(
                                        spacing: 7,
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Row(
                                            spacing: 10,
                                            children: [
                                              Icon(
                                                size: 16,
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade600,
                                                Icons
                                                    .person,
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
                                                ),
                                                customersClass
                                                        ?.name ??
                                                    customer ??
                                                    'Name',
                                              ),
                                            ],
                                          ),
                                          Row(
                                            spacing: 10,
                                            children: [
                                              Icon(
                                                size: 16,
                                                color:
                                                    Colors
                                                        .grey,
                                                Icons.phone,
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
                                                          .normal,
                                                ),
                                                customersClass
                                                        ?.phone ??
                                                    'Phone Number',
                                              ),
                                            ],
                                          ),
                                          Visibility(
                                            visible:
                                                customersClass
                                                        ?.email !=
                                                    null &&
                                                customersClass
                                                        ?.email
                                                        .isEmpty ==
                                                    false,
                                            child: Row(
                                              spacing: 10,
                                              children: [
                                                Icon(
                                                  size: 16,
                                                  color:
                                                      Colors
                                                          .grey,
                                                  Icons
                                                      .email_outlined,
                                                ),
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b4.fontSize,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  customersClass
                                                          ?.email ??
                                                      'Email',
                                                ),
                                              ],
                                            ),
                                          ),
                                          Visibility(
                                            visible:
                                                order.comment !=
                                                    null &&
                                                order
                                                        .comment
                                                        ?.isNotEmpty ==
                                                    true,
                                            child: Column(
                                              spacing: 5,
                                              children: [
                                                Divider(
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade300,
                                                  height:
                                                      10,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b3.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      'Comment:',
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b4.fontSize,
                                                        ),
                                                        order.comment ??
                                                            'Comment Not Set',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 15),
                                Ink(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(
                                          2,
                                        ),

                                    gradient:
                                        theme
                                            .lightModeColor
                                            .prGradient,
                                  ),
                                  child: InkWell(
                                    mouseCursor:
                                        SystemMouseCursors
                                            .click,
                                    onTap: () {
                                      deliverItemsAction(
                                        order: order,
                                        context: context,
                                      );
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(
                                            vertical: 9,
                                            horizontal: 25,
                                          ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        children: [
                                          Builder(
                                            builder: (
                                              context,
                                            ) {
                                              if (!isLoading) {
                                                return Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b3.fontSize,
                                                    color:
                                                        Colors.white,
                                                  ),
                                                  'Deliver Items',
                                                );
                                              } else {
                                                return SizedBox(
                                                  height:
                                                      15,
                                                  width: 15,
                                                  child: CircularProgressIndicator(
                                                    color:
                                                        Colors.white,
                                                    strokeWidth:
                                                        2,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Divider(
                                  color:
                                      Colors.grey.shade200,
                                  height: 10,
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      'Payment Records',
                                    ),
                                  ],
                                ),
                                Divider(
                                  color:
                                      Colors.grey.shade200,
                                  height: 10,
                                ),
                                Builder(
                                  builder: (context) {
                                    if (returnReceiptProvider(
                                          context,
                                        ).receipts
                                        .where(
                                          (rec) =>
                                              rec.orderUuid ==
                                              widget
                                                  .checkoutResponse
                                                  .order
                                                  ?.uuid,
                                        )
                                        .isEmpty) {
                                      return SizedBox(
                                        height: 100,
                                        child: Center(
                                          child: Column(
                                            spacing: 5,
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                            children: [
                                              Container(
                                                padding:
                                                    EdgeInsets.all(
                                                      15,
                                                    ),
                                                decoration: BoxDecoration(
                                                  shape:
                                                      BoxShape
                                                          .circle,
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade100,
                                                ),
                                                child: Icon(
                                                  Icons
                                                      .clear,
                                                  color:
                                                      Colors
                                                          .grey,
                                                ),
                                              ),
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      10,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade600,
                                                ),
                                                'No Records Found',
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return Column(
                                      spacing: 4,
                                      children:
                                          returnReceiptProvider(
                                                context,
                                              ).receipts
                                              .where(
                                                (rec) =>
                                                    rec.orderUuid ==
                                                    widget
                                                        .checkoutResponse
                                                        .order
                                                        ?.uuid,
                                              )
                                              .map(
                                                (
                                                  receipt,
                                                ) => InkWell(
                                                  mouseCursor:
                                                      SystemMouseCursors
                                                          .click,
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (
                                                          context,
                                                        ) {
                                                          return ReceiptPage(
                                                            response: CheckoutResponse(
                                                              receipt:
                                                                  receipt,
                                                            ),
                                                            isMain:
                                                                false,
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsetsGeometry.symmetric(
                                                      vertical:
                                                          5,
                                                      horizontal:
                                                          10,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                      spacing:
                                                          5,
                                                      children: [
                                                        Expanded(
                                                          child: Row(
                                                            spacing:
                                                                2,
                                                            children: [
                                                              RotatedBox(
                                                                quarterTurns:
                                                                    90,
                                                                child: Icon(
                                                                  size:
                                                                      30,
                                                                  Icons.arrow_left_rounded,
                                                                ),
                                                              ),
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b3.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                                formatMoneyBig(
                                                                  amount: returnReceiptProvider(
                                                                    context,
                                                                  ).getTotalMainRevenueReceipt(
                                                                    receipt,
                                                                  ),
                                                                  context:
                                                                      context,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b4.fontSize,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          formatDateTime(
                                                            receipt.createdAt,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> actionResultDialog({
    required BuildContext context,
    required String message,
    required bool isSuccess,
  }) async {
    await showDialog(
      barrierDismissible: false,
      // ignore: use_build_context_synchronously
      context: context,
      builder: (dialogContext) {
        Future.delayed(const Duration(seconds: 3), () {
          if (dialogContext.mounted) {
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
          }
        });

        return AlertDialog(
          backgroundColor: Colors.white,
          content: Container(
            height: 400,
            width: 400,
            color: Colors.white,
            child: Builder(
              builder: (context) {
                if (!isSuccess) {
                  return returnCompProvider(
                    context,
                    listen: false,
                  ).showError(message);
                } else {
                  return returnCompProvider(
                    context,
                    listen: false,
                  ).showSuccess(message);
                }
              },
            ),
          ),
        );
      },
    );
  }
}

void deliverItemsAction({
  required BuildContext context,
  required Orders order,
}) {
  var theme = returnTheme(context, listen: false);
  List<OrderItems> list = [];
  bool showTotal = false;

  showDialog(
    context: context,
    builder: (firstContext) {
      final commentController = TextEditingController();
      return StatefulBuilder(
        builder: (secondContext, setState) {
          return DialogTemplate(
            theme: theme,
            message:
                'Select Items to Deliver From this Order Receipt',
            title: 'Select Item(s)',
            action: () {
              showDialog(
                context: context,
                builder: (confirmContext) {
                  return ConfirmationAlert(
                    theme: theme,
                    message:
                        'You are about to Deliver the Selected Items, and Generate Payment Receipts. Are you sure you want to proceed?',
                    title: 'Record Delivery',
                    action: () async {
                      Navigator.of(confirmContext).pop();
                      if (list.isEmpty) {
                        list.addAll(order.orderItems);
                      }
                      await returnOrdersProvider()
                          .makeOrderPayment(
                            order: order,
                            orderItemsNew: list,
                            currentPayment: list
                                .map(
                                  (item) =>
                                      item.getRemainingBalance(),
                                )
                                .fold(0, (a, b) => a + b),
                            comment:
                                commentController.text
                                    .trim(),
                          );
                    },
                  );
                },
              );
            },
            widget: SizedBox(
              height: screenHeight(context) - 300,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 15,
                        ),
                        child: Column(
                          spacing: 5,
                          children:
                              order.orderItems
                                  .map(
                                    (item) =>
                                        OrderItemDeliverListWidget(
                                          action: () {
                                            setState(() {
                                              showTotal =
                                                  false;
                                            });
                                          },
                                          item: item,
                                          list: list,
                                          theme: theme,
                                        ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          'Deliver All Remaining Items',
                        ),
                        MyToggleButton(
                          boolValue: showTotal,
                          toggle: () {
                            setState(() {
                              if (showTotal == true) {
                                showTotal = false;
                                list.clear();
                              } else {
                                showTotal = true;
                                list.clear();
                                list.addAll(
                                  order.orderItems,
                                );
                              }
                            });
                          },
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ).then((_) {});
}

class ActionButtonSmall extends StatelessWidget {
  final Function()? action;
  final Color? textColor;
  final String text;
  final bool? isLoading;
  final Icon? icon;
  const ActionButtonSmall({
    super.key,
    this.textColor,
    required this.action,
    required this.text,
    this.isLoading,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: action,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: textColor ?? Colors.grey.shade200,
            ),
          ),
          child: Builder(
            builder: (context) {
              if (isLoading != null && isLoading == true) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      color:
                          theme.lightModeColor.secColor200,
                      strokeWidth: 2.5,
                    ),
                  ),
                );
              } else {
                return Row(
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      text,
                    ),
                    Visibility(
                      visible: icon != null,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 5.0,
                        ),
                        child: icon ?? Container(),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
