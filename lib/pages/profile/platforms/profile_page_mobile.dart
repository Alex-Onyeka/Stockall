import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/profile/change_email/enter_new_email/enter_new_email.dart';
import 'package:stockall/pages/profile/delete_account/delete_account.dart';
import 'package:stockall/pages/profile/edit/edit.dart';

class ProfilePageMobile extends StatefulWidget {
  const ProfilePageMobile({
    super.key,
    required this.passwordController,
  });
  final TextEditingController passwordController;

  @override
  State<ProfilePageMobile> createState() =>
      _ProfilePageMobileState();
}

class _ProfilePageMobileState
    extends State<ProfilePageMobile> {
  late Future<TempUserClass> userFuture;
  Future<TempUserClass> getUser() async {
    var user = await returnUserProvider(
      context,
      listen: false,
    ).fetchCurrentUser(context);

    return user!;
  }

  @override
  void initState() {
    super.initState();
    userFuture = getUser();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      appBar: appBar(context: context, title: 'Profile'),
      body: FutureBuilder(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
                  ConnectionState.waiting ||
              snapshot.hasError) {
            return Center(
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Image.asset(
                    profileIconImage,
                    height: 120,
                  ),
                  SizedBox(height: 10),
                  Column(
                    spacing: 2,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                            ),
                            'Loading',
                          ),
                        ),
                      ),
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                            ),
                            '000 0 00 000 0',
                          ),
                        ),
                      ),
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                            ),
                            'alexonyekasm@gmail.com',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    child: Column(
                      spacing: 10,
                      children: [
                        MainButtonTransparent(
                          themeProvider: theme,
                          action: () {},
                          text: 'Edit Profile Info',
                          constraints: BoxConstraints(),
                        ),
                        MainButtonTransparent(
                          themeProvider: theme,
                          action: () {},
                          text: 'Change Email',
                          constraints: BoxConstraints(),
                        ),
                        MainButtonTransparent(
                          themeProvider: theme,
                          action: () {},
                          text: 'Change Password',
                          constraints: BoxConstraints(),
                        ),
                        MainButtonTransparent(
                          themeProvider: theme,
                          action: () {},
                          text: 'Change PIN',
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            var user = snapshot.data!;
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Image.asset(
                      profileIconImage,
                      height: 120,
                    ),
                    SizedBox(height: 10),
                    Column(
                      spacing: 2,
                      children: [
                        Text(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                          ),
                          user.name,
                        ),
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                          ),
                          user.phone ?? 'Phone Number',
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                            color:
                                theme
                                    .lightModeColor
                                    .secColor200,
                          ),
                          user.email,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                      ),
                      child: Column(
                        spacing: 10,
                        children: [
                          MainButtonTransparent(
                            themeProvider: theme,
                            action: () {
                              if (returnConnectivityProvider()
                                  .isConnected) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Edit(
                                        user: user,
                                        action: 'normal',
                                      );
                                    },
                                  ),
                                ).then((context) {
                                  setState(() {
                                    userFuture = getUser();
                                  });
                                });
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return InfoAlert(
                                      theme: theme,
                                      message:
                                          'Please Turn on your internet connection to edit your profile info.',
                                      title: 'No Internet',
                                    );
                                  },
                                );
                              }
                            },
                            text: 'Edit Profile Info',
                            constraints: BoxConstraints(),
                          ),
                          MainButtonTransparent(
                            themeProvider: theme,
                            action: () {
                              if (returnConnectivityProvider()
                                  .isConnected) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Edit(
                                        user: user,
                                        action: 'password',
                                      );
                                    },
                                  ),
                                ).then((context) {
                                  setState(() {
                                    userFuture = getUser();
                                  });
                                });
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return InfoAlert(
                                      theme: theme,
                                      message:
                                          'Please Turn on your internet connection to edit your profile info.',
                                      title: 'No Internet',
                                    );
                                  },
                                );
                              }
                            },
                            text: 'Change Password',
                            constraints: BoxConstraints(),
                          ),
                          MainButtonTransparent(
                            themeProvider: theme,
                            action: () {
                              var isOnline =
                                  returnConnectivityProvider()
                                      .isConnected;
                              if (isOnline) {
                                showDialog(
                                  context: context,
                                  builder: (confirmDialog) {
                                    return DialogTemplate(
                                      theme: theme,
                                      message:
                                          'Are your sure you want to Change your Email? If so, enter your password to confirm.',
                                      title:
                                          'Proceed To Change Email?',
                                      action: () {
                                        if (widget
                                                .passwordController
                                                .text !=
                                            user.password) {
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
                                                    'The Password you entered is incorrect. Please confirm, and try again.',
                                                title:
                                                    'Incorrect Password.',
                                              );
                                            },
                                          );
                                        } else {
                                          Navigator.of(
                                            confirmDialog,
                                          ).pop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return EnterNewEmail();
                                              },
                                            ),
                                          );
                                        }
                                      },
                                      widget: EmailTextField(
                                        controller:
                                            widget
                                                .passwordController,
                                        theme: theme,
                                        isEmail: false,
                                        hint:
                                            'Enter Password',
                                        title: 'Password',
                                      ),
                                    );
                                  },
                                ).then((_) {
                                  widget.passwordController
                                      .clear();
                                });
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return InfoAlert(
                                      theme: theme,
                                      message:
                                          'Please Turn on your internet connection to edit your profile info.',
                                      title: 'No Internet',
                                    );
                                  },
                                );
                              }
                            },
                            text: 'Change Email',
                            constraints: BoxConstraints(),
                          ),
                          MainButtonTransparent(
                            themeProvider: theme,
                            action: () {
                              if (returnConnectivityProvider()
                                  .isConnected) {
                                showDialog(
                                  context: context,
                                  builder: (confirmDialog) {
                                    return DialogTemplate(
                                      theme: theme,
                                      message:
                                          'Enter your Account password to confirm. Before proceeding to change your PIN',
                                      title:
                                          'Proceed To Change PIN?',
                                      action: () {
                                        if (widget
                                                .passwordController
                                                .text !=
                                            user.password) {
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
                                                    'The Password you entered is incorrect. Please confirm, and try again.',
                                                title:
                                                    'Incorrect Password.',
                                              );
                                            },
                                          );
                                        } else {
                                          Navigator.of(
                                            confirmDialog,
                                          ).pop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return Edit(
                                                  user:
                                                      user,
                                                  action:
                                                      'PIN',
                                                );
                                              },
                                            ),
                                          ).then((context) {
                                            widget
                                                .passwordController
                                                .clear();
                                            setState(() {
                                              userFuture =
                                                  getUser();
                                            });
                                          });
                                        }
                                      },
                                      widget: EmailTextField(
                                        controller:
                                            widget
                                                .passwordController,
                                        theme: theme,
                                        isEmail: false,
                                        hint:
                                            'Enter Password',
                                        title: 'Password',
                                      ),
                                    );
                                  },
                                ).then((_) {
                                  widget.passwordController
                                      .clear();
                                });
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return InfoAlert(
                                      theme: theme,
                                      message:
                                          'Please Turn on your internet connection to edit your profile info.',
                                      title: 'No Internet',
                                    );
                                  },
                                );
                              }
                            },
                            text: 'Change PIN',
                            constraints: BoxConstraints(),
                          ),
                          MainButtonTransparent(
                            themeProvider: theme,
                            color: Colors.red,
                            action: () {
                              if (returnConnectivityProvider()
                                  .isConnected) {
                                showDialog(
                                  context: context,
                                  builder: (confirmDialog) {
                                    return ConfirmationAlert(
                                      theme: theme,
                                      message:
                                          'Deleting your account means loosing all your account information. This action cannot be reversed. Are you sure you want to proceed?',
                                      title:
                                          'Are you Sure?',
                                      action: () {
                                        Navigator.of(
                                          confirmDialog,
                                        ).pop();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return DeleteAccount();
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return InfoAlert(
                                      theme: theme,
                                      message:
                                          'Please Turn on your internet connection to Proceed with this action.',
                                      title: 'No Internet',
                                    );
                                  },
                                );
                              }
                            },
                            text: 'Delete Your Account',
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
