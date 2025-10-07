import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class MainDropdownOnly extends StatelessWidget {
  final bool isOpen;
  final bool valueSet;
  final String hint;
  final Function()? onTap;
  final ThemeProvider theme;

  const MainDropdownOnly({
    super.key,
    required this.hint,
    required this.theme,
    required this.isOpen,
    required this.onTap,
    required this.valueSet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
              isCollapsed: true,
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Icon(
                  size: 25,
                  color: Colors.grey,
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                ),
              ),
              suffixIconConstraints: BoxConstraints(
                minHeight: 0,
                minWidth: 0,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              hintText: hint,
              hintStyle: TextStyle(
                color:
                    valueSet
                        ? Colors.grey.shade700
                        : Colors.grey.shade500,
                fontSize: theme.mobileTexts.b2.fontSize,
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
                  width: isOpen ? 1.3 : 1,
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
