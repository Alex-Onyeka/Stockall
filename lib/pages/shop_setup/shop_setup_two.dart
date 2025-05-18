import 'dart:async';
import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:stockitt/classes/temp_shop_class.dart';
import 'package:stockitt/components/alert_dialogues/info_alert.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/progress_bar.dart';
import 'package:stockitt/components/text_fields/general_textfield.dart';
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
          state: selectedStateName.trim(),
          country: selectedCountryName,
          shopAddress: addressController.text.trim(),
          city: selectedCityName,
        ),
      );
      loading();
    }
  }

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

  FutureOr<List<String>> countries = [];
  List<dynamic> countriesCodes = [];
  FutureOr<List<String>> states = [];
  List<dynamic> stateCodes = [];
  FutureOr<List<String>> cities = [];

  String? selectedCountryCode;
  String selectedCountryName = 'Select Your Country';
  String? selectedStateCode;
  String selectedStateName = 'Select Your State';
  String? selectedCity;
  String selectedCityName = 'Select Your City';

  @override
  void initState() {
    super.initState();
    fetchCountries();
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
                            DropdownSearch<String>(
                              items: (filter, loadProps) {
                                return countries;
                              },
                              enabled: true,
                              selectedItem:
                                  selectedCountryName,
                              onChanged: (value) {
                                setState(() {
                                  final selected =
                                      countriesCodes.firstWhere(
                                        (country) =>
                                            country['name'] ==
                                            value,
                                      );
                                  setState(() {
                                    selectedCountryCode =
                                        selected['iso2'] ??
                                        '0';
                                    selectedCountryName =
                                        selected['name'] ??
                                        'Not Found';
                                  });
                                });
                                fetchStates(
                                  selectedCountryCode!,
                                );
                                // print(countriesCodes);
                                // print(countries);
                              },
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                menuProps: MenuProps(
                                  backgroundColor:
                                      Colors.white,
                                ),
                                searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search Country here...',
                                    border:
                                        OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                            DropdownSearch<String>(
                              items: (filter, loadProps) {
                                return states;
                              },
                              enabled:
                                  selectedCountryCode !=
                                  null,
                              selectedItem:
                                  selectedStateName,
                              onChanged: (value) {
                                setState(() {
                                  final selected =
                                      stateCodes.firstWhere(
                                        (state) =>
                                            state['name'] ==
                                            value,
                                      );
                                  setState(() {
                                    selectedStateCode =
                                        selected['iso2'] ??
                                        '0';
                                    selectedStateName =
                                        selected['name'] ??
                                        '';
                                  });
                                });
                                fetchCities(
                                  selectedCountryCode!,
                                  selectedStateCode!,
                                );
                              },
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                menuProps: MenuProps(
                                  backgroundColor:
                                      Colors.white,
                                ),
                                searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search State here...',
                                    border:
                                        OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                            DropdownSearch<String>(
                              items: (filter, loadProps) {
                                return cities;
                              },
                              enabled:
                                  selectedStateCode != null,
                              selectedItem:
                                  selectedCityName,
                              onChanged: (value) {
                                setState(() {
                                  selectedCity = value;
                                  selectedCityName =
                                      value ??
                                      'Select Your City';
                                });
                              },
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                menuProps: MenuProps(
                                  backgroundColor:
                                      Colors.white,
                                ),
                                searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search City here...',
                                    border:
                                        OutlineInputBorder(),
                                  ),
                                ),
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
