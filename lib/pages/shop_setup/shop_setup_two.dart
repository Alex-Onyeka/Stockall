import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:stockitt/classes/temp_shop_class.dart';
import 'package:stockitt/components/alert_dialogues/info_alert.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/major/empty_widget_display.dart';
import 'package:stockitt/components/progress_bar.dart';
import 'package:stockitt/components/text_fields/general_textfield.dart';
import 'package:stockitt/components/text_fields/general_textfield_only.dart';
import 'package:stockitt/components/text_fields/main_dropdown_only.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/home/home.dart';
import 'package:stockitt/components/major/top_banner.dart';
import 'package:stockitt/providers/theme_provider.dart';
import 'package:stockitt/services/auth_service.dart';

class ShopSetupTwo extends StatefulWidget {
  const ShopSetupTwo({super.key});

  @override
  State<ShopSetupTwo> createState() => _ShopSetupTwoState();
}

class _ShopSetupTwoState extends State<ShopSetupTwo> {
  bool isLoading = false;

  bool success = false;

  void loading() {
    setState(() {
      isLoading = true;
    });
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isLoading = false;
      });
      showSuccess();
    });
  }

  void showSuccess() {
    setState(() {
      success = true;
    });
    Future.delayed(Duration(seconds: 3), () {
      if (!context.mounted) return;
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) {
            return Home();
          },
        ),
      );
      // setState(() {
      //   success = false;
      // });
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

  void checkInputs() {
    if (selectedCountryCode == null ||
        selectedStateCode == null ||
        selectedCity == null) {
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
      returnShopProvider(context, listen: false).createShop(
        TempShopClass(
          createdAt: DateTime.now(),
          userId: AuthService().currentUser!.id,
          email:
              returnShopProvider(
                context,
                listen: false,
              ).email!,
          name:
              returnShopProvider(
                context,
                listen: false,
              ).name,
          state: selectedStateName,
          country: selectedCountryName,
          shopAddress:
              addressController.text.isEmpty
                  ? null
                  : addressController.text,
          city: selectedCityName,
        ),
      );
      loading();
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
      'ZmdubFNvNDloNjBrNWs2VGpTQ0ttem1Xa3A1SVdZZmpWTE5tdnBKVw=='; // Replace this

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
  void initState() {
    super.initState();
    countriesFuture = fetchCountries();
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
                    bottomSpace: 50,
                    iconData: Icons.home_work_outlined,
                    topSpace: 40,
                    theme: theme,
                    subTitle:
                        'Create a Shop to get Started.',
                    title: 'Shop Setup',
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
                                if (selectedCountryName ==
                                    null) {
                                  return;
                                }
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
                                );
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
                                if (selectedStateName ==
                                    null) {
                                  return;
                                }
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
                              text: 'Create Shop',
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
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader('Setting Up Your Shop'),
          ),
          Visibility(
            visible: success,
            child: returnCompProvider(
              context,
              listen: false,
            ).showSuccess('Shop Setup Complete'),
          ),
        ],
      ),
    );
  }
}
