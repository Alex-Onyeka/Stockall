import 'package:flutter/material.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';

class ForgotPasswordMobile extends StatelessWidget {
  final TextEditingController emailController;
  const ForgotPasswordMobile({
    super.key,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Forgot Password',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 25.0,
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Enter your email below and you will receive a password reset token.',
            ),
            SizedBox(height: 20),
            EmailTextField(
              controller: emailController,
              theme: theme,
              isEmail: true,
              hint: 'Enter Email',
              title: 'Email',
            ),
            SizedBox(height: 20),
            MainButtonP(
              themeProvider: theme,
              action: () {},
              text: 'Send Recovery Link',
            ),
          ],
        ),
      ),
    );
  }
}
