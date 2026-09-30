import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/custom_printing_page/components/open_printer_settings.dart';
import 'package:stockall/pages/custom_printing_page/components/print_label_desktop_action.dart';
import 'package:stockall/pages/custom_printing_page/components/printer_list_widget.dart';

class CustomLabelPrintWidget extends StatefulWidget {
  final String? mainText;
  const CustomLabelPrintWidget({super.key, this.mainText});

  @override
  State<CustomLabelPrintWidget> createState() =>
      _CustomLabelPrintWidgetState();
}

class _CustomLabelPrintWidgetState
    extends State<CustomLabelPrintWidget> {
  final TextEditingController customLabelTextController =
      TextEditingController();
  final TextEditingController customLabelTitleController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.mainText != null) {
      customLabelTextController.text =
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
        children: [
          Expanded(
            child: Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b1.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'Print Label',
                ),
                Divider(indent: 100, endIndent: 100),
                GeneralTextfieldOnly(
                  hint: 'Enter Title (Optional)',
                  controller: customLabelTitleController,
                  lines: 1,
                  theme: theme,
                  onSubmitted: (value) {},
                ),
                GeneralTextfieldOnly(
                  hint: 'Enter Text',
                  controller: customLabelTextController,
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
                    if (returnShopProvider().printerCache !=
                            null &&
                        customLabelTextController
                            .text
                            .isNotEmpty) {
                      printLabelDesktopAction(
                        context: context,
                        customLabelTextController:
                            customLabelTextController,
                        customLabelTitleController:
                            customLabelTitleController,
                      );
                    }
                  },
                  text: 'Print Label',
                ),
                MainButtonTransparent(
                  themeProvider: theme,
                  constraints: BoxConstraints(),
                  text: 'Select Printer',
                  action: () {
                    showDialog(
                      context: context,
                      builder: (firstContext) {
                        return DialogTemplate(
                          theme: theme,
                          message: 'message',
                          title: 'title',
                          action: () {},
                          showTopSection: false,
                          widget: SizedBox(
                            height:
                                screenHeight(context) - 210,
                            child: PrinterListWidget(),
                          ),
                          showBottomActionButtons: true,
                          showMainBottomActionButton: false,
                        );
                      },
                    );
                  },
                ),
                MainButtonTransparent(
                  themeProvider: theme,
                  constraints: BoxConstraints(),
                  text: 'Printer Settings',
                  action: () {
                    openPrinterSettings(context: context);
                  },
                ),
              ],
            ),
          ),
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
