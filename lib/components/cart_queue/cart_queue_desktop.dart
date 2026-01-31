import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class CartQueueDesktop extends StatelessWidget {
  const CartQueueDesktop({super.key, required this.theme});

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount:
            returnSalesProviderContext(
              context,
            ).cartQueue.length,
        itemBuilder: (context, index) {
          var salesP = returnSalesProviderContext(context);
          var cartItem =
              returnSalesProviderContext(
                context,
              ).cartQueue[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  color:
                      cartItem.id == salesP.cartIdCache &&
                              salesP.cartQueue.length > 1
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
                  borderRadius: BorderRadius.circular(3),
                  onTap: () {
                    returnSalesProvider().selectCart(
                      cartItem.id!,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          cartItem.id ==
                                      salesP.cartIdCache &&
                                  salesP.cartQueue.length >
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
                                      salesP.cartIdCache &&
                                  salesP.cartQueue.length >
                                      1
                              ? MainAxisAlignment
                                  .spaceBetween
                              : MainAxisAlignment.center,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          salesP
                                  .cartQueue[index]
                                  .isReceiptEdit
                              ? 'Edit ${index + 1}'
                              : 'Cart ${index + 1}',
                        ),
                        Visibility(
                          visible:
                              cartItem.id ==
                                  salesP.cartIdCache &&
                              salesP.cartQueue.length > 1,
                          child: SizedBox(width: 10),
                        ),
                        Visibility(
                          visible:
                              cartItem.id ==
                                  salesP.cartIdCache &&
                              salesP.cartQueue.length > 1,
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
                                      context: context,
                                      builder: (context) {
                                        return ConfirmationAlert(
                                          theme: theme,
                                          message:
                                              'You are about to Delete Entire Cart from the Queue, This action can not be reversed are you sure you want to proceed?',
                                          title:
                                              'Are you sure?',
                                          action: () {
                                            returnSalesProvider()
                                                .deleteCart(
                                                  cartItem
                                                      .id!,
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
    );
  }
}
