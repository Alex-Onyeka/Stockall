import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/items_report_/item_history_summary/class/item_history_summary_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Per-item version of the Item History Summary row, shown as a vertical list.
class ItemHistoryItemSummary extends StatefulWidget {
  final String productUuid;
  final bool isDesktop;
  const ItemHistoryItemSummary({
    super.key,
    required this.productUuid,
    required this.isDesktop,
  });

  @override
  State<ItemHistoryItemSummary> createState() =>
      _ItemHistoryItemSummaryState();
}

class _ItemHistoryItemSummaryState
    extends State<ItemHistoryItemSummary> {
  bool _loading = true;
  String? _error;

  TempProductClass? _product;
  List<ItemHistory> _histories = [];

  ItemHistoryPeriod _period = ItemHistoryPeriod.today;
  DateTimeRange? _customRange;

  ItemHistorySummaryRow? _row;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
  }

  bool get _departmentsEnabled =>
      shopSingle()?.manageDepartments == true;

  bool get _canViewAllDepartments => authorization(
    authorized: Authorizations().viewAllDepartments,
  );

  bool get _manageProductions =>
      shopSingle()?.manageProductions == true;

  String? get _currentDepartmentUuid =>
      returnDepartmentProvider().currentDepartment()?.uuid;

  Future<void> _load({
    required bool refreshFromStore,
  }) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (refreshFromStore && mounted) {
        final refresh = RefreshFunctions(context);
        await refresh.refreshProducts(context);
        if (!mounted) return;
        await returnItemHistoryProvider()
            .getItemHistories();
      } else {
        await returnItemHistoryProvider()
            .getItemHistoriesOffline();
      }

      final matches = returnData().productList().where(
        (p) => p.uuid == widget.productUuid,
      );
      _product = matches.isEmpty ? null : matches.first;

      // Same scoping as the Item History Summary report
      final currentShopId = shopId();
      final shopHistories =
          returnItemHistoryProvider().itemHistories
              .where((h) => h.shopId == currentShopId)
              .toList();

      if (_departmentsEnabled && !_canViewAllDepartments) {
        _histories =
            shopHistories
                .where(
                  (h) =>
                      h.departmentUuid ==
                      _currentDepartmentUuid,
                )
                .toList();
      } else {
        _histories = shopHistories;
      }

      _recompute();

      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _recompute() {
    if (_product == null) {
      _row = null;
      return;
    }
    final res =
        ItemHistorySummaryBuilder.buildSummaryAndRows(
          products: [_product!],
          histories: _histories,
          period: _period,
          businessNow: resolveBusinessDate(DateTime.now()),
          manageProductions: _manageProductions,
          customRange: _customRange,
        );
    _row = res.rows.isEmpty ? null : res.rows.first;
  }

  void _pickCustomRange() {
    final theme = returnTheme(context, listen: false);
    mainDatePicker(
      context: context,
      theme: theme,
      singleDate: (date) {
        if (date == null) return;
        final d = DateTime(date.year, date.month, date.day);
        setState(() {
          _period = ItemHistoryPeriod.custom;
          _customRange = DateTimeRange(start: d, end: d);
          _recompute();
        });
      },
      rangeDate: (start, end) {
        if (start == null) return;
        final s = DateTime(
          start.year,
          start.month,
          start.day,
        );
        final e =
            end == null
                ? s
                : DateTime(end.year, end.month, end.day);
        setState(() {
          _period = ItemHistoryPeriod.custom;
          _customRange = DateTimeRange(start: s, end: e);
          _recompute();
        });
      },
    );
  }

  void _resetToToday() {
    setState(() {
      _period = ItemHistoryPeriod.today;
      _customRange = null;
      _recompute();
    });
  }

  String get _periodLabel {
    final range =
        ItemHistorySummaryBuilder.resolveDateRange(
          period: _period,
          businessNow: resolveBusinessDate(DateTime.now()),
          customRange: _customRange,
        );
    final s = range.start;
    final e = range.end;
    final same =
        s.year == e.year &&
        s.month == e.month &&
        s.day == e.day;
    final dates =
        same
            ? formatDateTime(s)
            : '${formatDateTime(s)} - ${formatDateTime(e)}';
    return _period == ItemHistoryPeriod.today
        ? 'Today ($dates)'
        : dates;
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_error != null) {
      return _buildErrorView(theme);
    }
    if (_product == null || _row == null) {
      return Center(
        child: EmptyWidgetDisplayOnly(
          title: 'Item Not Found',
          subText: 'This item could not be found.',
          theme: theme,
          height: 30,
          altAction: () => _load(refreshFromStore: true),
          altActionText: 'Reload',
          icon: Icons.clear,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 15 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _buildHeader(theme),
          const SizedBox(height: 10),
          Expanded(child: _buildValues(theme, _row!)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildErrorView(ThemeProvider theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: theme.lightModeColor.errorColor200,
          ),
          Text(
            'Unable to generate item summary',
            style: TextStyle(
              fontSize: theme.mobileTexts.b1.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _error ?? 'An unexpected error occurred',
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              color: Colors.grey.shade600,
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _load(refreshFromStore: false),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              'Try Again',
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeProvider theme) {
    final isCustom = _period != ItemHistoryPeriod.today;
    return Wrap(
      spacing: 6,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _pill(
          theme: theme,
          icon: Icons.event_rounded,
          label: 'Date: $_periodLabel',
          highlighted: isCustom,
          onTap: _pickCustomRange,
        ),
        if (isCustom)
          _pill(
            theme: theme,
            icon: Icons.close,
            label: 'Clear',
            onTap: _resetToToday,
          ),
        _pill(
          theme: theme,
          icon: Icons.refresh_rounded,
          label: 'Refresh',
          onTap: () => _load(refreshFromStore: true),
        ),
      ],
    );
  }

  Widget _pill({
    required ThemeProvider theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    final accent = theme.lightModeColor.prColor300;
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              Icon(
                icon,
                size: 16,
                color:
                    highlighted ? accent : Colors.black87,
              ),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color:
                        highlighted
                            ? accent
                            : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValues(
    ThemeProvider theme,
    ItemHistorySummaryRow r,
  ) {
    final net = r.netQuantityChange;
    final entries = <
      ({String label, String value, Color color, bool bold})
    >[
      (
        label: 'Opening Stock',
        value: r.openingStockText,
        color: Colors.black87,
        bold: true,
      ),
      (
        label: 'Closing Stock',
        value: r.closingStockText,
        color: const Color(0xFF2563EB),
        bold: true,
      ),
      (
        label: 'Current Quantity',
        value: r.currentQuantityText,
        color: Colors.black87,
        bold: true,
      ),
      (
        label: 'Net Change',
        value: r.netQuantityChangeText,
        color:
            net > 0
                ? const Color(0xFF16A34A)
                : net < 0
                ? const Color(0xFFDC2626)
                : Colors.grey.shade600,
        bold: true,
      ),
      _movement(
        'Sold',
        r.soldText,
        r.sold,
        const Color(0xFFEA580C),
      ),
      _movement(
        'Returned (Sales)',
        r.returnedReceiptText,
        r.returnedReceipt,
        const Color(0xFF16A34A),
      ),
      _movement(
        'Purchased',
        r.purchasedText,
        r.purchased,
        const Color(0xFF3B82F6),
      ),
      _movement(
        'Returned (Purchase)',
        r.returnedPurchaseText,
        r.returnedPurchase,
        const Color(0xFFDC2626),
      ),
      _movement(
        'Transferred In',
        r.transferredInText,
        r.transferredIn,
        const Color(0xFF0284C7),
      ),
      _movement(
        'Transferred Out',
        r.transferredOutText,
        r.transferredOut,
        const Color(0xFFE11D48),
      ),
      _movement(
        'Stock In (Updated)',
        r.stockInUpdatedText,
        r.stockInUpdated,
        const Color(0xFF10B981),
      ),
      _movement(
        'Stock Out (Updated)',
        r.stockOutUpdatedText,
        r.stockOutUpdated,
        const Color(0xFF64748B),
      ),
      if (_manageProductions) ...[
        _movement(
          'Production',
          r.producedText,
          r.produced,
          const Color(0xFF8B5CF6),
        ),
        _movement(
          'Production Deleted',
          r.productionDeletedText,
          r.productionDeleted,
          const Color(0xFFF43F5E),
        ),
      ],
      _movement(
        'Delivered',
        r.deliveredText,
        r.delivered,
        const Color(0xFF9333EA),
      ),
      _movement(
        'Created',
        r.createdText,
        r.created,
        const Color(0xFF16A34A),
      ),
      _movement(
        'Deleted',
        r.deletedText,
        r.deleted,
        const Color(0xFFDC2626),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        itemCount: entries.length,
        separatorBuilder:
            (context, index) => Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
        itemBuilder: (context, index) {
          final e = entries[index];
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                  child: Text(
                    e.label,
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Text(
                  e.value,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight:
                        e.bold
                            ? FontWeight.bold
                            : FontWeight.normal,
                    color: e.color,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  ({String label, String value, Color color, bool bold})
  _movement(
    String label,
    String value,
    double amount,
    Color activeColor,
  ) {
    return (
      label: label,
      value: value,
      color:
          amount > 0 ? activeColor : Colors.grey.shade400,
      bold: amount > 0,
    );
  }
}
