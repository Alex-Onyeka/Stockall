import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/helpers/clean_up_url/clean_up_url.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_landing/auth_landing.dart';
import 'package:stockall/pages/shop_setup/banner_screen/copy_staff_id/copy_staff_id.dart';
import 'package:stockall/pages/shop_setup/shop_setup_one/shop_setup_page.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class ShopBannerScreenDesktop extends StatefulWidget {
  const ShopBannerScreenDesktop({super.key});

  @override
  State<ShopBannerScreenDesktop> createState() =>
      _ShopBannerScreenDesktopState();
}

class _ShopBannerScreenDesktopState
    extends State<ShopBannerScreenDesktop> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60.0,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 30),
                        LottieBuilder.asset(
                          shopSetup,
                          height: 140,
                        ),
                        SizedBox(height: 15),
                        Text(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color:
                                theme
                                    .lightModeColor
                                    .secColor200,
                          ),
                          'Your account has been Created Successfully',
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          spacing: 15,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setRole(context, theme);
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(
                                        horizontal: 65,
                                        vertical: 60,
                                      ),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            const Color.fromARGB(
                                              23,
                                              0,
                                              0,
                                              0,
                                            ),
                                        blurRadius: 10,
                                      ),
                                    ],
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(
                                          10,
                                        ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        textAlign:
                                            TextAlign
                                                .center,
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .h3
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Set Up Your Store To Start Selling',
                                      ),
                                      SizedBox(height: 30),
                                      MainButtonP(
                                        themeProvider:
                                            theme,
                                        action: () {
                                          setRole(
                                            context,
                                            theme,
                                          );
                                        },
                                        text: 'Create Shop',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return CopyStaffId();
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(
                                        horizontal: 65,
                                        vertical: 60,
                                      ),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            const Color.fromARGB(
                                              23,
                                              0,
                                              0,
                                              0,
                                            ),
                                        blurRadius: 10,
                                      ),
                                    ],
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(
                                          10,
                                        ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        textAlign:
                                            TextAlign
                                                .center,
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .h3
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Or, don\'t you have a Store?',
                                      ),
                                      SizedBox(height: 30),
                                      MainButtonTransparent(
                                        themeProvider:
                                            theme,
                                        constraints:
                                            BoxConstraints(),
                                        text:
                                            'Sign Up as a Staff',
                                        action: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return CopyStaffId();
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                    Row(
                      spacing: 20,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(10),
                              color: Colors.grey.shade100,
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                if (Theme.of(
                                          context,
                                        ).platform ==
                                        TargetPlatform
                                            .windows ||
                                    Theme.of(
                                          context,
                                        ).platform ==
                                        TargetPlatform
                                            .macOS ||
                                    Theme.of(
                                          context,
                                        ).platform ==
                                        TargetPlatform
                                            .linux) {
                                  Navigator.of(
                                    context,
                                  ).pushNamedAndRemoveUntil(
                                    '/',
                                    (route) => false,
                                  );
                                } else {
                                  performRestart();
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(
                                        10,
                                      ),
                                  border: Border.all(
                                    color:
                                        Colors
                                            .grey
                                            .shade400,
                                    width: 0.7,
                                  ),
                                ),
                                padding:
                                    EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                child: Center(
                                  child: Row(
                                    spacing: 5,
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b1
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          color:
                                              theme
                                                  .lightModeColor
                                                  .secColor200,
                                        ),
                                        'Refresh Page to Verify',
                                      ),
                                      Icon(
                                        size: 22,
                                        color: Colors.grey,
                                        Icons.refresh_sharp,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(10),
                              color: Colors.grey.shade100,
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 0.7,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) {
                                    return ConfirmationAlert(
                                      theme: theme,
                                      message:
                                          'Are you sure you want to Log out?',
                                      title: 'Log Out',
                                      action: () async {
                                        Navigator.of(
                                          dialogContext,
                                        ).pop();
                                        setState(() {
                                          isLoading = true;
                                        });
                                        await AuthService()
                                            .signOut(
                                              context:
                                                  context,
                                              allowLogout:
                                                  true,
                                            );
                                        if (context
                                            .mounted) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return AuthLanding();
                                              },
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(
                                        10,
                                      ),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    spacing: 5,
                                    children: [
                                      Icon(
                                        color:
                                            const Color.fromARGB(
                                              206,
                                              244,
                                              67,
                                              54,
                                            ),
                                        size: 20,
                                        Icons
                                            .logout_rounded,
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          color:
                                              Colors.grey,
                                        ),
                                        'Log Out',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                  ],
                ),
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

Future<dynamic> setRole(
  BuildContext context,
  ThemeProvider theme,
) {
  return showDialog(
    context: context,
    builder: (confirmDialog) {
      return StatefulBuilder(
        builder:
            (context, setState) => DialogTemplate(
              theme: theme,
              message:
                  'Select a Role for yourself from the List below, and then proceed to create the shop.',
              title: 'Select Role',
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 5,
                children:
                    returnShopProvider(context: context)
                        .roles
                        .map(
                          (role) => Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(5),
                              onTap: () {
                                returnShopProvider()
                                    .setRole(role);
                              },
                              child: Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 13,
                                    ),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(
                                        5,
                                      ),
                                  border: Border.all(
                                    color:
                                        Colors
                                            .grey
                                            .shade100,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      role,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape:
                                            BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              Colors
                                                  .grey
                                                  .shade400,
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape:
                                              BoxShape
                                                  .circle,
                                          color:
                                              returnShopProvider(
                                                        context:
                                                            context,
                                                      ).tempRole ==
                                                      role
                                                  ? theme
                                                      .lightModeColor
                                                      .prColor250
                                                  : Colors
                                                      .transparent,
                                        ),
                                        height: 8,
                                        width: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              action: () {
                if (returnShopProvider().tempRole == '') {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return InfoAlert(
                        theme: theme,
                        message:
                            'You Need to Select A Role before you can Proceed.',
                        title: 'Select A Role',
                      );
                    },
                  );
                } else {
                  Navigator.of(confirmDialog).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ShopSetupPage();
                      },
                    ),
                  );
                }
              },
            ),
      );
    },
  );
}
