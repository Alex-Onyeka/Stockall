import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/pin_code_widget/my_pin_code_widget.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class CartQueueDesktop extends StatefulWidget {
  const CartQueueDesktop({super.key, required this.theme});

  final ThemeProvider theme;

  @override
  State<CartQueueDesktop> createState() =>
      _CartQueueDesktopState();
}

class _CartQueueDesktopState
    extends State<CartQueueDesktop> {
  final TextEditingController cartNameC =
      TextEditingController();
  String formatText(String text) {
    var first = text.substring(0, 1).toUpperCase();
    var rest = text.substring(1).toLowerCase();
    return "$first$rest";
  }

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        controller: scrollController,
        trackVisibility: true,
        child: ListView.builder(
          controller: scrollController,
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
              padding: const EdgeInsets.only(right: 8.0),
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    color:
                        cartItem.id == salesP.cartIdCache &&
                                salesP
                                        .currentMainCart()
                                        .cartQueue
                                        .length >
                                    1
                            ? Colors.grey.shade100
                            : const Color.fromARGB(
                              167,
                              250,
                              250,
                              250,
                            ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    borderRadius: BorderRadius.circular(3),
                    onTap: () {
                      returnSalesProvider().selectCart(
                        cartItem.id!,
                      );
                    },
                    onLongPress: () {
                      if (cartItem.id ==
                              salesP.cartIdCache &&
                          !cartItem.isReceiptEdit) {
                        // returnSalesProvider()
                        //     .removeListenerScanBarcode();
                        cartNameC.text =
                            cartItem.cartName ?? '';
                        showDialog(
                          context: context,
                          builder: (setNameDialog) {
                            return DialogTemplate(
                              theme: widget.theme,
                              message:
                                  'Enter the name of the Cart',
                              title: 'Enter Cart Name',
                              action: () async {
                                if (cartItem
                                    .cartItems
                                    .isNotEmpty) {
                                  var res =
                                      await pinCodeAction(
                                        isMain: false,
                                        context: context,
                                      );
                                  if (res) {
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
                                  }
                                } else {
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
                                }
                              },
                              widget: GeneralTextfieldOnly(
                                hint: 'Enter Name',
                                controller: cartNameC,
                                lines: 1,
                                theme: widget.theme,
                              ),
                            );
                          },
                        ).then((_) {
                          returnSalesProvider()
                              .requestFocusScanBarcode();
                          // returnSalesProvider()
                          //     .addListenerScanBarcode();
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
                        vertical: 5,
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
                                : MainAxisAlignment.center,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.bold,
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
                                    salesP.cartIdCache &&
                                salesP
                                        .currentMainCart()
                                        .cartQueue
                                        .length >
                                    1,
                            child: SizedBox(width: 10),
                          ),
                          Visibility(
                            visible:
                                cartItem.id ==
                                    salesP.cartIdCache &&
                                salesP
                                        .currentMainCart()
                                        .cartQueue
                                        .length >
                                    1,
                            child: Material(
                              color: Colors.transparent,
                              child: Ink(
                                decoration: BoxDecoration(
                                  // shape: BoxShape.circle,
                                  borderRadius:
                                      BorderRadius.circular(
                                        2,
                                      ),
                                  color:
                                      widget
                                          .theme
                                          .lightModeColor
                                          .secColor200,
                                ),
                                child: InkWell(
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  onTap: () {
                                    if (!returnSalesProvider()
                                        .currentCart()
                                        .isReceiptEdit) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return ConfirmationAlert(
                                            theme:
                                                widget
                                                    .theme,
                                            message:
                                                'You are about to Delete Entire Cart from the Queue, This action can not be reversed are you sure you want to proceed?',
                                            title:
                                                'Are you sure?',
                                            action: () async {
                                              if (cartItem
                                                  .cartItems
                                                  .isNotEmpty) {
                                                if (returnShopProvider()
                                                        .userShop()
                                                        ?.trackCart ==
                                                    true) {
                                                  var res = await pinCodeAction(
                                                    isMain:
                                                        true,
                                                    context:
                                                        context,
                                                  );
                                                  if (res &&
                                                      context
                                                          .mounted) {
                                                    await returnSalesProvider().deleteCart(
                                                      cartId:
                                                          cartItem.id!,
                                                      context:
                                                          context,
                                                    );
                                                    Navigator.of(
                                                      context,
                                                    ).pop();
                                                  }
                                                } else {
                                                  await returnSalesProvider().deleteCart(
                                                    cartId:
                                                        cartItem.id!,
                                                    context:
                                                        context,
                                                  );
                                                  Navigator.of(
                                                    context,
                                                  ).pop();
                                                }
                                              } else {
                                                await returnSalesProvider().deleteCart(
                                                  cartId:
                                                      cartItem
                                                          .id!,
                                                  context:
                                                      context,
                                                );
                                                Navigator.of(
                                                  context,
                                                ).pop();
                                              }
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
                                          horizontal: 6,
                                          vertical: 4.5,
                                        ),
                                    decoration: BoxDecoration(
                                      // shape: BoxShape.circle,
                                      borderRadius:
                                          BorderRadius.circular(
                                            2,
                                          ),
                                    ),
                                    child: Icon(
                                      color: Colors.white,
                                      size: 9,
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
    );
  }
}
