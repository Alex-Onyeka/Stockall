import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class EmailTextField extends StatefulWidget {
  final String? Function(String?)? validatorAction;
  final ThemeProvider theme;
  final bool isEmail;
  final String hint;
  final String title;
  final bool? isEnabled;
  final TextEditingController controller;
  const EmailTextField({
    super.key,
    required this.controller,
    required this.theme,
    required this.isEmail,
    required this.hint,
    required this.title,
    this.validatorAction,
    this.isEnabled,
  });

  @override
  State<EmailTextField> createState() =>
      _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  bool hidden = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          style: widget.theme.mobileTexts.b3.textStyleBold,
          widget.title,
        ),
        TextFormField(
          enabled: widget.isEnabled ?? true,
          validator: widget.validatorAction,
          autocorrect: hidden && !widget.isEmail,
          enableSuggestions: hidden && !widget.isEmail,
          keyboardType:
              widget.isEmail
                  ? TextInputType.emailAddress
                  : TextInputType.visiblePassword,
          obscureText:
              widget.isEnabled == false
                  ? false
                  : hidden && !widget.isEmail,
          style: TextStyle(
            fontSize: widget.theme.mobileTexts.b2.fontSize,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            isCollapsed: true,
            suffixIcon: Visibility(
              visible: !widget.isEmail,
              child: InkWell(
                onTap: () {
                  setState(() {
                    hidden = !hidden;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12,
                  ),
                  child: Icon(
                    color: Colors.grey,
                    size: 20,
                    hidden
                        ? Icons.remove_red_eye_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            suffixIconConstraints: BoxConstraints(
              minHeight: 0,
              minWidth: 0,
            ),
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.normal,
              fontSize:
                  widget.theme.mobileTexts.b2.fontSize,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 5,
              ),
              child: Icon(
                widget.isEmail
                    ? Icons.email_outlined
                    : Icons.lock_outline_rounded,
                size: 16,
                color:
                    widget.theme.lightModeColor.secColor200,
              ),
            ),
            prefixIconConstraints: BoxConstraints(
              minHeight: 0,
              minWidth: 0,
            ),
            contentPadding: EdgeInsets.fromLTRB(
              10,
              13,
              10,
              13,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade500,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade500,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    widget.theme.lightModeColor.prColor200,
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
