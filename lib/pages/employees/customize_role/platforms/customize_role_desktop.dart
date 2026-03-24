import 'package:flutter/material.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/main.dart';

class CustomizeRoleDesktop extends StatefulWidget {
  final TempUserClass user;
  const CustomizeRoleDesktop({
    super.key,
    required this.user,
  });

  @override
  State<CustomizeRoleDesktop> createState() =>
      _CustomizeRoleDesktopState();
}

class _CustomizeRoleDesktopState
    extends State<CustomizeRoleDesktop> {
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
        DesktopCenterContainer(
          mainWidget: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
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
                                      title:
                                          'Discard Changes',
                                      action: () {
                                        Navigator.of(
                                          context,
                                        ).pop();
                                        Navigator.of(
                                          context,
                                        ).pop();
                                      },
                                    );
                                  },
                                );
                                // Navigator.of(context).pop();
                              },
                              child: Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 15,
                                    ),
                                child: Icon(
                                  color: Colors.grey,
                                  size: 20,
                                  Icons
                                      .arrow_back_ios_new_rounded,
                                ),
                              ),
                            ),
                            Column(
                              spacing: 8,
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
                                  'Customize Staff Role',
                                ),
                                Text(
                                  style:
                                      theme
                                          .mobileTexts
                                          .b1
                                          .textStyleNormal,
                                  "Select Roles to add or remove from Staff Access.",
                                ),
                              ],
                            ),
                            Opacity(
                              opacity: 0,
                              child: Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 15,
                                    ),
                                child: Icon(
                                  color: Colors.grey,
                                  size: 20,
                                  Icons
                                      .arrow_back_ios_new_rounded,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Builder(
                          builder: (context) {
                            if (isLoading) {
                              return Center(
                                child: SizedBox(
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
                              );
                            } else {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                    ),
                                child: Column(
                                  // spacing: 10,
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
                                            (
                                              permit,
                                            ) => InkWell(
                                              onTap: () {
                                                setState(() {
                                                  if (tempAccess
                                                      .contains(
                                                        permit,
                                                      )) {
                                                    tempAccess.remove(
                                                      permit,
                                                    );
                                                  } else {
                                                    tempAccess.add(
                                                      permit,
                                                    );
                                                  }
                                                });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  vertical:
                                                      8.0,
                                                  horizontal:
                                                      10,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  spacing:
                                                      10,
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
                                                        borderRadius: BorderRadius.circular(
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
                                                          Icons.check,
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
                      ],
                    ),
                  ),
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
                            title: 'Update Staff Access',
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
                                        user: widget.user,
                                        newAccess:
                                            tempAccess,
                                      );
                              if (res == 1) {
                                Navigator.of(context).pop();
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
            ],
          ),
        ),
      ],
    );
  }
}
