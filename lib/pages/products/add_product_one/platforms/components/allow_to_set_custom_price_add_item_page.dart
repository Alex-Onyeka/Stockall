import 'package:flutter/material.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class AllowToSetCustomPriceAddItemPage
    extends StatelessWidget {
  const AllowToSetCustomPriceAddItemPage({
    super.key,
    required this.theme,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: authorization(
        authorized: Authorizations().editSellingPrice,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: () {
            returnData().toggleSetCustomPrice();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      'Allow To Set Custom Price?',
                    ),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                        Text(
                          style: TextStyle(fontSize: 10),
                          'Allow Cashier to Set custom price during sale? ',
                        ),
                        Text(
                          style: TextStyle(fontSize: 10),
                          'NOTE: if "YES", then cashier can set a custom price during sale, instead of the selling price.',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Checkbox(
                activeColor:
                    theme.lightModeColor.secColor100,
                value:
                    returnData(
                      context: context,
                    ).setCustomPrice,
                onChanged: (value) {
                  returnData().toggleSetCustomPrice();
                  FocusManager.instance.primaryFocus
                      ?.unfocus();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
