import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/progress_bar.dart';
import 'package:stockall/components/text_fields/phone_number_text_field.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/shop_setup/components/text_field.dart';
import 'package:stockall/pages/shop_setup/shop_setup_two/shop_setup_two.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class ShopSetupDesktop extends StatefulWidget {
  final TempShopClass? shop;
  const ShopSetupDesktop({super.key, this.shop});

  @override
  State<ShopSetupDesktop> createState() =>
      _ShopSetupDesktopState();
}

class _ShopSetupDesktopState
    extends State<ShopSetupDesktop> {
  bool isLoading = false;
  bool showSuccess = false;
  TextEditingController nameController =
      TextEditingController();
  TextEditingController emailController =
      TextEditingController();
  TextEditingController numberController =
      TextEditingController();
  void checkInput() {
    if (widget.shop == null) {
      if (nameController.text.isEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            var theme = returnTheme(context);
            return InfoAlert(
              theme: theme,
              message: 'Shop Name Must be set',
              title: 'Empty Fields',
            );
          },
        );
      } else {
        returnShopProvider(context, listen: false).name =
            nameController.text.trim();
        returnShopProvider(context, listen: false).email =
            emailController.text.isEmpty
                ? AuthService().currentUser!.email!
                : emailController.text;
        returnShopProvider(context, listen: false).phone =
            numberController.text.isEmpty
                ? null
                : numberController.text;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ShopSetupTwo();
            },
          ),
        );
      }
    } else {
      if (nameController.text.isEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            var theme = returnTheme(context);
            return InfoAlert(
              theme: theme,
              message: 'Shop Name Must be set',
              title: 'Empty Fields',
            );
          },
        );
      } else {
        var theme = returnTheme(context, listen: false);
        var safeContext = context;
        var shopProvider = returnShopProvider(
          context,
          listen: false,
        );
        showDialog(
          context: safeContext,
          builder: (context) {
            return ConfirmationAlert(
              theme: theme,
              message:
                  'Are you sure you want to update your shop contact info?',
              title: 'Proceed?',
              action: () async {
                Navigator.of(safeContext).pop();
                setState(() {
                  isLoading = true;
                });

                await shopProvider.updateShopContactDetails(
                  shopId: widget.shop!.shopId!,
                  name: nameController.text,
                  email:
                      emailController.text.isNotEmpty
                          ? emailController.text
                          : AuthService()
                              .currentUser!
                              .email!,
                  phoneNumber:
                      numberController.text.isEmpty
                          ? null
                          : numberController.text,
                );

                setState(() {
                  isLoading = false;
                  showSuccess = true;
                });
                await Future.delayed(Duration(seconds: 2));
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
    nameController.dispose();
    emailController.dispose();
    numberController.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.shop != null) {
      nameController.text = widget.shop!.name;
      emailController.text = widget.shop!.email;
      numberController.text =
          widget.shop!.phoneNumber ?? '';
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
                                ? 'Edit Shop'
                                : 'Shop Setup',
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
                                ? 'Edit your shop information.'
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
                      position: -1,
                      calcValue: 0.08,
                      theme: theme,
                      percent: '0%',
                      title: 'Your Progress',
                    ),
                  ),
                  SizedBox(height: 10),
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
                            FormFieldShop(
                              isPhone: false,
                              isOptional: false,
                              theme: theme,
                              hintText:
                                  'Enter your shop Name',
                              title: 'Shop Name',
                              isEmail: false,
                              controller: nameController,
                            ),
                            FormFieldShop(
                              isPhone: false,
                              isOptional: true,
                              theme: theme,
                              hintText: 'Shop Email',
                              title: 'Enter Email',
                              message:
                                  'Uses your Personal Email if you don\'t set',
                              isEmail: true,
                              controller: emailController,
                            ),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                PhoneNumberTextField(
                                  theme: theme,
                                  hint: 'Shop Phone Number',
                                  title:
                                      'Enter Phone (Optional)',

                                  controller:
                                      numberController,
                                ),
                                Text(
                                  style: TextStyle(
                                    color:
                                        Colors
                                            .grey
                                            .shade600,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  'Uses your Personal Number if you don\'t set',
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(height: 5),
                                MainButtonP(
                                  themeProvider: theme,
                                  action: () {
                                    checkInput();
                                  },
                                  text:
                                      widget.shop == null
                                          ? 'Save and Proceed'
                                          : 'Update Shop',
                                ),
                                SizedBox(height: 5),
                                MainButtonTransparent(
                                  themeProvider: theme,
                                  action: () {
                                    Navigator.of(
                                      context,
                                    ).pop();
                                  },
                                  text: 'Cancel',
                                  constraints:
                                      BoxConstraints(),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
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
          ).showLoader('Updating'),
        ),
        Visibility(
          visible: showSuccess,
          child: returnCompProvider(
            context,
            listen: false,
          ).showSuccess('Updated Successfully'),
        ),
      ],
    );
  }
}
