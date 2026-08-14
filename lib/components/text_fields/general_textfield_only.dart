import 'package:flutter/material.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class GeneralTextfieldOnly extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final int lines;
  final int? minLines;
  final ThemeProvider theme;
  final GlobalKey<FormState>? formState;
  final String? initialValue;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function(PointerDownEvent pointerDownEvent)?
  onTapOutside;
  final Function(String value)? onSubmitted;
  final bool? autoFocus;
  const GeneralTextfieldOnly({
    super.key,
    required this.hint,
    required this.controller,
    required this.lines,
    required this.theme,
    this.onChanged,
    this.formState,
    this.initialValue,
    this.focusNode,
    this.minLines,
    this.textInputAction,
    this.onTapOutside,
    this.onSubmitted,
    this.autoFocus,
  });

  @override
  State<GeneralTextfieldOnly> createState() =>
      _GeneralTextfieldOnlyState();
}

class _GeneralTextfieldOnlyState
    extends State<GeneralTextfieldOnly> {
  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          widget.controller.text = widget.initialValue!;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return Form(
      key: widget.formState,
      child: TextFormField(
        autofocus: widget.autoFocus ?? false,
        onFieldSubmitted: widget.onSubmitted,
        onTapOutside: widget.onTapOutside,
        textInputAction:
            widget.textInputAction ?? TextInputAction.done,
        maxLines: widget.lines,
        keyboardType:
            widget.textInputAction ==
                    TextInputAction.newline
                ? TextInputType.multiline
                : TextInputType.text,
        textCapitalization: TextCapitalization.sentences,
        focusNode: widget.focusNode,
        minLines: widget.minLines ?? 1,
        onTap: () {
          if (returnShopProvider().isOnScreenKeyboardOn()) {
            showOnScreenKeyboard();
          }
        },
        validator: (value) {
          if (widget.formState != null &&
              value != null &&
              value.isEmpty) {
            return 'Input Field cannot be empty';
          } else {
            return null;
          }
        },
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: theme.mobileTexts.b2.fontSize,
        ),
        onChanged: widget.onChanged,
        autocorrect: true,
        enableSuggestions: true,
        decoration: InputDecoration(
          isCollapsed: true,
          labelText: widget.hint,
          labelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.grey.shade600,
            fontSize: theme.mobileTexts.b3.fontSize,
          ),
          floatingLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.lightModeColor.prColor300,
            fontSize: theme.mobileTexts.b1.fontSize,
            letterSpacing: 0.5,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.lightModeColor.prColor300,
              width: 1.3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        controller: widget.controller,
      ),
    );
  }
}
