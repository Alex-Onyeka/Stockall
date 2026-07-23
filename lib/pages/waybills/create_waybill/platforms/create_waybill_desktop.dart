import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_waybills/temp_way_bills.dart';
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
import 'package:stockall/pages/customers/customers_list/customer_list.dart';
// import 'package:stockall/pages/suppliers/supplier_list/supplier_list.dart';

class CreateWaybillDesktop extends StatefulWidget {
  final TempWayBills? waybill;
  final TextEditingController searchController;
  final TextEditingController priceController;
  final TextEditingController quantityController;

  const CreateWaybillDesktop({
    super.key,
    this.waybill,
    required this.searchController,
    required this.priceController,
    required this.quantityController,
  });

  @override
  State<CreateWaybillDesktop> createState() =>
      _CreateWaybillDesktopState();
}

class _CreateWaybillDesktopState
    extends State<CreateWaybillDesktop> {
  bool isLoading = false;
  bool showSuccess = false;

  bool updateInventory = true;
  int paymentSelected = 2;

  void checkFields() async {
    if (returnWaybillProvider().waybillItemsTemp.isEmpty) {
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
        builder: (confirmDialog) {
          return ConfirmationAlert(
            theme: returnTheme(context, listen: false),
            message:
                'You are about to ${widget.waybill == null ? "create" : "update"} a waybill, are you sure you want to proceed?',
            title:
                "${widget.waybill == null ? "Create" : "Update"} Waybill",
            action: () async {
              Navigator.of(confirmDialog).pop();
              setState(() {
                isLoading = true;
              });

              final waybillProvider =
                  returnWaybillProvider();
              var newWaybill = TempWayBills(
                uuid: widget.waybill?.uuid ?? uuidGen(),
                createdAt:
                    widget.waybill?.createdAt ??
                    DateTime.now(),
                shopId: widget.waybill?.shopId ?? shopId(),
                status:
                    widget.waybill?.status ?? 'not-sent',
                deliveryLocation: null,
                courierName: null,
                courierPhone: null,
                items: waybillProvider.waybillItemsTemp,
                customerId:
                    waybillProvider.tempCustomer?.uuid,
                customerName:
                    waybillProvider.tempCustomer?.name,
                updatedAt: DateTime.now(),
                staffId:
                    widget.waybill?.staffId ??
                    currentUser().userId,
                staffName:
                    widget.waybill?.staffName ??
                    currentUser().name,
                isCustomPriceSet:
                    waybillProvider.customTotalAmount !=
                    null,
                totalAmount:
                    waybillProvider.totalWaybillAmount(),
              );

              var res =
                  widget.waybill != null
                      ? await waybillProvider.createWaybill(
                        waybill: newWaybill,
                      )
                      : await waybillProvider.updateWaybill(
                        waybill: newWaybill,
                      );

              setState(() {
                isLoading = false;
              });
              if (res == null) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return InfoAlert(
                      theme: returnTheme(
                        context,
                        listen: false,
                      ),
                      message:
                          'An Error Occoured while Creating this waybill. Please try again later.',
                      title: 'An Error Occoured',
                    );
                  },
                );
                return;
              }
              setState(() {
                showSuccess = true;
              });

              Future.delayed(Duration(seconds: 2), () {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              });
            },
          );
        },
      );
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
                      widget.waybill != null
                          ? 'Edit Waybill'
                          : 'New Waybill',
                    ),
                    SizedBox(height: 5),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                      ),
                      widget.waybill != null
                          ? 'Edit Waybill details'
                          : 'Follow the Process to create new Waybill',
                    ),
                  ],
                ),
                actions: [
                  InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      selectProductsForWaybillBottomSheet(
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
                                  return CustomerList(
                                    isWaybill: true,
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
                                  returnWaybillProvider(
                                            context:
                                                context,
                                          )
                                          .tempCustomer
                                          ?.name ??
                                      'Select Customer',
                                ),
                                InkWell(
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  onTap: () {
                                    if (returnWaybillProvider()
                                            .tempCustomer !=
                                        null) {
                                      returnWaybillProvider()
                                          .selectCustomer();
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (
                                            context,
                                          ) {
                                            return CustomerList(
                                              isWaybill:
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
                                      returnWaybillProvider(
                                                context:
                                                    context,
                                              ).tempCustomer ==
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
                                  if (returnWaybillProvider(
                                        context: context,
                                      )
                                      .waybillItemsTemp
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
                                              'Click on "Add Items" to Start Selecing Items For Waybill',
                                          theme: theme,
                                          height: 25,
                                          icon: Icons.clear,
                                          altAction: () {
                                            selectProductsForWaybillBottomSheet(
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
                                          returnWaybillProvider(
                                                context:
                                                    context,
                                              )
                                              .waybillItemsReversed()
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
                                                                formatLargeNumberDouble(
                                                                  item.quantity,
                                                                ),
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
                                                                      item.amount,
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
                                                                selectProductWaybill(
                                                                  closeAction:
                                                                      () {},
                                                                  priceController:
                                                                      widget.priceController,
                                                                  quantityController:
                                                                      widget.quantityController,
                                                                  context:
                                                                      context,
                                                                  waybillItem:
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
                                                                          'You are about to remove this item from waybill list. Are you sure you want to proceed?',
                                                                      title:
                                                                          'Remove From List',
                                                                      action: () {
                                                                        returnWaybillProvider().addToItems(
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
                                                  returnWaybillProvider()
                                                      .totalWaybillAmount()
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
                                                        returnWaybillProvider().setCustomTotalAmount(
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
                                                          returnWaybillProvider(
                                                            context:
                                                                context,
                                                          ).totalWaybillAmount(),
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
                                              returnWaybillProvider(
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
                                                        returnWaybillProvider().setCustomTotalAmount(
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
                                    widget.waybill != null
                                        ? 'Update Waybill'
                                        : 'Create Waybill',
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
                  widget.waybill != null
                      ? 'Updating Waybill'
                      : 'Creating Waybill',
            ),
          ),
          Visibility(
            visible: showSuccess,
            child: returnCompProvider(
              context,
              listen: false,
            ).showSuccess(
              widget.waybill != null
                  ? 'Waybill Updated Successfully'
                  : 'Waybill Created Successfully',
            ),
          ),
        ],
      ),
    );
  }
}
