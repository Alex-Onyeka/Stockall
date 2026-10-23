import 'package:flutter/material.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/providers/theme_provider.dart';

/// "Group by" of the Receipts and Invoice report tables. A view
/// option, not a filter: Reset All keeps it.
enum ReportGroupBy { off, staff, customer, channel }

extension ReportGroupByLabel on ReportGroupBy {
  String get label {
    switch (this) {
      case ReportGroupBy.off:
        return 'Off';
      case ReportGroupBy.staff:
        return 'Staff';
      case ReportGroupBy.customer:
        return 'Customer';
      case ReportGroupBy.channel:
        return 'Channel';
    }
  }

  /// Pager label for the grouped rows.
  String get pagerLabel {
    switch (this) {
      case ReportGroupBy.staff:
        return 'staff';
      case ReportGroupBy.customer:
        return 'customers';
      case ReportGroupBy.channel:
        return 'channels';
      case ReportGroupBy.off:
        return 'rows';
    }
  }
}

/// Toolbar pill that opens the Group by choices.
class ReportGroupByButton extends StatelessWidget {
  final ThemeProvider theme;
  final ReportGroupBy value;
  final ValueChanged<ReportGroupBy> onChanged;

  const ReportGroupByButton({
    super.key,
    required this.theme,
    required this.value,
    required this.onChanged,
  });

  PopupMenuItem<ReportGroupBy> _item(ReportGroupBy g) {
    final selected = g == value;
    return PopupMenuItem<ReportGroupBy>(
      value: g,
      height: 38,
      child: Row(
        spacing: 8,
        children: [
          Icon(
            selected ? Icons.check_rounded : null,
            size: 16,
            color: theme.lightModeColor.prColor300,
          ),
          Text(
            g.label,
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: selected ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final on = value != ReportGroupBy.off;
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: PopupMenuButton<ReportGroupBy>(
        tooltip: 'Group rows',
        offset: const Offset(0, 42),
        color: Colors.white,
        onSelected: (g) {
          if (g != value) onChanged(g);
        },
        itemBuilder:
            (context) => [
              for (final g in ReportGroupBy.values) _item(g),
            ],
        child: ReportPill(
          theme: theme,
          icon: Icons.workspaces_outline,
          label: on ? 'Group by: ${value.label}' : 'Group by',
          highlighted: on,
        ),
      ),
    );
  }
}
