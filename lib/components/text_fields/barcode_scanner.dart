import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/providers/theme_provider.dart';

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
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          style: theme.mobileTexts.b3.textStyleBold,
          title,
        ),
        Stack(
          children: [
            Visibility(
              visible:
                  kIsWeb ||
                  platforms(context) ==
                      TargetPlatform.android ||
                  platforms(context) == TargetPlatform.iOS,
              child: InkWell(
                onTap: onTap,
                child: TextFormField(
                  enabled: false,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(
                        right: 50.0,
                      ),
                      child: Icon(
                        size: 20,
                        color: Colors.grey,
                        Icons.qr_code_scanner_sharp,
                      ),
                    ),
                    suffixIconConstraints: BoxConstraints(
                      maxHeight: 20,
                      maxWidth: 35,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    hintText: hint,
                    hintStyle: TextStyle(
                      color:
                          valueSet
                              ? Colors.grey.shade700
                              : Colors.grey.shade500,
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight:
                          valueSet
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
