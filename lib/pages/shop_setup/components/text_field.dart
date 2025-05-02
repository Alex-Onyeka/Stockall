import 'package:flutter/material.dart';
import 'package:stockitt/providers/theme_provider.dart';

class FormFieldShop extends StatelessWidget {
  final bool isOptional;
  final String? message;
  final TextEditingController controller;
  final bool isEmail;
  final String hintText;
  final String title;
  const FormFieldShop({
    super.key,
    required this.theme,
    required this.isEmail,
    required this.hintText,
    required this.title,
    required this.controller,
    this.message,
    required this.isOptional,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Row(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              style: TextStyle(
                color: const Color.fromARGB(
                  246,
                  32,
                  32,
                  32,
                ),
                fontSize: theme.mobileTexts.b1.fontSize,
                fontWeight:
                    theme.mobileTexts.b1.fontWeightBold,
              ),
              title,
            ),
            Visibility(
              visible: isOptional,
              child: Text(
                style: TextStyle(
                  color: const Color.fromARGB(
                    246,
                    82,
                    82,
                    82,
                  ),
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight:
                      theme.mobileTexts.b1.fontWeightBold,
                ),
                '(Optional)',
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              keyboardType:
                  isEmail
                      ? TextInputType.emailAddress
                      : TextInputType.text,
              autocorrect: true,
              controller: controller,
              enableSuggestions: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade500,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: theme.lightModeColor.prColor300,
                    width: 2,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: message != null,
              child: Text(
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                message ?? '',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
