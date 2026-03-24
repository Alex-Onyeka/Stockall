import 'package:flutter/material.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';

class CustomizeRoleMobile extends StatefulWidget {
  final TempUserClass user;
  const CustomizeRoleMobile({
    super.key,
    required this.user,
  });

  @override
  State<CustomizeRoleMobile> createState() =>
      _CustomizeRoleMobileState();
}

class _CustomizeRoleMobileState
    extends State<CustomizeRoleMobile> {
  bool isLoading = false;
  List<String> tempAccess = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        tempAccess = widget.user.access;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          appBar: appBar(
            context: context,
            title: 'Customize Staff Role',
            backAction: () {
              showDialog(
                context: context,
                builder: (confirmDialog) {
                  return ConfirmationAlert(
                    theme: returnTheme(
                      context,
                      listen: false,
                    ),
                    message:
                        'Your changes might not be saved when you exit this page. Are you sure you want to exit?',
                    title: 'Discard Changes',
                    action: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            },
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (isLoading) {
                          return Center(
                            child: ListView(
                              children: [
                                SizedBox(
                                  height: 400,
                                  // width: 100,
                                  child: Center(
                                    child: returnCompProvider(
                                      context,
                                    ).showLoader(
                                      message:
                                          'Updating Staff',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                            child: ListView(
                              children:
                                  returnPermissionProvider()
                                      .permissions
                                      .firstWhere(
                                        (per) =>
                                            per.role ==
                                            'Owner',
                                      )
                                      .access
                                      .map(
                                        (permit) => InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (tempAccess
                                                  .contains(
                                                    permit,
                                                  )) {
                                                tempAccess
                                                    .remove(
                                                      permit,
                                                    );
                                              } else {
                                                tempAccess
                                                    .add(
                                                      permit,
                                                    );
                                              }
                                            });
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  vertical:
                                                      8.0,
                                                  horizontal:
                                                      10,
                                                ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              spacing: 10,
                                              children: [
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b3.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  permit,
                                                ),
                                                Container(
                                                  padding:
                                                      EdgeInsets.all(
                                                        1,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          tempAccess.contains(
                                                                permit,
                                                              )
                                                              ? theme.lightModeColor.prColor250
                                                              : Colors.grey,
                                                    ),
                                                    color:
                                                        tempAccess.contains(
                                                              permit,
                                                            )
                                                            ? theme.lightModeColor.prColor250
                                                            : Colors.transparent,
                                                  ),
                                                  child: Opacity(
                                                    opacity:
                                                        tempAccess.contains(
                                                              permit,
                                                            )
                                                            ? 1
                                                            : 0,
                                                    child: Icon(
                                                      size:
                                                          12,
                                                      color:
                                                          Colors.white,
                                                      Icons
                                                          .check,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                    ),
                    child: MainButtonP(
                      themeProvider: theme,
                      action: () {
                        if (!isLoading) {
                          showDialog(
                            context: context,
                            builder: (confirmDialog) {
                              return ConfirmationAlert(
                                theme: theme,
                                message:
                                    'You are about to update the access of this Staff. Are you sure you want to Proceed?',
                                title:
                                    'Update Staff Access',
                                action: () async {
                                  Navigator.of(
                                    confirmDialog,
                                  ).pop();
                                  setState(() {
                                    isLoading = true;
                                  });
                                  int res =
                                      await returnUserProviderSingle()
                                          .updateStaffAccess(
                                            user:
                                                widget.user,
                                            newAccess:
                                                tempAccess,
                                          );
                                  if (res == 1) {
                                    Navigator.of(
                                      context,
                                    ).pop();
                                  } else {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                              );
                            },
                          );
                        }
                      },
                      text: 'Update Staff Access',
                    ),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
