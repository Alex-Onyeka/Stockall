import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/suppliers/supplier_list/supplier_list.dart';

class CreatePurchaseDesktop extends StatefulWidget {
  final TempPurchase? purchase;
  final TextEditingController searchController;
  final TextEditingController priceController;
  final TextEditingController quantityController;

  const CreatePurchaseDesktop({
    super.key,
    this.purchase,
    required this.searchController,
    required this.priceController,
    required this.quantityController,
  });

  @override
  State<CreatePurchaseDesktop> createState() =>
      _CreatePurchaseDesktopState();
}

class _CreatePurchaseDesktopState
    extends State<CreatePurchaseDesktop> {
  bool isLoading = false;
  bool showSuccess = false;

  bool updateInventory = true;
  int paymentSelected = 2;

  void checkFields() async {
    if (returnPurchaseActionProvider()
        .purchaseListItems
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
              returnPurchaseActionProvider()
                  .totalPurchaseAmount()
                  .toString();
          return StatefulBuilder(
            builder:
                (newContext, setStatee) => DialogTemplate(
                  theme: returnTheme(context),
                  message:
                      widget.purchase != null
                          ? "Click on the button below to confirm to create purchase."
                          : 'Set the payment amount below',
                  title:
                      widget.purchase != null
                          ? "Proceed with action"
                          : 'Set Payment Amount',
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
                              'You are about to record a purchase and update the items, are you sure you want to proceed?',
                          title: 'Proceed With Action',
                          action: () async {
                            Navigator.of(firstDialog).pop();
                            Navigator.of(
                              confirmDialog,
                            ).pop();

                            setState(() {
                              isLoading = true;
                            });

                            final purchaseProvider =
                                returnPurchaseActionProvider();
                            var res = await purchaseProvider
                                .createPurchaseAction(
                                  purchase: widget.purchase,
                                  updateInventory:
                                      widget.purchase !=
                                      null,
                                  paymentAmount:
                                      widget
                                              .priceController
                                              .text
                                              .isEmpty
                                          ? null
                                          : double.tryParse(
                                            widget
                                                .priceController
                                                .text
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ),
                                );
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
                                        'An Error Occoured while Creating this purchase. Please try again later.',
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
                  widget: Visibility(
                    visible: widget.purchase == null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 5,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          spacing: 4,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    returnTheme(
                                          context,
                                          listen: false,
                                        )
                                        .mobileTexts
                                        .b3
                                        .fontSize,
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
                                          returnPurchaseActionProvider()
                                              .totalPurchaseAmount()
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
                                returnPurchaseActionProvider()
                                    .totalPurchaseAmount()) {
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
                                returnPurchaseActionProvider()
                                    .totalPurchaseAmount()) {
                              widget.priceController.text =
                                  returnPurchaseActionProvider()
                                      .totalPurchaseAmount()
                                      .toStringAsFixed(0);
                              setStatee(() {
                                paymentSelected = 2;
                              });
                            }
                          },
                          showTitle: false,
                          title: 'Amount',
                          hint: 'Enter Amount',
                          controller:
                              widget.priceController,
                          theme: returnTheme(
                            context,
                            listen: false,
                          ),
                        ),
                      ],
                    ),
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
                      widget.purchase != null
                          ? 'Edit Purchase'
                          : 'New Purchase',
                    ),
                    SizedBox(height: 5),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                      ),
                      widget.purchase != null
                          ? 'Edit Purchase details'
                          : 'Follow the Process to create new Purchase',
                    ),
                  ],
                ),
                actions: [
                  InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      selectProductsForPurchaseBottomSheet(
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          10,
                          5,
                          10,
                          0,
                        ),
                        child: InkWell(
                          mouseCursor:
                              SystemMouseCursors.click,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return SupplierList(
                                    isPurchase: true,
                                  );
                                },
                              ),
                            );
                          },
                          borderRadius:
                              BorderRadius.circular(5),
                          child: Container(
                            height: 40,
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
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
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  returnPurchaseActionProvider(
                                            context:
                                                context,
                                          )
                                          .tempSupplier
                                          ?.name ??
                                      'Select Supplier',
                                ),
                                InkWell(
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  onTap: () {
                                    if (returnPurchaseActionProvider()
                                            .tempSupplier !=
                                        null) {
                                      returnPurchaseActionProvider()
                                          .selectSupplier();
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (
                                            context,
                                          ) {
                                            return SupplierList(
                                              isPurchase:
                                                  true,
                                            );
                                          },
                                        ),
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding:
                                        EdgeInsetsGeometry.all(
                                          7,
                                        ),
                                    child: Icon(
                                      size: 18,
                                      returnPurchaseActionProvider(
                                                context:
                                                    context,
                                              ).tempSupplier ==
                                              null
                                          ? Icons
                                              .arrow_forward_ios_rounded
                                          : Icons.clear,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
                                  if (returnPurchaseActionProvider(
                                        context: context,
                                      )
                                      .purchaseListItems
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
                                            selectProductsForPurchaseBottomSheet(
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
                                          returnPurchaseActionProvider(
                                                context:
                                                    context,
                                              )
                                              .purchaseItemReversed()
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
                                                                item.itemName,
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
                                                                '${formatLargeNumberDouble(item.quantity)} ${returnPurchaseActionProvider().itemUnit(purchaseItem: item)}',
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
                                                                      item.getPrice(),
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
                                                                selectProductPurchase(
                                                                  closeAction:
                                                                      () {},
                                                                  priceController:
                                                                      widget.priceController,
                                                                  quantityController:
                                                                      widget.quantityController,
                                                                  context:
                                                                      context,
                                                                  purchaseItem:
                                                                      item,
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
                                                                          'You are about to remove this item from purchase list. Are you sure you want to proceed?',
                                                                      title:
                                                                          'Remove From List',
                                                                      action: () {
                                                                        returnPurchaseActionProvider().addItemToList(
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
                                                  returnPurchaseActionProvider()
                                                      .totalPurchaseAmount()
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
                                                        returnPurchaseActionProvider().setCustomTotalAmount(
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
                                                          returnPurchaseActionProvider(
                                                            context:
                                                                context,
                                                          ).totalPurchaseAmount(),
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
                                              returnPurchaseActionProvider(
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
                                                        returnPurchaseActionProvider().setCustomTotalAmount(
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
                                text:
                                    widget.purchase != null
                                        ? 'Update Purchase'
                                        : 'Create Purchase',
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
            ).showLoader(
              message:
                  widget.purchase != null
                      ? 'Updating Purchase'
                      : 'Creating Purchase',
            ),
          ),
          Visibility(
            visible: showSuccess,
            child: returnCompProvider(
              context,
              listen: false,
            ).showSuccess(
              widget.purchase != null
                  ? 'Purchase Updated Successfully'
                  : 'Purchase Created Successfully',
            ),
          ),
        ],
      ),
    );
  }
}
