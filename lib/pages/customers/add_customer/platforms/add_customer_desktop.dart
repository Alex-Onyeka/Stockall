import 'package:flutter/material.dart';
import 'package:stockall/classes/locations/country_model.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/main_dropdown_only.dart';
import 'package:stockall/components/text_fields/phone_number_text_field.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/shop_setup/shop_setup_two/functions.dart';

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

  bool isExtra = false;
  TextEditingController countryController =
      TextEditingController();
  TextEditingController cityController =
      TextEditingController();
  TextEditingController stateController =
      TextEditingController();

  bool isLoading = false;

  //

  void checkInputs() {
    var theme = returnTheme(context, listen: false);
    var customerProvider = returnCustomersSingle();
    if (widget.customer == null) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return ConfirmationAlert(
            theme: theme,
            message:
                'Are you sure you want to proceed with Adding this customer to your Business?',
            title: 'Create Customer?',
            action: () async {
              Navigator.of(dialogContext).pop();
              setState(() {
                isLoading = true;
              });
              await customerProvider.addCustomerMain(
                TempCustomersClass(
                  balance: 0,
                  cashReward: 0,
                  updatedAt: DateTime.now(),
                  shopId:
                      returnShopProvider()
                          .userShop()!
                          .shopId!,
                  country:
                      returnCountryProvider()
                          .selectedCountry
                          ?.country,
                  state:
                      returnCountryProvider()
                          .selectedState
                          ?.stateName,
                  city:
                      returnCountryProvider().selectedCity,
                  address:
                      widget.addressController.text.isEmpty
                          ? null
                          : widget.addressController.text,
                  dateAdded: DateTime.now(),

                  name: widget.nameController.text,
                  email: widget.emailController.text,
                  phone: widget.phoneController.text,
                  departmentName:
                      returnDepartmentProvider()
                          .currentDepartment()
                          ?.name,
                  departmentUuid:
                      returnDepartmentProvider()
                          .currentDepartment()
                          ?.uuid,
                ),
                context,
              );
              Navigator.of(context).pop();
            },
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (confirmContext) {
          return ConfirmationAlert(
            theme: theme,
            message:
                'Are you sure you want to proceed with Update?',
            title: 'Update Customer?',
            action: () async {
              Navigator.of(confirmContext).pop();
              setState(() {
                isLoading = true;
              });
              await customerProvider.updateCustomerMain(
                TempCustomersClass(
                  balance: widget.customer!.balance,
                  cashReward: widget.customer!.cashReward,
                  uuid: widget.customer!.uuid,
                  id: widget.customer!.id,
                  shopId:
                      returnShopProvider()
                          .userShop()!
                          .shopId!,
                  name: widget.nameController.text,
                  email: widget.emailController.text,
                  phone: widget.phoneController.text,
                  address: widget.addressController.text,
                  country:
                      returnCountryProvider()
                          .selectedCountry
                          ?.country,
                  state:
                      returnCountryProvider()
                          .selectedState
                          ?.stateName,
                  city:
                      returnCountryProvider().selectedCity,
                  dateAdded: widget.customer!.dateAdded,
                  updatedAt: DateTime.now(),
                  departmentName:
                      widget.customer!.departmentName,
                  departmentUuid:
                      widget.customer!.departmentUuid,
                ),
              );
              Navigator.of(context).pop();
            },
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      WidgetsBinding.instance.addPostFrameCallback((
        _,
      ) async {
        setState(() {
          isExtra = true;
        });
        widget.nameController.text = widget.customer!.name;
        widget.emailController.text =
            widget.customer!.email;
        widget.phoneController.text =
            widget.customer!.phone;
        if (widget.customer!.address != null) {
          widget.addressController.text =
              widget.customer!.address!;
        }
        returnCountryProvider().selectCountry(
          widget.customer!.country,
          true,
        );
        returnCountryProvider().setCustomState(
          StateModel(
            stateName: widget.customer!.state,
            code:
                returnCountryProvider().states
                        .where(
                          (st) =>
                              st.stateName ==
                              widget.customer!.state,
                        )
                        .isNotEmpty
                    ? returnCountryProvider().states
                        .where(
                          (st) =>
                              st.stateName ==
                              widget.customer!.state,
                        )
                        .first
                        .code
                    : 'code',
          ),
        );
        returnCountryProvider().selectCity(
          widget.customer!.city,
        );
        await returnCountryProvider().fetchCountries();
        await returnCountryProvider().fetchStates();
        await returnCountryProvider().fetchCities();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((
        _,
      ) async {
        await returnCountryProvider().fetchCountries();
      });
    }
  }

  //
  //
  //
  @override
  void dispose() {
    super.dispose();
    countryController.dispose();
    stateController.dispose();
    cityController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnCountryProvider().clearAll();
    });
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
                            mouseCursor:
                                SystemMouseCursors.click,
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
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              spacing: 20,
                              children: [
                                MainDropdownOnly(
                                  hint:
                                      returnCountryProvider(
                                            context:
                                                context,
                                          )
                                          .selectedCountry
                                          ?.country ??
                                      'Select Your Country',
                                  theme: theme,
                                  isOpen: false,
                                  onTap: () async {
                                    selectCountry(
                                      context: context,
                                      countryController:
                                          countryController,
                                    );
                                  },
                                  valueSet:
                                      returnCountryProvider(
                                        context: context,
                                      ).selectedCountry !=
                                      null,
                                ),
                                MainDropdownOnly(
                                  hint:
                                      returnCountryProvider(
                                            context:
                                                context,
                                          )
                                          .selectedState
                                          ?.stateName ??
                                      'State',
                                  theme: theme,
                                  isOpen: false,
                                  onTap: () async {
                                    selectState(
                                      context: context,
                                      stateController:
                                          stateController,
                                      controller:
                                          controller,
                                    );
                                  },
                                  valueSet:
                                      returnCountryProvider(
                                        context: context,
                                      ).selectedState !=
                                      null,
                                ),

                                MainDropdownOnly(
                                  hint:
                                      returnCountryProvider(
                                        context: context,
                                      ).selectedCity ??
                                      'City',
                                  theme: theme,
                                  isOpen: false,
                                  onTap: () async {
                                    selectCity(
                                      context: context,
                                      cityController:
                                          cityController,
                                      controller:
                                          controller,
                                    );
                                  },
                                  valueSet:
                                      returnCountryProvider(
                                        context: context,
                                      ).selectedCity !=
                                      null,
                                ),
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
                      checkInputs();
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
          visible: isLoading,
          child: returnCompProvider(
            context,
            listen: false,
          ).showLoader(message: 'Loading'),
        ),
      ],
    );
  }
}
