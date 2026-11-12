import 'package:flutter/material.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/report_list_tile.dart';
import 'package:stockall/pages/report/production_report/class/production_report_hub_logic.dart';
import 'package:stockall/pages/report/production_report/material_history_summary/material_history_summary_page.dart';
import 'package:stockall/pages/report/production_report/material_history_table/material_history_table_page.dart';
import 'package:stockall/pages/report/production_report/materials_analysis/materials_analysis_page.dart';
import 'package:stockall/pages/report/production_report/materials_table/materials_table_page.dart';
import 'package:stockall/pages/report/production_report/produced_item_history_summary/produced_item_history_summary_page.dart';
import 'package:stockall/pages/report/production_report/produced_item_history_table/produced_item_history_table_page.dart';
import 'package:stockall/pages/report/production_report/produced_items_analysis/produced_items_analysis_page.dart';
import 'package:stockall/pages/report/production_report/produced_items_table/produced_items_table_page.dart';
import 'package:stockall/pages/report/production_report/production_records_table/production_records_table_page.dart';
import 'package:stockall/pages/report/production_report/production_summary/production_summary_page.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/usage_records_table_page.dart';
import 'package:stockall/pages/report/production_report/usage_summary/usage_summary_page.dart';
import 'package:stockall/providers/theme_provider.dart';

/// The Production Report hub: the report pages grouped by the four
/// production elements. One view for mobile and desktop.
class ProductionReportHubView extends StatelessWidget {
  final bool isDesktop;

  const ProductionReportHubView({super.key, required this.isDesktop});

  /// The built pages. A page that isn't here yet shows as
  /// "Coming Soon".
  static final Map<ProductionReportPageId, Widget Function()> _pages = {
    ProductionReportPageId.materialsTable: () => const MaterialsTablePage(),
    ProductionReportPageId.materialsAnalysis:
        () => const MaterialsAnalysisPage(),
    ProductionReportPageId.materialHistoryTable:
        () => const MaterialHistoryTablePage(),
    ProductionReportPageId.materialHistorySummary:
        () => const MaterialHistorySummaryPage(),
    ProductionReportPageId.productionRecordsTable:
        () => const ProductionRecordsTablePage(),
    ProductionReportPageId.productionSummary:
        () => const ProductionSummaryPage(),
    ProductionReportPageId.usageRecordsTable:
        () => const UsageRecordsTablePage(),
    ProductionReportPageId.usageSummary: () => const UsageSummaryPage(),
    ProductionReportPageId.producedItemsTable:
        () => const ProducedItemsTablePage(),
    ProductionReportPageId.producedItemsAnalysis:
        () => const ProducedItemsAnalysisPage(),
    ProductionReportPageId.producedItemHistoryTable:
        () => const ProducedItemHistoryTablePage(),
    ProductionReportPageId.producedItemHistorySummary:
        () => const ProducedItemHistorySummaryPage(),
  };

  static Widget Function()? pageFor(ProductionReportPageId id) =>
      _pages[id];

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    final groups = ProductionReportHub.groups(
      historyAllowed:
          authorization(authorized: Authorizations().viewItemsHistory) &&
          ItemsAuthAction().trackItemHistoryAction(context: null),
      producedItemsEnabled: shop(context)?.manageProductionItems == true,
    );

    final body = Scaffold(
      body: Column(
        children: [
          TopBanner(
            turnOnBackNavButton: true,
            subTitle:
                'View your materials, material usage, produced items and production records',
            title: 'Production Report',
            theme: theme,
            bottomSpace: 40,
            topSpace: 30,
            isMain: true,
            iconSvg: reportIconSvg,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final group in groups)
                      _GroupSection(
                        group: group,
                        theme: theme,
                      ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!isDesktop) return body;
    return DesktopCenterContainer(width: 800, mainWidget: body);
  }
}

class _GroupSection extends StatelessWidget {
  final ProductionReportGroup group;
  final ThemeProvider theme;

  const _GroupSection({required this.group, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.title,
            style: TextStyle(
              fontSize: theme.mobileTexts.b1.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            group.subText,
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              color: theme.lightModeColor.shadesColorBlack,
            ),
          ),
          const SizedBox(height: 10),
          for (final entry in group.entries) _entryTile(context, entry),
        ],
      ),
    );
  }

  Widget _entryTile(BuildContext context, ProductionReportEntry entry) {
    final page = ProductionReportHubView.pageFor(entry.id);
    return ReportListTile(
      isActive: page != null,
      theme: theme,
      action: () {
        if (page == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page()),
        );
      },
      subText: entry.subText,
      title: page == null ? '${entry.title} (Coming Soon)' : entry.title,
    );
  }
}
