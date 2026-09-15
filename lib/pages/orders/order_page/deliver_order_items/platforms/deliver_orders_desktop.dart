import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/orders/order_page/components/select_order_items_bottom_sheet.dart';

class DeliverOrdersDesktop extends StatefulWidget {
  final Orders order;
  final TextEditingController searchController;
  final TextEditingController priceController;
  final TextEditingController quantityController;

  const DeliverOrdersDesktop({
    super.key,
    required this.order,
    required this.searchController,
    required this.priceController,
    required this.quantityController,
  });

  @override
  State<DeliverOrdersDesktop> createState() =>
      _DeliverOrdersDesktopState();
}

class _DeliverOrdersDesktopState
    extends State<DeliverOrdersDesktop> {
  bool isLoading = false;
  bool showSuccess = false;

  bool updateInventory = true;
  int paymentSelected = 2;

  void checkFields() async {
    if (returnOrdersActionProvider()
        .orderListItems
        .isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message:
                'No Item has been added to the List. Please add items to the list before proceeding',
            title: 'Empty List',
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (firstDialog) {
          paymentSelected = 2;
          widget.priceController.text =
              returnOrdersActionProvider()
                  .totalOrdersAmount()
                  .toString();
          return StatefulBuilder(
            builder:
                (newContext, setStatee) => DialogTemplate(
                  theme: returnTheme(context),
                  message:
                      "Click on the button below to confirm to create order.",
                  title: "Proceed with action",
                  action: () async {
                    showDialog(
                      context: context,
                      builder: (confirmDialog) {
                        return ConfirmationAlert(
                          theme: returnTheme(
                            context,
                            listen: false,
                          ),
                          message:
                              'You are about to record a order and update the items, are you sure you want to proceed?',
                          title: 'Proceed With Action',
                          action: () async {
                            Navigator.of(firstDialog).pop();
                            Navigator.of(
                              confirmDialog,
                            ).pop();

                            setState(() {
                              isLoading = true;
                            });

                            var res = 1;

                            setState(() {
                              isLoading = false;
                            });
                            if (res == 0) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return InfoAlert(
                                    theme: returnTheme(
                                      context,
                                      listen: false,
                                    ),
                                    message:
                                        'An Error Occoured while Creating this order. Please try again later.',
                                    title:
                                        'An Error Occoured',
                                  );
                                },
                              );
                              return;
                            }
                            setState(() {
                              showSuccess = true;
                            });

                            Future.delayed(
                              Duration(seconds: 2),
                              () {
                                if (context.mounted) {
                                  Navigator.of(
                                    context,
                                  ).pop();
                                }
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                  widget: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 5,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        spacing: 4,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  returnTheme(
                                    context,
                                    listen: false,
                                  ).mobileTexts.b3.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            'Make Payment',
                          ),
                          Row(
                            spacing: 5,
                            children: [
                              InkWell(
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                onTap: () {
                                  setStatee(() {
                                    paymentSelected = 1;
                                    widget.priceController
                                        .clear();
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(
                                        4,
                                      ),
                                  child: Row(
                                    spacing: 4,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              returnTheme(
                                                    context,
                                                    listen:
                                                        false,
                                                  )
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                          fontWeight:
                                              paymentSelected ==
                                                      1
                                                  ? FontWeight
                                                      .bold
                                                  : null,
                                        ),
                                        'Part',
                                      ),
                                      Container(
                                        padding:
                                            EdgeInsets.all(
                                              2,
                                            ),
                                        decoration: BoxDecoration(
                                          shape:
                                              BoxShape
                                                  .circle,
                                          border: Border.all(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade400,
                                          ),
                                        ),
                                        child: Container(
                                          padding:
                                              EdgeInsets.all(
                                                3.5,
                                              ),
                                          decoration: BoxDecoration(
                                            shape:
                                                BoxShape
                                                    .circle,
                                            color:
                                                paymentSelected ==
                                                        1
                                                    ? returnTheme(
                                                      context,
                                                      listen:
                                                          false,
                                                    ).lightModeColor.prColor250
                                                    : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                onTap: () {
                                  setStatee(() {
                                    paymentSelected = 2;
                                    widget
                                            .priceController
                                            .text =
                                        returnOrdersActionProvider()
                                            .totalOrdersAmount()
                                            .toString();
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(
                                        6,
                                      ),
                                  child: Row(
                                    spacing: 4,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              returnTheme(
                                                    context,
                                                    listen:
                                                        false,
                                                  )
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                          fontWeight:
                                              paymentSelected ==
                                                      2
                                                  ? FontWeight
                                                      .bold
                                                  : null,
                                        ),
                                        'Full',
                                      ),
                                      Container(
                                        padding:
                                            EdgeInsets.all(
                                              2,
                                            ),
                                        decoration: BoxDecoration(
                                          shape:
                                              BoxShape
                                                  .circle,
                                          border: Border.all(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade400,
                                          ),
                                        ),
                                        child: Container(
                                          padding:
                                              EdgeInsets.all(
                                                3.5,
                                              ),
                                          decoration: BoxDecoration(
                                            shape:
                                                BoxShape
                                                    .circle,
                                            color:
                                                paymentSelected ==
                                                        2
                                                    ? returnTheme(
                                                      context,
                                                      listen:
                                                          false,
                                                    ).lightModeColor.prColor250
                                                    : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      MoneyTextfield(
                        onChanged: (value) {
                          if ((double.tryParse(
                                    value.replaceAll(
                                      ',',
                                      '',
                                    ),
                                  ) ??
                                  0) <
                              returnOrdersActionProvider()
                                  .totalOrdersAmount()) {
                            setStatee(() {
                              paymentSelected = 1;
                            });
                          }
                          if ((double.tryParse(
                                    value.replaceAll(
                                      ',',
                                      '',
                                    ),
                                  ) ??
                                  0) >=
                              returnOrdersActionProvider()
                                  .totalOrdersAmount()) {
                            widget.priceController.text =
                                returnOrdersActionProvider()
                                    .totalOrdersAmount()
                                    .toStringAsFixed(0);
                            setStatee(() {
                              paymentSelected = 2;
                            });
                          }
                        },
                        showTitle: false,
                        title: 'Amount',
                        hint: 'Enter Amount',
                        controller: widget.priceController,
                        theme: returnTheme(
                          context,
                          listen: false,
                        ),
                      ),
                    ],
                  ),
                ),
          );
        },
      ).then((_) {
        widget.priceController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Stack(
        children: [
          DesktopCenterContainer(
            width: 650,
            mainWidget: Scaffold(
              appBar: AppBar(
                scrolledUnderElevation: 0,
                centerTitle: true,
                title: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.h4.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      'Select Items',
                    ),
                    SizedBox(height: 5),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                      ),
                      'Select Items From Order to Deliver',
                    ),
                  ],
                ),
                actions: [
                  InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      selectItemsForOrderDeliveryBottomSheet(
                        priceController:
                            widget.priceController,
                        quantityController:
                            widget.quantityController,
                        context: context,
                        action: () {
                          setState(() {});
                        },
                        searchController:
                            widget.searchController,
                        order: widget.order,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        8,
                        8,
                        12,
                        8,
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),
                            'Add Item',
                          ),
                          Icon(size: 16, Icons.add),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              body: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(
                                    top: 10.0,
                                  ),
                              child: Builder(
                                builder: (context) {
                                  if (returnOrdersActionProvider(
                                        context: context,
                                      )
                                      .orderListItems
                                      .isEmpty) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(
                                            top: 100.0,
                                          ),
                                      child: Center(
                                        child: EmptyWidgetDisplayOnly(
                                          title:
                                              'No Items Selected',
                                          subText:
                                              'Click on "Add Items" to Start Selecing Items For Purchase',
                                          theme: theme,
                                          height: 25,
                                          icon: Icons.clear,
                                          altAction: () {
                                            selectItemsForOrderDeliveryBottomSheet(
                                              priceController:
                                                  widget
                                                      .priceController,
                                              quantityController:
                                                  widget
                                                      .quantityController,
                                              context:
                                                  context,
                                              action: () {
                                                setState(
                                                  () {},
                                                );
                                              },
                                              searchController:
                                                  widget
                                                      .searchController,
                                              order:
                                                  widget
                                                      .order,
                                            );
                                          },
                                          altActionText:
                                              'Add Item',
                                          altIcon:
                                              Icons.add,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Column(
                                      children:
                                          returnOrdersActionProvider(
                                                context:
                                                    context,
                                              )
                                              .orderItemReversed()
                                              .map(
                                                (
                                                  item,
                                                ) => Container(
                                                  margin: EdgeInsets.symmetric(
                                                    vertical:
                                                        3,
                                                  ),
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade100,
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        10,
                                                    horizontal:
                                                        20,
                                                  ),
                                                  child: Row(
                                                    spacing:
                                                        5,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        spacing:
                                                            5,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.spaceBetween,
                                                            spacing:
                                                                5,
                                                            children: [
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b1.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                                item.productName,
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            spacing:
                                                                10,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b3.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                                '${formatLargeNumberDouble(item.quantity)} ${returnOrdersActionProvider().itemUnit(orderItem: item)}',
                                                              ),
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b2.fontSize,
                                                                  color:
                                                                      Colors.grey,
                                                                ),
                                                                '|',
                                                              ),
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b3.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                                formatMoneyBig(
                                                                  amount:
                                                                      item.revenue,
                                                                  context:
                                                                      context,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        spacing:
                                                            5,
                                                        children: [
                                                          Material(
                                                            color:
                                                                Colors.transparent,
                                                            child: InkWell(
                                                              mouseCursor:
                                                                  SystemMouseCursors.click,
                                                              onTap: () {
                                                                selectOrderItemsBottomSheet(
                                                                  priceController:
                                                                      widget.priceController,
                                                                  quantityController:
                                                                      widget.quantityController,
                                                                  context:
                                                                      context,
                                                                  orderItem:
                                                                      item,
                                                                  order:
                                                                      widget.order,
                                                                );
                                                              },
                                                              borderRadius: BorderRadius.circular(
                                                                20,
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(
                                                                  8.0,
                                                                ),
                                                                child: Icon(
                                                                  size:
                                                                      20,
                                                                  color:
                                                                      Colors.grey.shade700,
                                                                  Icons.mode_edit_outlined,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Material(
                                                            color:
                                                                Colors.transparent,
                                                            child: InkWell(
                                                              mouseCursor:
                                                                  SystemMouseCursors.click,
                                                              onTap: () {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (
                                                                    confirmContext,
                                                                  ) {
                                                                    return ConfirmationAlert(
                                                                      theme:
                                                                          theme,
                                                                      message:
                                                                          'You are about to remove this item from order list. Are you sure you want to proceed?',
                                                                      title:
                                                                          'Remove From List',
                                                                      action: () {
                                                                        returnOrdersActionProvider().addItemToList(
                                                                          item:
                                                                              item,
                                                                        );
                                                                        Navigator.of(
                                                                          context,
                                                                        ).pop();
                                                                      },
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              borderRadius: BorderRadius.circular(
                                                                20,
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(
                                                                  8.0,
                                                                ),
                                                                child: Icon(
                                                                  size:
                                                                      20,
                                                                  Icons.clear,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10.0,
                            top: 10,
                            left: 20,
                            right: 20,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.all(
                                      6.0,
                                    ),
                                child: Row(
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
                                      'Total:',
                                    ),
                                    Row(
                                      spacing: 3,
                                      children: [
                                        Material(
                                          color:
                                              Colors
                                                  .transparent,
                                          child: InkWell(
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            onTap: () {
                                              widget
                                                      .priceController
                                                      .text =
                                                  returnOrdersActionProvider()
                                                      .totalOrdersAmount()
                                                      .toString();
                                              showDialog(
                                                context:
                                                    context,
                                                builder: (
                                                  context,
                                                ) {
                                                  return DialogTemplate(
                                                    theme:
                                                        theme,
                                                    message:
                                                        'Enter a custom total Value to set.',
                                                    title:
                                                        'Set Custom Total',
                                                    action: () {
                                                      if (widget
                                                          .priceController
                                                          .text
                                                          .isNotEmpty) {
                                                        returnOrdersActionProvider().setCustomTotalAmount(
                                                          double.tryParse(
                                                                widget.priceController.text.replaceAll(
                                                                  ',',
                                                                  '',
                                                                ),
                                                              ) ??
                                                              0,
                                                        );
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      }
                                                    },
                                                    widget: MoneyTextfield(
                                                      title:
                                                          'Total',
                                                      hint:
                                                          'Enter Total',
                                                      controller:
                                                          widget.priceController,
                                                      theme:
                                                          theme,
                                                    ),
                                                  );
                                                },
                                              ).then((_) {
                                                widget
                                                    .priceController
                                                    .clear();
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                    10.0,
                                                    4,
                                                    4,
                                                    4,
                                                  ),
                                              child: Row(
                                                spacing: 5,
                                                children: [
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b1.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    formatMoneyBig(
                                                      amount:
                                                          returnOrdersActionProvider(
                                                            context:
                                                                context,
                                                          ).totalOrdersAmount(),
                                                      context:
                                                          context,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          8.0,
                                                        ),
                                                    child: Icon(
                                                      size:
                                                          20,
                                                      color:
                                                          Colors.grey.shade700,
                                                      Icons
                                                          .mode_edit_outlined,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible:
                                              returnOrdersActionProvider(
                                                context:
                                                    context,
                                              ).customTotalAmount !=
                                              null,
                                          child: Material(
                                            color:
                                                Colors
                                                    .transparent,
                                            child: InkWell(
                                              mouseCursor:
                                                  SystemMouseCursors
                                                      .click,
                                              onTap: () {
                                                showDialog(
                                                  context:
                                                      context,
                                                  builder: (
                                                    confirmContext,
                                                  ) {
                                                    return ConfirmationAlert(
                                                      theme:
                                                          theme,
                                                      message:
                                                          'You are about to cancel the custom total price, and return to the original total price. Are you sure you want to proceed?',
                                                      title:
                                                          'Reset Total Price',
                                                      action: () {
                                                        returnOrdersActionProvider().setCustomTotalAmount(
                                                          null,
                                                        );
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    20,
                                                  ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                child: Icon(
                                                  size: 20,
                                                  Icons
                                                      .clear,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              MainButtonP(
                                themeProvider: theme,
                                action: () {
                                  checkFields();
                                },
                                text: 'Create Purchase',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader(message: 'Creating Purchase'),
          ),
          Visibility(
            visible: showSuccess,
            child: returnCompProvider(
              context,
              listen: false,
            ).showSuccess('Purchase Created Successfully'),
          ),
        ],
      ),
    );
  }
}
