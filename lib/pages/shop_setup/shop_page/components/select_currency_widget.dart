import 'package:flutter/material.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/components/text_fields/main_dropdown_only.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';

class SelectCurrencyWidget extends StatefulWidget {
  const SelectCurrencyWidget({super.key});

  @override
  State<SelectCurrencyWidget> createState() =>
      _SelectCurrencyWidgetState();
}

class _SelectCurrencyWidgetState
    extends State<SelectCurrencyWidget> {
  String? selectedCurrency;
  String? displayCurrency;

  TextEditingController currencyController =
      TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        displayCurrency =
            returnShopProvider()
                    .userShop()!
                    .currency
                    .isEmpty
                ? 'Currency Not Set'
                : '${currencies.firstWhere((currency) => currency.symbol == returnShopProvider().userShop()!.currency).currency} (${currencies.firstWhere((currency) => currency.symbol == returnShopProvider().userShop()!.currency).symbol})';
        selectedCurrency =
            returnShopProvider()
                    .userShop()!
                    .currency
                    .isEmpty
                ? null
                : currencies
                    .firstWhere(
                      (currency) =>
                          currency.symbol ==
                          returnShopProvider()
                              .userShop()!
                              .currency,
                    )
                    .symbol;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: theme.mobileTexts.b3.fontSize,
          ),
          'Set your Currency',
        ),
        SizedBox(height: 5),
        MainDropdownOnly(
          valueSet: displayCurrency != null,
          hint: displayCurrency ?? 'Select Your Currency',
          theme: theme,
          isOpen: false,
          onTap: () {
            showGeneralDialog(
              context: context,
              pageBuilder: (
                context,
                animation,
                secondaryAnimation,
              ) {
                return GestureDetector(
                  onTap:
                      () =>
                          FocusManager.instance.primaryFocus
                              ?.unfocus(),
                  child: StatefulBuilder(
                    builder:
                        (context, setState) => Material(
                          color: Colors.transparent,
                          // elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 10.0,
                            ),
                            child: Ink(
                              height:
                                  MediaQuery.of(
                                    context,
                                  ).size.height,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(
                                          55,
                                          0,
                                          0,
                                          0,
                                        ),
                                    blurRadius: 5,
                                  ),
                                ],
                                borderRadius:
                                    BorderRadius.vertical(
                                      top: Radius.circular(
                                        20,
                                      ),
                                    ),
                              ),
                              child: Container(
                                height:
                                    MediaQuery.of(
                                      context,
                                    ).size.height *
                                    0.9,

                                padding:
                                    const EdgeInsets.fromLTRB(
                                      15,
                                      15,
                                      15,
                                      45,
                                    ),
                                child: Column(
                                  children: [
                                    Material(
                                      color: Colors.white,
                                      child: Column(
                                        children: [
                                          Center(
                                            child: Container(
                                              height: 4,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      15,
                                                    ),
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade400,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal:
                                                      15.0,
                                                ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Text(
                                                      'Select Your Currency',
                                                      style: TextStyle(
                                                        fontSize:
                                                            returnTheme(
                                                              context,
                                                            ).mobileTexts.b1.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Search For Countries or Currency name',
                                                      style: TextStyle(
                                                        fontSize:
                                                            returnTheme(
                                                              context,
                                                            ).mobileTexts.b2.fontSize,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                InkWell(
                                                  mouseCursor:
                                                      SystemMouseCursors
                                                          .click,
                                                  onTap: () {
                                                    Navigator.of(
                                                      context,
                                                    ).pop();
                                                    currencyController
                                                        .clear();
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.all(
                                                          10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      shape:
                                                          BoxShape.circle,
                                                      color:
                                                          Colors.grey.shade800,
                                                    ),
                                                    child: Icon(
                                                      color:
                                                          Colors.white,
                                                      Icons
                                                          .clear_rounded,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal:
                                                      20.0,
                                                ),
                                            child: GeneralTextfieldOnly(
                                              hint:
                                                  'Search for country or currency',
                                              lines: 1,
                                              theme: theme,
                                              controller:
                                                  currencyController,
                                              onChanged: (
                                                value,
                                              ) {
                                                setState(
                                                  () {},
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Builder(
                                        builder: (context) {
                                          var safeContext =
                                              context;
                                          var currenciies = currencies.where(
                                            (currency) =>
                                                currency
                                                    .country
                                                    .toLowerCase()
                                                    .contains(
                                                      currencyController
                                                          .text
                                                          .toLowerCase(),
                                                    ) ||
                                                currency
                                                    .currency
                                                    .toLowerCase()
                                                    .contains(
                                                      currencyController
                                                          .text
                                                          .toLowerCase(),
                                                    ),
                                          );
                                          if (isLoading) {
                                            return Container(
                                              color:
                                                  const Color.fromARGB(
                                                    67,
                                                    255,
                                                    255,
                                                    255,
                                                  ),
                                              child: Center(
                                                child: returnCompProvider(
                                                  context,
                                                  listen:
                                                      false,
                                                ).showLoader(
                                                  message:
                                                      'Loading',
                                                ),
                                              ),
                                            );
                                          } else {
                                            if (currenciies
                                                .isEmpty) {
                                              return Container(
                                                color:
                                                    Colors
                                                        .white,
                                                child: Center(
                                                  child: Text(
                                                    'Not Found',
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return ListView.builder(
                                                itemCount:
                                                    currenciies
                                                        .length,
                                                itemBuilder: (
                                                  context,
                                                  index,
                                                ) {
                                                  var item =
                                                      currenciies
                                                          .toList()[index];
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                      vertical:
                                                          5,
                                                    ),
                                                    child: ListTile(
                                                      tileColor:
                                                          Colors.white,
                                                      subtitle: Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b2.fontSize,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              theme.lightModeColor.secColor100,
                                                        ),
                                                        item.currency,
                                                      ),
                                                      title: Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b1.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        item.country,
                                                      ),
                                                      trailing: Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b1.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              theme.lightModeColor.secColor100,
                                                        ),
                                                        item.symbol,
                                                      ),
                                                      onTap: () async {
                                                        setState(() {
                                                          isLoading =
                                                              true;
                                                        });
                                                        await returnShopProvider().updateShopCurrency(
                                                          currency:
                                                              item.symbol,
                                                          shopId:
                                                              shopId(),
                                                        );
                                                        setState(() {
                                                          selectedCurrency =
                                                              item.symbol;
                                                          displayCurrency =
                                                              '${item.currency} (${item.symbol})';
                                                          isLoading =
                                                              false;
                                                        });
                                                        if (safeContext.mounted) {
                                                          Navigator.of(
                                                            safeContext,
                                                          ).pop();
                                                        }
                                                      },
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                  ),
                );
              },
            ).then((context) {
              setState(() {});
            });
          },
        ),
      ],
    );
  }
}
