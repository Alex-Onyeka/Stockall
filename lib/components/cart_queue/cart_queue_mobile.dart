import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class CartQueueMobile extends StatelessWidget {
  final bool isFirst;
  const CartQueueMobile({super.key, required this.isFirst});

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
            isFirst ? Colors.white : Colors.grey.shade100,
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount:
                  returnSalesProvider(
                    context,
                  ).cartQueue.length,
              itemBuilder: (context, index) {
                var salesP = returnSalesProvider(context);
                return Padding(
                  padding: const EdgeInsets.only(
                    right: 8.0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Ink(
                      decoration: BoxDecoration(
                        color:
                            isFirst
                                ? salesP.cartIndex == index
                                    ? Colors.grey.shade100
                                    : const Color.fromARGB(
                                      167,
                                      250,
                                      250,
                                      250,
                                    )
                                : salesP.cartIndex == index
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
                          returnSalesProvider(
                            context,
                            listen: false,
                          ).selectCart(index);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                salesP.cartIndex == index &&
                                        salesP
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
                                salesP.cartIndex == index &&
                                        salesP
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
                                        .cartQueue[index]
                                        .isReceiptEdit
                                    ? 'Edit ${index + 1}'
                                    : 'Cart ${index + 1}',
                              ),
                              Visibility(
                                visible:
                                    salesP.cartIndex ==
                                        index &&
                                    salesP
                                            .cartQueue
                                            .length >
                                        1,
                                child: SizedBox(width: 6),
                              ),
                              Visibility(
                                visible:
                                    salesP.cartIndex ==
                                        index &&
                                    salesP
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
                                        if (!returnSalesProvider(
                                              context,
                                              listen: false,
                                            )
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
                                                    'You are about to Delete Entier Cart from the Queue, This action can not be reversed are you sure you want to proceed?',
                                                title:
                                                    'Are you sure?',
                                                action: () {
                                                  returnSalesProvider(
                                                    context,
                                                    listen:
                                                        false,
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
            //     ).cartQueue.length <=
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
                      returnSalesProvider(
                        context,
                        listen: false,
                      ).addNewCart(context);
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
