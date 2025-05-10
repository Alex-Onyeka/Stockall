import 'package:flutter/material.dart';
import 'package:stockitt/providers/theme_provider.dart';

class EditCartTextField extends StatefulWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final ThemeProvider theme;

  const EditCartTextField({
    super.key,
    required this.title,
    required this.hint,
    required this.controller,
    required this.theme,
  });

  @override
  State<EditCartTextField> createState() =>
      _EditCartTextFieldState();
}

class _EditCartTextFieldState
    extends State<EditCartTextField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: widget.theme.mobileTexts.b2.textStyleBold,
        ),
        SizedBox(height: 10),
        TextFormField(
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
          keyboardType: TextInputType.number,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            isCollapsed: true,
            prefixIcon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                  '#',
                ),
              ],
            ),

            contentPadding: EdgeInsets.only(
              right: 20,
              left: 15,
              top: 12,
              bottom: 12,
            ),
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    widget.theme.lightModeColor.prColor300,
                width: 1.8,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          controller: widget.controller,
        ),
      ],
    );
  }
}
