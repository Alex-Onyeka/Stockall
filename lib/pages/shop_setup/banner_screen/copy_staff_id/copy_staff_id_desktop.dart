import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CopyStaffIdDesktop extends StatefulWidget {
  const CopyStaffIdDesktop({super.key});

  @override
  State<CopyStaffIdDesktop> createState() =>
      _CopyStaffIdDesktopState();
}

class _CopyStaffIdDesktopState
    extends State<CopyStaffIdDesktop> {
  bool showId = false;
  bool sendEmail = false;
  bool whatsapp = false;

  TextEditingController emailC = TextEditingController();
  TextEditingController phoneC = TextEditingController();

  String hideText(String text) {
    if (showId) {
      return text;
    } else {
      return '${text.substring(0, 3)}************${text.substring(text.length - 3, text.length)}';
    }
  }

  late Future<TempUserClass> userFuture;
  Future<TempUserClass> getUser() async {
    var tempUser = await returnUserProvider(
      context,
      listen: false,
    ).fetchCurrentUser(context);

    return tempUser!;
  }

  @override
  void initState() {
    super.initState();
    userFuture = getUser();
  }

  @override
  void dispose() {
    super.dispose();
    emailC.dispose();
    phoneC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backGroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              color: const Color.fromARGB(
                201,
                255,
                255,
                255,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 40,
                        ),
                        width: 550,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 30,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                46,
                                0,
                                0,
                                0,
                              ),
                              blurRadius: 10,
                              spreadRadius: 5,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 20),

                            Column(
                              spacing: 8,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
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
                                      'Add yourself to a shop',
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Text(
                                      style:
                                          Provider.of<
                                                ThemeProvider
                                              >(context)
                                              .mobileTexts
                                              .b1
                                              .textStyleNormal,
                                      "Send your Id to your employee",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Text(
                                  textAlign:
                                      TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b2
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        theme
                                            .lightModeColor
                                            .secColor200,
                                  ),
                                  hideText(
                                    AuthService()
                                        .currentUser!
                                        .id,
                                  ),
                                ),
                                Row(
                                  spacing: 10,
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          showId = !showId;
                                        });
                                      },
                                      icon: Column(
                                        spacing: 5,
                                        children: [
                                          Icon(
                                            size: 22,
                                            showId
                                                ? Icons
                                                    .visibility
                                                : Icons
                                                    .visibility_off_outlined,
                                          ),
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b3
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              color:
                                                  Colors
                                                      .grey,
                                            ),
                                            showId
                                                ? 'Hide Id'
                                                : 'Show Id',
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(
                                            text:
                                                AuthService()
                                                    .currentUser!
                                                    .id,
                                          ),
                                        );
                                        if (context
                                            .mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Copied to clipboard',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      icon: Column(
                                        spacing: 5,
                                        children: [
                                          Icon(
                                            size: 20,
                                            Icons.copy,
                                          ),
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b3
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              color:
                                                  Colors
                                                      .grey,
                                            ),
                                            'Copy Id',
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          whatsapp =
                                              !whatsapp;
                                          sendEmail = false;
                                        });
                                        phoneC.clear();
                                        emailC.clear();
                                      },
                                      icon: Column(
                                        spacing: 5,
                                        children: [
                                          // Icon(size: 20, Icons.copy),
                                          SvgPicture.asset(
                                            whatsappIconSvg,
                                            height: 18,
                                          ),
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b3
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              color:
                                                  Colors
                                                      .grey,
                                            ),
                                            'Send',
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          sendEmail =
                                              !sendEmail;
                                          whatsapp = false;
                                        });
                                        phoneC.clear();
                                        emailC.clear();
                                      },
                                      icon: Column(
                                        spacing: 5,
                                        children: [
                                          Icon(
                                            size: 20,
                                            Icons
                                                .mail_outline_outlined,
                                          ),
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b3
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              color:
                                                  Colors
                                                      .grey,
                                            ),
                                            'Send',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Visibility(
                                  visible: sendEmail,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    spacing: 5,
                                    children: [
                                      SizedBox(height: 20),
                                      // Text(),
                                      // SizedBox(height: 5),
                                      GeneralTextField(
                                        hint:
                                            'Enter Employers\' Email',
                                        title:
                                            'Enter Employers\' Email',
                                        controller: emailC,
                                        lines: 1,
                                        theme: theme,
                                      ),
                                      SizedBox(height: 10),
                                      FutureBuilder(
                                        future: userFuture,
                                        builder: (
                                          context,
                                          snapshot,
                                        ) {
                                          return MainButtonP(
                                            themeProvider:
                                                theme,
                                            action: () async {
                                              final userId =
                                                  AuthService()
                                                      .currentUser!
                                                      .id; // or wherever your user ID is
                                              final email =
                                                  Uri.encodeFull(
                                                    'mailto:${emailC.text.trim()}?subject=My ID&body=Hello Sir/Ma. My Name is ${snapshot.connectionState == ConnectionState.waiting || snapshot.hasError ? "'No Name'" : snapshot.data!.name}. Here is my ID: $userId',
                                                  );

                                              if (emailC
                                                  .text
                                                  .isEmpty) {
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
                                                          'Email Field cannot be empty.',
                                                      title:
                                                          'Empty Email Field',
                                                    );
                                                  },
                                                );
                                              } else if (!isValidEmail(
                                                emailC.text,
                                              )) {
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
                                                          'Please enter a Valid email and try again.',
                                                      title:
                                                          'Email Invalid',
                                                    );
                                                  },
                                                );
                                              } else {
                                                if (await canLaunchUrl(
                                                  Uri.parse(
                                                    email,
                                                  ),
                                                )) {
                                                  await launchUrl(
                                                    Uri.parse(
                                                      email,
                                                    ),
                                                  );
                                                } else {
                                                  // You can show a snackbar or dialog here
                                                  if (context
                                                      .mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Email Opening Failed. Try again.',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                            text:
                                                'Send Your ID Via Email',
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: whatsapp,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    spacing: 5,
                                    children: [
                                      SizedBox(height: 10),
                                      FutureBuilder(
                                        future: userFuture,
                                        builder: (
                                          context,
                                          snapshot,
                                        ) {
                                          return MainButtonP(
                                            themeProvider:
                                                theme,
                                            action: () async {
                                              final messagee =
                                                  Uri.encodeComponent(
                                                    AuthService()
                                                        .currentUser!
                                                        .id,
                                                  );
                                              final uri =
                                                  Uri.parse(
                                                    "https://wa.me/?text=$messagee",
                                                  );

                                              if (await canLaunchUrl(
                                                uri,
                                              )) {
                                                await launchUrl(
                                                  uri,
                                                  mode:
                                                      LaunchMode
                                                          .externalApplication,
                                                );
                                              } else {
                                                if (context
                                                    .mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Couldn't open WhatsApp",
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            // },
                                            text:
                                                'Send Your ID on Whatsapp',
                                          );
                                        },
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
