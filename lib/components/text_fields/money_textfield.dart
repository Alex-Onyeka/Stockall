import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/providers/theme_provider.dart';

class MoneyTextfield extends StatefulWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final ThemeProvider theme;

  const MoneyTextfield({
    super.key,
    required this.title,
    required this.hint,
    required this.controller,
    required this.theme,
    this.onChanged,
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
                currencySymbol(context),
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
