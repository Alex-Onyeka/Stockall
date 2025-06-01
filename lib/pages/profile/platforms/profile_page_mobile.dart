import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockitt/classes/temp_user_class.dart';
import 'package:stockitt/components/buttons/main_button_transparent.dart';
import 'package:stockitt/constants/app_bar.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/profile/edit/edit.dart';

class ProfilePageMobile extends StatefulWidget {
  const ProfilePageMobile({super.key});

  @override
  State<ProfilePageMobile> createState() =>
      _ProfilePageMobileState();
}

class _ProfilePageMobileState
    extends State<ProfilePageMobile> {
  late Future<TempUserClass> userFuture;
  Future<TempUserClass> getUser() async {
    var user =
        await returnUserProvider(
          context,
          listen: false,
        ).fetchCurrentUser();

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
                        // MainButtonTransparent(
                        //   themeProvider: theme,
                        //   action: () {},
                        //   text: 'Change Email',
                        //   constraints: BoxConstraints(),
                        // ),
                        MainButtonTransparent(
                          themeProvider: theme,
                          action: () {},
                          text: 'Change Password',
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
                            },
                            text: 'Edit Profile Info',
                            constraints: BoxConstraints(),
                          ),
                          // MainButtonTransparent(
                          //   themeProvider: theme,
                          //   action: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) {
                          //           return Edit(
                          //             user: user,
                          //             action: 'email',
                          //           );
                          //         },
                          //       ),
                          //     ).then((context) {
                          //       setState(() {
                          //         userFuture = getUser();
                          //       });
                          //     });
                          //   },
                          //   text: 'Change Email',
                          //   constraints: BoxConstraints(),
                          // ),
                          MainButtonTransparent(
                            themeProvider: theme,
                            action: () {
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
                            },
                            text: 'Change Password',
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
