import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/buttons/small_button_main.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/progress_bar.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/components/text_fields/main_dropdown_only.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class ShopSetupTwoDesktop extends StatefulWidget {
  final TempShopClass? shop;
  const ShopSetupTwoDesktop({super.key, this.shop});

  @override
  State<ShopSetupTwoDesktop> createState() =>
      _ShopSetupTwoDesktopState();
}

class _ShopSetupTwoDesktopState
    extends State<ShopSetupTwoDesktop> {
  bool isLoading = false;

  bool success = false;

  TextEditingController controller =
      TextEditingController();

  bool stateSet = false;

  double screenPadding() {
    if (MediaQuery.of(context).size.width < 700) {
      return 50;
    } else if (MediaQuery.of(context).size.width > 700 &&
        MediaQuery.of(context).size.width < 1000) {
      return 100;
    } else {
      return 200;
    }
  }

  void setCity(Function() updateAction, String name) {
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

  TextEditingController addressController =
      TextEditingController();
  TextEditingController countryController =
      TextEditingController();
  TextEditingController cityController =
      TextEditingController();
  TextEditingController stateController =
      TextEditingController();
  TextEditingController referralController =
      TextEditingController();
  TextEditingController currencyController =
      TextEditingController();

  void checkInputs() {
    var shopProvider = returnShopProvider(
      context,
      listen: false,
    );
    var theme = returnTheme(context, listen: false);
    var safeContext = context;
    if (selectedCountryName == null ||
        selectedStateName == null ||
        selectedCityName == null) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message:
                'Country, State, and City Must be set.',
            title: 'Empty Fields',
          );
        },
      );
    } else if (displayCurrency == null) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message:
                'Currency Must be Set before shop can be created.',
            title: 'Currency Not set',
          );
        },
      );
    } else {
      if (widget.shop == null) {
        showDialog(
          context: safeContext,
          builder: (context) {
            return ConfirmationAlert(
              theme: theme,
              message:
                  'Are you sure you want to proceed with creating your shop?',
              title: 'Create Shop?',
              action: () async {
                Navigator.of(safeContext).pop();
                setState(() {
                  isLoading = true;
                });
                await shopProvider.createShop(
                  TempShopClass(
                    updateNumber: currentUpdate,
                    isVerified: false,
                    currency: selectedCurrency!,
                    employees: [
                      AuthService().currentUser!.id,
                    ],
                    createdAt: DateTime.now(),
                    userId: AuthService().currentUser!.id,
                    email: shopProvider.email!,
                    name: shopProvider.name,
                    state: selectedStateName,
                    country: selectedCountryName,
                    shopAddress:
                        addressController.text.isEmpty
                            ? null
                            : addressController.text,
                    city: selectedCityName,
                    phoneNumber: shopProvider.phone,
                    refCode: referralController.text.trim(),
                    language: 'en',
                  ),
                );
                await Future.delayed(Duration(seconds: 1));
                setState(() {
                  isLoading = false;
                  success = true;
                });

                await Future.delayed(Duration(seconds: 3));

                if (safeContext.mounted) {
                  Navigator.pushReplacement(
                    safeContext,
                    MaterialPageRoute(
                      builder: (context) {
                        return BasePage();
                      },
                    ),
                  );
                }
              },
            );
          },
        );
      } else {
        showDialog(
          context: safeContext,
          builder: (context) {
            return ConfirmationAlert(
              theme: theme,
              message:
                  'Are you sure you want to proceed with Update?',
              title: 'Proceed?',
              action: () async {
                Navigator.of(safeContext).pop();
                setState(() {
                  isLoading = true;
                });

                await shopProvider.updateShopLocation(
                  shopId: widget.shop!.shopId!,
                  country: selectedCountryName!,
                  state: selectedStateName!,
                  city: selectedCityName!,
                  address:
                      addressController.text.isEmpty
                          ? null
                          : addressController.text,
                );
                setState(() {
                  isLoading = false;
                  success = true;
                });

                await Future.delayed(Duration(seconds: 3));

                if (safeContext.mounted) {
                  Navigator.of(safeContext).pop();
                }
              },
            );
          },
        );
      }
    }
  }

  late Future<void> countriesFuture;

  Future<void> fetchCountries() async {
    final url = Uri.parse(
      'https://api.countrystatecity.in/v1/countries',
    );
    final response = await http.get(
      url,
      headers: {'X-CSCAPI-KEY': apiKey},
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(
        response.body,
      );

      // Convert List<dynamic> to List<String>
      final List<String> countryNames =
          responseData
              .map<String>(
                (country) => country['name'].toString(),
              )
              .toList();

      // Assign it to countries
      setState(() {
        countries = countryNames;
        countriesCodes = responseData;
      });
    } else {
      throw Exception('Failed to load countries');
    }
  }

  late Future<void> stateFuture;
  Future<void> fetchStates(String countryCode) async {
    final url = Uri.parse(
      'https://api.countrystatecity.in/v1/countries/$countryCode/states',
    );
    final response = await http.get(
      url,
      headers: {'X-CSCAPI-KEY': apiKey},
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(
        response.body,
      );

      final List<String> stateNames =
          responseData
              .map<String>(
                (state) => state['name'].toString(),
              )
              .toList();

      setState(() {
        states = stateNames;
        stateCodes = responseData;
        cities = [];
      });
    } else {
      throw Exception('Failed to load states');
    }
  }

  late Future<void> cityFuture;
  Future<void> fetchCities(
    String countryCode,
    String stateCode,
  ) async {
    final url = Uri.parse(
      'https://api.countrystatecity.in/v1/countries/$countryCode/states/$stateCode/cities',
    );
    final response = await http.get(
      url,
      headers: {'X-CSCAPI-KEY': apiKey},
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(
        response.body,
      );

      final List<String> cityNames =
          responseData
              .map<String>(
                (city) => city['name'].toString(),
              )
              .toList();

      setState(() {
        cities = cityNames;
      });
    } else {
      throw Exception('Failed to load cities');
    }
  }

  final String apiKey =
      'ZmdubFNvNDloNjBrNWs2VGpTQ0ttem1Xa3A1SVdZZmpWTE5tdnBKVw==';

  List<String> countries = [];
  List<dynamic> countriesCodes = [];
  List<String> states = [];
  List<dynamic> stateCodes = [];
  List<String> cities = [];

  String? selectedCountryCode;
  String? selectedCountryName;
  String? selectedStateCode;
  String? selectedStateName;
  String? selectedCity;
  String? selectedCityName;

  String? selectedCurrency;

  String? displayCurrency;

  @override
  void dispose() {
    super.dispose();
    countryController.dispose();
    stateController.dispose();
    cityController.dispose();
    addressController.dispose();
    referralController.dispose();
    currencyController.dispose();
  }

  @override
  void initState() {
    super.initState();
    countriesFuture = fetchCountries();
    if (widget.shop != null) {
      selectedCurrency = widget.shop!.currency;
      displayCurrency =
          '${currencies.firstWhere((currency) => currency.symbol == widget.shop!.currency).currency} (${currencies.firstWhere((currency) => currency.symbol == widget.shop!.currency).symbol})';
      selectedCountryName = 'Loading...';
      selectedStateName = 'Loading...';
      selectedCityName = 'Loading...';
      addressController.text =
          widget.shop!.shopAddress ?? '';
      WidgetsBinding.instance.addPostFrameCallback((
        _,
      ) async {
        await fetchCountries();
        countriesFuture = fetchCountries();
        final selectedCountry = countriesCodes.firstWhere(
          (country) =>
              country['name'] == widget.shop!.country,
          orElse: () => {'name': 'Not Found', 'iso2': '0'},
        );

        selectedCountryCode = selectedCountry['iso2'];
        selectedCountryName = selectedCountry['name'];
        // print('countryCode: $selectedCountryCode');
        // print('countryName: $selectedCountryName');
        await fetchStates(selectedCountryCode!);
        stateFuture = fetchStates(selectedCountryCode!);

        // await Future.delayed(
        //   Duration(milliseconds: 1000),
        // );

        final selectedState = stateCodes.firstWhere(
          (state) => state['name'] == widget.shop!.state,
          orElse: () => {'name': 'Not Set', 'iso2': '0'},
        );

        selectedStateCode = selectedState['iso2'];
        selectedStateName = selectedState['name'];
        // print('stateCode: $selectedStateCode');
        // print('stateName: $selectedStateName');

        await fetchCities(
          selectedCountryCode!,
          selectedStateCode!,
        );
        cityFuture = fetchCities(
          selectedCountryCode!,
          selectedStateCode!,
        );

        selectedCityName = widget.shop!.city;
        // print('cityName: $selectedCityName');
        // print('city: $selectedCity');
        setState(
          () {},
        ); // Single setState to update the widget once
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          body: DesktopCenterContainer(
            mainWidget: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Column(
                    spacing: 8,
                    children: [
                      Row(
                        children: [
                          Text(
                            style: TextStyle(
                              color:
                                  theme
                                      .lightModeColor
                                      .shadesColorBlack,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .h3
                                      .fontSize,
                              fontWeight:
                                  theme
                                      .mobileTexts
                                      .h3
                                      .fontWeightBold,
                            ),
                            widget.shop != null
                                ? 'Update Shop Address'
                                : 'Set Shop Address',
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            style:
                                Provider.of<ThemeProvider>(
                                      context,
                                    )
                                    .mobileTexts
                                    .b1
                                    .textStyleNormal,
                            widget.shop != null
                                ? 'Update shop address details.'
                                : 'Create a Shop to get Started.',
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    child: ProgressBar(
                      position: 0.06,
                      calcValue: 0.3,
                      theme: theme,
                      percent: '50%',
                      title: 'Your Progress',
                    ),
                  ),
                  SizedBox(height: 15),
                  Column(
                    spacing: 10,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                        ),
                        child: Column(
                          spacing: 20,
                          children: [
                            MainDropdownOnly(
                              hint:
                                  selectedCountryName ??
                                  'Select Your Country',
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
                                      onTap: () {
                                        FocusManager
                                            .instance
                                            .primaryFocus
                                            ?.unfocus();
                                      },
                                      child: StatefulBuilder(
                                        builder:
                                            (
                                              context,
                                              setState,
                                            ) => Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    screenPadding(),
                                              ),
                                              child: Material(
                                                color:
                                                    Colors
                                                        .transparent,
                                                // elevation: 1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top:
                                                            10.0,
                                                      ),
                                                  child: Ink(
                                                    height:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.height,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade100,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: const Color.fromARGB(
                                                            55,
                                                            0,
                                                            0,
                                                            0,
                                                          ),
                                                          blurRadius:
                                                              5,
                                                        ),
                                                      ],
                                                      borderRadius: BorderRadius.vertical(
                                                        top: Radius.circular(
                                                          20,
                                                        ),
                                                      ),
                                                    ),
                                                    child: FutureBuilder(
                                                      future:
                                                          countriesFuture,
                                                      builder: (
                                                        context,
                                                        snapshot,
                                                      ) {
                                                        return Container(
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
                                                                color:
                                                                    Colors.white,
                                                                child: Container(
                                                                  color:
                                                                      Colors.white,
                                                                  child: Column(
                                                                    children: [
                                                                      Center(
                                                                        child: Container(
                                                                          height:
                                                                              4,
                                                                          width:
                                                                              70,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(
                                                                              15,
                                                                            ),
                                                                            color:
                                                                                Colors.grey.shade400,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              15.0,
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
                                                                                  'Select Your Country',
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
                                                                                  'Search For Countries to Select',
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
                                                                              onTap: () {
                                                                                Navigator.of(
                                                                                  context,
                                                                                ).pop();
                                                                                countryController.clear();
                                                                              },
                                                                              child: Container(
                                                                                padding: EdgeInsets.all(
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
                                                                                  Icons.clear_rounded,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              20.0,
                                                                        ),
                                                                        child: GeneralTextfieldOnly(
                                                                          hint:
                                                                              'Search for country names',
                                                                          lines:
                                                                              1,
                                                                          theme:
                                                                              theme,
                                                                          controller:
                                                                              countryController,
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
                                                              ),
                                                              Expanded(
                                                                child: Builder(
                                                                  builder: (
                                                                    context,
                                                                  ) {
                                                                    if (snapshot.connectionState ==
                                                                        ConnectionState.waiting) {
                                                                      return Scaffold(
                                                                        body: returnCompProvider(
                                                                          context,
                                                                          listen:
                                                                              false,
                                                                        ).showLoader(
                                                                          'Loading',
                                                                        ),
                                                                      );
                                                                    } else if (snapshot.hasError) {
                                                                      return Scaffold(
                                                                        body: EmptyWidgetDisplay(
                                                                          title:
                                                                              'An Error Occured',
                                                                          subText:
                                                                              'Please check your internet and try again.',
                                                                          buttonText:
                                                                              'Close',
                                                                          theme:
                                                                              theme,
                                                                          height:
                                                                              30,
                                                                          action: () {
                                                                            Navigator.of(
                                                                              context,
                                                                            ).pop();
                                                                          },
                                                                          icon:
                                                                              Icons.clear,
                                                                        ),
                                                                      );
                                                                    } else {
                                                                      var main =
                                                                          countriesCodes;
                                                                      main.sort(
                                                                        (
                                                                          a,
                                                                          b,
                                                                        ) => a['name'].compareTo(
                                                                          b['name'],
                                                                        ),
                                                                      );
                                                                      var items =
                                                                          main
                                                                              .where(
                                                                                (
                                                                                  mainn,
                                                                                ) => mainn['name'].toString().toLowerCase().contains(
                                                                                  countryController.text.toLowerCase(),
                                                                                ),
                                                                              )
                                                                              .toList();
                                                                      if (items.isEmpty) {
                                                                        return Scaffold(
                                                                          body: Center(
                                                                            child: Row(
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment.center,
                                                                              children: [
                                                                                EmptyWidgetDisplay(
                                                                                  title:
                                                                                      'Empty List',
                                                                                  subText:
                                                                                      'There are no results for this Location.',
                                                                                  buttonText:
                                                                                      'Close',
                                                                                  theme:
                                                                                      theme,
                                                                                  height:
                                                                                      30,
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
                                                                          itemCount:
                                                                              items.length,
                                                                          itemBuilder: (
                                                                            context,
                                                                            index,
                                                                          ) {
                                                                            var item =
                                                                                items[index];
                                                                            return Padding(
                                                                              padding: const EdgeInsets.symmetric(
                                                                                vertical:
                                                                                    5,
                                                                              ),
                                                                              child: ListTile(
                                                                                tileColor:
                                                                                    Colors.white,
                                                                                title: Text(
                                                                                  item['name'],
                                                                                ),
                                                                                onTap: () {
                                                                                  setState(
                                                                                    () {
                                                                                      final selected = countriesCodes.firstWhere(
                                                                                        (
                                                                                          country,
                                                                                        ) =>
                                                                                            country['name'] ==
                                                                                            item['name'],
                                                                                      );
                                                                                      setState(
                                                                                        () {
                                                                                          selectedCountryCode =
                                                                                              selected['iso2'] ??
                                                                                              '0';
                                                                                          selectedCountryName =
                                                                                              selected['name'] ??
                                                                                              'Not Found';
                                                                                        },
                                                                                      );
                                                                                    },
                                                                                  );

                                                                                  Navigator.of(
                                                                                    context,
                                                                                  ).pop();
                                                                                  setState(
                                                                                    () {
                                                                                      stateFuture = fetchStates(
                                                                                        selectedCountryCode!,
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                  countryController.clear();
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
                                                        );
                                                      },
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
                              valueSet:
                                  selectedCountryName !=
                                  null,
                            ),
                            Builder(
                              builder: (context) {
                                if (widget.shop == null) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    spacing: 10,
                                    children: [
                                      Expanded(
                                        child: MainDropdownOnly(
                                          hint:
                                              selectedStateName ??
                                              'State',
                                          theme: theme,
                                          isOpen: false,
                                          onTap: () {
                                            if (widget.shop !=
                                                    null
                                                ? states
                                                    .isEmpty
                                                : selectedCountryName ==
                                                    null) {
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
                                                        'Country Must be set before state can be selected.',
                                                    title:
                                                        'Country Not Set.',
                                                  );
                                                },
                                              );
                                            } else {
                                              showGeneralDialog(
                                                context:
                                                    context,
                                                pageBuilder: (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                ) {
                                                  return StatefulBuilder(
                                                    builder:
                                                        (
                                                          context,
                                                          setState,
                                                        ) => FutureBuilder(
                                                          future:
                                                              stateFuture,
                                                          builder: (
                                                            context,
                                                            snapshot,
                                                          ) {
                                                            return Material(
                                                              color:
                                                                  Colors.white,
                                                              // elevation: 1,
                                                              child: Padding(
                                                                padding: const EdgeInsets.only(
                                                                  top:
                                                                      10.0,
                                                                ),
                                                                child: Ink(
                                                                  height:
                                                                      MediaQuery.of(
                                                                        context,
                                                                      ).size.height,
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        Colors.grey.shade100,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: const Color.fromARGB(
                                                                          55,
                                                                          0,
                                                                          0,
                                                                          0,
                                                                        ),
                                                                        blurRadius:
                                                                            5,
                                                                      ),
                                                                    ],
                                                                    borderRadius: BorderRadius.vertical(
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

                                                                    padding: const EdgeInsets.fromLTRB(
                                                                      15,
                                                                      15,
                                                                      15,
                                                                      45,
                                                                    ),
                                                                    child: Column(
                                                                      children: [
                                                                        Material(
                                                                          color:
                                                                              Colors.white,
                                                                          child: Column(
                                                                            children: [
                                                                              Center(
                                                                                child: Container(
                                                                                  height:
                                                                                      4,
                                                                                  width:
                                                                                      70,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      15,
                                                                                    ),
                                                                                    color:
                                                                                        Colors.grey.shade400,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height:
                                                                                    10,
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.symmetric(
                                                                                  horizontal:
                                                                                      15.0,
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
                                                                                          'Select Your State',
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
                                                                                          'Search For States to Select',
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
                                                                                      onTap: () {
                                                                                        Navigator.of(
                                                                                          context,
                                                                                        ).pop();
                                                                                        setState(
                                                                                          () {
                                                                                            stateController.clear();
                                                                                          },
                                                                                        );
                                                                                      },
                                                                                      child: Container(
                                                                                        padding: EdgeInsets.all(
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
                                                                                          Icons.clear_rounded,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height:
                                                                                    10,
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.symmetric(
                                                                                  horizontal:
                                                                                      20.0,
                                                                                ),
                                                                                child: GeneralTextfieldOnly(
                                                                                  hint:
                                                                                      'Search for state names',
                                                                                  lines:
                                                                                      1,
                                                                                  theme:
                                                                                      theme,
                                                                                  controller:
                                                                                      stateController,
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
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            InkWell(
                                                                              onTap: () {
                                                                                setCity(
                                                                                  () {
                                                                                    if (controller.text.isEmpty) {
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
                                                                                      setState(
                                                                                        () {
                                                                                          selectedStateName =
                                                                                              controller.text.trim();
                                                                                          selectedStateCode =
                                                                                              null;
                                                                                          stateSet =
                                                                                              true;
                                                                                          cityFuture = fetchCities(
                                                                                            '',

                                                                                            '',
                                                                                          );
                                                                                        },
                                                                                      );

                                                                                      int count =
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
                                                                                  'State',
                                                                                );
                                                                              },
                                                                              child: Container(
                                                                                padding: EdgeInsets.fromLTRB(
                                                                                  20,
                                                                                  10,
                                                                                  20,
                                                                                  5,
                                                                                ),
                                                                                child: Row(
                                                                                  spacing:
                                                                                      3,
                                                                                  children: [
                                                                                    Text(
                                                                                      'Add Custom State',
                                                                                    ),
                                                                                    Icon(
                                                                                      size:
                                                                                          20,
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
                                                                            builder: (
                                                                              context,
                                                                            ) {
                                                                              if (snapshot.connectionState ==
                                                                                  ConnectionState.waiting) {
                                                                                return Scaffold(
                                                                                  body: returnCompProvider(
                                                                                    context,
                                                                                    listen:
                                                                                        false,
                                                                                  ).showLoader(
                                                                                    'Loading',
                                                                                  ),
                                                                                );
                                                                              } else if (snapshot.hasError) {
                                                                                return Scaffold(
                                                                                  body: Row(
                                                                                    mainAxisAlignment:
                                                                                        MainAxisAlignment.center,
                                                                                    children: [
                                                                                      EmptyWidgetDisplay(
                                                                                        title:
                                                                                            'An Error Occured',
                                                                                        subText:
                                                                                            'Please check your internet and try again.',
                                                                                        buttonText:
                                                                                            'Close',
                                                                                        theme:
                                                                                            theme,
                                                                                        height:
                                                                                            30,
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
                                                                                );
                                                                              } else {
                                                                                var main =
                                                                                    stateCodes;
                                                                                main.sort(
                                                                                  (
                                                                                    a,
                                                                                    b,
                                                                                  ) => a['name'].compareTo(
                                                                                    b['name'],
                                                                                  ),
                                                                                );
                                                                                var items =
                                                                                    main
                                                                                        .where(
                                                                                          (
                                                                                            mainn,
                                                                                          ) => mainn['name'].toString().toLowerCase().contains(
                                                                                            stateController.text.toLowerCase(),
                                                                                          ),
                                                                                        )
                                                                                        .toList();

                                                                                if (items.isEmpty) {
                                                                                  return Scaffold(
                                                                                    body: Row(
                                                                                      mainAxisAlignment:
                                                                                          MainAxisAlignment.center,
                                                                                      children: [
                                                                                        EmptyWidgetDisplay(
                                                                                          title:
                                                                                              'Empty List',
                                                                                          subText:
                                                                                              'There are no results for this Location.',
                                                                                          buttonText:
                                                                                              'Add State',
                                                                                          theme:
                                                                                              theme,
                                                                                          height:
                                                                                              30,
                                                                                          action: () {
                                                                                            setCity(
                                                                                              () {
                                                                                                if (controller.text.isEmpty) {
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
                                                                                                  setState(
                                                                                                    () {
                                                                                                      selectedStateName =
                                                                                                          controller.text.trim();
                                                                                                      selectedStateCode =
                                                                                                          null;
                                                                                                      stateSet =
                                                                                                          true;
                                                                                                      cityFuture = fetchCities(
                                                                                                        selectedCountryCode ??
                                                                                                            '',
                                                                                                        selectedStateCode ??
                                                                                                            '',
                                                                                                      );
                                                                                                    },
                                                                                                  );

                                                                                                  int count =
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
                                                                                              'State',
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
                                                                                        padding: const EdgeInsets.symmetric(
                                                                                          vertical:
                                                                                              5,
                                                                                        ),
                                                                                        child: ListTile(
                                                                                          tileColor:
                                                                                              Colors.white,
                                                                                          title: Text(
                                                                                            item['name'],
                                                                                          ),
                                                                                          onTap: () {
                                                                                            setState(
                                                                                              () {
                                                                                                final selected = stateCodes.firstWhere(
                                                                                                  (
                                                                                                    state,
                                                                                                  ) =>
                                                                                                      state['name'] ==
                                                                                                      item['name'],
                                                                                                );
                                                                                                setState(
                                                                                                  () {
                                                                                                    selectedStateCode =
                                                                                                        selected['iso2'] ??
                                                                                                        '0';
                                                                                                    selectedStateName =
                                                                                                        selected['name'] ??
                                                                                                        '';
                                                                                                  },
                                                                                                );
                                                                                              },
                                                                                            );
                                                                                            setState(
                                                                                              () {
                                                                                                cityFuture = fetchCities(
                                                                                                  selectedCountryCode!,
                                                                                                  selectedStateCode!,
                                                                                                );
                                                                                              },
                                                                                            );
                                                                                            Navigator.of(
                                                                                              context,
                                                                                            ).pop();
                                                                                            setState(
                                                                                              () {
                                                                                                stateController.clear();
                                                                                              },
                                                                                            );
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
                                                            );
                                                          },
                                                        ),
                                                  );
                                                },
                                              ).then((
                                                context,
                                              ) {
                                                setState(
                                                  () {},
                                                );
                                              });
                                            }
                                          },
                                          valueSet:
                                              selectedStateName !=
                                              null,
                                        ),
                                      ),

                                      Expanded(
                                        child: MainDropdownOnly(
                                          hint:
                                              selectedCityName ??
                                              'City',
                                          theme: theme,
                                          isOpen: false,
                                          onTap: () {
                                            if (widget.shop !=
                                                    null
                                                ? cities
                                                    .isEmpty
                                                : selectedStateName ==
                                                    null) {
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
                                                        'You must set Your state Location before setting City.',
                                                    title:
                                                        'State Not Set',
                                                  );
                                                },
                                              );
                                            } else {
                                              showGeneralDialog(
                                                context:
                                                    context,
                                                pageBuilder: (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                ) {
                                                  return FutureBuilder(
                                                    future:
                                                        cityFuture,
                                                    builder: (
                                                      context,
                                                      snapshot,
                                                    ) {
                                                      return StatefulBuilder(
                                                        builder:
                                                            (
                                                              context,
                                                              setState,
                                                            ) => Material(
                                                              color:
                                                                  Colors.transparent,
                                                              // elevation: 1,
                                                              child: Padding(
                                                                padding: const EdgeInsets.only(
                                                                  top:
                                                                      10.0,
                                                                ),
                                                                child: Ink(
                                                                  height:
                                                                      MediaQuery.of(
                                                                        context,
                                                                      ).size.height,
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        Colors.grey.shade100,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: const Color.fromARGB(
                                                                          55,
                                                                          0,
                                                                          0,
                                                                          0,
                                                                        ),
                                                                        blurRadius:
                                                                            5,
                                                                      ),
                                                                    ],
                                                                    borderRadius: BorderRadius.vertical(
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

                                                                    padding: const EdgeInsets.fromLTRB(
                                                                      15,
                                                                      15,
                                                                      15,
                                                                      45,
                                                                    ),
                                                                    child: Column(
                                                                      children: [
                                                                        Material(
                                                                          color:
                                                                              Colors.white,
                                                                          child: Column(
                                                                            children: [
                                                                              Center(
                                                                                child: Container(
                                                                                  height:
                                                                                      4,
                                                                                  width:
                                                                                      70,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      15,
                                                                                    ),
                                                                                    color:
                                                                                        Colors.grey.shade400,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height:
                                                                                    10,
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.symmetric(
                                                                                  horizontal:
                                                                                      15.0,
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
                                                                                          'Select Your City',
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
                                                                                          'Search For cities to Select',
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
                                                                                      onTap: () {
                                                                                        Navigator.of(
                                                                                          context,
                                                                                        ).pop();
                                                                                        cityController.clear();
                                                                                        controller.clear();
                                                                                      },
                                                                                      child: Container(
                                                                                        padding: EdgeInsets.all(
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
                                                                                          Icons.clear_rounded,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height:
                                                                                    10,
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.symmetric(
                                                                                  horizontal:
                                                                                      20.0,
                                                                                ),
                                                                                child: GeneralTextfieldOnly(
                                                                                  hint:
                                                                                      'Search for city names',
                                                                                  lines:
                                                                                      1,
                                                                                  theme:
                                                                                      theme,
                                                                                  controller:
                                                                                      cityController,
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
                                                                        SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            InkWell(
                                                                              onTap: () {
                                                                                setCity(
                                                                                  () {
                                                                                    if (controller.text.isEmpty) {
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
                                                                                      setState(
                                                                                        () {
                                                                                          selectedCityName =
                                                                                              controller.text.trim();
                                                                                        },
                                                                                      );
                                                                                      int count =
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
                                                                                  'City',
                                                                                );
                                                                              },
                                                                              child: Container(
                                                                                padding: EdgeInsets.fromLTRB(
                                                                                  20,
                                                                                  10,
                                                                                  20,
                                                                                  5,
                                                                                ),
                                                                                child: Row(
                                                                                  spacing:
                                                                                      3,
                                                                                  children: [
                                                                                    Text(
                                                                                      'Add City',
                                                                                    ),
                                                                                    Icon(
                                                                                      size:
                                                                                          20,
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
                                                                            builder: (
                                                                              context,
                                                                            ) {
                                                                              if (snapshot.connectionState ==
                                                                                  ConnectionState.waiting) {
                                                                                return Scaffold(
                                                                                  body: returnCompProvider(
                                                                                    context,
                                                                                    listen:
                                                                                        false,
                                                                                  ).showLoader(
                                                                                    'Loading',
                                                                                  ),
                                                                                );
                                                                              } else if (stateSet ==
                                                                                      true &&
                                                                                  (selectedStateCode ==
                                                                                      null)) {
                                                                                return Scaffold(
                                                                                  body: Row(
                                                                                    mainAxisAlignment:
                                                                                        MainAxisAlignment.center,
                                                                                    children: [
                                                                                      EmptyWidgetDisplay(
                                                                                        title:
                                                                                            'Empty List',
                                                                                        subText:
                                                                                            'There are no results for this Location.',
                                                                                        buttonText:
                                                                                            'Add Custom City',
                                                                                        theme:
                                                                                            theme,
                                                                                        height:
                                                                                            30,
                                                                                        action: () {
                                                                                          setCity(
                                                                                            () {
                                                                                              if (controller.text.isEmpty) {
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
                                                                                                setState(
                                                                                                  () {
                                                                                                    selectedCityName =
                                                                                                        controller.text.trim();
                                                                                                  },
                                                                                                );
                                                                                                int count =
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
                                                                                            'City',
                                                                                          );
                                                                                        },
                                                                                        icon:
                                                                                            Icons.clear,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                              } else if (snapshot.hasError) {
                                                                                return Scaffold(
                                                                                  body: EmptyWidgetDisplay(
                                                                                    title:
                                                                                        'An Error Occured',
                                                                                    subText:
                                                                                        'Please check your internet and try again.',
                                                                                    buttonText:
                                                                                        'Close',
                                                                                    theme:
                                                                                        theme,
                                                                                    height:
                                                                                        30,
                                                                                    action: () {
                                                                                      Navigator.of(
                                                                                        context,
                                                                                      ).pop();
                                                                                      setState(
                                                                                        () {
                                                                                          cityController.clear();
                                                                                        },
                                                                                      );
                                                                                    },
                                                                                    icon:
                                                                                        Icons.clear,
                                                                                  ),
                                                                                );
                                                                              } else {
                                                                                var items =
                                                                                    cities
                                                                                        .where(
                                                                                          (
                                                                                            city,
                                                                                          ) => city.toLowerCase().contains(
                                                                                            cityController.text.toLowerCase(),
                                                                                          ),
                                                                                        )
                                                                                        .toList();
                                                                                items.sort();
                                                                                if (items.isEmpty) {
                                                                                  return Scaffold(
                                                                                    body: Row(
                                                                                      mainAxisAlignment:
                                                                                          MainAxisAlignment.center,
                                                                                      children: [
                                                                                        EmptyWidgetDisplay(
                                                                                          title:
                                                                                              'Empty Listt',
                                                                                          subText:
                                                                                              'There are no results for this Location.',
                                                                                          buttonText:
                                                                                              'Add Custom City',
                                                                                          theme:
                                                                                              theme,
                                                                                          height:
                                                                                              30,
                                                                                          action: () {
                                                                                            setCity(
                                                                                              () {
                                                                                                if (controller.text.isEmpty) {
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
                                                                                                  setState(
                                                                                                    () {
                                                                                                      selectedCityName =
                                                                                                          controller.text.trim();
                                                                                                    },
                                                                                                  );
                                                                                                  int count =
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
                                                                                              'City',
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
                                                                                        padding: const EdgeInsets.symmetric(
                                                                                          vertical:
                                                                                              5,
                                                                                        ),
                                                                                        child: ListTile(
                                                                                          tileColor:
                                                                                              Colors.white,
                                                                                          title: Text(
                                                                                            item,
                                                                                          ),
                                                                                          onTap: () {
                                                                                            setState(
                                                                                              () {
                                                                                                selectedCity =
                                                                                                    item;
                                                                                                selectedCityName =
                                                                                                    item;
                                                                                              },
                                                                                            );
                                                                                            Navigator.of(
                                                                                              context,
                                                                                            ).pop();
                                                                                            setState(
                                                                                              () {
                                                                                                cityController.clear();
                                                                                              },
                                                                                            );
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
                                                },
                                              ).then((
                                                context,
                                              ) {
                                                setState(
                                                  () {},
                                                );
                                              });
                                            }
                                          },
                                          valueSet:
                                              selectedCityName !=
                                              null,
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    spacing: 20,
                                    children: [
                                      MainDropdownOnly(
                                        hint:
                                            selectedStateName ??
                                            'State',
                                        theme: theme,
                                        isOpen: false,
                                        onTap: () {
                                          if (widget.shop !=
                                                  null
                                              ? states
                                                  .isEmpty
                                              : selectedCountryName ==
                                                  null) {
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
                                                      'Country Must be set before state can be selected.',
                                                  title:
                                                      'Country Not Set.',
                                                );
                                              },
                                            );
                                          } else {
                                            showGeneralDialog(
                                              context:
                                                  context,
                                              pageBuilder: (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                              ) {
                                                return StatefulBuilder(
                                                  builder:
                                                      (
                                                        context,
                                                        setState,
                                                      ) => FutureBuilder(
                                                        future:
                                                            stateFuture,
                                                        builder: (
                                                          context,
                                                          snapshot,
                                                        ) {
                                                          return Material(
                                                            color:
                                                                Colors.white,
                                                            // elevation: 1,
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(
                                                                top:
                                                                    10.0,
                                                              ),
                                                              child: Ink(
                                                                height:
                                                                    MediaQuery.of(
                                                                      context,
                                                                    ).size.height,
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      Colors.grey.shade100,
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: const Color.fromARGB(
                                                                        55,
                                                                        0,
                                                                        0,
                                                                        0,
                                                                      ),
                                                                      blurRadius:
                                                                          5,
                                                                    ),
                                                                  ],
                                                                  borderRadius: BorderRadius.vertical(
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

                                                                  padding: const EdgeInsets.fromLTRB(
                                                                    15,
                                                                    15,
                                                                    15,
                                                                    45,
                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Material(
                                                                        color:
                                                                            Colors.white,
                                                                        child: Column(
                                                                          children: [
                                                                            Center(
                                                                              child: Container(
                                                                                height:
                                                                                    4,
                                                                                width:
                                                                                    70,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    15,
                                                                                  ),
                                                                                  color:
                                                                                      Colors.grey.shade400,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              height:
                                                                                  10,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(
                                                                                horizontal:
                                                                                    15.0,
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
                                                                                        'Select Your State',
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
                                                                                        'Search For States to Select',
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
                                                                                    onTap: () {
                                                                                      Navigator.of(
                                                                                        context,
                                                                                      ).pop();
                                                                                      setState(
                                                                                        () {
                                                                                          stateController.clear();
                                                                                        },
                                                                                      );
                                                                                    },
                                                                                    child: Container(
                                                                                      padding: EdgeInsets.all(
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
                                                                                        Icons.clear_rounded,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              height:
                                                                                  10,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(
                                                                                horizontal:
                                                                                    20.0,
                                                                              ),
                                                                              child: GeneralTextfieldOnly(
                                                                                hint:
                                                                                    'Search for state names',
                                                                                lines:
                                                                                    1,
                                                                                theme:
                                                                                    theme,
                                                                                controller:
                                                                                    stateController,
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
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          InkWell(
                                                                            onTap: () {
                                                                              setCity(
                                                                                () {
                                                                                  if (controller.text.isEmpty) {
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
                                                                                    setState(
                                                                                      () {
                                                                                        selectedStateName =
                                                                                            controller.text.trim();
                                                                                        selectedStateCode =
                                                                                            null;
                                                                                        stateSet =
                                                                                            true;
                                                                                        cityFuture = fetchCities(
                                                                                          '',

                                                                                          '',
                                                                                        );
                                                                                      },
                                                                                    );

                                                                                    int count =
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
                                                                                'State',
                                                                              );
                                                                            },
                                                                            child: Container(
                                                                              padding: EdgeInsets.fromLTRB(
                                                                                20,
                                                                                10,
                                                                                20,
                                                                                5,
                                                                              ),
                                                                              child: Row(
                                                                                spacing:
                                                                                    3,
                                                                                children: [
                                                                                  Text(
                                                                                    'Add Custom State',
                                                                                  ),
                                                                                  Icon(
                                                                                    size:
                                                                                        20,
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
                                                                          builder: (
                                                                            context,
                                                                          ) {
                                                                            if (snapshot.connectionState ==
                                                                                ConnectionState.waiting) {
                                                                              return Scaffold(
                                                                                body: returnCompProvider(
                                                                                  context,
                                                                                  listen:
                                                                                      false,
                                                                                ).showLoader(
                                                                                  'Loading',
                                                                                ),
                                                                              );
                                                                            } else if (snapshot.hasError) {
                                                                              return Scaffold(
                                                                                body: Row(
                                                                                  mainAxisAlignment:
                                                                                      MainAxisAlignment.center,
                                                                                  children: [
                                                                                    EmptyWidgetDisplay(
                                                                                      title:
                                                                                          'An Error Occured',
                                                                                      subText:
                                                                                          'Please check your internet and try again.',
                                                                                      buttonText:
                                                                                          'Close',
                                                                                      theme:
                                                                                          theme,
                                                                                      height:
                                                                                          30,
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
                                                                              );
                                                                            } else {
                                                                              var main =
                                                                                  stateCodes;
                                                                              main.sort(
                                                                                (
                                                                                  a,
                                                                                  b,
                                                                                ) => a['name'].compareTo(
                                                                                  b['name'],
                                                                                ),
                                                                              );
                                                                              var items =
                                                                                  main
                                                                                      .where(
                                                                                        (
                                                                                          mainn,
                                                                                        ) => mainn['name'].toString().toLowerCase().contains(
                                                                                          stateController.text.toLowerCase(),
                                                                                        ),
                                                                                      )
                                                                                      .toList();

                                                                              if (items.isEmpty) {
                                                                                return Scaffold(
                                                                                  body: Row(
                                                                                    mainAxisAlignment:
                                                                                        MainAxisAlignment.center,
                                                                                    children: [
                                                                                      EmptyWidgetDisplay(
                                                                                        title:
                                                                                            'Empty List',
                                                                                        subText:
                                                                                            'There are no results for this Location.',
                                                                                        buttonText:
                                                                                            'Add State',
                                                                                        theme:
                                                                                            theme,
                                                                                        height:
                                                                                            30,
                                                                                        action: () {
                                                                                          setCity(
                                                                                            () {
                                                                                              if (controller.text.isEmpty) {
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
                                                                                                setState(
                                                                                                  () {
                                                                                                    selectedStateName =
                                                                                                        controller.text.trim();
                                                                                                    selectedStateCode =
                                                                                                        null;
                                                                                                    stateSet =
                                                                                                        true;
                                                                                                    cityFuture = fetchCities(
                                                                                                      selectedCountryCode ??
                                                                                                          '',
                                                                                                      selectedStateCode ??
                                                                                                          '',
                                                                                                    );
                                                                                                  },
                                                                                                );

                                                                                                int count =
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
                                                                                            'State',
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
                                                                                      padding: const EdgeInsets.symmetric(
                                                                                        vertical:
                                                                                            5,
                                                                                      ),
                                                                                      child: ListTile(
                                                                                        tileColor:
                                                                                            Colors.white,
                                                                                        title: Text(
                                                                                          item['name'],
                                                                                        ),
                                                                                        onTap: () {
                                                                                          setState(
                                                                                            () {
                                                                                              final selected = stateCodes.firstWhere(
                                                                                                (
                                                                                                  state,
                                                                                                ) =>
                                                                                                    state['name'] ==
                                                                                                    item['name'],
                                                                                              );
                                                                                              setState(
                                                                                                () {
                                                                                                  selectedStateCode =
                                                                                                      selected['iso2'] ??
                                                                                                      '0';
                                                                                                  selectedStateName =
                                                                                                      selected['name'] ??
                                                                                                      '';
                                                                                                },
                                                                                              );
                                                                                            },
                                                                                          );
                                                                                          setState(
                                                                                            () {
                                                                                              cityFuture = fetchCities(
                                                                                                selectedCountryCode!,
                                                                                                selectedStateCode!,
                                                                                              );
                                                                                            },
                                                                                          );
                                                                                          Navigator.of(
                                                                                            context,
                                                                                          ).pop();
                                                                                          setState(
                                                                                            () {
                                                                                              stateController.clear();
                                                                                            },
                                                                                          );
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
                                                          );
                                                        },
                                                      ),
                                                );
                                              },
                                            ).then((
                                              context,
                                            ) {
                                              setState(
                                                () {},
                                              );
                                            });
                                          }
                                        },
                                        valueSet:
                                            selectedStateName !=
                                            null,
                                      ),

                                      MainDropdownOnly(
                                        hint:
                                            selectedCityName ??
                                            'City',
                                        theme: theme,
                                        isOpen: false,
                                        onTap: () {
                                          if (widget.shop !=
                                                  null
                                              ? cities
                                                  .isEmpty
                                              : selectedStateName ==
                                                  null) {
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
                                                      'You must set Your state Location before setting City.',
                                                  title:
                                                      'State Not Set',
                                                );
                                              },
                                            );
                                          } else {
                                            showGeneralDialog(
                                              context:
                                                  context,
                                              pageBuilder: (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                              ) {
                                                return FutureBuilder(
                                                  future:
                                                      cityFuture,
                                                  builder: (
                                                    context,
                                                    snapshot,
                                                  ) {
                                                    return StatefulBuilder(
                                                      builder:
                                                          (
                                                            context,
                                                            setState,
                                                          ) => Material(
                                                            color:
                                                                Colors.transparent,
                                                            // elevation: 1,
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(
                                                                top:
                                                                    10.0,
                                                              ),
                                                              child: Ink(
                                                                height:
                                                                    MediaQuery.of(
                                                                      context,
                                                                    ).size.height,
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      Colors.grey.shade100,
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: const Color.fromARGB(
                                                                        55,
                                                                        0,
                                                                        0,
                                                                        0,
                                                                      ),
                                                                      blurRadius:
                                                                          5,
                                                                    ),
                                                                  ],
                                                                  borderRadius: BorderRadius.vertical(
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

                                                                  padding: const EdgeInsets.fromLTRB(
                                                                    15,
                                                                    15,
                                                                    15,
                                                                    45,
                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Material(
                                                                        color:
                                                                            Colors.white,
                                                                        child: Column(
                                                                          children: [
                                                                            Center(
                                                                              child: Container(
                                                                                height:
                                                                                    4,
                                                                                width:
                                                                                    70,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    15,
                                                                                  ),
                                                                                  color:
                                                                                      Colors.grey.shade400,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              height:
                                                                                  10,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(
                                                                                horizontal:
                                                                                    15.0,
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
                                                                                        'Select Your City',
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
                                                                                        'Search For cities to Select',
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
                                                                                    onTap: () {
                                                                                      Navigator.of(
                                                                                        context,
                                                                                      ).pop();
                                                                                      cityController.clear();
                                                                                      controller.clear();
                                                                                    },
                                                                                    child: Container(
                                                                                      padding: EdgeInsets.all(
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
                                                                                        Icons.clear_rounded,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              height:
                                                                                  10,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(
                                                                                horizontal:
                                                                                    20.0,
                                                                              ),
                                                                              child: GeneralTextfieldOnly(
                                                                                hint:
                                                                                    'Search for city names',
                                                                                lines:
                                                                                    1,
                                                                                theme:
                                                                                    theme,
                                                                                controller:
                                                                                    cityController,
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
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          InkWell(
                                                                            onTap: () {
                                                                              setCity(
                                                                                () {
                                                                                  if (controller.text.isEmpty) {
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
                                                                                    setState(
                                                                                      () {
                                                                                        selectedCityName =
                                                                                            controller.text.trim();
                                                                                      },
                                                                                    );
                                                                                    int count =
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
                                                                                'City',
                                                                              );
                                                                            },
                                                                            child: Container(
                                                                              padding: EdgeInsets.fromLTRB(
                                                                                20,
                                                                                10,
                                                                                20,
                                                                                5,
                                                                              ),
                                                                              child: Row(
                                                                                spacing:
                                                                                    3,
                                                                                children: [
                                                                                  Text(
                                                                                    'Add City',
                                                                                  ),
                                                                                  Icon(
                                                                                    size:
                                                                                        20,
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
                                                                          builder: (
                                                                            context,
                                                                          ) {
                                                                            if (snapshot.connectionState ==
                                                                                ConnectionState.waiting) {
                                                                              return Scaffold(
                                                                                body: returnCompProvider(
                                                                                  context,
                                                                                  listen:
                                                                                      false,
                                                                                ).showLoader(
                                                                                  'Loading',
                                                                                ),
                                                                              );
                                                                            } else if (stateSet ==
                                                                                    true &&
                                                                                (selectedStateCode ==
                                                                                    null)) {
                                                                              return Scaffold(
                                                                                body: Row(
                                                                                  mainAxisAlignment:
                                                                                      MainAxisAlignment.center,
                                                                                  children: [
                                                                                    EmptyWidgetDisplay(
                                                                                      title:
                                                                                          'Empty List',
                                                                                      subText:
                                                                                          'There are no results for this Location.',
                                                                                      buttonText:
                                                                                          'Add Custom City',
                                                                                      theme:
                                                                                          theme,
                                                                                      height:
                                                                                          30,
                                                                                      action: () {
                                                                                        setCity(
                                                                                          () {
                                                                                            if (controller.text.isEmpty) {
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
                                                                                              setState(
                                                                                                () {
                                                                                                  selectedCityName =
                                                                                                      controller.text.trim();
                                                                                                },
                                                                                              );
                                                                                              int count =
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
                                                                                          'City',
                                                                                        );
                                                                                      },
                                                                                      icon:
                                                                                          Icons.clear,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            } else if (snapshot.hasError) {
                                                                              return Scaffold(
                                                                                body: EmptyWidgetDisplay(
                                                                                  title:
                                                                                      'An Error Occured',
                                                                                  subText:
                                                                                      'Please check your internet and try again.',
                                                                                  buttonText:
                                                                                      'Close',
                                                                                  theme:
                                                                                      theme,
                                                                                  height:
                                                                                      30,
                                                                                  action: () {
                                                                                    Navigator.of(
                                                                                      context,
                                                                                    ).pop();
                                                                                    setState(
                                                                                      () {
                                                                                        cityController.clear();
                                                                                      },
                                                                                    );
                                                                                  },
                                                                                  icon:
                                                                                      Icons.clear,
                                                                                ),
                                                                              );
                                                                            } else {
                                                                              var items =
                                                                                  cities
                                                                                      .where(
                                                                                        (
                                                                                          city,
                                                                                        ) => city.toLowerCase().contains(
                                                                                          cityController.text.toLowerCase(),
                                                                                        ),
                                                                                      )
                                                                                      .toList();
                                                                              items.sort();
                                                                              if (items.isEmpty) {
                                                                                return Scaffold(
                                                                                  body: Row(
                                                                                    mainAxisAlignment:
                                                                                        MainAxisAlignment.center,
                                                                                    children: [
                                                                                      EmptyWidgetDisplay(
                                                                                        title:
                                                                                            'Empty Listt',
                                                                                        subText:
                                                                                            'There are no results for this Location.',
                                                                                        buttonText:
                                                                                            'Add Custom City',
                                                                                        theme:
                                                                                            theme,
                                                                                        height:
                                                                                            30,
                                                                                        action: () {
                                                                                          setCity(
                                                                                            () {
                                                                                              if (controller.text.isEmpty) {
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
                                                                                                setState(
                                                                                                  () {
                                                                                                    selectedCityName =
                                                                                                        controller.text.trim();
                                                                                                  },
                                                                                                );
                                                                                                int count =
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
                                                                                            'City',
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
                                                                                      padding: const EdgeInsets.symmetric(
                                                                                        vertical:
                                                                                            5,
                                                                                      ),
                                                                                      child: ListTile(
                                                                                        tileColor:
                                                                                            Colors.white,
                                                                                        title: Text(
                                                                                          item,
                                                                                        ),
                                                                                        onTap: () {
                                                                                          setState(
                                                                                            () {
                                                                                              selectedCity =
                                                                                                  item;
                                                                                              selectedCityName =
                                                                                                  item;
                                                                                            },
                                                                                          );
                                                                                          Navigator.of(
                                                                                            context,
                                                                                          ).pop();
                                                                                          setState(
                                                                                            () {
                                                                                              cityController.clear();
                                                                                            },
                                                                                          );
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
                                              },
                                            ).then((
                                              context,
                                            ) {
                                              setState(
                                                () {},
                                              );
                                            });
                                          }
                                        },
                                        valueSet:
                                            selectedCityName !=
                                            null,
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                            Visibility(
                              visible: widget.shop == null,
                              child: MainDropdownOnly(
                                valueSet:
                                    displayCurrency != null,
                                hint:
                                    displayCurrency ??
                                    'Select Your Currency',
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
                                                FocusManager
                                                    .instance
                                                    .primaryFocus
                                                    ?.unfocus(),
                                        child: StatefulBuilder(
                                          builder:
                                              (
                                                context,
                                                setState,
                                              ) => Material(
                                                color:
                                                    Colors
                                                        .transparent,
                                                // elevation: 1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top:
                                                            10.0,
                                                      ),
                                                  child: Ink(
                                                    height:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.height,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade100,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: const Color.fromARGB(
                                                            55,
                                                            0,
                                                            0,
                                                            0,
                                                          ),
                                                          blurRadius:
                                                              5,
                                                        ),
                                                      ],
                                                      borderRadius: BorderRadius.vertical(
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

                                                      padding: const EdgeInsets.fromLTRB(
                                                        15,
                                                        15,
                                                        15,
                                                        45,
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Material(
                                                            color:
                                                                Colors.white,
                                                            child: Column(
                                                              children: [
                                                                Center(
                                                                  child: Container(
                                                                    height:
                                                                        4,
                                                                    width:
                                                                        70,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(
                                                                        15,
                                                                      ),
                                                                      color:
                                                                          Colors.grey.shade400,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      10,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        15.0,
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
                                                                        onTap: () {
                                                                          Navigator.of(
                                                                            context,
                                                                          ).pop();
                                                                          currencyController.clear();
                                                                        },
                                                                        child: Container(
                                                                          padding: EdgeInsets.all(
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
                                                                            Icons.clear_rounded,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      10,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        20.0,
                                                                  ),
                                                                  child: GeneralTextfieldOnly(
                                                                    hint:
                                                                        'Search for country or currency',
                                                                    lines:
                                                                        1,
                                                                    theme:
                                                                        theme,
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
                                                              builder: (
                                                                context,
                                                              ) {
                                                                var currenciies = currencies.where(
                                                                  (
                                                                    currency,
                                                                  ) =>
                                                                      currency.country.toLowerCase().contains(
                                                                        currencyController.text.toLowerCase(),
                                                                      ) ||
                                                                      currency.currency.toLowerCase().contains(
                                                                        currencyController.text.toLowerCase(),
                                                                      ),
                                                                );
                                                                if (currenciies.isEmpty) {
                                                                  return Container(
                                                                    color:
                                                                        Colors.white,
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
                                                                          currenciies.toList()[index];
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
                                                                                  FontWeight.normal,
                                                                            ),
                                                                            item.country,
                                                                          ),
                                                                          trailing: Text(
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                                  16,
                                                                              fontWeight:
                                                                                  FontWeight.bold,
                                                                              color:
                                                                                  theme.lightModeColor.secColor100,
                                                                            ),
                                                                            item.symbol,
                                                                          ),
                                                                          onTap: () {
                                                                            setState(
                                                                              () {
                                                                                selectedCurrency =
                                                                                    item.symbol;
                                                                                displayCurrency =
                                                                                    '${item.currency} (${item.symbol})';
                                                                              },
                                                                            );
                                                                            Navigator.of(
                                                                              context,
                                                                            ).pop();
                                                                            setState(
                                                                              () {
                                                                                cityController.clear();
                                                                              },
                                                                            );
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
                                        ),
                                      );
                                    },
                                  ).then((context) {
                                    setState(() {});
                                  });
                                },
                              ),
                            ),
                            GeneralTextField(
                              title:
                                  'Shop Address (Optional)',
                              theme: theme,
                              hint:
                                  'Enter Your Shop Address',
                              controller: addressController,
                              lines: 1,
                            ),

                            Visibility(
                              visible: widget.shop == null,
                              child: GeneralTextField(
                                title:
                                    'Referral Code (Optional)',
                                theme: theme,
                                hint: 'Enter Referral Code',
                                controller:
                                    referralController,
                                lines: 1,
                              ),
                            ),

                            Column(
                              children: [
                                MainButtonP(
                                  themeProvider: theme,
                                  action: () {
                                    checkInputs();
                                    // loading();
                                  },
                                  text:
                                      widget.shop != null
                                          ? 'Update Details'
                                          : 'Create Shop',
                                ),
                                SizedBox(height: 5),
                                Visibility(
                                  visible:
                                      widget.shop != null,
                                  child:
                                      MainButtonTransparent(
                                        themeProvider:
                                            theme,
                                        action: () {
                                          Navigator.of(
                                            context,
                                          ).pop();
                                        },
                                        text: 'Cancel',
                                        constraints:
                                            BoxConstraints(),
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: isLoading,
          child: returnCompProvider(
            context,
            listen: false,
          ).showLoader(
            widget.shop != null
                ? 'Updating Details'
                : 'Setting Up Your Shop',
          ),
        ),
        Visibility(
          visible: success,
          child: returnCompProvider(
            context,
            listen: false,
          ).showSuccess(
            widget.shop != null
                ? 'Update Completed Successfully'
                : 'Shop Setup Complete',
          ),
        ),
      ],
    );
  }
}
