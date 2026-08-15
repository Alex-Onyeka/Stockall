import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/locations/country_model.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/progress_bar.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/main_dropdown_only.dart';
// import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/pages/shop_setup/shop_setup_two/functions.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class ShopSetupTwoMobile extends StatefulWidget {
  final TempShopClass? shop;
  const ShopSetupTwoMobile({super.key, this.shop});

  @override
  State<ShopSetupTwoMobile> createState() =>
      _ShopSetupTwoMobileState();
}

class _ShopSetupTwoMobileState
    extends State<ShopSetupTwoMobile> {
  bool isLoading = false;

  bool success = false;

  TextEditingController controller =
      TextEditingController();
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
    var shopProvider = returnShopProvider();
    var theme = returnTheme(context, listen: false);
    var safeContext = context;
    if (returnCountryProvider().selectedCountry == null ||
        returnCountryProvider().selectedState == null ||
        returnCountryProvider().selectedCity == null) {
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
    } else if (returnCountryProvider().selectedCurrency ==
        null) {
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
          builder: (dialogContext) {
            return ConfirmationAlert(
              theme: theme,
              message:
                  'Are you sure you want to proceed with creating your shop?',
              title: 'Create Shop?',
              action: () async {
                Navigator.of(dialogContext).pop();
                setState(() {
                  isLoading = true;
                });
                await shopProvider.createShop(
                  TempShopClass(
                    manageProductionItems: false,
                    manageProductions: false,
                    manageProductionsStorage: false,
                    manageInventoryStorage: false,
                    closeSaleTimeString: null,
                    isVerified: false,
                    currency:
                        returnCountryProvider()
                            .selectedCurrency
                            ?.symbol ??
                        '₦',
                    employees: [],
                    createdAt: DateTime.now(),
                    userId:
                        AuthService().currentUser ??
                        returnUserProviderSingle()
                            .currentUserMain
                            ?.userId ??
                        '',
                    email: shopProvider.email,
                    name: shopProvider.name,
                    state:
                        returnCountryProvider()
                            .selectedState
                            ?.stateName,
                    country:
                        returnCountryProvider()
                            .selectedCountry
                            ?.country,
                    shopAddress:
                        addressController.text.isEmpty
                            ? null
                            : addressController.text,
                    city:
                        returnCountryProvider()
                            .selectedCity,
                    phoneNumber: shopProvider.phone,
                    refCode:
                        referralController.text
                            .trim()
                            .toLowerCase(),
                    language: 'en',
                    isHeadQuarters:
                        returnShopProvider()
                                .userShops
                                .isEmpty
                            ? true
                            : false,
                    applyVAT: false,
                    // useGroupUnit: false,
                    wholeSale: false,
                    manageDepartments: false,
                    printSalesDocket: false,
                    trackCart: false,
                    accessPin: '0000',
                  ),
                  safeContext,
                );
                await Future.delayed(Duration(seconds: 1));
                setState(() {
                  isLoading = false;
                  success = true;
                });

                if (safeContext.mounted) {
                  if (returnShopProvider()
                      .userShops
                      .isEmpty) {
                    await Future.delayed(
                      Duration(seconds: 2),
                    );
                    Navigator.pushReplacement(
                      // ignore: use_build_context_synchronously
                      safeContext,
                      MaterialPageRoute(
                        builder: (context) {
                          return BasePage();
                        },
                      ),
                    );
                  } else {
                    await returnShopProvider()
                        .getUserShops();
                    // ignore: use_build_context_synchronously
                    Navigator.of(safeContext).pop();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  }
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
                  // shopId: widget.shop!.shopId!,
                  country:
                      returnCountryProvider()
                          .selectedCountry!
                          .country!,
                  state:
                      returnCountryProvider()
                          .selectedState!
                          .stateName!,
                  city:
                      returnCountryProvider().selectedCity!,
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

  @override
  void dispose() {
    super.dispose();
    countryController.dispose();
    stateController.dispose();
    cityController.dispose();
    addressController.dispose();
    referralController.dispose();
    currencyController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnCountryProvider().clearAll();
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.shop != null) {
      WidgetsBinding.instance.addPostFrameCallback((
        _,
      ) async {
        addressController.text =
            widget.shop!.shopAddress ?? '';
        returnCountryProvider().setCurrency(
          widget.shop!.currency,
        );
        returnCountryProvider().selectCountry(
          widget.shop!.country,
          true,
        );
        returnCountryProvider().setCustomState(
          StateModel(
            stateName: widget.shop!.state,
            code:
                returnCountryProvider().states
                        .where(
                          (st) =>
                              st.stateName ==
                              widget.shop!.state,
                        )
                        .isNotEmpty
                    ? returnCountryProvider().states
                        .where(
                          (st) =>
                              st.stateName ==
                              widget.shop!.state,
                        )
                        .first
                        .code
                    : 'code',
          ),
        );
        returnCountryProvider().selectCity(
          widget.shop!.city,
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
                    bottomSpace: 40,
                    iconData: Icons.home_work_outlined,
                    topSpace: 30,
                    theme: theme,
                    subTitle:
                        widget.shop != null
                            ? 'Update shop address details.'
                            : 'Create a Shop to get Started.',
                    title:
                        widget.shop != null
                            ? 'Update Shop Address'
                            : 'Set Shop Address',
                  ),
                  SizedBox(height: 20),
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
                                  returnCountryProvider(
                                        context: context,
                                      )
                                      .selectedCountry
                                      ?.country ??
                                  'Select Your Country',
                              theme: theme,
                              isOpen: false,
                              onTap: () {
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
                            Column(
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
                                          .selectedState
                                          ?.stateName ??
                                      'State',
                                  theme: theme,
                                  isOpen: false,
                                  onTap: () {
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
                                  onTap: () {
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
                              ],
                            ),
                            Visibility(
                              visible: widget.shop == null,
                              child: MainDropdownOnly(
                                valueSet:
                                    returnCountryProvider(
                                      context: context,
                                    ).selectedCurrency !=
                                    null,
                                hint:
                                    returnCountryProvider(
                                          context: context,
                                        )
                                        .selectedCurrency
                                        ?.currency ??
                                    'Select Your Currency',
                                theme: theme,
                                isOpen: false,
                                onTap: () {
                                  selectCurrency(
                                    context,
                                    theme,
                                    currencyController,
                                  );
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

                            GeneralTextField(
                              title:
                                  'Referral Code (Optional)',
                              theme: theme,
                              hint: 'Enter Referral Code',
                              controller:
                                  referralController,
                              lines: 1,
                            ),

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
                            SizedBox(height: 40),
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
            ).showLoader(
              message:
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
      ),
    );
  }
}
