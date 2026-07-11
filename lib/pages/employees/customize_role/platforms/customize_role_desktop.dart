import 'package:flutter/material.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
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

  final FocusNode focusNode = FocusNode();

  bool isSearch = false;
  final accessController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    accessController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          isSearch = false;
        });
        accessController.clear();
      },
      child: Stack(
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
                                    builder: (
                                      confirmDialog,
                                    ) {
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
                                  Builder(
                                    builder: (context) {
                                      if (isSearch) {
                                        return SizedBox(
                                          width: 250,
                                          height: 35,
                                          child: GeneralTextfieldOnly(
                                            focusNode:
                                                focusNode,
                                            hint:
                                                'Enter Access',
                                            controller:
                                                accessController,
                                            lines: 1,
                                            theme: theme,
                                            onChanged: (
                                              value,
                                            ) {
                                              setState(
                                                () {},
                                              );
                                            },
                                          ),
                                        );
                                      } else {
                                        return Text(
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
                                        );
                                      }
                                    },
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
                              Padding(
                                padding: EdgeInsets.only(
                                  right: 10,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        isSearch =
                                            !isSearch;
                                        focusNode
                                            .requestFocus();
                                      });
                                      accessController
                                          .clear();
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                              5,
                                            ),
                                      ),
                                      child: Icon(
                                        size: 22,
                                        isSearch
                                            ? Icons.clear
                                            : Icons.search,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          Builder(
                            builder: (context) {
                              List<String> permissionS =
                                  accessController
                                          .text
                                          .isNotEmpty
                                      ? returnPermissionProvider()
                                          .permissions()
                                          .firstWhere(
                                            (per) =>
                                                per.role ==
                                                'Owner',
                                          )
                                          .access
                                          .where(
                                            (acc) => acc
                                                .toLowerCase()
                                                .contains(
                                                  accessController
                                                      .text
                                                      .toLowerCase(),
                                                ),
                                          )
                                          .toList()
                                      : returnPermissionProvider()
                                          .permissions()
                                          .firstWhere(
                                            (per) =>
                                                per.role ==
                                                'Owner',
                                          )
                                          .access;
                              permissionS.sort();
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
                                        permissionS
                                            .map(
                                              (
                                                permit,
                                              ) => InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (tempAccess.contains(
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
                                                        MainAxisAlignment.spaceBetween,
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
                                                        padding: EdgeInsets.all(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
