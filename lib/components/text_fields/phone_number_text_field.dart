import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:storrec/providers/theme_provider.dart';

class PhoneNumberTextField extends StatefulWidget {
  final TextEditingController controller;
  final ThemeProvider theme;
  final String title;
  final String hint;
  final bool? isEnabled;

  const PhoneNumberTextField({
    super.key,
    required this.controller,
    required this.theme,
    required this.title,
    required this.hint,
    this.isEnabled,
  });

  @override
  State<PhoneNumberTextField> createState() =>
      _PhoneNumberTextFieldState();
}

class _PhoneNumberTextFieldState
    extends State<PhoneNumberTextField> {
  @override
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
        IntlPhoneField(
          enabled: widget.isEnabled ?? true,
          disableLengthCheck: false,
          controller: widget.controller,
          pickerDialogStyle: PickerDialogStyle(
            backgroundColor: Colors.white,
            width: 400,
          ),
          decoration: InputDecoration(
            labelText: 'Enter Phone Number',
            labelStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    widget.theme.lightModeColor.prColor200,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    widget.theme.lightModeColor.prColor200,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    widget.theme.lightModeColor.prColor300,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          initialCountryCode: 'NG',
        ),
      ],
    );
  }
}
