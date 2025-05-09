import 'package:flutter/material.dart';
import 'package:stockitt/providers/theme_provider.dart';

class GeneralTextField extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final int lines;
  final ThemeProvider theme;

  const GeneralTextField({
    super.key,
    required this.title,
    required this.hint,
    required this.controller,
    required this.lines,
    required this.theme,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 7,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          style: theme.mobileTexts.b2.textStyleBold,
          title,
        ),
        TextFormField(
          onChanged: onChanged,
          maxLines: lines,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.words,
          autocorrect: true,
          enableSuggestions: true,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: theme.lightModeColor.prColor300,
                width: 1.8,
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
