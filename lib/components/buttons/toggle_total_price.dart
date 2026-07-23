import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class ToggleTotalPriceWidget extends StatelessWidget {
  const ToggleTotalPriceWidget({
    super.key,
    required this.theme,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 5,
        children: [
          Text(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: theme.mobileTexts.b3.fontSize,
              color: Colors.grey.shade600,
            ),
            'Set Total Price?',
          ),
          Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 0.5,
              ),
              color: Colors.grey.shade100,
            ),
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              borderRadius: BorderRadius.circular(5),
              onTap: () {
                if (returnSalesProvider().setTotalPrice ==
                    true) {
                  returnSalesProvider().toggleSetTotalPrice(
                    false,
                  );
                } else {
                  returnSalesProvider().toggleSetTotalPrice(
                    true,
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        if (returnSalesProvider()
                                .setTotalPrice ==
                            true) {
                          returnSalesProvider()
                              .toggleSetTotalPrice(false);
                        } else {
                          returnSalesProvider()
                              .toggleSetTotalPrice(true);
                        }
                      },
                      child: Container(
                        width: 50,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(30),
                          border: Border.all(
                            color:
                                returnSalesProvider()
                                        .setTotalPrice
                                    ? theme
                                        .lightModeColor
                                        .prColor250
                                    : Colors.grey,
                          ),
                          color:
                              returnSalesProvider()
                                      .setTotalPrice
                                  ? theme
                                      .lightModeColor
                                      .prColor250
                                  : Colors.grey.shade200,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              returnSalesProvider()
                                      .setTotalPrice
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    returnSalesProvider()
                                            .setTotalPrice
                                        ? Colors.white
                                        : Colors
                                            .grey
                                            .shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
