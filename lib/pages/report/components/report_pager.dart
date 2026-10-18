import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

// Shared copy of the Items Report's pager, for the report tables.

/// "Showing 1-100 of 250 receipts" plus Previous / Next.
class ReportPager extends StatelessWidget {
  final ThemeProvider theme;
  final int page;
  final int totalPages;
  final int totalCount;
  final int firstIndex;
  final int lastIndex;

  /// Plural noun for the count, e.g. "receipts".
  final String itemLabel;
  final ValueChanged<int> onPage;

  const ReportPager({
    super.key,
    required this.theme,
    required this.page,
    required this.totalPages,
    required this.totalCount,
    required this.firstIndex,
    required this.lastIndex,
    required this.itemLabel,
    required this.onPage,
  });

  @override
  Widget build(BuildContext context) {
    final accent = theme.lightModeColor.prColor300;
    Widget nav(
      String text,
      IconData icon,
      bool enabled,
      int to, {
      bool iconRight = false,
    }) {
      final color = enabled ? accent : Colors.grey;
      return TextButton(
        onPressed: enabled ? () => onPage(to) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            if (!iconRight)
              Icon(icon, size: 16, color: color),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (iconRight)
              Icon(icon, size: 16, color: color),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 4,
        children: [
          Text(
            totalCount == 0
                ? 'No $itemLabel'
                : 'Showing $firstIndex-$lastIndex of $totalCount $itemLabel',
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              color: Colors.grey.shade700,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              nav(
                'Previous',
                Icons.chevron_left_rounded,
                page > 1,
                page - 1,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Page $page of $totalPages',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: theme.mobileTexts.b3.fontSize,
                  ),
                ),
              ),
              nav(
                'Next',
                Icons.chevron_right_rounded,
                page < totalPages,
                page + 1,
                iconRight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
