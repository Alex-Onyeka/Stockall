import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/components/buttons/small_button_main.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';

void selectOrderItemsBottomSheet({
  required Orders order,
  required TextEditingController priceController,
  required TextEditingController quantityController,
  required BuildContext context,
  required OrderItems orderItem,
}) {
  var theme = returnTheme(context, listen: false);
  bool setCustomPrice = false;
  bool isGroupTemp = false;

  bool useGroupUnit() {
    return orderItem.useGroupQuantity ?? false;
  }

  isGroupTemp = orderItem.useGroupQuantity ?? false;
  quantityController.text = (orderItem.quantity).toString();

  double amount() {
    if (setCustomPrice) {
      return (double.tryParse(
            priceController.text.replaceAll(',', ''),
          ) ??
          0);
    } else {
      return isGroupTemp
          ? ((orderItem.getRevenuePerItem()) *
              (double.tryParse(
                    quantityController.text.replaceAll(
                      ',',
                      '',
                    ),
                  ) ??
                  0) *
              (orderItem.qttyPerGroup ?? 1))
          : (orderItem.costPrice ?? 0) *
              (double.tryParse(
                    quantityController.text.replaceAll(
                      ',',
                      '',
                    ),
                  ) ??
                  0);
    }
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
                        title: 'Enter Item Quantity',
                        hint: 'Quantity',
                        controller: quantityController,
                        theme: theme,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    Visibility(
                      visible: useGroupUnit(),
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
                    Builder(
                      builder: (context) {
                        if (setCustomPrice) {
                          return Column(
                            children: [
                              Row(
                                spacing: 10,
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: MoneyTextfield(
                                      title: 'Custom Price',
                                      hint: 'Enter Price',
                                      controller:
                                          priceController,
                                      theme: theme,
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    // SizedBox(height: 20),
                    InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        setState(() {
                          setCustomPrice = !setCustomPrice;
                        });
                        priceController.clear();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          spacing: 5,
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
                              setCustomPrice
                                  ? 'Cancel Custom Price'
                                  : 'Set Custom Price',
                            ),
                            Stack(
                              children: [
                                Visibility(
                                  visible:
                                      setCustomPrice ==
                                      false,
                                  child: SvgPicture.asset(
                                    editIconSvg,
                                    height: 20,
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      setCustomPrice ==
                                      true,
                                  child: Icon(Icons.clear),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                          action: () {},
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
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Select Items',
                              style: TextStyle(
                                fontSize:
                                    returnTheme(context)
                                        .mobileTexts
                                        .b1
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
                          Expanded(
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pop();
                                    FocusScope.of(
                                      context,
                                    ).unfocus();
                                  },
                                  icon: Icon(Icons.check),
                                ),
                              ],
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
                                                          formatLargeNumberDouble(
                                                            pro.remainingQuantity ??
                                                                0,
                                                          ),
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
