import 'package:flutter/material.dart';
import 'package:storrec/providers/theme_provider.dart';

class BarcodeScanner extends StatelessWidget {
  final String title;
  final bool valueSet;
  final String hint;
  final Function()? onTap;
  final ThemeProvider theme;

  const BarcodeScanner({
    super.key,
    required this.title,
    required this.hint,
    required this.theme,
    required this.onTap,
    required this.valueSet,
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
        InkWell(
          onTap: onTap,
          child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
              suffixIcon: Icon(
                size: 30,
                color: Colors.grey,
                Icons.qr_code_scanner_sharp,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 13,
              ),
              hintText: hint,
              hintStyle: TextStyle(
                color:
                    valueSet
                        ? Colors.grey.shade700
                        : Colors.grey.shade500,
                fontSize: 14,
                fontWeight:
                    valueSet
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
