import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class MoneyTextfield extends StatefulWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final ThemeProvider theme;
  final FocusNode? focusNode;
  final Function(String)? onSubmitted;
  final bool? showTitle;
  final Function()? onTap;

  const MoneyTextfield({
    super.key,
    required this.title,
    required this.hint,
    required this.controller,
    required this.theme,
    this.onChanged,
    this.focusNode,
    this.onSubmitted,
    this.showTitle,
    this.onTap,
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
      final input = widget.controller.text;
      print('Input: $input');
      String normalized = input
          .replaceAll(',', '')
          .replaceAll(RegExp(r'[^0-9.]'), '');
      print('Normalized: $normalized');

      // prevent multiple dots
      final parts = normalized.split('.');
      if (parts.length > 2) {
        normalized =
            '${parts[0]}.${parts.sublist(1).join('')}';
      }
      print('Raw: $_rawValue');
      // if (normalized != _rawValue) {
      _rawValue = normalized;

      final String amount =
          _rawValue.isEmpty ? '0' : _rawValue;
      print('Amount: $amount');
      String formatted = '';
      if (amount == '0') {
        formatted = '';
      } else {
        if (amount.contains('.')) {
          final part = amount.split('.');
          if (part[1].isNotEmpty && part[1].length > 3) {
            formatted =
                "${_formatter.format((double.tryParse(part[0].replaceAll(',', '')) ?? 0))}.${part[1].substring(0, (part[1].length - 1))}";
          } else {
            formatted =
                "${_formatter.format((double.tryParse(part[0].replaceAll(',', '')) ?? 0))}.${part[1]}";
          }
        } else {
          formatted = _formatter.format(
            (double.tryParse(amount.replaceAll(',', '')) ??
                0),
          );
        }
      }

      print('Formatted: $formatted');

      _isEditing = true;
      widget.controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(
          offset: formatted.length,
        ),
      );
      _isEditing = false;
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: widget.showTitle == null,
          child: Column(
            children: [
              Text(
                widget.title,
                style:
                    widget
                        .theme
                        .mobileTexts
                        .b3
                        .textStyleBold,
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
        TextFormField(
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            }
            if (returnShopProvider()
                .isOnScreenKeyboardOn()) {
              showOnScreenKeyboard();
            }
          },
          focusNode: widget.focusNode,
          onFieldSubmitted: widget.onSubmitted,
          onChanged: (value) {
            if (widget.controller.text == '.') {
              widget.controller.text = '';
            } else {
              widget.onChanged != null
                  ? widget.onChanged!(value)
                  : {};
              setState(() {});
            }
          },
          keyboardType: TextInputType.numberWithOptions(
            decimal: true,
          ),
          // inputFormatters: [
          //   FilteringTextInputFormatter.allow(
          //     RegExp(r'^\d*\.?\d*'),
          //   ),
          // ],
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
                currencySymbol(context: context),
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
