import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class EditCartTextField extends StatefulWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final ThemeProvider theme;
  final Function(String)? onChanged;
  final bool? discount;

  const EditCartTextField({
    super.key,
    required this.title,
    required this.hint,
    required this.controller,
    required this.theme,
    this.onChanged,
    this.discount,
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
          style: widget.theme.mobileTexts.b3.textStyleBold,
        ),
        SizedBox(height: 5),
        TextFormField(
          onChanged: widget.onChanged,

          keyboardType: TextInputType.number,
          autocorrect: false,
          enableSuggestions: false,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
          decoration: InputDecoration(
            isCollapsed: true,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 2,
              ),
              child: Text(
                widget.discount != null ? '%' : '#',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),

            contentPadding: EdgeInsets.only(
              right: 15,
              left: 15,
              top: 10,
              bottom: 10,
            ),
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            hintText: widget.hint,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    widget.theme.lightModeColor.prColor300,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          controller: widget.controller,
        ),
      ],
    );
  }
}
