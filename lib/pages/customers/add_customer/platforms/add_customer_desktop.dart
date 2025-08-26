import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stockall/classes/temp_customers_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/small_button_main.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/components/text_fields/main_dropdown_only.dart';
import 'package:stockall/components/text_fields/phone_number_text_field.dart';
import 'package:stockall/main.dart';

class AddCustomerDesktop extends StatefulWidget {
  final TempCustomersClass? customer;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  const AddCustomerDesktop({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    this.customer,
  });

  @override
  State<AddCustomerDesktop> createState() =>
      _AddCustomerDesktopState();
}

class _AddCustomerDesktopState
    extends State<AddCustomerDesktop> {
  TextEditingController controller =
      TextEditingController();

  bool stateSet = false;

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
  //
  //
  //

  bool isExtra = false;
  TextEditingController countryController =
      TextEditingController();
  TextEditingController cityController =
      TextEditingController();
  TextEditingController stateController =
      TextEditingController();

  //
  //
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
  void initState() {
    super.initState();
    countriesFuture = fetchCountries();
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
        DesktopCenterContainer(
          mainWidget: Scaffold(
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
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.h4.fontSize,
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
                            controller:
                                widget.nameController,
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
                            title: 'Email (Optional)',
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
                                          MainDropdownOnly(
                                            hint:
                                                selectedCountryName ??
                                                'Select Your Country',
                                            theme: theme,
                                            isOpen: false,
                                            onTap: () {
                                              showGeneralDialog(
                                                context:
                                                    context,
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
                                              ).then((
                                                context,
                                              ) {
                                                setState(
                                                  () {},
                                                );
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
                                                                                              'Add Custom State',
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
                                            },
                                            valueSet:
                                                selectedStateName !=
                                                null,
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
                                            },
                                            valueSet:
                                                selectedCityName !=
                                                null,
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
                        conditionsSecond:
                            widget
                                    .emailController
                                    .text
                                    .isNotEmpty
                                ? returnValidate(
                                  listen: false,
                                  context,
                                ).isValidEmail(
                                  widget
                                      .emailController
                                      .text,
                                )
                                : true,
                        conditionsFirst:
                            widget
                                .nameController
                                .text
                                .isEmpty ||
                            widget
                                .phoneController
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
                                country:
                                    selectedCountryName ==
                                            'Select Your Country'
                                        ? null
                                        : selectedCountryName,
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
                                city:
                                    selectedCityName ==
                                            'Select Your City'
                                        ? null
                                        : selectedCityName,
                                state:
                                    selectedStateName ==
                                            'Select Your State'
                                        ? null
                                        : selectedStateName,
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
                                city:
                                    selectedCityName ==
                                            'Select Your City'
                                        ? null
                                        : selectedCityName,
                                state:
                                    selectedStateName ==
                                            'Select Your State'
                                        ? null
                                        : selectedStateName,
                                country:
                                    selectedCountryName ==
                                            'Select Your Country'
                                        ? null
                                        : selectedCountryName,
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
                            () =>
                                Navigator.of(context).pop(),
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
