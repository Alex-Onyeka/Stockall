import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/profile/profile_page.dart';
import 'package:stockall/pages/shop_setup/edit_receipt_page/edit_receipt.dart';
import 'package:stockall/pages/shop_setup/shop_page/shop_page.dart';

class SettingsPageMobile extends StatefulWidget {
  const SettingsPageMobile({super.key});

  @override
  State<SettingsPageMobile> createState() =>
      _SettingsPageMobileState();
}

class _SettingsPageMobileState
    extends State<SettingsPageMobile> {
  final passwordController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          appBar: appBar(
            context: context,
            title: 'General Settings',
            backAction: () {
              Navigator.of(context).pop();
            },
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        spacing: 10,
                        children: [
                          NavListTileDesktopAlt(
                            title: 'Account',
                            action: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ProfilePage();
                                  },
                                ),
                              );
                            },
                            height: 18,
                            icon: Icons.person,
                          ),
                          Visibility(
                            visible: authorization(
                              authorized:
                                  Authorizations()
                                      .manageShop,
                              context: context,
                            ),
                            child: NavListTileDesktopAlt(
                              height: 18,
                              action: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ShopPage();
                                    },
                                  ),
                                );
                              },
                              title: 'Manage Shop',
                              icon: Icons.home_filled,
                            ),
                          ),
                          Visibility(
                            visible: authorization(
                              authorized:
                                  Authorizations()
                                      .editReceiptTemplate,
                              context: context,
                            ),
                            child: NavListTileDesktopAlt(
                              height: 18,
                              action: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return EditReceipt();
                                    },
                                  ),
                                );
                              },
                              title:
                                  'Edit Receipt Template',
                              icon: Icons.receipt,
                            ),
                          ),
                          Visibility(
                            visible: authorization(
                              authorized:
                                  Authorizations()
                                      .contactStockall,
                              context: context,
                            ),
                            child: NavListTileDesktopAlt(
                              height: 18,
                              action: () async {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ConfirmationAlert(
                                      theme: theme,
                                      message:
                                          'You are about to download and install our official Native application, for better experience.',
                                      title:
                                          screenWidth(
                                                    context,
                                                  ) >
                                                  tabletScreenSmall
                                              ? 'Proceed to Download Desktop App'
                                              : 'Proceed to Download Mobile App',
                                      action: () async {
                                        Navigator.of(
                                          context,
                                        ).pop();
                                        await downloadApkFromApp(
                                          context: context,
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              title:
                                  screenWidth(context) >
                                          tabletScreenSmall
                                      ? 'Download Desktop App'
                                      : 'Download Mobile App',
                              icon: Icons.download_outlined,
                            ),
                          ),
                          Visibility(
                            visible: authorization(
                              authorized:
                                  Authorizations()
                                      .contactStockall,
                              context: context,
                            ),
                            child: NavListTileDesktopAlt(
                              height: 18,
                              action: () async {
                                phoneCall();
                              },
                              title: 'Contact Us',
                              icon: Icons.phone,
                            ),
                          ),
                          Visibility(
                            visible: authorization(
                              authorized:
                                  Authorizations()
                                      .contactStockall,
                              context: context,
                            ),
                            child: NavListTileDesktopAlt(
                              height: 14,
                              action: () async {
                                openWhatsApp();
                              },
                              title: 'Chat With Us',
                              svg: whatsappIconSvg,
                            ),
                          ),
                          NavListTileDesktopAlt(
                            height: 18,
                            action: () {},
                            title: 'Privacy P. & Terms/C.',
                            icon: Icons.menu_book_rounded,
                          ),
                          NavListTileDesktopAlt(
                            height: 18,
                            action: () {},
                            title: 'Go to Wesbite.',
                            icon: Icons.language_rounded,
                          ),
                          NavListTileDesktopAlt(
                            height: 18,
                            action: () {
                              var safeContext = context;
                              var shopP =
                                  returnShopProvider(
                                    context,
                                    listen: false,
                                  );
                              var userP =
                                  returnUserProvider(
                                    context,
                                    listen: false,
                                  );
                              showDialog(
                                context: context,
                                builder: (confirmDialog) {
                                  return ConfirmationAlert(
                                    theme: theme,
                                    message:
                                        'You are about to delete an entire Store, with all its data. You will loose all the data of this store after this process. This Action can not be reversed. Are you sure you want to proceed?',
                                    title: 'Delete Shop?',
                                    action: () async {
                                      Navigator.of(
                                        confirmDialog,
                                      ).pop();
                                      showDialog(
                                        context:
                                            safeContext,
                                        builder: (
                                          newDialog,
                                        ) {
                                          return DialogTemplate(
                                            theme: theme,
                                            message:
                                                'You have to enter your password to verify that you are the owner this shop, in other to delete',
                                            title:
                                                'Enter Password',
                                            action: () async {
                                              var password =
                                                  userP
                                                      .currentUserMain!
                                                      .password;
                                              if (passwordController
                                                  .text
                                                  .isEmpty) {
                                                showDialog(
                                                  // ignore: use_build_context_synchronously
                                                  context:
                                                      context,
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return InfoAlert(
                                                      theme: returnTheme(
                                                        context,
                                                        listen:
                                                            false,
                                                      ),
                                                      message:
                                                          'Password field cannot be empty. You must enter you password in the password field to proceed.',
                                                      title:
                                                          'Password Empty',
                                                    );
                                                  },
                                                );
                                                return;
                                              }
                                              if (password !=
                                                  passwordController
                                                      .text) {
                                                showDialog(
                                                  // ignore: use_build_context_synchronously
                                                  context:
                                                      context,
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return InfoAlert(
                                                      theme: returnTheme(
                                                        context,
                                                        listen:
                                                            false,
                                                      ),
                                                      message:
                                                          'The Password you entered is Incorrect. Please check the password and try again.',
                                                      title:
                                                          'Password Incorrect.',
                                                    );
                                                  },
                                                );
                                                return;
                                              }
                                              Navigator.of(
                                                newDialog,
                                              ).pop();
                                              setState(() {
                                                isLoading =
                                                    true;
                                              });
                                              var res = await shopP
                                                  .deleteShop(
                                                    context:
                                                        context,
                                                  );
                                              if (res ==
                                                  0) {
                                                setState(() {
                                                  isLoading =
                                                      false;
                                                });
                                              }
                                            },
                                            widget: SizedBox(
                                              width:
                                                  double
                                                      .infinity,
                                              child: EmailTextField(
                                                controller:
                                                    passwordController,
                                                theme:
                                                    theme,
                                                isEmail:
                                                    false,
                                                hint:
                                                    'Enter Password',
                                                title:
                                                    'Password',
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            title: 'Delete Shop',
                            color: Colors.red,
                            icon:
                                Icons
                                    .delete_outline_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    color: Colors.transparent,
                    height: 20,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: Row(
                        spacing: 10,
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Row(
                            spacing: 10,
                            mainAxisAlignment:
                                MainAxisAlignment.start,
                            children: [
                              // SizedBox(
                              //   width: 20,
                              //   child: Center(),
                              // ),
                              Text(
                                style: TextStyle(
                                  color:
                                      Colors.grey.shade900,
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontStyle:
                                      FontStyle.italic,
                                ),
                                'Current App Build: ',
                              ),
                            ],
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.bold,
                            ),
                            currentUpdate.toString(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // SizedBox(
                  //   height: screenHeight(context) * 0.2,
                  // ),
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
          ).showLoader(message: 'Deleting Store'),
        ),
      ],
    );
  }
}
