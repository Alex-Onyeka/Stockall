import 'package:flutter/material.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/phone_number_text_field.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/authentication/components/check_agree.dart';
import 'package:stockall/providers/theme_provider.dart';

class CompleteDetailsDesktop extends StatelessWidget {
  final ThemeProvider theme;
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController emailController;
  final bool checked;
  final Function()? onTap;
  final Function(bool?)? onChanged;
  final Function() onSubmit;
  final Function() onUseAnotherAccount;

  const CompleteDetailsDesktop({
    super.key,
    required this.theme,
    required this.nameController,
    required this.lastNameController,
    required this.phoneNumberController,
    required this.emailController,
    required this.checked,
    required this.onTap,
    required this.onChanged,
    required this.onSubmit,
    required this.onUseAnotherAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DesktopCenterContainer(
        mainWidget: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(mainLogoIcon, height: 20),
                  Text(
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 25,
                      fontWeight:
                          theme.mobileTexts.h3.fontWeightBold,
                    ),
                    appName,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Column(
                spacing: 8,
                children: [
                  Row(
                    children: [
                      Text(
                        style: TextStyle(
                          color:
                              theme
                                  .lightModeColor
                                  .shadesColorBlack,
                          fontSize:
                              theme.mobileTexts.h3.fontSize,
                          fontWeight:
                              theme
                                  .mobileTexts
                                  .h3
                                  .fontWeightBold,
                        ),
                        'Complete your details',
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          style:
                              theme
                                  .mobileTexts
                                  .b1
                                  .textStyleNormal,
                          'You signed in with Google. Add a few details to finish your Account.',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Expanded(
                    child: GeneralTextField(
                      title: 'First Name*',
                      hint: 'Enter Your First Name',
                      controller: nameController,
                      lines: 1,
                      theme: theme,
                    ),
                  ),
                  Expanded(
                    child: GeneralTextField(
                      title: 'Last Name (Optional)',
                      hint: 'Enter Last Name',
                      controller: lastNameController,
                      lines: 1,
                      theme: theme,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              GeneralTextField(
                title: 'Email Address',
                hint: 'Email',
                controller: emailController,
                lines: 1,
                isEnabled: false,
                theme: theme,
              ),
              SizedBox(height: 10),
              PhoneNumberTextField(
                title: 'User Phone Number*',
                hint: 'Enter your Phone Number',
                controller: phoneNumberController,
                theme: theme,
              ),
              SizedBox(height: 20),
              CheckAgree(
                onChanged: onChanged,
                checked: checked,
                theme: theme,
                onTap: onTap,
              ),
              SizedBox(height: 20),
              MainButtonP(
                themeProvider: theme,
                action: onSubmit,
                text: 'Continue',
              ),
              SizedBox(height: 10),
              MainButtonTransparent(
                themeProvider: theme,
                constraints: BoxConstraints(),
                text: 'Use a different account',
                action: onUseAnotherAccount,
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
