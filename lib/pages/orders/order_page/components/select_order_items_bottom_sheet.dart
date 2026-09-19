import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/small_button_main.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';

void selectOrderItemsBottomSheet({
  required Orders order,
  required TextEditingController priceController,
  required TextEditingController quantityController,
  required BuildContext context,
  required OrderItems orderItem,
}) {
  var theme = returnTheme(context, listen: false);
  bool isGroupTemp = false;

  bool originalUseGroupUnit() {
    return orderItem.getOriginalUseGroupQuantity();
  }

  bool useGroupUnit() {
    return orderItem.useGroupQuantity ?? false;
  }

  isGroupTemp = orderItem.useGroupQuantity ?? false;
  quantityController.text =
      (orderItem.remainingQuantity ?? 0).toString();

  double? originalItemQuantity() {
    var items = returnData().productListMain.where(
      (item) => item.uuid == orderItem.productUuid,
    );
    if (items.isNotEmpty) {
      var itemTemp = items.first;
      return itemTemp.quantity;
    } else {
      return null;
    }
  }

  double amount() {
    return orderItem.calcQuantity(
          quantity:
              (double.tryParse(
                    quantityController.text.replaceAll(
                      ',',
                      '',
                    ),
                  ) ??
                  0),
          useGroupTemp: isGroupTemp,
        ) *
        orderItem.revenue;
  }

  showDialog(
    context: context,
    builder: (context) {
      return GestureDetector(
        onTap:
            () =>
                FocusManager.instance.primaryFocus
                    ?.unfocus(),
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: 15,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 20,
              ),
              backgroundColor: Colors.white,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter Item Purchase Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.h4.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey.shade300),
                ],
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 450,
                      child: EditCartTextField(
                        title:
                            'Enter Item Quantity ${orderItem.getUnit(useGroupTemp: isGroupTemp)}',
                        hint: 'Quantity',
                        controller: quantityController,
                        theme: theme,
                        onChanged: (value) {
                          var itemRemainingQuantity =
                              orderItem
                                  .getActualRemainingQuantity(
                                    useGroupTemp:
                                        useGroupUnit(),
                                  );
                          var itemQttyPerGroup =
                              orderItem.qttyPerGroup ?? 1;
                          var number =
                              isGroupTemp
                                  ? (itemQttyPerGroup *
                                      (double.tryParse(
                                            value
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ) ??
                                          0))
                                  : double.tryParse(
                                        value.replaceAll(
                                          ',',
                                          '',
                                        ),
                                      ) ??
                                      0;
                          setState(() {
                            if (number >
                                itemRemainingQuantity) {
                              quantityController.text = '0';
                            }
                            if (originalItemQuantity() !=
                                    null &&
                                number >
                                    (originalItemQuantity() ??
                                        0)) {
                              showDialog(
                                context: context,
                                builder: (errorContext) {
                                  return InfoAlert(
                                    theme: theme,
                                    message:
                                        'The Quantity you are trying to Deliver Exceeds Whats Left in your Stock: ${originalItemQuantity()}',
                                    title:
                                        'Insufficient Stock',
                                  );
                                },
                              );
                              quantityController.text = '0';
                            }
                          });
                        },
                      ),
                    ),
                    Visibility(
                      visible: originalUseGroupUnit(),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  'Use Group Quantity?',
                                ),
                                MyToggleButton(
                                  boolValue: isGroupTemp,
                                  toggle: () {
                                    setState(() {
                                      isGroupTemp =
                                          !isGroupTemp;
                                    });
                                    quantityController
                                        .text = '0';
                                  },
                                  theme: theme,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                        color: Colors.grey.shade100,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                            ),
                            'Total',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                              fontWeight:
                                  theme
                                      .mobileTexts
                                      .b1
                                      .fontWeightBold,
                            ),
                            formatMoneyMid(
                              amount: amount(),
                              context: context,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      spacing: 5,
                      children: [
                        MaterialButton(
                          mouseCursor:
                              SystemMouseCursors.click,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        SmallButtonMain(
                          theme: theme,
                          action: () {
                            var itemQttyPerGroup =
                                orderItem.qttyPerGroup ?? 1;
                            var number =
                                isGroupTemp
                                    ? (itemQttyPerGroup *
                                        (double.tryParse(
                                              quantityController
                                                  .text
                                                  .replaceAll(
                                                    ',',
                                                    '',
                                                  ),
                                            ) ??
                                            0))
                                    : double.tryParse(
                                          quantityController
                                              .text
                                              .replaceAll(
                                                ',',
                                                '',
                                              ),
                                        ) ??
                                        0;
                            if (originalItemQuantity() !=
                                    null &&
                                number >
                                    (originalItemQuantity() ??
                                        0)) {
                              showDialog(
                                context: context,
                                builder: (errorContext) {
                                  return InfoAlert(
                                    theme: theme,
                                    message:
                                        'The Quantity you are trying to Deliver Exceeds Whats Left in your Stock: ${originalItemQuantity()}',
                                    title:
                                        'Insufficient Stock',
                                  );
                                },
                              );
                              return;
                            } else {
                              if ((double.tryParse(
                                        quantityController
                                            .text
                                            .replaceAll(
                                              ',',
                                              '',
                                            ),
                                      ) ??
                                      0) >
                                  0) {
                                OrderItems item =
                                    orderItem.copyWith();
                                item.useGroupQuantity =
                                    isGroupTemp;
                                item.quantity =
                                    double.tryParse(
                                      quantityController
                                          .text
                                          .replaceAll(
                                            ',',
                                            '',
                                          ),
                                    ) ??
                                    0;
                                returnOrdersActionProvider()
                                    .addItemToList(
                                      item: item,
                                    );
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          buttonText: 'Add Item',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  ).then((value) {
    quantityController.clear();
    priceController.clear();
  });
}

void selectItemsForOrderDeliveryBottomSheet({
  required BuildContext context,
  required Orders order,
  Function()? action,
  required TextEditingController searchController,
  required TextEditingController priceController,
  required TextEditingController quantityController,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.95,
        maxChildSize: 0.95,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          List<OrderItems> orderItems =
              order.orderItems.where((item) {
                if (returnOrdersActionProvider()
                    .orderListItems
                    .map((it) => it.productUuid)
                    .contains(item.productUuid)) {
                  return false;
                } else {
                  return true;
                }
              }).toList();

          return StatefulBuilder(
            builder:
                (context, setState) => Container(
                  padding: const EdgeInsets.fromLTRB(
                    30,
                    15,
                    30,
                    45,
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          height: 4,
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(5),
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            'Select Items',
                            style: TextStyle(
                              fontSize:
                                  returnTheme(
                                    context,
                                  ).mobileTexts.b1.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        spacing: 10,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 30,
                              width: 200,
                              child: GeneralTextfieldOnly(
                                onChanged: (value) {
                                  setState(() {});
                                },
                                hint: 'Search Name',
                                controller:
                                    searchController,
                                lines: 1,
                                theme: returnTheme(
                                  context,
                                  listen: false,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (firstContext) {
                                  return ConfirmationAlert(
                                    theme: returnTheme(
                                      context,
                                      listen: false,
                                    ),
                                    message:
                                        'You are about to Select All remaining items for delivery.',
                                    title:
                                        'Deliver All Items',
                                    action: () {
                                      Navigator.of(
                                        firstContext,
                                      ).pop();
                                      var res = returnOrdersActionProvider()
                                          .addAllItemsToList(
                                            items:
                                                orderItems,
                                          );
                                      if (res == 0) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              style: TextStyle(
                                                fontSize:
                                                    returnTheme(
                                                      context,
                                                      listen:
                                                          false,
                                                    ).mobileTexts.b2.fontSize,
                                              ),
                                              'Some Items Were Not Added To Cart Because Their current Stock Amount is Less than The Delivery Amount',
                                            ),
                                            behavior:
                                                SnackBarBehavior
                                                    .floating,
                                            backgroundColor:
                                                returnTheme(
                                                  context,
                                                  listen:
                                                      false,
                                                ).lightModeColor.prColor300,
                                            margin:
                                                EdgeInsets.all(
                                                  16,
                                                ),
                                            duration:
                                                const Duration(
                                                  seconds:
                                                      5,
                                                ),
                                          ),
                                        );
                                      }

                                      Navigator.of(
                                        context,
                                      ).pop();
                                    },
                                  );
                                },
                              );
                            },
                            mouseCursor:
                                SystemMouseCursors.click,
                            borderRadius:
                                BorderRadius.circular(5),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 8,
                                  ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                      3,
                                    ),
                              ),
                              child: Text(
                                'Select All',
                                style: TextStyle(
                                  fontSize:
                                      returnTheme(context)
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          IconButton(
                            mouseCursor:
                                SystemMouseCursors.click,
                            onPressed: () {
                              Navigator.of(context).pop();
                              FocusScope.of(
                                context,
                              ).unfocus();
                            },
                            icon: Icon(
                              size: 18,
                              Icons.clear,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: ListView(
                            controller: scrollController,
                            children:
                                orderItems
                                    .where(
                                      (prod) => prod
                                          .productName
                                          .toLowerCase()
                                          .contains(
                                            searchController
                                                .text
                                                .toLowerCase(),
                                          ),
                                    )
                                    .map(
                                      (pro) => Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                              vertical: 3.0,
                                            ),
                                        child: Material(
                                          color:
                                              Colors
                                                  .transparent,
                                          child: Ink(
                                            child: InkWell(
                                              mouseCursor:
                                                  SystemMouseCursors
                                                      .click,
                                              onTap: () {
                                                selectOrderItemsBottomSheet(
                                                  orderItem:
                                                      pro,
                                                  priceController:
                                                      priceController,
                                                  quantityController:
                                                      quantityController,
                                                  context:
                                                      context,
                                                  order:
                                                      order,
                                                );
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical:
                                                      10,
                                                  horizontal:
                                                      10,
                                                ),
                                                child: Row(
                                                  spacing:
                                                      5,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              returnTheme(
                                                                context,
                                                                listen:
                                                                    false,
                                                              ).mobileTexts.b3.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        pro.productName,
                                                      ),
                                                    ),
                                                    Row(
                                                      spacing:
                                                          5,
                                                      children: [
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                returnTheme(
                                                                  context,
                                                                  listen:
                                                                      false,
                                                                ).mobileTexts.b3.fontSize,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          "${formatLargeNumberDouble(pro.remainingQuantity ?? 0)} ${pro.getUnit()}",
                                                        ),
                                                        Icon(
                                                          size:
                                                              16,
                                                          Icons.add,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          );
        },
      );
    },
  ).then((_) {
    searchController.clear();
  });
  action!();
}
