import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockitt/components/alert_dialogues/info_alert.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/buttons/main_button_transparent.dart';
import 'package:stockitt/components/calendar/calendar_widget.dart';
import 'package:stockitt/components/text_fields/edit_cart_text_field.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/products/product_details/platforms/product_details_mobile.dart';
import 'package:stockitt/providers/theme_provider.dart';

class EditDiscountPage extends StatefulWidget {
  final ThemeProvider theme;
  final TempProductClass product;
  final TextEditingController discountController;
  const EditDiscountPage({
    super.key,
    required this.theme,
    required this.product,
    required this.discountController,
  });

  @override
  State<EditDiscountPage> createState() =>
      _EditDiscountPageState();
}

class _EditDiscountPageState
    extends State<EditDiscountPage> {
  // TextEditingController discountController =
  //     TextEditingController();
  bool setDate = false;
  bool isLoading = false;
  bool showSuccess = false;

  @override
  void initState() {
    super.initState();
    widget.discountController.text =
        widget.product.discount != null
            ? widget.product.discount.toString()
            : '0';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.product.discount != null
          ? returnData(context, listen: false).setBothDates(
            widget.product.startDate,
            widget.product.endDate,
          )
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap:
                () =>
                    FocusManager.instance.primaryFocus
                        ?.unfocus(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  top: 40,
                  right: 15,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Opacity(
                          opacity: 0,
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.clear),
                          ),
                        ),
                        Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          'Discount Percentage',
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.clear),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Column(
                      spacing: 20,
                      children: [
                        EditCartTextField(
                          onChanged: (value) {
                            setState(() {});
                            if (value.isNotEmpty) {
                              if (int.parse(value) > 99) {
                                setState(() {
                                  widget
                                      .discountController
                                      .text = '100';
                                });
                              }
                              if (value.isEmpty) {
                                returnData(
                                  context,
                                  listen: false,
                                ).clearEndDate();
                                returnData(
                                  context,
                                  listen: false,
                                ).clearStartDate();
                              }
                            }
                          },
                          title: 'Discount',
                          hint: 'Enter Discount Percentage',
                          controller:
                              widget.discountController,
                          theme: widget.theme,
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    Visibility(
                      visible: true,
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        spacing: 10,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                setDate = true;
                              });
                              returnData(
                                context,
                                listen: false,
                              ).changeDateBoolToTrue();
                              FocusManager
                                  .instance
                                  .primaryFocus
                                  ?.unfocus();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                spacing: 5,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          widget
                                              .theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    returnData(
                                              context,
                                            ).startDate !=
                                            null
                                        ? formatDateTime(
                                          returnData(
                                                context,
                                              ).startDate ??
                                              DateTime.now(),
                                        )
                                        : 'Start Date',
                                  ),
                                  Icon(
                                    size: 20,
                                    Icons
                                        .calendar_month_outlined,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                setDate = true;
                              });
                              returnData(
                                context,
                                listen: false,
                              ).clearEndDate();
                              returnData(
                                context,
                                listen: false,
                              ).changeDateBoolToFalse();
                              FocusManager
                                  .instance
                                  .primaryFocus
                                  ?.unfocus();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                spacing: 5,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          widget
                                              .theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    returnData(
                                              context,
                                            ).endDate !=
                                            null
                                        ? formatDateTime(
                                          returnData(
                                                context,
                                              ).endDate ??
                                              DateTime.now(),
                                        )
                                        : 'End Date',
                                  ),
                                  Icon(
                                    size: 20,
                                    Icons
                                        .calendar_month_outlined,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    MainButtonP(
                      themeProvider: widget.theme,
                      action: () {
                        final safeContext = context;
                        if (widget
                            .discountController
                            .text
                            .isNotEmpty) {
                          if (returnData(
                                    context,
                                    listen: false,
                                  ).startDate ==
                                  null ||
                              returnData(
                                    context,
                                    listen: false,
                                  ).endDate ==
                                  null) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return InfoAlert(
                                  theme: widget.theme,
                                  message:
                                      'You must set Start and End date for discount.',
                                  title: 'Dates not set',
                                );
                              },
                            );
                          } else {
                            showDialog(
                              context: safeContext,
                              builder: (context) {
                                return ConfirmationAlert(
                                  theme: widget.theme,
                                  message:
                                      'Are you sure you want to proceed?',
                                  title: 'Proceed?',
                                  action: () async {
                                    final dataProvider =
                                        returnData(
                                          context,
                                          listen: false,
                                        );
                                    if (safeContext
                                        .mounted) {
                                      Navigator.of(
                                        safeContext,
                                      ).pop();
                                    }
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await dataProvider.updateDiscount(
                                      endDate:
                                          dataProvider
                                              .endDate,
                                      statDate:
                                          dataProvider
                                              .startDate,
                                      productId:
                                          widget
                                              .product
                                              .id!,

                                      newDiscount:
                                          widget
                                                  .discountController
                                                  .text
                                                  .isEmpty
                                              ? null
                                              : widget
                                                      .discountController
                                                      .text ==
                                                  '0'
                                              ? null
                                              : double.parse(
                                                widget
                                                    .discountController
                                                    .text,
                                              ),
                                    );

                                    setState(() {
                                      isLoading = false;
                                      showSuccess = true;
                                    });

                                    Future.delayed(
                                      Duration(seconds: 2),
                                      () {
                                        dataProvider
                                            .clearFields();
                                        if (safeContext
                                            .mounted) {
                                          Navigator.of(
                                            safeContext,
                                          ).pop();
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          }
                        }
                      },
                      text: 'Update Discount',
                    ),
                    Visibility(
                      visible:
                          widget
                              .discountController
                              .text
                              .isNotEmpty,
                      child: Column(
                        children: [
                          SizedBox(height: 15),
                          Material(
                            color: Colors.transparent,
                            child: EditButton(
                              color: Colors.redAccent,
                              icon: Icons.clear,
                              text: 'Cancel Discount',
                              action: () {
                                final dataProvider =
                                    returnData(
                                      context,
                                      listen: false,
                                    );
                                final safeContext = context;
                                showDialog(
                                  context: safeContext,
                                  builder: (context) {
                                    return ConfirmationAlert(
                                      theme: widget.theme,
                                      message:
                                          'Are you sure you want to cancel a running discount?',
                                      title:
                                          'Are you sure?',
                                      action: () async {
                                        if (safeContext
                                            .mounted) {
                                          Navigator.of(
                                            safeContext,
                                          ).pop();
                                        }
                                        setState(() {
                                          isLoading = true;
                                        });
                                        await dataProvider
                                            .updateDiscount(
                                              productId:
                                                  widget
                                                      .product
                                                      .id!,
                                              newDiscount:
                                                  null,
                                              endDate: null,
                                              statDate:
                                                  null,
                                            );

                                        dataProvider
                                            .clearFields();

                                        setState(() {
                                          isLoading = false;
                                          showSuccess =
                                              true;
                                        });

                                        Future.delayed(
                                          Duration(
                                            seconds: 2,
                                          ),
                                          () {
                                            if (safeContext
                                                .mounted) {
                                              Navigator.of(
                                                safeContext,
                                              ).pop();
                                            }
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              theme: widget.theme,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Material(
                      color: Colors.transparent,
                      child: EditButton(
                        text: 'Cancel',
                        action: () {
                          returnData(
                            context,
                            listen: false,
                          ).clearFields();
                          Navigator.of(context).pop();
                        },
                        theme: widget.theme,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: Visibility(
            visible: setDate,
            child: InkWell(
              onTap: () {
                setState(() {
                  returnData(
                    context,
                    listen: false,
                  ).clearEndDate();
                  setDate = false;
                });
              },
              child: Container(
                color: const Color.fromARGB(60, 0, 0, 0),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height:
                            MediaQuery.of(
                              context,
                            ).size.height *
                            0.15,
                      ),
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  30,
                                  0,
                                  0,
                                  0,
                                ),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          height: 480,
                          width:
                              (MediaQuery.of(
                                    context,
                                  ).size.width /
                                  10) *
                              9.2,
                          child: CalendarWidget(
                            isMain: false,
                            onDaySelected: (
                              selectedDay,
                              focusedDay,
                            ) {
                              returnData(
                                context,
                                listen: false,
                              ).setDate(selectedDay);
                              setState(() {
                                setDate = false;
                              });
                            },
                            actionWeek: (
                              startOfWeek,
                              endOfWeek,
                            ) {
                              returnReceiptProvider(
                                context,
                                listen: false,
                              ).setReceiptWeek(
                                startOfWeek,
                                endOfWeek,
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15,
                          left: 30,
                          right: 30,
                        ),
                        child: MainButtonTransparent(
                          constraints: BoxConstraints(),
                          themeProvider: widget.theme,
                          action: () {
                            setState(() {
                              setDate = false;
                            });
                          },
                          text: 'Cancel',
                        ),
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(
                              context,
                            ).size.height *
                            0.4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: isLoading,
          child: returnCompProvider(
            context,
            listen: false,
          ).showLoader('Loading'),
        ),
        Visibility(
          visible: showSuccess,
          child: returnCompProvider(
            context,
            listen: false,
          ).showSuccess('Updated Successfully'),
        ),
      ],
    );
  }
}
