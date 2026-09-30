import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_generated_prints/custom_label_printer_class/custom_label_printer_settings/custom_label_printer_settings.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/main.dart';

void openPrinterSettings({required BuildContext context}) {
  final TextEditingController widthC =
      TextEditingController();
  final TextEditingController heightC =
      TextEditingController();
  final TextEditingController startX =
      TextEditingController();
  final TextEditingController startY =
      TextEditingController();
  final TextEditingController labelHeightC =
      TextEditingController();
  final TextEditingController labelScaleC =
      TextEditingController();

  void initPrinterSetting() {
    var shopP = returnShopProvider();
    widthC.text =
        shopP.customLabelPrinterSettings!.widthMm
            .toString();
    heightC.text =
        shopP.customLabelPrinterSettings!.heightMm
            .toString();
    startX.text =
        shopP.customLabelPrinterSettings!.startX.toString();
    startY.text =
        shopP.customLabelPrinterSettings!.startY.toString();
    labelHeightC.text =
        shopP.customLabelPrinterSettings!.labelHeight
            .toString();
    labelScaleC.text =
        shopP.customLabelPrinterSettings!.labelScale
            .toString();
  }

  initPrinterSetting();
  var theme = returnTheme(context, listen: false);
  showDialog(
    context: context,
    builder: (context) {
      return DialogTemplate(
        theme: theme,
        message: 'Edit Printer Settings',
        title: 'Edit Printer',
        topRightWidget: Material(
          color: Colors.transparent,
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            onTap: () {
              returnShopProvider()
                  .updateCustomLabelPrinterSettings(
                    returnShopProvider()
                        .defaultCustomLabelPrinterSettings,
                  );
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 3,
                children: [
                  Icon(size: 16, Icons.refresh),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    'Reset',
                  ),
                ],
              ),
            ),
          ),
        ),
        action: () {
          var shopP = returnShopProvider();
          var newSettings = CustomLabelPrinterSettings(
            widthMm:
                double.tryParse(widthC.text) ??
                shopP.customLabelPrinterSettings!.widthMm,
            heightMm:
                double.tryParse(heightC.text) ??
                shopP.customLabelPrinterSettings!.heightMm,
            startX:
                int.tryParse(startX.text) ??
                shopP.customLabelPrinterSettings!.startX,
            startY:
                int.tryParse(startY.text) ??
                shopP.customLabelPrinterSettings!.startY,
            labelHeight:
                int.tryParse(labelHeightC.text) ??
                shopP
                    .customLabelPrinterSettings!
                    .labelHeight,
            labelScale:
                int.tryParse(labelScaleC.text) ??
                shopP
                    .customLabelPrinterSettings!
                    .labelScale,
          );

          shopP.updateCustomLabelPrinterSettings(
            newSettings,
          );
          Navigator.of(context).pop();
        },
        widget: Builder(
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  spacing: 10,
                  children: [
                    Expanded(
                      child: EditCartTextField(
                        title: 'Label Width',
                        hint: 'Width (mm)',
                        controller: widthC,
                        theme: theme,
                      ),
                    ),
                    Expanded(
                      child: EditCartTextField(
                        title: 'Label Height',
                        hint: 'Height (mm)',
                        controller: heightC,
                        theme: theme,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  spacing: 10,
                  children: [
                    Expanded(
                      child: EditCartTextField(
                        title: 'Left Margin Position',
                        hint: 'Left Margin (mm)',
                        controller: startX,
                        theme: theme,
                      ),
                    ),
                    Expanded(
                      child: EditCartTextField(
                        title: 'Top Margin Position',
                        hint: 'Top Margin (mm)',
                        controller: startY,
                        theme: theme,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  spacing: 10,
                  children: [
                    Expanded(
                      child: EditCartTextField(
                        title: 'Text Scale',
                        hint: 'Scale (mm)',
                        controller: labelScaleC,
                        theme: theme,
                      ),
                    ),
                    Expanded(
                      child: EditCartTextField(
                        title: 'Text height',
                        hint: 'Height (mm)',
                        controller: labelHeightC,
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actionButtonText: 'Update Printer',
      );
    },
  );
}
