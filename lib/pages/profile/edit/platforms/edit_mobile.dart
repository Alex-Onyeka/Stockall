import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/phone_number_text_field.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/services/auth_service.dart';

class EditMobile extends StatefulWidget {
  final TempUserClass user;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController emailController;
  final TextEditingController oldEmailController;
  final TextEditingController oldPasswordController;
  final TextEditingController confirmPasswordController;
  final String action;

  const EditMobile({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.user,
    required this.action,
    required this.emailController,
    required this.passwordController,
    required this.oldEmailController,
    required this.oldPasswordController,
    required this.confirmPasswordController,
  });

  @override
  State<EditMobile> createState() => _EditMobileState();
}

class _EditMobileState extends State<EditMobile> {
  bool isLoading = false;
  bool showSuccess = false;

  @override
  void initState() {
    super.initState();
    if (widget.action == 'normal') {
      widget.nameController.text = widget.user.name;
      widget.phoneController.text = widget.user.phone ?? '';
    } else if (widget.action == 'email') {
      widget.oldEmailController.text = widget.user.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          appBar: appBar(
            context: context,
            title:
                widget.action == 'normal'
                    ? 'Edit Profile'
                    : widget.action == 'email'
                    ? 'Update Email'
                    : 'Change Password',
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Visibility(
                    visible: widget.action == 'normal',
                    child: Column(
                      children: [
                        GeneralTextField(
                          title: 'Name',
                          hint: 'Enter New Name',
                          controller: widget.nameController,
                          lines: 1,
                          theme: theme,
                        ),
                        SizedBox(height: 10),
                        PhoneNumberTextField(
                          title: 'Phone Number',
                          hint: 'Enter New Phone',
                          controller:
                              widget.phoneController,
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: widget.action == 'email',
                    child: Column(
                      children: [
                        EmailTextField(
                          controller:
                              widget.oldEmailController,
                          theme: theme,
                          isEmail: true,
                          hint: 'Enter Email',
                          title: 'Old Email',
                          isEnabled: false,
                        ),
                        SizedBox(height: 10),
                        EmailTextField(
                          isEmail: true,
                          title: 'New Email',
                          hint: 'Enter New Email',
                          controller:
                              widget.emailController,
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: widget.action == 'password',
                    child: Column(
                      children: [
                        EmailTextField(
                          controller:
                              widget.oldPasswordController,
                          theme: theme,
                          isEmail: false,
                          hint: 'Enter Old Password',
                          title: 'Old Password',
                        ),
                        SizedBox(height: 10),
                        EmailTextField(
                          isEmail: false,
                          title: 'New Password',
                          hint: 'Enter New Password',
                          controller:
                              widget.passwordController,
                          theme: theme,
                        ),
                        SizedBox(height: 10),
                        EmailTextField(
                          isEmail: false,
                          title: 'Confirm Password',
                          hint: 'Confirm New Password',
                          controller:
                              widget
                                  .confirmPasswordController,
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  MainButtonP(
                    themeProvider: theme,
                    action: () {
                      if (widget.action == 'normal') {
                        if (widget
                            .nameController
                            .text
                            .isEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return InfoAlert(
                                theme: theme,
                                message:
                                    'Name field can\'t be empty. Please enter Your name.',
                                title: 'Empty Fields',
                              );
                            },
                          );
                        } else {
                          final safeContex = context;
                          var userProvider =
                              returnUserProvider(
                                context,
                                listen: false,
                              );
                          showDialog(
                            context: safeContex,
                            builder: (context) {
                              return ConfirmationAlert(
                                theme: theme,
                                message:
                                    'Are you sure you want to proceed?',
                                title: 'Proceed?',
                                action: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  Navigator.of(
                                    safeContex,
                                  ).pop();

                                  TempUserClass
                                  user = await userProvider.updateUser(
                                    TempUserClass(
                                      userId:
                                          widget
                                              .user
                                              .userId,
                                      authUserId:
                                          widget
                                              .user
                                              .authUserId,
                                      password:
                                          widget
                                              .user
                                              .password,
                                      name:
                                          widget
                                              .nameController
                                              .text,
                                      email:
                                          widget.user.email,
                                      role:
                                          widget.user.role,
                                      phone:
                                          widget
                                                  .phoneController
                                                  .text
                                                  .isEmpty
                                              ? widget
                                                  .user
                                                  .phone
                                              : widget
                                                  .phoneController
                                                  .text,
                                    ),
                                    context,
                                  );

                                  if (safeContex.mounted) {
                                    await returnLocalDatabase(
                                      safeContex,
                                      listen: false,
                                    ).insertUser(user);
                                  }

                                  setState(() {
                                    isLoading = false;
                                    showSuccess = true;
                                  });

                                  Future.delayed(
                                    Duration(seconds: 2),
                                    () {
                                      if (safeContex
                                          .mounted) {
                                        Navigator.of(
                                          safeContex,
                                        ).pop();
                                      }
                                    },
                                  );
                                },
                              );
                            },
                          );
                        }
                      } else if (widget.action == 'email') {
                      } else {
                        if (widget
                                .oldPasswordController
                                .text
                                .isEmpty ||
                            widget
                                .passwordController
                                .text
                                .isEmpty ||
                            widget
                                .confirmPasswordController
                                .text
                                .isEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return InfoAlert(
                                theme: theme,
                                message:
                                    'Name field can\'t be empty. Enter all fields and try again.',
                                title: 'Empty Fields',
                              );
                            },
                          );
                        } else if (widget
                                .passwordController
                                .text !=
                            widget
                                .confirmPasswordController
                                .text) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return InfoAlert(
                                theme: theme,
                                message:
                                    'Passwords do not match. Please check the passwords fields and try again.',
                                title: 'Password Mismatch',
                              );
                            },
                          );
                        } else if (widget
                                .oldPasswordController
                                .text !=
                            widget.user.password) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return InfoAlert(
                                theme: theme,
                                message:
                                    'Old password is not correct. Please check the password field and try again.',
                                title: 'Password Incorrect',
                              );
                            },
                          );
                        } else {
                          final safeContex = context;

                          showDialog(
                            context: safeContex,
                            builder: (context) {
                              return ConfirmationAlert(
                                theme: theme,
                                message:
                                    'Are you sure you want to proceed?',
                                title: 'Proceed?',
                                action: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  Navigator.of(
                                    safeContex,
                                  ).pop();

                                  await AuthService()
                                      .changePasswordAndUpdateLocal(
                                        newPassword:
                                            widget
                                                .passwordController
                                                .text,
                                        context: context,
                                      );

                                  setState(() {
                                    isLoading = false;
                                    showSuccess = true;
                                  });

                                  Future.delayed(
                                    Duration(seconds: 2),
                                    () {
                                      if (safeContex
                                          .mounted) {
                                        Navigator.of(
                                          safeContex,
                                        ).pop();
                                      }
                                    },
                                  );
                                },
                              );
                            },
                          );
                        }
                      }
                    },
                    text: 'Update Details',
                  ),
                  SizedBox(height: 10),
                  MainButtonTransparent(
                    themeProvider: theme,
                    constraints: BoxConstraints(),
                    text: 'Cancel',
                    action: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(height: 30),
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
            widget.action == 'normal'
                ? 'Updated Successfully'
                : widget.action == 'password'
                ? 'Password Updated Successfully'
                : 'Successful',
          ),
        ),
      ],
    );
  }
}
