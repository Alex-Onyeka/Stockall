import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockitt/providers/theme_provider.dart';

class MoneyTextfield extends StatefulWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final ThemeProvider theme;

  const MoneyTextfield({
    super.key,
    required this.title,
    required this.hint,
    required this.controller,
    required this.theme,
  });

  @override
  State<MoneyTextfield> createState() =>
      _MoneyTextfieldState();
}

class _MoneyTextfieldState extends State<MoneyTextfield> {
  final NumberFormat _formatter =
      NumberFormat.decimalPattern('en_NG');

  String _rawValue = '';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      if (_isEditing) return;

      // Keep only digits
      final rawText = widget.controller.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      // Remove leading zeros (but leave a single zero if the field is empty)
      final cleaned = rawText.replaceFirst(
        RegExp(r'^0+'),
        '',
      );

      if (cleaned != _rawValue) {
        _rawValue = cleaned;

        final int amount =
            int.tryParse(
              _rawValue.isEmpty ? '0' : _rawValue,
            ) ??
            0;
        final formatted =
            amount == 0 ? '' : _formatter.format(amount);

        _isEditing = true;
        widget.controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(
            offset: formatted.length,
          ),
        );
        _isEditing = false;
      }
    });
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
                  '₦',
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
              borderRadius: BorderRadius.circular(5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    widget.theme.lightModeColor.prColor300,
                width: 1.8,
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
