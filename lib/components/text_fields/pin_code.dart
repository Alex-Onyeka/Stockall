import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/main.dart';

class PinCodeWidget extends StatefulWidget {
  final Function()? action;
  final TextEditingController controller;
  final String? text;
  final bool hideText;
  final Function(String value)? onChanged;
  final bool? focus;

  const PinCodeWidget({
    super.key,
    required this.controller,
    this.text,
    this.action,
    required this.hideText,
    this.onChanged,
    this.focus,
  });

  @override
  State<PinCodeWidget> createState() =>
      _PinCodeWidgetState();
}

class _PinCodeWidgetState extends State<PinCodeWidget> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return PinCodeTextField(
      autoFocus:
          widget.focus != null && widget.focus == true,
      appContext: context,
      length: 4,
      onChanged: (value) {
        widget.onChanged != null
            ? widget.onChanged!(value)
            : {};
        print(widget.controller.text);
        // print(value);
        print(widget.text);
        //   if (value.length > 2) {
        //     widget.controller.clear();
        //   }
      },
      controller: widget.controller,
      onCompleted: (value) {
        if (widget.text != null) {
          if (value != widget.text!) {
            showDialog(
              context: context,
              builder: (context) {
                return InfoAlert(
                  theme: theme,
                  message:
                      'PIN Does not match. Please Check the two PIN\'s, and Try again.',
                  title: 'PIN Mismatch',
                );
              },
            );
            widget.controller.clear();
          }
        }
        widget.action != null ? widget.action!() : {};
        // return;
      },
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(5),
        fieldHeight: 50,
        fieldWidth: 40,
        activeFillColor: Colors.white,
        selectedFillColor: Colors.grey.shade100,
        inactiveFillColor: Colors.grey.shade100,
        activeColor: theme.lightModeColor.secColor200,
        selectedColor: theme.lightModeColor.prColor300,
        inactiveColor: Colors.grey,
      ),
      cursorColor: theme.lightModeColor.prColor300,
      keyboardType: TextInputType.number,
      blinkWhenObscuring: widget.hideText,
      obscureText: widget.hideText,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      obscuringWidget:
          widget.hideText
              ? Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade800,
                ),
              )
              : null,
      animationType: AnimationType.fade,
      enableActiveFill: true,
    );
  }
}
