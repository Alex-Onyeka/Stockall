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
            returnSalesProvider(context).cartQueue.length,
        itemBuilder: (context, index) {
          var salesP = returnSalesProvider(context);
          // var cart =
          //     salesP
          //         .cartQueue[index];
          // return Container();
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  color:
                      salesP.cartIndex == index &&
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
                    returnSalesProvider(
                      context,
                      listen: false,
                    ).selectCart(index);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          salesP.cartIndex == index &&
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
                          salesP.cartIndex == index &&
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
                              salesP.cartIndex == index &&
                              salesP.cartQueue.length > 1,
                          child: SizedBox(width: 10),
                        ),
                        Visibility(
                          visible:
                              salesP.cartIndex == index &&
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
                                  if (!returnSalesProvider(
                                        context,
                                        listen: false,
                                      )
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
                                            returnSalesProvider(
                                              context,
                                              listen: false,
                                            ).deleteCart(
                                              index,
                                            );
                                            Navigator.of(
                                              context,
                                            ).pop();
                                          },
                                        );
                                      },
                                    );
                                  } else {
                                    returnSalesProvider(
                                      context,
                                      listen: false,
                                    ).cancelReceiptEdit(
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
