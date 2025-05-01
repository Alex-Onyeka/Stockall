import 'package:flutter/material.dart';
import 'package:stockitt/providers/theme_provider.dart';

class EmailTextField extends StatefulWidget {
  final ThemeProvider theme;
  final bool isEmail;
  final String hint;
  final String title;
  final TextEditingController controller;
  const EmailTextField({
    super.key,
    required this.controller,
    required this.theme,
    required this.isEmail,
    required this.hint,
    required this.title,
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
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          style: widget.theme.mobileTexts.b2.textStyleBold,
          widget.title,
        ),
        TextFormField(
          autocorrect: hidden && !widget.isEmail,
          enableSuggestions: hidden && !widget.isEmail,
          keyboardType:
              widget.isEmail
                  ? TextInputType.emailAddress
                  : TextInputType.visiblePassword,
          obscureText: hidden && !widget.isEmail,
          decoration: InputDecoration(
            suffixIcon: Visibility(
              visible: !widget.isEmail,
              child: InkWell(
                onTap: () {
                  setState(() {
                    hidden = !hidden;
                  });
                },
                child: Icon(
                  color: Colors.grey,
                  size: 23,
                  hidden
                      ? Icons.remove_red_eye_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              widget.isEmail
                  ? Icons.email_outlined
                  : Icons.lock_outline_rounded,
              size: 20,
              color:
                  widget.theme.lightModeColor.secColor200,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    widget.theme.lightModeColor.prColor200,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(15),
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
          controller: widget.controller,
        ),
      ],
    );
  }
}
