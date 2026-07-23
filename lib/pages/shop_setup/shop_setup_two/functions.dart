import 'package:flutter/material.dart';
import 'package:stockall/classes/locations/country_model.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/small_button_main.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

void selectCurrency(
  BuildContext context,
  ThemeProvider theme,
  TextEditingController currencyController,
) {
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
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
                child: Ink(
                  height:
                      MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          55,
                          0,
                          0,
                          0,
                        ),
                        blurRadius: 5,
                      ),
                    ],
                    // borderRadius: BorderRadius.vertical(
                    //   top: Radius.circular(20),
                    // ),
                  ),
                  child: Container(
                    // height:
                    //     MediaQuery.of(
                    //       context,
                    //     ).size.height *
                    //     0.9,
                    padding: const EdgeInsets.fromLTRB(
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
                              SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 15.0,
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
                                                    )
                                                    .mobileTexts
                                                    .b1
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                        Text(
                                          'Search For Countries or Currency name',
                                          style: TextStyle(
                                            fontSize:
                                                returnTheme(
                                                      context,
                                                    )
                                                    .mobileTexts
                                                    .b2
                                                    .fontSize,
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
                                              BoxShape
                                                  .circle,
                                          color:
                                              Colors
                                                  .grey
                                                  .shade800,
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
                              SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                    ),
                                child: GeneralTextfieldOnly(
                                  hint:
                                      'Search for country or currency',
                                  lines: 1,
                                  theme: theme,
                                  controller:
                                      currencyController,
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              var currenciies = returnCountryProvider().getCurrencies().where(
                                (currency) =>
                                    currency.country
                                        .toLowerCase()
                                        .contains(
                                          currencyController
                                              .text
                                              .toLowerCase(),
                                        ) ||
                                    currency.currency
                                        .toLowerCase()
                                        .contains(
                                          currencyController
                                              .text
                                              .toLowerCase(),
                                        ) ||
                                    currency.symbol
                                        .toLowerCase()
                                        .contains(
                                          currencyController
                                              .text
                                              .toLowerCase(),
                                        ) ||
                                    currency.currencyName
                                        .toLowerCase()
                                        .contains(
                                          currencyController
                                              .text
                                              .toLowerCase(),
                                        ),
                              );
                              if (currenciies.isEmpty) {
                                return Container(
                                  color: Colors.white,
                                  child: Center(
                                    child: Text(
                                      'Not Found',
                                    ),
                                  ),
                                );
                              } else {
                                return ListView.builder(
                                  itemCount:
                                      currenciies.length,
                                  itemBuilder: (
                                    context,
                                    index,
                                  ) {
                                    var item =
                                        currenciies
                                            .toList()[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                            vertical: 5,
                                          ),
                                      child: ListTile(
                                        tileColor:
                                            Colors.white,
                                        subtitle: Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b3
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .normal,
                                            color:
                                                theme
                                                    .lightModeColor
                                                    .secColor100,
                                          ),
                                          "${item.currencyName} ( ${item.currency} )",
                                        ),
                                        title: Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b1
                                                    .fontSize,

                                            fontWeight:
                                                FontWeight
                                                    .normal,
                                          ),
                                          item.country,
                                        ),
                                        trailing: Text(
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            color:
                                                theme
                                                    .lightModeColor
                                                    .secColor100,
                                          ),
                                          item.symbol,
                                        ),
                                        onTap: () {
                                          returnCountryProvider()
                                              .setCurrency(
                                                item.symbol,
                                              );
                                          Navigator.of(
                                            context,
                                          ).pop();
                                          setState(() {
                                            currencyController
                                                .clear();
                                          });
                                        },
                                      ),
                                    );
                                  },
                                );
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
      );
    },
  );
}

//
//
//
//
//
//
//
//
//
//

