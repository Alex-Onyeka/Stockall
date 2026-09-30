import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/custom_receipt_print_and_download.dart';
import 'package:stockall/main.dart';

class CustomReceiptPrintWidget extends StatefulWidget {
  final String? mainText;
  const CustomReceiptPrintWidget({
    super.key,
    this.mainText,
  });

  @override
  State<CustomReceiptPrintWidget> createState() =>
      _CustomReceiptPrintWidgetState();
}

class _CustomReceiptPrintWidgetState
    extends State<CustomReceiptPrintWidget> {
  final TextEditingController customReceiptTextController =
      TextEditingController();
  final TextEditingController customReceiptTitleController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.mainText != null) {
      customReceiptTextController.text =
          widget.mainText ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(19, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.b1.fontSize,
              fontWeight: FontWeight.bold,
            ),
            'Print Receipt',
          ),
          Divider(indent: 100, endIndent: 100),
          GeneralTextfieldOnly(
            hint: 'Enter Title (Optional)',
            controller: customReceiptTitleController,
            lines: 1,
            theme: theme,
            onSubmitted: (value) {},
          ),
          GeneralTextfieldOnly(
            hint: 'Enter Text',
            controller: customReceiptTextController,
            textInputAction: TextInputAction.newline,
            lines: 6,
            theme: theme,
            minLines: 3,
            onSubmitted: (value) {},
          ),
          SizedBox(height: 10),
          MainButtonP(
            themeProvider: theme,
            action: () {
              printCustomReceiptAction(
                context: context,
                title:
                    customReceiptTitleController
                            .text
                            .isNotEmpty
                        ? customReceiptTitleController.text
                            .trim()
                        : null,
                text:
                    customReceiptTextController.text.trim(),
              );
            },
            text: 'Print',
          ),
          SizedBox(height: 5),
          Visibility(
            visible: widget.mainText != null,
            child: MainButtonTransparent(
              themeProvider: theme,
              constraints: BoxConstraints(),
              text: 'Cancel',
              action: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

void printCustomReceiptAction({
  required BuildContext context,
  String? title,
  required String text,
}) {
  if (text.isNotEmpty) {
    var theme = returnTheme(context, listen: false);
    showDialog(
      context: context,
      builder: (firstContext) {
        return ConfirmationAlert(
          theme: theme,
          message:
              'You are about to print a Custom Receipt. Are you sure you want to continue?',
          title: 'Print Custom Receipt',
          action: () {
            Navigator.of(firstContext).pop();
            // print('Action Started');
            generateAndPreviewPdfRollCustomAccountBalance(
              text: text,
              title: title,
              context: context,
            );
          },
        );
      },
    );
  }
}
