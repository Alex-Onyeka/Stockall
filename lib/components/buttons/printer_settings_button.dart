import 'package:flutter/material.dart';
import 'package:stockall/main.dart' show returnTheme;
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/services/pos_printing/printer_settings_panel.dart';

const String printerSettingsLabel = 'Printer Settings';

// Opens the Printer Settings panel. Put it next to every print action.
class PrinterSettingsButton extends StatelessWidget {
  // True shows an icon with a tooltip instead of the pill, for tight
  // headers.
  final bool iconOnly;

  // True shows the pill with its icon only (tooltip for the label), for
  // narrow screens.
  final bool compact;

  // The section shown first (the A4 one next to A4 prints).
  final PrinterSettingsFocus focus;

  // Icon colour for iconOnly (e.g. on a dark banner).
  final Color? iconColor;

  const PrinterSettingsButton({
    super.key,
    this.iconOnly = false,
    this.compact = false,
    this.focus = PrinterSettingsFocus.roll,
    this.iconColor,
  });

  void _open(BuildContext context) =>
      openPrinterSettings(context, focus: focus);

  @override
  Widget build(BuildContext context) {
    if (iconOnly) {
      return IconButton(
        key: const ValueKey('printer-settings-button'),
        tooltip: printerSettingsLabel,
        icon: Icon(Icons.settings_outlined, color: iconColor),
        onPressed: () => _open(context),
      );
    }
    if (compact) {
      return Tooltip(
        message: printerSettingsLabel,
        child: Material(
          key: const ValueKey('printer-settings-button'),
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(5),
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(5),
            onTap: () => _open(context),
            child: const SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                Icons.settings_outlined,
                size: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      );
    }
    return ReportPill(
      key: const ValueKey('printer-settings-button'),
      theme: returnTheme(context),
      icon: Icons.settings_outlined,
      label: printerSettingsLabel,
      onTap: () => _open(context),
    );
  }
}

// The Printer Settings entry for a page's print menu (PopupMenuButton).
// [context] is the page's, which stays mounted when the menu closes.
PopupMenuItem<T> printerSettingsMenuItem<T>(
  BuildContext context, {
  double height = 35,
  TextStyle? style,
}) {
  return PopupMenuItem<T>(
    key: const ValueKey('printer-settings-menu-item'),
    height: height,
    onTap: () => openPrinterSettings(context),
    child: Text(
      style:
          style ??
          TextStyle(
            fontSize: returnTheme(context, listen: false).mobileTexts.b3.fontSize,
            fontWeight: FontWeight.bold,
          ),
      printerSettingsLabel,
    ),
  );
}