void selectCountry({
  required BuildContext context,
  required TextEditingController countryController,
}) {
  var theme = returnTheme(context, listen: false);
  showGeneralDialog(
    context: context,
    pageBuilder: (
      generalDialogContext,
      animation,
      secondaryAnimation,
    ) {
      return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: StatefulBuilder(
          builder:
              (stateContext, setState) => Material(
                color: Colors.transparent,
                // elevation: 1,
                child: Ink(
                  height:
                      MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          55,
                          0,
                          0,
                          0,
                        ),
                        blurRadius: 5,
                      ),
                    ],
                    // borderRadius: BorderRadius.vertical(
                    //   top: Radius.circular(20),
                    // ),
                  ),
                  child: Container(
                    // height:
                    //     MediaQuery.of(context).size.height *
                    //     0.9,
                    padding: const EdgeInsets.fromLTRB(
                      15,
                      15,
                      15,
                      45,
                    ),
                    child: Column(
                      children: [
                        Material(
                          color: Colors.white,
                          child: Container(
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
                                SizedBox(height: 10),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 15.0,
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
                                            'Select Your Country',
                                            style: TextStyle(
                                              fontSize:
                                                  returnTheme(
                                                        context,
                                                      )
                                                      .mobileTexts
                                                      .b1
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                          Text(
                                            'Search For Countries to Select',
                                            style: TextStyle(
                                              fontSize:
                                                  returnTheme(
                                                        context,
                                                      )
                                                      .mobileTexts
                                                      .b2
                                                      .fontSize,
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
                                          countryController
                                              .clear();
                                        },
                                        child: Container(
                                          padding:
                                              EdgeInsets.all(
                                                10,
                                              ),
                                          decoration: BoxDecoration(
                                            shape:
                                                BoxShape
                                                    .circle,
                                            color:
                                                Colors
                                                    .grey
                                                    .shade800,
                                          ),
                                          child: Icon(
                                            color:
                                                Colors
                                                    .white,
                                            Icons
                                                .clear_rounded,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                  child: GeneralTextfieldOnly(
                                    hint:
                                        'Search for country names',
                                    lines: 1,
                                    theme: theme,
                                    controller:
                                        countryController,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              if (returnCountryProvider(
                                context: context,
                              ).isLoading) {
                                return Center(
                                  child: returnCompProvider(
                                    context,
                                    listen: false,
                                  ).showLoader(
                                    message:
                                        'Loading Countries',
                                  ),
                                );
                              } else if (returnCountryProvider(
                                context: context,
                              ).countries.isEmpty) {
                                return Scaffold(
                                  body: EmptyWidgetDisplay(
                                    title:
                                        'No Countries Found',
                                    subText:
                                        'Please check your internet and try again.',
                                    buttonText:
                                        'Fetch Countries',
                                    theme: theme,
                                    height: 30,
                                    action: () async {
                                      await returnCountryProvider()
                                          .fetchCountries();
                                      setState(() {});
                                    },
                                    icon: Icons.clear,
                                  ),
                                );
                              } else {
                                List<CountryModel> main =
                                    returnCountryProvider(
                                      context: context,
                                    ).getCountries();
                                List<CountryModel> items =
                                    main
                                        .where(
                                          (mainn) => mainn
                                              .country!
                                              .toLowerCase()
                                              .contains(
                                                countryController
                                                    .text
                                                    .toLowerCase(),
                                              ),
                                        )
                                        .toList();
                                if (items.isEmpty) {
                                  return Scaffold(
                                    body: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        children: [
                                          EmptyWidgetDisplay(
                                            title:
                                                'Empty List',
                                            subText:
                                                'There are no results for this Location.',
                                            buttonText:
                                                'Close',
                                            theme: theme,
                                            height: 30,
                                            action: () {
                                              Navigator.of(
                                                context,
                                              ).pop();
                                            },
                                            icon:
                                                Icons.clear,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return ListView.builder(
                                    itemCount: items.length,
                                    itemBuilder: (
                                      context,
                                      index,
                                    ) {
                                      var item =
                                          items[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                              vertical: 5,
                                            ),
                                        child: ListTile(
                                          tileColor:
                                              Colors.white,
                                          title: Text(
                                            item.country ??
                                                "Not Set",
                                          ),
                                          onTap: () {
                                            returnCountryProvider()
                                                .selectCountry(
                                                  item.country,
                                                  false,
                                                );
                                            countryController
                                                .clear();
                                            Navigator.of(
                                              context,
                                            ).pop();
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
      );
    },
  );
}

//
//
//
//
//
//
//
//
//
//
//

void setCity({
  required Function() updateAction,
  required String name,
  required BuildContext context,
  required TextEditingController controller,
}) {
  showDialog(
    context: context,
    builder: (context) {
      var theme = returnTheme(context, listen: false);
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: 15,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20,
            ),
            backgroundColor: Colors.white,
            title: Text(
              'Add $name Name',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: theme.mobileTexts.h4.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 450,
                  child: GeneralTextField(
                    lines: 1,

                    title: 'Enter $name Name',
                    hint: 'Enter $name',
                    controller: controller,
                    theme: theme,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  spacing: 5,
                  children: [
                    MaterialButton(
                      mouseCursor: SystemMouseCursors.click,
                      onPressed: () {
                        Navigator.of(context).pop();
                        controller.clear();
                      },
                      child: Text('Cancel'),
                    ),
                    SmallButtonMain(
                      theme: theme,
                      action: () {
                        updateAction();
                      },
                      buttonText: 'Save $name',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  ).then((value) {
    controller.clear();
  });
}

void selectState({
  required BuildContext context,
  required TextEditingController stateController,
  required TextEditingController controller,
}) {
  var theme = returnTheme(context, listen: false);
  if (returnCountryProvider().selectedCountry == null) {
    showDialog(
      context: context,
      builder: (context) {
        return InfoAlert(
          theme: theme,
          message:
              'Country Must be set before state can be selected.',
          title: 'Country Not Set.',
        );
      },
    );
  } else {
    showGeneralDialog(
      context: context,
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return StatefulBuilder(
          builder:
              (context, setState) => Material(
                color: Colors.white,
                // elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Ink(
                    height:
                        MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            55,
                            0,
                            0,
                            0,
                          ),
                          blurRadius: 5,
                        ),
                      ],
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Container(
                      height:
                          MediaQuery.of(
                            context,
                          ).size.height *
                          0.9,

                      padding: const EdgeInsets.fromLTRB(
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
                                SizedBox(height: 10),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 15.0,
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
                                            'Select Your State',
                                            style: TextStyle(
                                              fontSize:
                                                  returnTheme(
                                                        context,
                                                      )
                                                      .mobileTexts
                                                      .b1
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                          Text(
                                            'Search For States to Select',
                                            style: TextStyle(
                                              fontSize:
                                                  returnTheme(
                                                        context,
                                                      )
                                                      .mobileTexts
                                                      .b2
                                                      .fontSize,
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
                                          setState(() {
                                            stateController
                                                .clear();
                                          });
                                        },
                                        child: Container(
                                          padding:
                                              EdgeInsets.all(
                                                10,
                                              ),
                                          decoration: BoxDecoration(
                                            shape:
                                                BoxShape
                                                    .circle,
                                            color:
                                                Colors
                                                    .grey
                                                    .shade800,
                                          ),
                                          child: Icon(
                                            color:
                                                Colors
                                                    .white,
                                            Icons
                                                .clear_rounded,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                  child: GeneralTextfieldOnly(
                                    hint:
                                        'Search for state names',
                                    lines: 1,
                                    theme: theme,
                                    controller:
                                        stateController,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.end,
                            children: [
                              InkWell(
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                onTap: () {
                                  setCity(
                                    updateAction: () {
                                      if (controller
                                          .text
                                          .isEmpty) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return InfoAlert(
                                              theme: theme,
                                              message:
                                                  'Name Field can\'t be set as Empty',
                                              title:
                                                  'Empty Field',
                                            );
                                          },
                                        );
                                      } else {
                                        var stateModel =
                                            StateModel(
                                              stateName:
                                                  controller
                                                      .text
                                                      .trim(),
                                              code: 'code',
                                            );
                                        returnCountryProvider()
                                            .setCustomState(
                                              stateModel,
                                            );

                                        int count = 0;
                                        Navigator.popUntil(
                                          context,
                                          (route) {
                                            return count++ ==
                                                2;
                                          },
                                        );
                                      }
                                    },
                                    name: 'State',
                                    context: context,
                                    controller: controller,
                                  );
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.fromLTRB(
                                        20,
                                        10,
                                        20,
                                        5,
                                      ),
                                  child: Row(
                                    spacing: 3,
                                    children: [
                                      Text(
                                        'Add Custom State',
                                      ),
                                      Icon(
                                        size: 20,
                                        Icons.add,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                List<StateModel> main =
                                    returnCountryProvider(
                                      context: context,
                                    ).getStates();
                                // main.sort();
                                List<StateModel> items =
                                    main
                                        .where(
                                          (mainn) => mainn
                                              .stateName!
                                              .toLowerCase()
                                              .contains(
                                                stateController
                                                    .text
                                                    .toLowerCase(),
                                              ),
                                        )
                                        .toList();
                                if (returnCountryProvider(
                                  context: context,
                                ).isLoading) {
                                  return Center(
                                    child: returnCompProvider(
                                      context,
                                      listen: false,
                                    ).showLoader(
                                      message:
                                          'Loading States',
                                    ),
                                  );
                                } else if (items.isEmpty) {
                                  return Scaffold(
                                    body: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      children: [
                                        EmptyWidgetDisplay(
                                          title:
                                              'Empty List',
                                          subText:
                                              'There are no results for this Location.',
                                          buttonText:
                                              'Add State',
                                          theme: theme,
                                          height: 30,
                                          action: () {
                                            setCity(
                                              updateAction: () {
                                                if (controller
                                                    .text
                                                    .isEmpty) {
                                                  showDialog(
                                                    context:
                                                        context,
                                                    builder: (
                                                      context,
                                                    ) {
                                                      return InfoAlert(
                                                        theme:
                                                            theme,
                                                        message:
                                                            'Name Field can\'t be set as Empty',
                                                        title:
                                                            'Empty Field',
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  var stateModel = StateModel(
                                                    stateName:
                                                        controller.text.trim(),
                                                    code:
                                                        'code',
                                                  );
                                                  returnCountryProvider()
                                                      .setCustomState(
                                                        stateModel,
                                                      );

                                                  int
                                                  count = 0;
                                                  Navigator.popUntil(
                                                    context,
                                                    (
                                                      route,
                                                    ) {
                                                      return count++ ==
                                                          2;
                                                    },
                                                  );
                                                }
                                              },
                                              name: 'State',
                                              context:
                                                  context,
                                              controller:
                                                  controller,
                                            );
                                          },
                                          icon: Icons.clear,
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return ListView.builder(
                                    itemCount: items.length,
                                    itemBuilder: (
                                      context,
                                      index,
                                    ) {
                                      StateModel item =
                                          items[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                              vertical: 5,
                                            ),
                                        child: ListTile(
                                          tileColor:
                                              Colors.white,
                                          title: Text(
                                            item.stateName ??
                                                'Not Set',
                                          ),
                                          onTap: () {
                                            returnCountryProvider()
                                                .selectState(
                                                  item.stateName,
                                                  false,
                                                );
                                            Navigator.of(
                                              context,
                                            ).pop();
                                          },
                                        ),
                                      );
                                    },
                                  );
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
        );
      },
    );
  }
}

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//

void selectCity({
  required BuildContext context,
  required TextEditingController cityController,
  required TextEditingController controller,
}) {
  var theme = returnTheme(context, listen: false);
  if (returnCountryProvider().selectedState == null) {
    showDialog(
      context: context,
      builder: (context) {
        return InfoAlert(
          theme: theme,
          message:
              'You must set Your state Location before setting City.',
          title: 'State Not Set',
        );
      },
    );
  } else {
    showGeneralDialog(
      context: context,
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return StatefulBuilder(
          builder:
              (context, setState) => Material(
                color: Colors.transparent,
                // elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Ink(
                    height:
                        MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            55,
                            0,
                            0,
                            0,
                          ),
                          blurRadius: 5,
                        ),
                      ],
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Container(
                      height:
                          MediaQuery.of(
                            context,
                          ).size.height *
                          0.9,

                      padding: const EdgeInsets.fromLTRB(
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
                                SizedBox(height: 10),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 15.0,
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
                                            'Select Your City',
                                            style: TextStyle(
                                              fontSize:
                                                  returnTheme(
                                                        context,
                                                      )
                                                      .mobileTexts
                                                      .b1
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                          Text(
                                            'Search For cities to Select',
                                            style: TextStyle(
                                              fontSize:
                                                  returnTheme(
                                                        context,
                                                      )
                                                      .mobileTexts
                                                      .b2
                                                      .fontSize,
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
                                          cityController
                                              .clear();
                                          // controller
                                          //     .clear();
                                        },
                                        child: Container(
                                          padding:
                                              EdgeInsets.all(
                                                10,
                                              ),
                                          decoration: BoxDecoration(
                                            shape:
                                                BoxShape
                                                    .circle,
                                            color:
                                                Colors
                                                    .grey
                                                    .shade800,
                                          ),
                                          child: Icon(
                                            color:
                                                Colors
                                                    .white,
                                            Icons
                                                .clear_rounded,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                  child: GeneralTextfieldOnly(
                                    hint:
                                        'Search for city names',
                                    lines: 1,
                                    theme: theme,
                                    controller:
                                        cityController,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.end,
                            children: [
                              InkWell(
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                onTap: () {
                                  setCity(
                                    updateAction: () {
                                      if (controller
                                          .text
                                          .isEmpty) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return InfoAlert(
                                              theme: theme,
                                              message:
                                                  'Name Field can\'t be set as Empty',
                                              title:
                                                  'Empty Field',
                                            );
                                          },
                                        );
                                      } else {
                                        returnCountryProvider()
                                            .setCustomCity(
                                              controller
                                                  .text,
                                            );

                                        int count = 0;
                                        Navigator.popUntil(
                                          context,
                                          (route) {
                                            return count++ ==
                                                2;
                                          },
                                        );
                                      }
                                    },
                                    name: 'City',
                                    context: context,
                                    controller: controller,
                                  );
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.fromLTRB(
                                        20,
                                        10,
                                        20,
                                        5,
                                      ),
                                  child: Row(
                                    spacing: 3,
                                    children: [
                                      Text('Add City'),
                                      Icon(
                                        size: 20,
                                        Icons.add,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                if (returnCountryProvider(
                                  context: context,
                                ).isLoading) {
                                  return Center(
                                    child: returnCompProvider(
                                      context,
                                      listen: false,
                                    ).showLoader(
                                      message:
                                          'Loading Cities',
                                    ),
                                  );
                                } else if (returnCountryProvider(
                                      context: context,
                                    ).selectedState ==
                                    null) {
                                  return Scaffold(
                                    body: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      children: [
                                        EmptyWidgetDisplay(
                                          title:
                                              'Empty List',
                                          subText:
                                              'There are no results for this Location.',
                                          buttonText:
                                              'Add Custom City',
                                          theme: theme,
                                          height: 30,
                                          action: () {
                                            setCity(
                                              updateAction: () {
                                                if (controller
                                                    .text
                                                    .isEmpty) {
                                                  showDialog(
                                                    context:
                                                        context,
                                                    builder: (
                                                      context,
                                                    ) {
                                                      return InfoAlert(
                                                        theme:
                                                            theme,
                                                        message:
                                                            'Name Field can\'t be set as Empty',
                                                        title:
                                                            'Empty Field',
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  returnCountryProvider().setCustomCity(
                                                    controller
                                                        .text,
                                                  );

                                                  int
                                                  count = 0;
                                                  Navigator.popUntil(
                                                    context,
                                                    (
                                                      route,
                                                    ) {
                                                      return count++ ==
                                                          2;
                                                    },
                                                  );
                                                }
                                              },
                                              name: 'City',
                                              context:
                                                  context,
                                              controller:
                                                  controller,
                                            );
                                          },
                                          icon: Icons.clear,
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (returnCountryProvider(
                                  context: context,
                                ).cities.isEmpty) {
                                  return Scaffold(
                                    body: EmptyWidgetDisplay(
                                      title:
                                          'No Cities Found',
                                      subText:
                                          'Please check your internet and try again.',
                                      buttonText: 'Close',
                                      theme: theme,
                                      height: 30,
                                      action: () {
                                        // Navigator.of(
                                        //   context,
                                        // ).pop();
                                        // setState(() {
                                        //   cityController
                                        //       .clear();
                                        // });
                                      },
                                      icon: Icons.clear,
                                    ),
                                  );
                                } else {
                                  var items =
                                      returnCountryProvider(
                                            context:
                                                context,
                                          ).cities
                                          .where(
                                            (city) => city
                                                .toLowerCase()
                                                .contains(
                                                  cityController
                                                      .text
                                                      .toLowerCase(),
                                                ),
                                          )
                                          .toList();
                                  items.sort();
                                  if (items.isEmpty) {
                                    return Scaffold(
                                      body: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        children: [
                                          EmptyWidgetDisplay(
                                            title:
                                                'Empty Listt',
                                            subText:
                                                'There are no results for this Location.',
                                            buttonText:
                                                'Add Custom City',
                                            theme: theme,
                                            height: 30,
                                            action: () {
                                              setCity(
                                                updateAction: () {
                                                  if (controller
                                                      .text
                                                      .isEmpty) {
                                                    showDialog(
                                                      context:
                                                          context,
                                                      builder: (
                                                        context,
                                                      ) {
                                                        return InfoAlert(
                                                          theme:
                                                              theme,
                                                          message:
                                                              'Name Field can\'t be set as Empty',
                                                          title:
                                                              'Empty Field',
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    returnCountryProvider().setCustomCity(
                                                      controller
                                                          .text,
                                                    );

                                                    int
                                                    count =
                                                        0;
                                                    Navigator.popUntil(
                                                      context,
                                                      (
                                                        route,
                                                      ) {
                                                        return count++ ==
                                                            2;
                                                      },
                                                    );
                                                  }
                                                },
                                                name:
                                                    'City',
                                                context:
                                                    context,
                                                controller:
                                                    controller,
                                              );
                                            },
                                            icon:
                                                Icons.clear,
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return ListView.builder(
                                      itemCount:
                                          items.length,
                                      itemBuilder: (
                                        context,
                                        index,
                                      ) {
                                        var item =
                                            items[index];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                vertical: 5,
                                              ),
                                          child: ListTile(
                                            tileColor:
                                                Colors
                                                    .white,
                                            title: Text(
                                              item,
                                            ),
                                            onTap: () {
                                              returnCountryProvider()
                                                  .selectCity(
                                                    item,
                                                  );
                                              Navigator.of(
                                                context,
                                              ).pop();
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
        );
      },
    ).then((_) {
      returnCountryProvider().toggleLoading(false);
    });
  }
}
