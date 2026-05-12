import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class CartQueueMobile extends StatefulWidget {
  final bool isFirst;
  const CartQueueMobile({super.key, required this.isFirst});

  @override
  State<CartQueueMobile> createState() =>
      _CartQueueMobileState();
}

class _CartQueueMobileState extends State<CartQueueMobile> {
  final TextEditingController cartNameC =
      TextEditingController();
  String formatText(String text) {
    var first = text.substring(0, 1).toUpperCase();
    var rest = text.substring(1).toLowerCase();
    return "$first$rest";
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color:
            widget.isFirst
                ? Colors.white
                : Colors.grey.shade100,
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount:
                  returnSalesProviderContext(
                    context,
                  ).currentMainCart().cartQueue.length,
              itemBuilder: (context, index) {
                var salesP = returnSalesProviderContext(
                  context,
                );
                var cartItem =
                    returnSalesProviderContext(
                      context,
                    ).currentMainCart().cartQueue[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    right: 8.0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Ink(
                      decoration: BoxDecoration(
                        color:
                            widget.isFirst
                                ? cartItem.id ==
                                        salesP.cartIdCache
                                    ? Colors.grey.shade100
                                    : const Color.fromARGB(
                                      167,
                                      250,
                                      250,
                                      250,
                                    )
                                : cartItem.id ==
                                    salesP.cartIdCache
                                ? Colors.white
                                : const Color.fromARGB(
                                  167,
                                  250,
                                  250,
                                  250,
                                ),
                        borderRadius: BorderRadius.circular(
                          3,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          3,
                        ),
                        onTap: () {
                          returnSalesProvider().selectCart(
                            cartItem.id!,
                          );
                        },
                        onLongPress: () {
                          if (cartItem.id ==
                                  salesP.cartIdCache &&
                              !cartItem.isReceiptEdit) {
                            returnSalesProvider()
                                .removeListenerScanBarcode();
                            cartNameC.text =
                                cartItem.cartName ?? '';
                            showDialog(
                              context: context,
                              builder: (setNameDialog) {
                                return DialogTemplate(
                                  theme: theme,
                                  message:
                                      'Enter the name of the Cart',
                                  title: 'Enter Cart Name',
                                  action: () async {
                                    await returnSalesProvider()
                                        .updateCurrentCartName(
                                          cartItem.id!,
                                          formatText(
                                            cartNameC.text
                                                .trim(),
                                          ),
                                        );
                                    Navigator.of(
                                      setNameDialog,
                                    ).pop();
                                  },
                                  widget:
                                      GeneralTextfieldOnly(
                                        hint: 'Enter Name',
                                        controller:
                                            cartNameC,
                                        lines: 1,
                                        theme: theme,
                                      ),
                                );
                              },
                            ).then((_) {
                              returnSalesProvider()
                                  .requestFocusScanBarcode();
                              returnSalesProvider()
                                  .addListenerScanBarcode();
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                cartItem.id ==
                                            salesP
                                                .cartIdCache &&
                                        salesP
                                                .currentMainCart()
                                                .cartQueue
                                                .length >
                                            1
                                    ? 8
                                    : 12,
                            vertical: 1,
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            // spacing:
                            //     10,
                            mainAxisAlignment:
                                cartItem.id ==
                                            salesP
                                                .cartIdCache &&
                                        salesP
                                                .currentMainCart()
                                                .cartQueue
                                                .length >
                                            1
                                    ? MainAxisAlignment
                                        .spaceBetween
                                    : MainAxisAlignment
                                        .center,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                salesP
                                        .currentMainCart()
                                        .cartQueue[index]
                                        .isReceiptEdit
                                    ? 'Edit ${index + 1}'
                                    : salesP
                                            .currentMainCart()
                                            .cartQueue[index]
                                            .cartName ==
                                        null
                                    ? 'Cart ${index + 1}'
                                    : salesP
                                            .currentMainCart()
                                            .cartQueue[index]
                                            .cartName ??
                                        '',
                              ),
                              Visibility(
                                visible:
                                    cartItem.id ==
                                        salesP
                                            .cartIdCache &&
                                    salesP
                                            .currentMainCart()
                                            .cartQueue
                                            .length >
                                        1,
                                child: SizedBox(width: 6),
                              ),
                              Visibility(
                                visible:
                                    cartItem.id ==
                                        salesP
                                            .cartIdCache &&
                                    salesP
                                            .currentMainCart()
                                            .cartQueue
                                            .length >
                                        1,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      // shape:
                                      //     BoxShape.circle,
                                      borderRadius:
                                          BorderRadius.circular(
                                            3,
                                          ),
                                      color:
                                          theme
                                              .lightModeColor
                                              .secColor200,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (!returnSalesProvider()
                                            .currentCart()
                                            .isReceiptEdit) {
                                          showDialog(
                                            context:
                                                context,
                                            builder: (
                                              context,
                                            ) {
                                              return ConfirmationAlert(
                                                theme:
                                                    theme,
                                                message:
                                                    'You are about to Delete Entire Cart from the Queue, This action can not be reversed are you sure you want to proceed?',
                                                title:
                                                    'Are you sure?',
                                                action: () {
                                                  returnSalesProvider().deleteCart(
                                                    cartId:
                                                        cartItem.id!,
                                                    context:
                                                        context,
                                                  );
                                                  Navigator.of(
                                                    context,
                                                  ).pop();
                                                },
                                              );
                                            },
                                          );
                                        } else {
                                          returnSalesProvider()
                                              .cancelReceiptEdit(
                                                context,
                                              );
                                        }
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsets.symmetric(
                                              horizontal:
                                                  5.5,
                                              vertical: 4,
                                            ),
                                        decoration: BoxDecoration(
                                          // shape:
                                          //     BoxShape
                                          //         .circle,
                                          borderRadius:
                                              BorderRadius.circular(
                                                3,
                                              ),
                                        ),
                                        child: Icon(
                                          color:
                                              Colors.white,
                                          size: 11,
                                          Icons.clear,
                                        ),
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
                );
              },
            ),
          ),
          SizedBox(width: 10),
          Visibility(
            // visible:
            //     returnSalesProvider(
            //       context,
            //     ).currentMainCart().cartQueue.length <=
            //     4,
            child: SubWrapper(
              isVisible:
                  !SalesAuthAction().numberOfCartsAction(
                    context: context,
                  ),
              mainWidget: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    color: theme.lightModeColor.prColor300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: InkWell(
                    onTap: () {
                      returnSalesProvider().addNewCart(
                        context,
                        TempCart(
                          departmentName: null,
                          departmentUuid: null,
                          staffId: currentUser().userId,
                          staffName:
                              "${currentUser().name} ${currentUser().lastName}",
                          cartItems: [],
                          isInvoice: false,
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                      ),
                      child: Icon(
                        color: Colors.white,
                        size: 15,
                        Icons.add,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
