import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class GeneralTextField extends StatelessWidget {
  final String title;
  final String hint;
  final bool? isEmail;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final int lines;
  final bool? isEnabled;
  final ThemeProvider theme;

  const GeneralTextField({
    super.key,
    required this.title,
    required this.hint,
    required this.controller,
    required this.lines,
    required this.theme,
    this.onChanged,
    this.isEmail,
    this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          style: theme.mobileTexts.b3.textStyleBold,
          title,
        ),
        TextFormField(
          enabled: isEnabled ?? true,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
          onChanged: onChanged,
          maxLines: lines,
          keyboardType:
              isEmail == null
                  ? TextInputType.text
                  : TextInputType.emailAddress,
          textCapitalization:
              isEmail == null
                  ? TextCapitalization.words
                  : TextCapitalization.none,
          autocorrect: isEmail == null ? true : false,
          enableSuggestions: isEmail == null ? true : false,
          decoration: InputDecoration(
            isCollapsed: true,
            labelText: hint,
            labelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
            floatingLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.lightModeColor.prColor300,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: theme.lightModeColor.prColor300,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          controller: controller,
        ),
      ],
    );
  }
}
