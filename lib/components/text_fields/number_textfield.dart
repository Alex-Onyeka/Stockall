import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class NumberTextField extends StatefulWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final ThemeProvider theme;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final Function(String)? onSubmitted;
  final bool? showTitle;
  final Function()? onTap;
  final bool? autoFocus;

  const NumberTextField({
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
    this.autoFocus,
  });

  @override
  State<NumberTextField> createState() =>
      _NumberTextFieldState();
}

class _NumberTextFieldState extends State<NumberTextField> {
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
      // await mainLocalLog('Input: $input');
      String normalized = input
          .replaceAll(',', '')
          .replaceAll(RegExp(r'[^0-9.]'), '');
      // await mainLocalLog('Normalized: $normalized');

      // prevent multiple dots
      final parts = normalized.split('.');
      if (parts.length > 2) {
        normalized =
            '${parts[0]}.${parts.sublist(1).join('')}';
      }
      // await mainLocalLog('Raw: $_rawValue');
      // if (normalized != _rawValue) {
      _rawValue = normalized;

      final String amount =
          _rawValue.isEmpty ? '' : _rawValue;
      // await mainLocalLog('Amount: $amount');
      String formatted = '';
      if (amount.isEmpty) {
        _isEditing = true;
        widget.controller.value = const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
        _isEditing = false;
        return;
      }

      if (amount.contains('.')) {
        final part = amount.split('.');
        if (part[1].isNotEmpty && part[1].length > 3) {
          formatted =
              "${_formatter.format((double.tryParse(part[0]) ?? 0))}.${part[1].substring(0, part[1].length - 1)}";
        } else {
          formatted =
              "${_formatter.format((double.tryParse(part[0]) ?? 0))}.${part[1]}";
        }
      } else {
        formatted = _formatter.format(
          double.tryParse(amount) ?? 0,
        );
      }

      // await mainLocalLog('Formatted: $formatted');

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
          visible: widget.showTitle != false,
          child: Text(
            widget.title,
            style:
                widget.theme.mobileTexts.b3.textStyleBold,
          ),
        ),
        SizedBox(height: 5),
        TextFormField(
          autofocus:
              widget.autoFocus ??
              (screenWidth(context) > mobileScreen
                  ? true
                  : false),
          focusNode: widget.focusNode,
          onFieldSubmitted: widget.onSubmitted,
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            }
            if (returnShopProvider()
                .isOnScreenKeyboardOn()) {
              showOnScreenKeyboard();
            }
          },
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
          autocorrect: false,
          enableSuggestions: false,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
          decoration: InputDecoration(
            isCollapsed: true,
            prefixIconConstraints: BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),

            contentPadding: EdgeInsets.only(
              right: 5,
              left: 5,
              top: 8,
              bottom: 8,
            ),
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            hintText: widget.hint,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    widget.theme.lightModeColor.prColor300,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          controller: widget.controller,
        ),
      ],
    );
  }
}
