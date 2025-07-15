import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class GeneralTextfieldOnly extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final int lines;
  final ThemeProvider theme;

  const GeneralTextfieldOnly({
    super.key,
    required this.hint,
    required this.controller,
    required this.lines,
    required this.theme,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(fontWeight: FontWeight.bold),
      onChanged: onChanged,
      maxLines: lines,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      autocorrect: true,
      enableSuggestions: true,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        floatingLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: theme.lightModeColor.prColor300,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(5),
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
    );
  }
}
