import 'dart:async';
import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stockitt/classes/temp_customers_class.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/text_fields/general_textfield.dart';
import 'package:stockitt/components/text_fields/phone_number_text_field.dart';
import 'package:stockitt/main.dart';

class AddCustomerMobile extends StatefulWidget {
  final TempCustomersClass? customer;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  const AddCustomerMobile({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    this.customer,
  });

  @override
  State<AddCustomerMobile> createState() =>
      _AddCustomerMobileState();
}

class _AddCustomerMobileState
    extends State<AddCustomerMobile> {
  //
  //
  //

  bool isExtra = false;

  //
  //

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
      'ZmdubFNvNDloNjBrNWs2VGpTQ0ttem1Xa3A1SVdZZmpWTE5tdnBKVw==';

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
    if (widget.customer == null) {
      return;
    } else {
      setState(() {
        isExtra = true;
      });
      widget.nameController.text = widget.customer!.name;
      widget.emailController.text = widget.customer!.email;
      widget.phoneController.text = widget.customer!.phone;
      if (widget.customer!.address != null) {
        widget.addressController.text =
            widget.customer!.address!;
      }
      if (widget.customer!.country != null) {
        selectedCountryName = widget.customer!.country!;
      }

      if (widget.customer!.city != null) {
        selectedCityName = widget.customer!.city!;
      }
      if (widget.customer!.state != null) {
        selectedStateName = widget.customer!.state!;
      }
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            toolbarHeight: 60,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 10,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                ),
              ),
            ),
            centerTitle: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.h4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  widget.customer != null
                      ? 'Edit Customer Info'
                      : 'Add New Customer',
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        GeneralTextField(
                          title: 'Name',
                          hint: 'Enter Customers\' Name',
                          controller: widget.nameController,
                          lines: 1,
                          theme: theme,
                        ),
                        SizedBox(height: 15),
                        PhoneNumberTextField(
                          title: 'Phone Number',
                          hint:
                              'Enter Customers\' Phone Numer',
                          controller:
                              widget.phoneController,
                          theme: theme,
                        ),
                        SizedBox(height: 15),
                        GeneralTextField(
                          title: 'Email',
                          hint:
                              'Enter Customers\' Email Address',
                          controller:
                              widget.emailController,
                          lines: 1,
                          theme: theme,
                          isEmail: true,
                        ),
                        SizedBox(height: 20),
                        Row(
                          spacing: 5,
                          children: [
                            Icon(
                              size: 17,
                              color:
                                  theme
                                      .lightModeColor
                                      .secColor100,
                              Icons.warning_rounded,
                            ),
                            Text(
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              'The fields below are optional.',
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isExtra = !isExtra;
                            });
                          },
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            spacing: 5,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                isExtra
                                    ? 'Colapse'
                                    : 'Expand',
                              ),
                              Icon(
                                size: 35,
                                color: Colors.grey,
                                isExtra
                                    ? Icons
                                        .keyboard_arrow_up_rounded
                                    : Icons
                                        .keyboard_arrow_down_rounded,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Visibility(
                          visible: isExtra,
                          child: Column(
                            children: [
                              Column(
                                spacing: 10,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 0.0,
                                        ),
                                    child: Column(
                                      spacing: 20,
                                      children: [
                                        DropdownSearch<
                                          String
                                        >(
                                          items: (
                                            filter,
                                            loadProps,
                                          ) {
                                            return countries;
                                          },
                                          enabled: true,
                                          selectedItem:
                                              selectedCountryName,
                                          onChanged: (
                                            value,
                                          ) {
                                            setState(() {
                                              final selected =
                                                  countriesCodes.firstWhere(
                                                    (
                                                      country,
                                                    ) =>
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
                                            showSearchBox:
                                                true,
                                            menuProps: MenuProps(
                                              backgroundColor:
                                                  Colors
                                                      .white,
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
                                        DropdownSearch<
                                          String
                                        >(
                                          items: (
                                            filter,
                                            loadProps,
                                          ) {
                                            return states;
                                          },
                                          enabled:
                                              selectedCountryCode !=
                                              null,
                                          selectedItem:
                                              selectedStateName,
                                          onChanged: (
                                            value,
                                          ) {
                                            setState(() {
                                              final selected =
                                                  stateCodes.firstWhere(
                                                    (
                                                      state,
                                                    ) =>
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
                                            showSearchBox:
                                                true,
                                            menuProps: MenuProps(
                                              backgroundColor:
                                                  Colors
                                                      .white,
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
                                        DropdownSearch<
                                          String
                                        >(
                                          items: (
                                            filter,
                                            loadProps,
                                          ) {
                                            return cities;
                                          },
                                          enabled:
                                              selectedStateCode !=
                                              null,
                                          selectedItem:
                                              selectedCityName,
                                          onChanged: (
                                            value,
                                          ) {
                                            setState(() {
                                              selectedCity =
                                                  value;
                                              selectedCityName =
                                                  value ??
                                                  'Select Your City';
                                            });
                                          },
                                          popupProps: PopupProps.menu(
                                            showSearchBox:
                                                true,
                                            menuProps: MenuProps(
                                              backgroundColor:
                                                  Colors
                                                      .white,
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
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              GeneralTextField(
                                title: 'Address',
                                hint:
                                    'Enter Address (32 close, behind school gate.)',
                                controller:
                                    widget
                                        .addressController,
                                lines: 1,
                                theme: theme,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                MainButtonP(
                  themeProvider: theme,
                  action: () {
                    returnValidate(
                      context,
                      listen: false,
                    ).checkInputs(
                      conditionsThree: false,
                      conditionsFour: false,
                      conditionsSecond: returnValidate(
                        listen: false,
                        context,
                      ).isValidEmail(
                        widget.emailController.text,
                      ),
                      conditionsFirst:
                          widget
                              .nameController
                              .text
                              .isEmpty ||
                          widget
                              .phoneController
                              .text
                              .isEmpty ||
                          widget
                              .emailController
                              .text
                              .isEmpty,
                      context: context,
                      action: () {
                        if (widget.customer == null) {
                          returnCustomers(
                            context,
                            listen: false,
                          ).addCustomerMain(
                            TempCustomersClass(
                              shopId:
                                  returnShopProvider(
                                    context,
                                    listen: false,
                                  ).userShop!.shopId!,
                              country: selectedCountryName,
                              dateAdded: DateTime.now(),

                              name:
                                  widget
                                      .nameController
                                      .text,
                              email:
                                  widget
                                      .emailController
                                      .text,
                              phone:
                                  widget
                                      .phoneController
                                      .text,
                              address:
                                  widget
                                      .addressController
                                      .text,
                              city: selectedCityName,
                              state: selectedStateName,
                            ),
                          );
                        } else {
                          returnCustomers(
                            context,
                            listen: false,
                          ).updateCustomerMain(
                            TempCustomersClass(
                              id: widget.customer!.id,
                              shopId:
                                  returnShopProvider(
                                    context,
                                    listen: false,
                                  ).userShop!.shopId!,
                              name:
                                  widget
                                      .nameController
                                      .text,
                              email:
                                  widget
                                      .emailController
                                      .text,
                              phone:
                                  widget
                                      .phoneController
                                      .text,
                              address:
                                  widget
                                      .addressController
                                      .text,
                              city: selectedCityName,
                              state: selectedStateName,
                              country: selectedCountryName,
                              dateAdded:
                                  widget
                                      .customer!
                                      .dateAdded,
                            ),
                          );
                        }
                        returnCompProvider(
                          context,
                          listen: false,
                        ).successAction(
                          () => Navigator.of(context).pop(),
                        );
                      },
                    );
                  },
                  text:
                      widget.customer != null
                          ? 'Update Details'
                          : 'Add Customer',
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: returnCompProvider(context).isLoaderOn,
          child: returnCompProvider(
            context,
            listen: false,
          ).showSuccess(
            widget.customer != null
                ? 'Customer Updated Successfully'
                : 'Customer Added Successfully',
          ),
        ),
      ],
    );
  }
}
