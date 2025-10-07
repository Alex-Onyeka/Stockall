import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class FormFieldShop extends StatelessWidget {
  final bool isOptional;
  final String? message;
  final TextEditingController controller;
  final bool isEmail;
  final String hintText;
  final String title;
  final bool isPhone;
  const FormFieldShop({
    super.key,
    required this.theme,
    required this.isEmail,
    required this.hintText,
    required this.title,
    required this.controller,
    this.message,
    required this.isOptional,
    required this.isPhone,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Row(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              style: theme.mobileTexts.b3.textStyleBold,
              title,
            ),
            Visibility(
              visible: isOptional,
              child: Text(
                style: theme.mobileTexts.b3.textStyleBold,
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
                      : isPhone
                      ? TextInputType.phone
                      : TextInputType.text,
              autocorrect: true,
              controller: controller,
              textCapitalization:
                  isEmail
                      ? TextCapitalization.none
                      : TextCapitalization.words,
              enableSuggestions: true,
              style: TextStyle(
                fontSize: theme.mobileTexts.b2.fontSize,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.normal,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade500,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: theme.lightModeColor.prColor300,
                    width: 1.3,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: message != null,
              child: Text(
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: theme.mobileTexts.b3.fontSize,
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
