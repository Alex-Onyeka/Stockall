import 'package:flutter/material.dart';
import 'package:stockall/main.dart';

class PaymentTypeButton extends StatelessWidget {
  final int index;
  const PaymentTypeButton({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: () {
            if (returnSalesProvider()
                    .currentCart()
                    .isInvoice &&
                index == 2) {
              return;
            } else {
              returnSalesProvider().changeMethod(
                index: index,
                context: context,
              );
            }
          },
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                7,
                10,
                7,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b1.fontSize,
                          fontWeight: FontWeight.bold,
                          color:
                              returnSalesProviderContext(
                                            context,
                                          )
                                          .currentCart()
                                          .isInvoice &&
                                      index == 2
                                  ? Colors.grey
                                  : null,
                        ),
                        returnSalesProviderContext(
                          context,
                        ).paymentMethods[index]['method'],
                      ),
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.normal,
                          color:
                              returnSalesProviderContext(
                                            context,
                                          )
                                          .currentCart()
                                          .isInvoice &&
                                      index == 2
                                  ? Colors.grey
                                  : theme
                                      .lightModeColor
                                      .secColor200,
                        ),
                        returnSalesProviderContext(
                          context,
                        ).paymentMethods[index]['subText'],
                      ),
                    ],
                  ),
                  Checkbox(
                    activeColor:
                        returnSalesProviderContext(
                                  context,
                                ).currentCart().isInvoice &&
                                index == 2
                            ? Colors.grey
                            : theme
                                .lightModeColor
                                .prColor250,
                    shape: CircleBorder(side: BorderSide()),
                    side: BorderSide(
                      width: 1,
                      color:
                          theme.lightModeColor.secColor200,
                    ),
                    value:
                        returnSalesProviderContext(
                          context,
                        ).currentCart().paymentMethod ==
                        index,
                    onChanged: (value) {
                      if (returnSalesProvider()
                              .currentCart()
                              .isInvoice &&
                          index == 2) {
                        return;
                      } else {
                        returnSalesProvider().changeMethod(
                          context: context,
                          index: index,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
