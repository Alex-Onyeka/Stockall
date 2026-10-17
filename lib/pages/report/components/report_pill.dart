import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Toolbar button of the report tables (date, filters, reset).
/// With a null [onTap] the pill only shows, so a parent such as a
/// PopupMenuButton can handle the tap.
class ReportPill extends StatelessWidget {
  final ThemeProvider theme;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool highlighted;

  /// Text and icon colour; defaults to the accent when
  /// [highlighted], otherwise black.
  final Color? color;

  const ReportPill({
    super.key,
    required this.theme,
    required this.icon,
    required this.label,
    this.onTap,
    this.highlighted = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = theme.lightModeColor.prColor300;
    final fg =
        color ?? (highlighted ? accent : Colors.black87);
    return Material(
      color:
          highlighted
              ? accent.withAlpha(30)
              : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Icon(icon, size: 16, color: fg),
              Text(
                label,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.bold,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
