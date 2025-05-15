import 'package:flutter/material.dart';
import 'package:stockitt/providers/theme_provider.dart';

class MainDropdown extends StatelessWidget {
  final bool isOpen;
  final String title;
  final bool valueSet;
  final String hint;
  final Function()? onTap;
  final ThemeProvider theme;

  const MainDropdown({
    super.key,
    required this.title,
    required this.hint,
    required this.theme,
    required this.isOpen,
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
                isOpen
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
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
                  color:
                      isOpen
                          ? theme.lightModeColor.prColor300
                          : Colors.grey,
                  width: isOpen ? 1.8 : 1.5,
                ),
                borderRadius: BorderRadius.circular(
                  isOpen ? 10 : 5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
