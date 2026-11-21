import 'package:flutter/material.dart';
import 'package:stockall/pages/report/components/report_list_tile.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/expenses_report_table_page.dart';
import 'package:stockall/pages/report/expenses_report/expenses_summary/expenses_summary_page.dart';
import 'package:stockall/providers/theme_provider.dart';

/// The hub's tiles, the same on mobile and desktop.
List<Widget> expensesReportTiles(BuildContext context, ThemeProvider theme) => [
  ReportListTile(
    isActive: true,
    theme: theme,
    action: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ExpensesReportTablePage(),
        ),
      );
    },
    subText:
        'A complete table of every expense, with its category, staff paid and sub-expenses',
    title: 'Expenses Report Table',
  ),
  ReportListTile(
    isActive: true,
    theme: theme,
    action: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ExpensesSummaryPage()),
      );
    },
    subText:
        'Totals and breakdowns by category, staff salary, staff, channel and trend',
    title: 'Expenses Summary and Analysis',
  ),
];
