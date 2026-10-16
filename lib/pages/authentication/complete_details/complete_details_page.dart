import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/authentication/complete_details/platforms/complete_details_desktop.dart';
import 'package:stockall/pages/authentication/complete_details/platforms/complete_details_mobile.dart';
import 'package:stockall/pages/authentication/translations/general.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

/// Shown after a Google sign-in when the user has no profile yet.
/// Same details as the create account page, minus email and passwords:
/// the email comes from the Google account and is read-only.
class CompleteDetailsPage extends StatefulWidget {
  const CompleteDetailsPage({super.key});

  @override
  State<CompleteDetailsPage> createState() =>
      _CompleteDetailsPageState();
}

class _CompleteDetailsPageState
    extends State<CompleteDetailsPage> {
  TextEditingController nameController =
      TextEditingController();
  TextEditingController lastNameController =
      TextEditingController();
  TextEditingController phoneNumberController =
      TextEditingController();
  TextEditingController emailController =
      TextEditingController();

  bool checked = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController.text =
        AuthService().currentUserAuth?.email
            ?.toLowerCase()
            .trim() ??
        '';
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
  }

  void showInfo(
    ThemeProvider theme, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return InfoAlert(
          theme: theme,
          message: message,
          title: title,
        );
      },
    );
  }

  void restart() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => BasePage()),
      (route) => false,
    );
  }

  Future<void> submit(ThemeProvider theme) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (nameController.text.trim().isEmpty ||
        phoneNumberController.text.trim().isEmpty) {
      showInfo(
        theme,
        title: 'Empty Input',
        message:
            'Please fill out all required fields before proceeding.',
      );
      return;
    }
    if (!checked) {
      showInfo(
        theme,
        title: 'Check the Box to Continue',
        message:
            'You need to Agree to Terms and Conditions before proceeding to create your account.',
      );
      return;
    }

    final authUser = AuthService().currentUserAuth;
    if (authUser == null) {
      restart();
      return;
    }

    setState(() {
      isLoading = true;
    });
    if (!await ConnectivityProvider().isOnline()) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showInfo(
        theme,
        title: General().authenticationError,
        message: General().noInternetConnection,
      );
      return;
    }

    try {
      await AuthService().createUserProfile(
        details: TempUserClass(
          access: [],
          userId: authUser.id,
          createdAt: DateTime.now(),
          name: nameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailController.text,
          phone: phoneNumberController.text.trim(),
          role: 'Cashier',
          password: '',
          departmentUuids: [],
        ),
        userId: authUser.id,
        email: emailController.text,
      );
      if (!mounted) return;
      returnNavProvider(context, listen: false).verify();
      restart();
    } catch (e) {
      await mainLocalLog(
        'Error completing user details: ${e.toString()}',
      );
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showInfo(
        theme,
        title: General().unexpectedError,
        message:
            'We could not save your details. Please check your internet and try again.',
      );
    }
  }

  Future<void> useAnotherAccount() async {
    setState(() {
      isLoading = true;
    });
    await AuthService().signOutWithoutProfile();
    if (!mounted) return;
    restart();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeProvider>(context);
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap:
            () =>
                FocusManager.instance.primaryFocus
                    ?.unfocus(),
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < mobileScreen) {
                  return CompleteDetailsMobile(
                    theme: theme,
                    nameController: nameController,
                    lastNameController: lastNameController,
                    phoneNumberController:
                        phoneNumberController,
                    emailController: emailController,
                    checked: checked,
                    onTap: () {
                      FocusManager.instance.primaryFocus
                          ?.unfocus();
                      setState(() {
                        checked = !checked;
                      });
                    },
                    onChanged: (value) {
                      FocusManager.instance.primaryFocus
                          ?.unfocus();
                      setState(() {
                        checked = value!;
                      });
                    },
                    onSubmit: () => submit(theme),
                    onUseAnotherAccount: useAnotherAccount,
                  );
                } else {
                  return CompleteDetailsDesktop(
                    theme: theme,
                    nameController: nameController,
                    lastNameController: lastNameController,
                    phoneNumberController:
                        phoneNumberController,
                    emailController: emailController,
                    checked: checked,
                    onTap: () {
                      setState(() {
                        checked = !checked;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        checked = value!;
                      });
                    },
                    onSubmit: () => submit(theme),
                    onUseAnotherAccount: useAnotherAccount,
                  );
                }
              },
            ),
            Visibility(
              visible: isLoading,
              child: returnCompProvider(
                context,
                listen: false,
              ).showLoader(message: 'Loading'),
            ),
          ],
        ),
      ),
    );
  }
}
