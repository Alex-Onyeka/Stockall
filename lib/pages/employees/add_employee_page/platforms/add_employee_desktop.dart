import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class AddEmployeeDesktop extends StatefulWidget {
  final TextEditingController idC;
  final TempUserClass? employee;

  const AddEmployeeDesktop({
    super.key,
    required this.idC,
    this.employee,
  });

  @override
  State<AddEmployeeDesktop> createState() =>
      _AddEmployeeDesktopState();
}

class _AddEmployeeDesktopState
    extends State<AddEmployeeDesktop> {
  bool isLoading = false;
  bool showSuccess = false;

  //
  //
  //
  int? currentSelected;

  late Future<List<TempUserClass>> usersFuture;
  Future<List<TempUserClass>> getUsers() {
    var tempUsers =
        returnUserProvider(
          context,
          listen: false,
        ).fetchUsers();
    return tempUsers;
  }

  @override
  void initState() {
    super.initState();
    usersFuture = getUsers();
    if (widget.employee != null) {
      setState(() {
        currentSelected = empSetup.indexOf(
          empSetup.firstWhere(
            (emp) =>
                emp['position'] == widget.employee!.role,
          ),
        );
      });
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        DesktopCenterContainer(
          mainWidget: Scaffold(
            backgroundColor: Colors.grey.shade100,
            appBar: appBar(
              context: context,
              title:
                  widget.employee != null
                      ? 'Edit Employee'
                      : 'Add New Employee',
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                            horizontal:
                                                20.0,
                                          ),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .h4
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                widget
                                                        .employee
                                                        ?.name ??
                                                    '',
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                            ],
                                          ),
                                          Visibility(
                                            visible:
                                                widget
                                                    .employee ==
                                                null,
                                            child: GeneralTextField(
                                              isEnabled:
                                                  widget
                                                      .employee ==
                                                  null,
                                              title:
                                                  'Enter Staff Id',
                                              hint:
                                                  'Enter Staff\'s Id',
                                              controller:
                                                  widget
                                                      .idC,
                                              lines: 1,
                                              theme: theme,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 25,
                                          ),
                                          Visibility(
                                            visible: authorization(
                                              authorized:
                                                  Authorizations()
                                                      .addEmployee,
                                              context:
                                                  context,
                                            ),
                                            child: Row(
                                              spacing: 5,
                                              children: [
                                                Icon(
                                                  size: 20,
                                                  color:
                                                      theme
                                                          .lightModeColor
                                                          .secColor100,
                                                  Icons
                                                      .warning_rounded,
                                                ),
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        'Select Staff Role.',
                                                      ),
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              12,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                        'Note, Staff Role Determines their Authorization level.',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 0),
                                    Visibility(
                                      visible: authorization(
                                        authorized:
                                            Authorizations()
                                                .addEmployee,
                                        context: context,
                                      ),

                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            NeverScrollableScrollPhysics(),
                                        itemCount:
                                            empSetup
                                                .where(
                                                  (emp) =>
                                                      emp['position'] !=
                                                      'Owner',
                                                )
                                                .toList()
                                                .length,
                                        itemBuilder: (
                                          context,
                                          index,
                                        ) {
                                          var employee =
                                              empSetup
                                                  .where(
                                                    (emp) =>
                                                        emp['position'] !=
                                                        'Owner',
                                                  )
                                                  .toList()[index];
                                          return EmployeeListTile(
                                            currentSelected:
                                                currentSelected ??
                                                5,
                                            index: index,
                                            action: () {
                                              setState(() {
                                                currentSelected =
                                                    index;
                                              });
                                            },
                                            authorizations:
                                                employee['auths'],
                                            position:
                                                employee['position'],
                                            theme: theme,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(top: 20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                      ),
                      child: FutureBuilder(
                        future: usersFuture,
                        builder: (context, snapshot) {
                          return MainButtonP(
                            themeProvider: theme,
                            action: () {
                              if (widget.employee == null) {
                                if (widget
                                    .idC
                                    .text
                                    .isEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InfoAlert(
                                        theme: theme,
                                        message:
                                            'Staff Id field cannot be empty.',
                                        title:
                                            'Empty Field',
                                      );
                                    },
                                  );
                                } else if (currentSelected ==
                                    null) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InfoAlert(
                                        theme: theme,
                                        message:
                                            'Staff Role cannot be empty.',
                                        title:
                                            'Empty Field',
                                      );
                                    },
                                  );
                                } else {
                                  var userProvider =
                                      returnUserProvider(
                                        context,
                                        listen: false,
                                      );
                                  // var safeContext = context;
                                  var shopProvider =
                                      returnShopProvider(
                                        context,
                                        listen: false,
                                      );
                                  showDialog(
                                    context: context,
                                    builder: (
                                      dialogContext,
                                    ) {
                                      return ConfirmationAlert(
                                        theme: theme,
                                        message:
                                            'You are about to add a new Staff, are you sure you want to proceed?',
                                        title:
                                            'Are you Sure?',
                                        action: () async {
                                          setState(() {
                                            isLoading =
                                                true;
                                          });

                                          try {
                                            // Validate UUID
                                            final uuid =
                                                Uuid.parse(
                                                  widget
                                                      .idC
                                                      .text
                                                      .trim(),
                                                );
                                            if (uuid
                                                .toString()
                                                .isEmpty) {
                                              throw Exception();
                                            }
                                          } catch (_) {
                                            setState(
                                              () =>
                                                  isLoading =
                                                      false,
                                            );
                                            showDialog(
                                              context:
                                                  context,
                                              builder:
                                                  (
                                                    _,
                                                  ) => InfoAlert(
                                                    theme:
                                                        theme,
                                                    message:
                                                        'Employee Id is invalid.',
                                                    title:
                                                        'Invalid Employee Id.',
                                                    action: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                                  ),
                                            );
                                            return;
                                          }

                                          final res = await userProvider.updateEmployeeRole(
                                            userId:
                                                widget
                                                    .idC
                                                    .text
                                                    .trim(),
                                            newRole:
                                                empSetup[currentSelected!]['position'],
                                            authUserId:
                                                AuthService()
                                                    .currentUser!
                                                    .id,
                                          );

                                          if (res != null &&
                                              context
                                                  .mounted) {
                                            setState(
                                              () =>
                                                  isLoading =
                                                      false,
                                            );

                                            if (res ==
                                                    '121' ||
                                                res ==
                                                    '131') {
                                              showDialog(
                                                context:
                                                    context,
                                                builder:
                                                    (
                                                      _,
                                                    ) => InfoAlert(
                                                      theme:
                                                          theme,
                                                      message:
                                                          res ==
                                                                  '121'
                                                              ? 'Employee Id is invalid.'
                                                              : 'User is not found in the database.',
                                                      title:
                                                          res ==
                                                                  '121'
                                                              ? 'Invalid Employee Id.'
                                                              : 'User not Found.',
                                                      action: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                    ),
                                              );
                                              return;
                                            }
                                          }

                                          await shopProvider.addEmployeeToShop(
                                            shopId:
                                                shopProvider
                                                    .userShop!
                                                    .shopId!,
                                            newEmployeeId:
                                                widget
                                                    .idC
                                                    .text
                                                    .trim(),
                                          );

                                          setState(() {
                                            isLoading =
                                                false;
                                            showSuccess =
                                                true;
                                          });

                                          Navigator.of(
                                            context,
                                          ).pop(); // close confirmation dialog immediately

                                          showDialog(
                                            context:
                                                context,
                                            builder:
                                                (
                                                  _,
                                                ) => InfoAlert(
                                                  theme:
                                                      theme,
                                                  message:
                                                      'Staff added successfully.',
                                                  title:
                                                      'Success',
                                                  action: () {
                                                    Navigator.of(
                                                      context,
                                                    ).pop();
                                                  },
                                                ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                }
                              } else {
                                final safeContext = context;
                                showDialog(
                                  context: safeContext,
                                  builder: (context) {
                                    return ConfirmationAlert(
                                      theme: theme,
                                      message:
                                          'You are about to update details, do you want to proceed?',
                                      title: 'Procced?',
                                      action: () async {
                                        if (safeContext
                                            .mounted) {
                                          Navigator.of(
                                            safeContext,
                                          ).pop();
                                        }
                                        setState(() {
                                          isLoading = true;
                                        });
                                        await returnUserProvider(
                                          context,
                                          listen: false,
                                        ).updateEmployeeRole(
                                          newRole:
                                              empSetup[currentSelected!]['position'],
                                          userId:
                                              widget.employee !=
                                                      null
                                                  ? widget
                                                      .employee!
                                                      .userId!
                                                  : '',
                                          authUserId:
                                              AuthService()
                                                  .currentUser!
                                                  .id,
                                        );
                                        // await returnUserProvider(
                                        //   context,
                                        //   listen: false,
                                        // ).fetchUsers();

                                        setState(() {
                                          isLoading = false;
                                          showSuccess =
                                              true;
                                        });

                                        await Future.delayed(
                                          Duration(
                                            seconds: 2,
                                          ),
                                        );

                                        if (safeContext
                                            .mounted) {
                                          Navigator.of(
                                            safeContext,
                                          ).pop();
                                        }
                                      },
                                    );
                                  },
                                );
                              }
                            },
                            text:
                                widget.employee != null
                                    ? 'Update Details'
                                    : 'Add Employee',
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
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
          ).showLoader('Loading'),
        ),
        Visibility(
          visible: showSuccess,
          child: returnCompProvider(
            context,
            listen: false,
          ).showSuccess(
            widget.employee != null
                ? 'Updated Successfully'
                : 'Employee Added Successfully',
          ),
        ),
      ],
    );
  }
}

class EmployeeListTile extends StatelessWidget {
  final String position;
  final List<String> authorizations;
  final Function() action;
  final int index;
  final int currentSelected;
  final ThemeProvider theme;

  const EmployeeListTile({
    super.key,
    required this.position,
    required this.authorizations,
    required this.action,
    required this.theme,
    required this.index,
    required this.currentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Ink(
        color: Colors.white,
        child: InkWell(
          onTap: () {
            action();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 20.0,
              left: 15,
              right: 15,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      position,
                    ),
                    SizedBox(height: 5),
                    Checkbox(
                      activeColor:
                          theme.lightModeColor.secColor100,
                      value: currentSelected == index,
                      onChanged: (value) {
                        action();
                        FocusManager.instance.primaryFocus
                            ?.unfocus();
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                authorizations.map((auth) {
                                  return Container(
                                    padding:
                                        EdgeInsets.symmetric(
                                          vertical: 4,
                                          horizontal: 8,
                                        ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            Colors
                                                .grey
                                                .shade200,
                                      ),
                                    ),

                                    child: Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      auth,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
