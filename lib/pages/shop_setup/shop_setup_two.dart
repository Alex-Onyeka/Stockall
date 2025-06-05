import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/progress_bar.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/components/text_fields/main_dropdown_only.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class ShopSetupTwo extends StatefulWidget {
  final TempShopClass? shop;
  const ShopSetupTwo({super.key, this.shop});

  @override
  State<ShopSetupTwo> createState() => _ShopSetupTwoState();
}

class _ShopSetupTwoState extends State<ShopSetupTwo> {
  bool isLoading = false;

  bool success = false;

  // void loading() {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   Future.delayed(Duration(seconds: 3), () {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     showSuccess();
  //   });
  // }

  // void showSuccess() {
  //   setState(() {
  //     success = true;
  //   });
  //   Future.delayed(Duration(seconds: 3), () {
  //     if (!context.mounted) return;
  //     Navigator.pushReplacement(
  //       // ignore: use_build_context_synchronously
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) {
  //           return Home();
  //         },
  //       ),
  //     );
  //     // setState(() {
  //     //   success = false;
  //     // });
  //   });
  // }

  TextEditingController addressController =
      TextEditingController();
  TextEditingController countryController =
      TextEditingController();
  TextEditingController cityController =
      TextEditingController();
  TextEditingController stateController =
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

  @override
  void dispose() {
    super.dispose();
    countryController.dispose();
    stateController.dispose();
    cityController.dispose();
    addressController.dispose();
  }

  @override
  void initState() {
    super.initState();
    countriesFuture = fetchCountries();
    if (widget.shop != null) {
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
    var theme = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  TopBanner(
                    isMain: true,
                    bottomSpace: 50,
                    iconData: Icons.home_work_outlined,
                    topSpace: 40,
                    theme: theme,
                    subTitle:
                        widget.shop != null
                            ? 'Update shop address details.'
                            : 'Create a Shop to get Started.',
                    title: 'Update Shop Address',
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    child: ProgressBar(
                      position: 0.06,
                      calcValue: 0.35,
                      theme: theme,
                      percent: '50%',
                      title: 'Your Progress',
                    ),
                  ),
                  SizedBox(height: 20),
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
                            MainDropdownOnly(
                              hint:
                                  selectedStateName ??
                                  'Select Your State',
                              theme: theme,
                              isOpen: false,
                              onTap: () {
                                if (widget.shop != null
                                    ? states.isEmpty
                                    : selectedCountryName ==
                                        null) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InfoAlert(
                                        theme: theme,
                                        message:
                                            'Country Must be set before state can be selected.',
                                        title:
                                            'Country Not Set.',
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
                                                      Colors
                                                          .white,
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
                                  ).then((context) {
                                    setState(() {});
                                  });
                                }
                              },
                              valueSet:
                                  selectedStateName != null,
                            ),

                            MainDropdownOnly(
                              hint:
                                  selectedCityName ??
                                  'Select Your City',
                              theme: theme,
                              isOpen: false,
                              onTap: () {
                                if (widget.shop != null
                                    ? cities.isEmpty
                                    : selectedStateName ==
                                        null) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InfoAlert(
                                        theme: theme,
                                        message:
                                            'You must set Your state Location before setting City.',
                                        title:
                                            'State Not Set',
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
                                      return FutureBuilder(
                                        future: cityFuture,
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
                                                      Colors
                                                          .transparent,
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
                                  ).then((context) {
                                    setState(() {});
                                  });
                                }
                              },
                              valueSet:
                                  selectedCityName != null,
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

                            SizedBox(height: 10),
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
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Visibility(
            visible: isLoading,
            child: Material(
              child: Container(
                color: const Color.fromARGB(
                  245,
                  255,
                  255,
                  255,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment(0, 0),
                              child: SizedBox(
                                width: 180,
                                child: Lottie.asset(
                                  mainLoader.isEmpty
                                      ? 'assets/animations/main_loader.json'
                                      : mainLoader,
                                  height: 80,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment(0, 0.1),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 60.0,
                                    ),
                                child: Text(
                                  textAlign:
                                      TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        theme
                                            .lightModeColor
                                            .prColor300,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .h4
                                            .fontSize,
                                    fontWeight:
                                        theme
                                            .mobileTexts
                                            .h2
                                            .fontWeightBold,
                                  ),
                                  widget.shop != null
                                      ? 'Updating Details'
                                      : 'Setting Up Your Shop',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: success,
            child: Material(
              child: Container(
                color: const Color.fromARGB(
                  251,
                  255,
                  255,
                  255,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment(0, -0.2),
                              child: SizedBox(
                                width: 180,
                                child: Lottie.asset(
                                  successAnim.isEmpty
                                      ? 'assets/animations/check_animation.json'
                                      : successAnim,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment(0, 0.2),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 60.0,
                                    ),
                                child: Text(
                                  widget.shop != null
                                      ? 'Update Completed Successfully'
                                      : 'Shop Setup Complete',
                                  textAlign:
                                      TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        theme
                                            .lightModeColor
                                            .prColor300,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .h2
                                            .fontSize,
                                    fontWeight:
                                        theme
                                            .mobileTexts
                                            .h2
                                            .fontWeightBold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
