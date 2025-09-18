import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/phone_number_text_field.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/home/home.dart';
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
  final bool? main;

  const EditMobile({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.user,
    this.main,
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

  String value1 = '0';
  String value2 = '0';

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          appBar: appBar(
            context: context,
            main:
                widget.action == 'PIN' &&
                widget.main != null,
            title:
                widget.action == 'normal'
                    ? 'Edit Profile'
                    : widget.action == 'email'
                    ? 'Update Email'
                    : widget.action == 'PIN' &&
                        widget.main != null
                    ? 'Create New PIN'
                    : widget.action == 'PIN'
                    ? 'Change PIN'
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
                  Visibility(
                    visible: widget.action == 'PIN',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                'Enter New PIN',
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          PinCodeTextField(
                            appContext: context,
                            length: 4,
                            onChanged: (value) {
                              setState(() {
                                value1 = value;
                              });
                            },
                            onCompleted: (value) {},
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius:
                                  BorderRadius.circular(5),
                              fieldHeight: 50,
                              fieldWidth: 40,
                              activeFillColor: Colors.white,
                              selectedFillColor:
                                  Colors.grey.shade100,
                              inactiveFillColor:
                                  Colors.grey.shade100,
                              activeColor:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                              selectedColor:
                                  theme
                                      .lightModeColor
                                      .prColor300,
                              inactiveColor: Colors.grey,
                            ),
                            cursorColor:
                                theme
                                    .lightModeColor
                                    .prColor300,
                            keyboardType:
                                TextInputType.number,
                            animationType:
                                AnimationType.fade,
                            enableActiveFill: true,
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                'Confirm New PIN',
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          PinCodeTextField(
                            appContext: context,
                            length: 4,
                            onChanged: (value) {
                              setState(() {
                                value2 = value;
                              });
                            },
                            onCompleted: (value) {
                              if (value1 != value) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return InfoAlert(
                                      theme: theme,
                                      message:
                                          'PIN Does not match. Please Check the two PIN\'s, and Try again.',
                                      title: 'PIN Mismatch',
                                    );
                                  },
                                );
                              } else {
                                return;
                              }
                            },
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius:
                                  BorderRadius.circular(5),
                              fieldHeight: 50,
                              fieldWidth: 40,
                              activeFillColor: Colors.white,
                              selectedFillColor:
                                  Colors.grey.shade100,
                              inactiveFillColor:
                                  Colors.grey.shade100,
                              activeColor:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                              selectedColor:
                                  theme
                                      .lightModeColor
                                      .prColor300,
                              inactiveColor: Colors.grey,
                            ),
                            cursorColor:
                                theme
                                    .lightModeColor
                                    .prColor300,
                            keyboardType:
                                TextInputType.number,
                            animationType:
                                AnimationType.fade,
                            enableActiveFill: true,
                          ),
                        ],
                      ),
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

                                  // TempUserClass
                                  // user =
                                  await userProvider.updateUser(
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
                      } else if (widget.action == 'PIN') {
                        if (value1 != value2) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return InfoAlert(
                                theme: theme,
                                message:
                                    'PIN Does not match. Please Check the two PIN\'s, and Try again.',
                                title: 'PIN Mismatch',
                              );
                            },
                          );
                        } else if (value1.length != 4 ||
                            value2.length != 4) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return InfoAlert(
                                theme: theme,
                                message:
                                    'Invalid PIN Length. Please Ensure that the Length of PINS are 4, and try again.',
                                title: 'Invalid PIN',
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
                          var navP = returnNavProvider(
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

                                  await userProvider
                                      .updatePinInSupabase(
                                        newPin: value2,
                                        userId:
                                            AuthService()
                                                .currentUser!,
                                      );

                                  setState(() {
                                    isLoading = false;
                                    showSuccess = true;
                                  });

                                  if (!mounted) return;
                                  navP.verify();

                                  if (safeContex.mounted) {
                                    if (widget.main !=
                                        null) {
                                      Navigator.push(
                                        safeContex, // ✅ use this
                                        MaterialPageRoute(
                                          builder: (
                                            context,
                                          ) {
                                            return Home();
                                          },
                                        ),
                                      );
                                      // performRestart();
                                    } else {
                                      Navigator.of(
                                        safeContex,
                                      ).pop();
                                    }
                                  }
                                },
                              );
                            },
                          );
                        }
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
                          final BuildContext rootContext =
                              context; // Save outer context

                          showDialog(
                            context: rootContext,
                            builder: (dialogContext) {
                              return ConfirmationAlert(
                                theme: theme,
                                message:
                                    'Are you sure you want to proceed?',
                                title: 'Proceed?',
                                action: () async {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  // Close the confirmation dialog
                                  Navigator.of(
                                    dialogContext,
                                  ).pop();

                                  // Try to change password
                                  var res = await AuthService()
                                      .changePasswordAndUpdateLocal(
                                        newPassword:
                                            widget
                                                .passwordController
                                                .text,
                                        context:
                                            rootContext,
                                      );

                                  // 💡 Handle "new password = old password" (422 error)
                                  if (res == '422' &&
                                      rootContext.mounted) {
                                    await showDialog(
                                      context: rootContext,
                                      builder: (context) {
                                        return InfoAlert(
                                          theme: theme,
                                          message:
                                              'New password cannot be the same as the old password.',
                                          title:
                                              'Password Not Changed',
                                        );
                                      },
                                    );
                                    setState(() {
                                      isLoading = false;
                                    });
                                    return;
                                  }

                                  setState(() {
                                    isLoading = false;
                                    showSuccess = true;
                                  });

                                  // Wait 2 seconds then pop the parent page
                                  Future.delayed(
                                    Duration(seconds: 2),
                                    () {
                                      if (rootContext
                                          .mounted) {
                                        Navigator.of(
                                          rootContext,
                                        ).pop(); // close the whole screen/page
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
                    text:
                        widget.action == 'normal'
                            ? 'Update Details'
                            : widget.action == 'password'
                            ? 'Update Password'
                            : widget.action == 'PIN' &&
                                widget.main != null
                            ? 'Create PIN'
                            : widget.action == 'PIN'
                            ? 'Update PIN'
                            : 'Update Details',
                  ),
                  SizedBox(height: 10),
                  Visibility(
                    visible: widget.main == null,
                    child: MainButtonTransparent(
                      themeProvider: theme,
                      constraints: BoxConstraints(),
                      text: 'Cancel',
                      action: () {
                        Navigator.of(context).pop();
                      },
                    ),
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
                : widget.action == 'PIN'
                ? 'PIN Updated Successfully'
                : widget.action == 'PIN' &&
                    widget.main != null
                ? 'PIN Set Successfully'
                : 'Successful',
          ),
        ),
      ],
    );
  }
}
