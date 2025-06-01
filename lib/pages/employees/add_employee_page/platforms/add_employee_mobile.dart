import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_user_class.dart';
import 'package:stockitt/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockitt/components/alert_dialogues/info_alert.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/text_fields/general_textfield.dart';
import 'package:stockitt/components/text_fields/phone_number_text_field.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/authentication/components/email_text_field.dart';
import 'package:stockitt/providers/theme_provider.dart';
import 'package:stockitt/services/auth_service.dart';

class AddEmployeeMobile extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController newPasswordController;
  final TextEditingController phoneController;
  final TempUserClass? employee;

  const AddEmployeeMobile({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.newPasswordController,
    required this.phoneController,
    this.employee,
  });

  @override
  State<AddEmployeeMobile> createState() =>
      _AddEmployeeMobileState();
}

class _AddEmployeeMobileState
    extends State<AddEmployeeMobile> {
  bool isLoading = false;
  bool showSuccess = false;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    );
    return emailRegex.hasMatch(email);
  }

  //
  //
  //
  int? currentSelected;
  List<Map<String, dynamic>> employees = [
    // {
    //   'position': 'Owner',
    //   'auths': ['Overall Access'],
    // },
    {
      'position': 'General Manager',
      'auths': [
        'Add Products',
        'Update Products',
        'Delete Products',
        'Add Customers',
        'Update Customers',
        'Delete Customers',
        'Make Sale',
        'View Daily Sales',
        'View Weekly Sales',
        'Make Refund',
        'Delete Sales',
      ],
    },
    {
      'position': 'Manager',
      'auths': [
        'Add Products',
        'Update Products',
        'Add Customers',
        'Update Customers',
        'Delete Customers',
        'Make Sale',
        'View Daily Sales',
        'Make Refund',
      ],
    },
    {
      'position': 'Cashier',
      'auths': [
        'Add Customers',
        'Make Sale',
        'View Products',
        'View Daily Sales',
        'Make Refund,',
      ],
    },
  ];
  //
  //
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
      widget.emailController.text = widget.employee!.email;
      widget.phoneController.text =
          widget.employee!.phone ?? '';
      widget.nameController.text = widget.employee!.name;
      if (returnLocalDatabase(
            context,
            listen: false,
          ).currentEmployee!.role ==
          'Owner') {
        widget.passwordController.text =
            widget.employee!.password;
      }
      currentSelected = employees.indexOf(
        employees.firstWhere(
          (emp) => emp['position'] == widget.employee!.role,
        ),
      );
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            toolbarHeight: 60,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 10,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                ),
              ),
            ),
            centerTitle: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.h4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),

                  widget.employee != null
                      ? 'Edit Employee'
                      : 'Add New Employee',
                ),
              ],
            ),
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
                                          horizontal: 20.0,
                                        ),
                                    child: Column(
                                      children: [
                                        GeneralTextField(
                                          isEnabled:
                                              widget
                                                  .employee ==
                                              null,
                                          title: 'Name',
                                          hint:
                                              'Enter employees\' Name',
                                          controller:
                                              widget
                                                  .nameController,
                                          lines: 1,
                                          theme: theme,
                                        ),
                                        SizedBox(
                                          height: 12,
                                        ),
                                        EmailTextField(
                                          isEnabled:
                                              widget
                                                  .employee ==
                                              null,
                                          title: 'Email',
                                          hint:
                                              'Enter employees\' Email',
                                          isEmail: true,
                                          controller:
                                              widget
                                                  .emailController,
                                          theme: theme,
                                        ),

                                        Visibility(
                                          visible:
                                              widget
                                                  .employee ==
                                              null,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 12,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  EmailTextField(
                                                    isEnabled:
                                                        false,
                                                    controller:
                                                        widget.emailController,
                                                    theme:
                                                        theme,
                                                    isEmail:
                                                        false,
                                                    hint:
                                                        'Enter Password',
                                                    title:
                                                        'Password',
                                                  ),
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b3.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          theme.lightModeColor.secColor100,
                                                    ),
                                                    'The email is the default password',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 12,
                                        ),
                                        PhoneNumberTextField(
                                          isEnabled:
                                              widget
                                                  .employee ==
                                              null,
                                          controller:
                                              widget
                                                  .phoneController,
                                          theme: theme,
                                          title:
                                              'Phone Number',
                                          hint:
                                              'Add Phone Number',
                                        ),
                                        Visibility(
                                          visible:
                                              widget
                                                  .employee !=
                                              null,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 30,
                                              ),
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
                                                'Change Password',
                                              ),
                                              SizedBox(
                                                height: 12,
                                              ),
                                              EmailTextField(
                                                isEnabled:
                                                    returnLocalDatabase(
                                                              context,
                                                              listen:
                                                                  false,
                                                            ).currentEmployee!.role ==
                                                            'Owner'
                                                        ? false
                                                        : true,
                                                controller:
                                                    widget
                                                        .passwordController,
                                                theme:
                                                    theme,
                                                isEmail:
                                                    false,
                                                hint:
                                                    'Old Password',
                                                title:
                                                    'Old Password',
                                              ),
                                              SizedBox(
                                                height: 12,
                                              ),
                                              EmailTextField(
                                                controller:
                                                    widget
                                                        .newPasswordController,
                                                theme:
                                                    theme,
                                                isEmail:
                                                    false,
                                                hint:
                                                    'Enter New Password',
                                                title:
                                                    'New Password',
                                              ),
                                            ],
                                          ),
                                        ),

                                        SizedBox(
                                          height: 25,
                                        ),
                                        Visibility(
                                          visible:
                                              returnLocalDatabase(
                                                    context,
                                                  )
                                                  .currentEmployee!
                                                  .role ==
                                              'Owner',
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
                                                      CrossAxisAlignment
                                                          .start,
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
                                    visible:
                                        returnLocalDatabase(
                                              context,
                                            )
                                            .currentEmployee!
                                            .role ==
                                        'Owner',
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          NeverScrollableScrollPhysics(),
                                      itemCount:
                                          employees.length,
                                      itemBuilder: (
                                        context,
                                        index,
                                      ) {
                                        var employee =
                                            employees[index];
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
                              if (snapshot.connectionState ==
                                      ConnectionState
                                          .waiting ||
                                  snapshot.hasError) {
                                return;
                              } else {
                                var users = snapshot.data!;
                                List<String> userEmails() {
                                  List<String> tempEmails =
                                      [];
                                  for (var item in users) {
                                    tempEmails.add(
                                      item.email
                                          .toLowerCase(),
                                    );
                                  }
                                  return tempEmails;
                                }

                                if (widget
                                        .nameController
                                        .text
                                        .isEmpty ||
                                    widget
                                        .emailController
                                        .text
                                        .isEmpty ||
                                    widget
                                        .phoneController
                                        .text
                                        .isEmpty ||
                                    currentSelected ==
                                        null) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InfoAlert(
                                        theme: theme,
                                        message:
                                            'Name, email, phone number and Staff Role must be set.',
                                        title:
                                            'Fields not set',
                                      );
                                    },
                                  );
                                } else if (userEmails()
                                    .contains(
                                      widget
                                          .emailController
                                          .text
                                          .toLowerCase(),
                                    )) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InfoAlert(
                                        theme: theme,
                                        message:
                                            'Email already in use. Please Select a different email, or Log into the account.',
                                        title:
                                            'Email Already Registered',
                                      );
                                    },
                                  );
                                } else if (!isValidEmail(
                                  widget
                                      .emailController
                                      .text,
                                )) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InfoAlert(
                                        theme: theme,
                                        message:
                                            'Please enter a valid Email Address',
                                        title:
                                            'Email Invalid',
                                      );
                                    },
                                  );
                                } else {
                                  final safeContext =
                                      context;
                                  showDialog(
                                    context: safeContext,
                                    builder: (context) {
                                      return ConfirmationAlert(
                                        theme: theme,
                                        message:
                                            'You are about to create an employee with the role of a ${employees[currentSelected!]['position']}, do you want to proceed?',
                                        title: 'Procced?',
                                        action: () async {
                                          if (safeContext
                                              .mounted) {
                                            Navigator.of(
                                              safeContext,
                                            ).pop();
                                          }
                                          setState(() {
                                            isLoading =
                                                true;
                                          });
                                          await returnUserProvider(
                                            context,
                                            listen: false,
                                          ).addEmployee(
                                            TempUserClass(
                                              name:
                                                  widget
                                                      .nameController
                                                      .text
                                                      .trim(),
                                              email:
                                                  widget
                                                      .emailController
                                                      .text
                                                      .trim()
                                                      .toLowerCase(),
                                              role:
                                                  employees[currentSelected!]['position'],
                                              authUserId:
                                                  AuthService()
                                                      .currentUser!
                                                      .id,
                                              password:
                                                  widget
                                                      .emailController
                                                      .text
                                                      .trim()
                                                      .toLowerCase(),
                                              phone:
                                                  widget
                                                      .phoneController
                                                      .text,
                                            ),
                                          );

                                          setState(() {
                                            isLoading =
                                                false;
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
                              }
                            } else {
                              final safeContext = context;
                              if (widget
                                  .newPasswordController
                                  .text
                                  .isEmpty) {
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
                                        ).updateUser(
                                          TempUserClass(
                                            userId:
                                                widget
                                                    .employee!
                                                    .userId,
                                            name:
                                                widget
                                                    .nameController
                                                    .text
                                                    .trim(),
                                            email:
                                                widget
                                                    .emailController
                                                    .text
                                                    .trim()
                                                    .toLowerCase(),
                                            role:
                                                employees[currentSelected!]['position'],

                                            password:
                                                widget
                                                        .newPasswordController
                                                        .text
                                                        .isNotEmpty
                                                    ? widget
                                                        .newPasswordController
                                                        .text
                                                    : widget
                                                        .passwordController
                                                        .text,
                                            phone:
                                                widget
                                                    .phoneController
                                                    .text,
                                          ),
                                          context,
                                        );

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
                              } else {
                                if (widget
                                        .passwordController
                                        .text !=
                                    widget
                                        .employee!
                                        .password) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InfoAlert(
                                        theme: theme,
                                        message:
                                            'Old Password Incorrect, please check and try again later.',
                                        title:
                                            'Incorrect Old Password',
                                      );
                                    },
                                  );
                                } else {
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
                                            isLoading =
                                                true;
                                          });
                                          await returnUserProvider(
                                            context,
                                            listen: false,
                                          ).updateUser(
                                            TempUserClass(
                                              userId:
                                                  widget
                                                      .employee!
                                                      .userId,
                                              name:
                                                  widget
                                                      .nameController
                                                      .text
                                                      .trim(),
                                              email:
                                                  widget
                                                      .emailController
                                                      .text
                                                      .trim(),
                                              role:
                                                  employees[currentSelected!]['position'],

                                              password:
                                                  widget
                                                          .newPasswordController
                                                          .text
                                                          .isNotEmpty
                                                      ? widget
                                                          .newPasswordController
                                                          .text
                                                      : widget
                                                          .passwordController
                                                          .text,
                                              phone:
                                                  widget
                                                      .phoneController
                                                      .text,
                                            ),
                                            context,
                                          );

                                          setState(() {
                                            isLoading =
                                                false;
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
                              }
                            }
                          },
                          text:
                              widget.employee != null &&
                                      returnLocalDatabase(
                                                context,
                                                listen:
                                                    false,
                                              )
                                              .currentEmployee!
                                              .role ==
                                          'Owner'
                                  ? 'Update Details'
                                  : widget.employee !=
                                          null &&
                                      returnLocalDatabase(
                                                context,
                                                listen:
                                                    false,
                                              )
                                              .currentEmployee!
                                              .role !=
                                          'Owner'
                                  ? 'Save New Password'
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
