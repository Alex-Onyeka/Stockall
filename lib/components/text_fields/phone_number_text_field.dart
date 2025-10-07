import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:stockall/providers/theme_provider.dart';

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
          style: widget.theme.mobileTexts.b3.textStyleBold,
        ),
        SizedBox(height: 5),
        IntlPhoneField(
          onChanged: (value) {
            if (widget.controller.text.split('').first ==
                '0') {
              setState(() {
                widget.controller.text = widget
                    .controller
                    .text
                    .substring(
                      1,
                      widget.controller.text.length,
                    );
              });
            }
          },
          style: TextStyle(
            fontSize: widget.theme.mobileTexts.b2.fontSize,
            fontWeight: FontWeight.bold,
          ),
          enabled: widget.isEnabled ?? true,
          disableLengthCheck: false,
          controller: widget.controller,
          pickerDialogStyle: PickerDialogStyle(
            backgroundColor: Colors.white,
            listTileDivider: Divider(
              height: 0,
              color: Colors.grey.shade400,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            countryNameStyle: TextStyle(
              fontSize:
                  widget.theme.mobileTexts.b2.fontSize,
            ),
            width: 500,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(
              right: 20,
              bottom: 10,
              left: 10,
              top: 10,
            ),
            labelText: 'Enter Phone Number',
            labelStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize:
                  widget.theme.mobileTexts.b2.fontSize,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade700,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade700,
                width: 1.0,
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
          initialCountryCode: 'NG',
        ),
      ],
    );
  }
}
