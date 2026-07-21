import 'package:flutter/material.dart';
import 'package:stockall/classes/locations/country_model.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/main_dropdown_only.dart';
import 'package:stockall/components/text_fields/phone_number_text_field.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/shop_setup/shop_setup_two/functions.dart';

class AddSupplierMobile extends StatefulWidget {
  final SuppliersClass? supplier;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  const AddSupplierMobile({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    this.supplier,
  });

  @override
  State<AddSupplierMobile> createState() =>
      _AddSupplierMobileState();
}

class _AddSupplierMobileState
    extends State<AddSupplierMobile> {
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
    var supplierProvider = returnSuppliersProvider();
    if (widget.supplier == null) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return ConfirmationAlert(
            theme: theme,
            message:
                'Are you sure you want to proceed with Adding this Supplier to your Business?',
            title: 'Create Supplier?',
            action: () async {
              Navigator.of(dialogContext).pop();
              setState(() {
                isLoading = true;
              });
              await supplierProvider.addSupplierMain(
                SuppliersClass(
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
                  createdAt: DateTime.now(),

                  name: widget.nameController.text,
                  email:
                      widget.emailController.text.isNotEmpty
                          ? widget.emailController.text
                          : null,
                  phone:
                      widget.phoneController.text.isEmpty
                          ? null
                          : widget.phoneController.text,
                  address: widget.addressController.text,
                  departmentName:
                      returnDepartmentProvider()
                          .currentDepartment()
                          ?.name,
                  departmentId:
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
            title: 'Update Supplier?',
            action: () async {
              Navigator.of(confirmContext).pop();
              setState(() {
                isLoading = true;
              });
              await supplierProvider.updateSupplierrMain(
                SuppliersClass(
                  updatedAt: DateTime.now(),
                  uuid: widget.supplier!.uuid,
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
                  createdAt: widget.supplier!.createdAt,
                  departmentName:
                      widget.supplier!.departmentName,
                  departmentId:
                      widget.supplier!.departmentId,
                ),
                context,
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
    if (widget.supplier != null) {
      WidgetsBinding.instance.addPostFrameCallback((
        _,
      ) async {
        setState(() {
          isExtra = true;
        });
        widget.nameController.text = widget.supplier!.name;
        widget.emailController.text =
            widget.supplier!.email ?? '';
        widget.phoneController.text =
            widget.supplier!.phone ?? '';
        if (widget.supplier!.address != null) {
          widget.addressController.text =
              widget.supplier!.address!;
        }
        returnCountryProvider().selectCountry(
          widget.supplier!.country,
          true,
        );
        returnCountryProvider().setCustomState(
          StateModel(
            stateName: widget.supplier!.state,
            code:
                returnCountryProvider().states
                        .where(
                          (st) =>
                              st.stateName ==
                              widget.supplier!.state,
                        )
                        .isNotEmpty
                    ? returnCountryProvider().states
                        .where(
                          (st) =>
                              st.stateName ==
                              widget.supplier!.state,
                        )
                        .first
                        .code
                    : 'code',
          ),
        );
        returnCountryProvider().selectCity(
          widget.supplier!.city,
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
        Scaffold(
          appBar: AppBar(
            toolbarHeight: 60,
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
                  widget.supplier != null
                      ? 'Edit Supplier Info'
                      : 'Add New Supplier',
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
                          hint: 'Enter Suppliers\' Name',
                          controller: widget.nameController,
                          lines: 1,
                          theme: theme,
                        ),
                        SizedBox(height: 15),
                        PhoneNumberTextField(
                          title: 'Phone Number',
                          hint:
                              'Enter Suppliers\' Phone Numer',
                          controller:
                              widget.phoneController,
                          theme: theme,
                        ),
                        SizedBox(height: 15),
                        GeneralTextField(
                          title: 'Email (Optional)',
                          hint:
                              'Enter Suppliers\' Email Address',
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
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            spacing: 20,
                            children: [
                              MainDropdownOnly(
                                hint:
                                    returnCountryProvider(
                                          context: context,
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
                                          context: context,
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
                                    controller: controller,
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
                                    controller: controller,
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
                      widget.supplier != null
                          ? 'Update Details'
                          : 'Add Supplier',
                ),
                SizedBox(height: 20),
              ],
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
