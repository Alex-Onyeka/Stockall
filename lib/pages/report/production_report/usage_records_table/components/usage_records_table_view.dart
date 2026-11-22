import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/production_materials_usage.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/materials_usage/unsync_funcs/deleted/deleted_production_materials_usage_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_details/production_details_page.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/components/materials_usage_tile.dart'
    show MaterialUsageDetailsWidget;
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/components/production_records_table_view.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_report_access.dart';
import 'package:stockall/pages/report/production_report/shared/components/production_filter_panel_box.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_export_spec.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/components/usage_records_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Everything the Usage Records table and summary read from the app.
/// [UsageRecordsEnv.live] uses the providers; tests pass their own,
/// since the providers need Supabase.
class UsageRecordsEnv {
  final bool Function() departmentsEnabled;
  final bool Function() canPickDate;

  /// "Manage Cost Price": cost columns, filters and KPIs.
  final bool Function() canSeeCost;

  /// "View Item Quantity": quantity columns and filters.
  final bool Function() canSeeQuantity;

  /// The shop's "Manage Production Items" setting, for the output of
  /// production records.
  final bool Function() manageProductionItems;

  /// Usage records the user may see (department and own-records scope
  /// applied).
  final List<ProductionMaterialsUsage> Function() usages;

  /// Production records the user may see, for the output of production
  /// usages and the note on earlier productions.
  final List<ProductionRecord> Function() records;

  /// Usage records queued for deletion, left out of the report.
  final Set<String> Function() pendingDeletedUuids;

  /// Production records queued for deletion.
  final Set<String> Function() pendingDeletedRecordUuids;

  final Future<void> Function(
    BuildContext context, {
    required bool refreshFromStore,
  })
  load;

  final Future<void> Function(
    BuildContext context, {
    required bool refreshFromStore,
    ReceiptsReportPeriod? period,
  })?
  loadForPeriod;

  Future<void> loadWithPeriod(
    BuildContext context, {
    required bool refreshFromStore,
    required ReceiptsReportPeriod period,
  }) =>
      loadForPeriod != null
          ? loadForPeriod!(
            context,
            refreshFromStore: refreshFromStore,
            period: period,
          )
          : load(
            context,
            refreshFromStore: refreshFromStore,
          );

  /// Changes whenever the source data or the user's scope does.
  final String Function() signature;

  /// Subscribes the view to the providers it reads.
  final void Function(BuildContext context) listen;
  final String Function(BuildContext context, num amount)
  money;

  /// Opens the production a usage came from.
  final Future<void> Function(
    BuildContext context,
    String productionUuid,
  )
  openProduction;

  /// Opens the usage details dialog of the usage records page.
  final Future<void> Function(
    BuildContext context,
    ProductionMaterialsUsage usage,
  )
  openUsage;

  /// Used by the summary to open the table. Null in the app: the
  /// summary pushes `UsageRecordsTablePage`.
  final Future<void> Function(
    BuildContext context,
    UsageRecordsFilters filters,
    ReceiptsReportPeriod period,
  )?
  openTable;

  const UsageRecordsEnv({
    required this.departmentsEnabled,
    required this.canPickDate,
    required this.canSeeCost,
    required this.canSeeQuantity,
    required this.manageProductionItems,
    required this.usages,
    required this.records,
    required this.pendingDeletedUuids,
    required this.pendingDeletedRecordUuids,
    required this.load,
    this.loadForPeriod,
    required this.signature,
    required this.listen,
    required this.money,
    required this.openProduction,
    required this.openUsage,
    this.openTable,
  });

  /// The production records part comes from [ProductionRecordsEnv.live].
  factory UsageRecordsEnv.live() {
    final production = ProductionRecordsEnv.live();
    Set<String> pendingDeleted() {
      try {
        return DeletedProductionMaterialsUsageFunc()
            .deletedProductionMaterialsUsageBox
            .values
            .map((d) => d.materialsUsageUuid)
            .toSet();
      } catch (_) {
        return const {};
      }
    }

    Future<void> loadPeriod(
      BuildContext context, {
      required bool refreshFromStore,
      ReceiptsReportPeriod? period,
    }) async {
      if (period != null) {
        await production.loadWithPeriod(
          context,
          refreshFromStore: refreshFromStore,
          period: period,
        );
      } else {
        await production.load(
          context,
          refreshFromStore: refreshFromStore,
        );
      }
      final sid = shopSingle()?.shopId;
      if (sid == null) return;
      final provider = returnMaterialsUsageProvider();
      final fetchAll = period?.isAllTime ?? false;
      final startDate = period?.start;
      final endDate = period?.end ?? period?.start;
      if (refreshFromStore) {
        await provider.getProductionMaterialsUsage(
          sid,
          startDate: startDate,
          endDate: endDate,
          fetchAll: fetchAll,
          forceRefresh: true,
        );
        return;
      }
      // Local (offline) reads, only when nothing is loaded yet.
      if (provider.productionMaterialsUsage.isEmpty) {
        await provider.getProductionMaterialsUsageOffline();
      }
      if (period != null && !period.isAllTime) {
        await provider.getProductionMaterialsUsage(
          sid,
          startDate: startDate,
          endDate: endDate,
          forceRefresh: false,
        );
      }
    }

    return UsageRecordsEnv(
      departmentsEnabled: production.departmentsEnabled,
      canPickDate: production.canPickDate,
      canSeeCost: production.canSeeCost,
      canSeeQuantity: production.canSeeQuantity,
      manageProductionItems:
          production.manageProductionItems,
      usages:
          () => ProductionReportAccess.scopeUsages(
            usages:
                returnMaterialsUsageProvider()
                    .productionMaterialsUsage,
            departmentsEnabled:
                production.departmentsEnabled(),
            canViewAllDepartments: authorization(
              authorized:
                  Authorizations().viewAllDepartments,
            ),
            currentDepartmentUuid:
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid,
            canViewAllTransactions: authorization(
              authorized:
                  Authorizations()
                      .viewAllTransactionRecords,
            ),
            currentUserId: currentUser().userId,
          ),
      records: production.records,
      pendingDeletedUuids: pendingDeleted,
      pendingDeletedRecordUuids:
          production.pendingDeletedUuids,
      load: (context, {required refreshFromStore}) async {
        await loadPeriod(
          context,
          refreshFromStore: refreshFromStore,
        );
      },
      loadForPeriod: (
        context, {
        required refreshFromStore,
        period,
      }) async {
        await loadPeriod(
          context,
          refreshFromStore: refreshFromStore,
          period: period,
        );
      },
      signature: () {
        final usages =
            returnMaterialsUsageProvider()
                .productionMaterialsUsage;
        int latest = 0;
        double cost = 0;
        for (final u in usages) {
          final t =
              (u.updatedAt ?? u.createdAt)
                  ?.millisecondsSinceEpoch ??
              0;
          if (t > latest) latest = t;
          cost += u.getTotalCost();
        }
        return '${usages.length}|$latest|$cost|${pendingDeleted().length}|'
            '${production.signature()}';
      },
      listen: (context) {
        production.listen(context);
        returnMaterialsUsageProvider(context: context);
      },
      money: production.money,
      openProduction:
          (context, uuid) => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProductionDetailsPage(
                    productionRecordUuid: uuid,
                  ),
            ),
          ),
      openUsage: (context, usage) {
        final theme = returnTheme(context);
        // The same dialog as the usage records page.
        return showDialog<void>(
          context: context,
          builder: (dialogContext) {
            return DialogTemplate(
              theme: theme,
              message: 'View usage record details',
              title: 'Usage Details',
              action: () {},
              showBottomActionButtons: false,
              topRightWidget: IconButton(
                mouseCursor: SystemMouseCursors.click,
                padding: EdgeInsets.zero,
                onPressed:
                    () => Navigator.of(dialogContext).pop(),
                icon: const Icon(size: 26, Icons.clear),
              ),
              widget: SizedBox(
                height: screenHeight(context) - 270,
                child: MaterialUsageDetailsWidget(
                  materialsUsage: usage,
                  fromDetails: false,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Col {
  final String label;
  final double width;
  final UsageRecordsSortField? sort;
  final TextAlign align;
  final Widget Function(UsageRecordRow row) cell;

  /// Cell of the totals row; empty when null.
  final Widget Function(UsageRecordsPage res)? total;

  const _Col({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.align = TextAlign.center,
    this.total,
  });
}

class _GCol {
  final String label;
  final double width;
  final UsageGroupSortField? sort;
  final TextAlign align;
  final Widget Function(UsageGroupRow row) cell;
  final Widget Function(UsageGroupPage res)? total;

  const _GCol({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.align = TextAlign.center,
    this.total,
  });
}

/// Shared body of the Usage Records table page (desktop +
/// mobile).
///
/// [initialFilters] and [initialPeriod] let another page (the
/// usage summary) open the table on a given set.
class UsageRecordsTableView extends StatefulWidget {
  final bool isDesktop;
  final UsageRecordsFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [UsageRecordsEnv.live] is used.
  final UsageRecordsEnv? env;

  const UsageRecordsTableView({
    super.key,
    required this.isDesktop,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  State<UsageRecordsTableView> createState() =>
      _UsageRecordsTableViewState();
}

class _UsageRecordsTableViewState
    extends State<UsageRecordsTableView> {
  late final UsageRecordsEnv _env;
  late final UsageRecordsTableState _state;
  final _searchCtrl = TextEditingController();
  final _qtyMinCtrl = TextEditingController();
  final _qtyMaxCtrl = TextEditingController();
  final _costMinCtrl = TextEditingController();
  final _costMaxCtrl = TextEditingController();
  final _hScroll = ScrollController();
  final _vScroll = ScrollController();

  bool _showFilters = false;
  bool _toolbarIsOpen = false;

  late ReceiptsReportPeriod _period;

  bool _loading = true;
  String? _error;

  List<UsageRecordRow> _baseRows = [];
  UsageRecordsPage? _result;
  UsageGroupPage? _groupResult;
  String _signature = '';

  // Every filtered, sorted row and group, for the export; the loaded
  // production rows, for the output names and the notes.
  List<UsageRecordRow> _sortedRows = [];
  List<UsageGroupRow> _sortedGroups = [];
  List<ProductionRecordRow> _recordRows = [];

  UsageRecordsFilterChoices _choices =
      UsageRecordsFilterChoices.empty;

  UsageRecordsFilters get _filters => _state.filters;
  bool get _grouped => _state.grouped;

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? UsageRecordsEnv.live();
    _state = UsageRecordsTableState(
      filters: widget.initialFilters?.copy(),
    );
    _searchCtrl.text = _filters.search;
    _qtyMinCtrl.text = _numText(_filters.quantityMin);
    _qtyMaxCtrl.text = _numText(_filters.quantityMax);
    _costMinCtrl.text = _numText(_filters.costMin);
    _costMaxCtrl.text = _numText(_filters.costMax);
    _period =
        widget.initialPeriod ??
        ReceiptsReportPeriod.today();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: true);
    });
  }

  @override
  void dispose() {
    for (final c in [
      _searchCtrl,
      _qtyMinCtrl,
      _qtyMaxCtrl,
      _costMinCtrl,
      _costMaxCtrl,
    ]) {
      c.dispose();
    }
    _hScroll.dispose();
    _vScroll.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // data
  // ---------------------------------------------------------------

  bool get _departmentsEnabled => _env.departmentsEnabled();
  bool get _canSeeCost => _env.canSeeCost();
  bool get _canSeeQuantity => _env.canSeeQuantity();

  Future<void> _load({
    required bool refreshFromStore,
  }) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _env.loadWithPeriod(
        context,
        refreshFromStore: refreshFromStore,
        period: _period,
      );
      _rebuildBase();
      _recompute();
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _rebuildBase() {
    _recordRows = ProductionRecordRowBuilder.buildAll(
      records: _env.records(),
      manageProductionItems: _env.manageProductionItems(),
      pendingDeletedUuids: _env.pendingDeletedRecordUuids(),
    );
    _baseRows = UsageRecordRowBuilder.buildAll(
      usages: _env.usages(),
      recordRows: _recordRows,
      pendingDeletedUuids: _env.pendingDeletedUuids(),
    );
    _choices = UsageRecordsFilterChoices.fromRows(
      _baseRows,
    );
    _signature = _env.signature();
  }

  void _recompute() {
    final sorted = UsageRecordsQuery.filterAndSort(
      rows: _baseRows,
      period: _period,
      filters: _filters,
      sortField: _state.sortField,
      ascending: _state.ascending,
      departmentsEnabled: _departmentsEnabled,
      canSeeCost: _canSeeCost,
      canSeeQuantity: _canSeeQuantity,
    );
    _sortedRows = sorted;
    if (_grouped) {
      final groups = UsageGrouping.sort(
        UsageGrouping.build(sorted, _state.groupBy),
        field: _state.groupSortField,
        ascending: _state.groupAscending,
      );
      _sortedGroups = groups;
      final page = UsageGrouping.paginate(
        groups,
        _state.page,
      );
      _state.page = page.page;
      _groupResult = page;
    } else {
      final page = UsageRecordsQuery.paginate(
        sorted,
        _state.page,
        singleMaterialKey: _filters.singleMaterialKey,
      );
      _state.page = page.page;
      _result = page;
    }
  }

  void _apply(
    VoidCallback change, {
    bool resetPage = true,
  }) {
    setState(() {
      change();
      if (resetPage) _state.page = 1;
      try {
        _recompute();
        _error = null;
      } catch (e) {
        _error = e.toString();
      }
    });
  }

  void _goToPage(int p) {
    final totalPages =
        _grouped
            ? _groupResult?.totalPages
            : _result?.totalPages;
    final current =
        _grouped ? _groupResult?.page : _result?.page;
    if (totalPages == null ||
        p < 1 ||
        p > totalPages ||
        p == current) {
      return;
    }
    _apply(() => _state.page = p, resetPage: false);
    if (_vScroll.hasClients) _vScroll.jumpTo(0);
  }

  void _setSort(UsageRecordsSortField f) {
    _apply(() {
      if (_state.sortField == f) {
        _state.ascending = !_state.ascending;
      } else {
        _state.sortField = f;
        // Names A-Z first; dates, amounts and quantities largest first.
        _state.ascending =
            f == UsageRecordsSortField.material ||
            f == UsageRecordsSortField.source ||
            f == UsageRecordsSortField.staff;
      }
    });
  }

  void _setGroupSort(UsageGroupSortField f) {
    _apply(() {
      if (_state.groupSortField == f) {
        _state.groupAscending = !_state.groupAscending;
      } else {
        _state.groupSortField = f;
        _state.groupAscending =
            f == UsageGroupSortField.name;
      }
    });
  }

  /// Clears the filters only: the period and Group by stay.
  void _resetAll() {
    for (final c in [
      _searchCtrl,
      _qtyMinCtrl,
      _qtyMaxCtrl,
      _costMinCtrl,
      _costMaxCtrl,
    ]) {
      c.clear();
    }
    _apply(_state.resetAll);
  }

  /// A production usage whose production is loaded opens the
  /// production; any other usage opens its details dialog.
  Future<void> _openRow(UsageRecordRow row) async {
    final productionUuid = row.productionRecordUuid;
    if (row.source == UsageSource.production &&
        productionUuid != null &&
        row.productionOutputName != null) {
      await _env.openProduction(context, productionUuid);
    } else {
      await _env.openUsage(context, row.usage);
    }
    // Picks up an edit or delete made on the page or dialog.
    if (mounted) {
      setState(() {
        try {
          _rebuildBase();
          _recompute();
        } catch (e) {
          _error = e.toString();
        }
      });
    }
  }

  void _setPeriod(ReceiptsReportPeriod p) {
    _apply(() => _period = p);
    if (!p.isAllTime) {
      _load(refreshFromStore: false);
    }
  }

  /// Clears a range's fields once its filter was removed (chip).
  void _applyAndSyncFields(VoidCallback change) {
    _apply(change);
    if (_filters.quantityMin == null &&
        _filters.quantityMax == null) {
      _qtyMinCtrl.clear();
      _qtyMaxCtrl.clear();
    }
    if (_filters.costMin == null &&
        _filters.costMax == null) {
      _costMinCtrl.clear();
      _costMaxCtrl.clear();
    }
    if (_filters.search.isEmpty) _searchCtrl.clear();
  }

  // ---------------------------------------------------------------
  // formatting
  // ---------------------------------------------------------------

  String _money(num v) => _env.money(context, v);
  String _number(num v) =>
      formatLargeNumberDouble(v.toDouble());

  ReportExportSpec _exportSpec() {
    return usageRecordsExportSpec(
      rows: _sortedRows,
      groups: _sortedGroups,
      allUsages: _baseRows,
      recordRows: _recordRows,
      state: _state,
      choices: _choices,
      period: _period,
      currency: currencySymbol(context: context),
      departmentsEnabled: _departmentsEnabled,
      canSeeCost: _canSeeCost,
      canSeeQuantity: _canSeeQuantity,
    );
  }

  static String _numText(double? v) {
    if (v == null) return '';
    return v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toString();
  }

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    // Listen, so new, edited and synced records update the table.
    _env.listen(context);

    if (!_loading && _error == null) {
      final sig = _env.signature();
      if (sig != _signature) {
        try {
          _rebuildBase();
          _recompute();
        } catch (e) {
          _error = e.toString();
        }
      }
    }

    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Usage Records',
        widget: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              borderRadius: BorderRadius.circular(10),
              onTap:
                  _loading
                      ? null
                      : () => _load(refreshFromStore: true),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    Text(
                      'Refresh',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(
                      Icons.refresh_rounded,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isDesktop ? 20 : 12,
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _toolbar(theme),
            if (_showFilters)
              productionFilterPanelBox(
                context,
                isDesktop: widget.isDesktop,
                child: _filterPanel(theme),
              ),
            UsageRecordsFilterChips(
              theme: theme,
              filters: _filters,
              choices: _choices,
              departmentsEnabled: _departmentsEnabled,
              canSeeCost: _canSeeCost,
              canSeeQuantity: _canSeeQuantity,
              money: _money,
              number: _number,
              onApply: _applyAndSyncFields,
            ),
            _notes(),
            Expanded(child: _content(theme)),
            if (!_loading &&
                _error == null &&
                _grouped &&
                _groupResult != null)
              ReportPager(
                theme: theme,
                page: _groupResult!.page,
                totalPages: _groupResult!.totalPages,
                totalCount: _groupResult!.totalCount,
                firstIndex: _groupResult!.firstIndex,
                lastIndex: _groupResult!.lastIndex,
                itemLabel: _state.groupBy.pagerLabel,
                onPage: _goToPage,
              ),
            if (!_loading &&
                _error == null &&
                !_grouped &&
                _result != null)
              ReportPager(
                theme: theme,
                page: _result!.page,
                totalPages: _result!.totalPages,
                totalCount: _result!.totalCount,
                firstIndex: _result!.firstIndex,
                lastIndex: _result!.lastIndex,
                itemLabel: 'records',
                onPage: _goToPage,
              ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _content(ThemeProvider theme) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_error != null) {
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
              'The report could not be generated.',
              style: TextStyle(
                fontSize: theme.mobileTexts.b2.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            OutlinedButton.icon(
              onPressed:
                  () => _load(refreshFromStore: false),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    final res = _result;
    final groups = _groupResult;
    final count =
        _grouped ? groups?.totalCount : res?.totalCount;
    if (count == null || count == 0) {
      final hasFilters = _filters.hasAnything;
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: EmptyWidgetDisplayOnly(
          title:
              hasFilters
                  ? 'No Matching Records'
                  : 'Empty List',
          subText:
              hasFilters
                  ? 'No usage record matches your search and filters'
                  : 'No material usage was recorded in this period',
          theme: theme,
          height: 35,
          icon: Icons.clear,
          altAction: hasFilters ? _resetAll : null,
          altActionText:
              hasFilters ? 'Clear all filters' : null,
          altIcon: hasFilters ? Icons.filter_alt_off : null,
        ),
      );
    }
    if (_grouped) return _groupTable(theme, groups!);
    return _table(theme, res!);
  }

  // ---------------------------------------------------------------
  // toolbar / filters
  // ---------------------------------------------------------------

  Widget _toolbar(ThemeProvider theme) {
    final active = _filters.activeCount;
    final accent = theme.lightModeColor.prColor300;
    return Wrap(
      spacing: 2,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 6.0),
          child: SizedBox(
            width: widget.isDesktop ? 320 : double.infinity,
            height: 38,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged:
                        (v) => _apply(
                          () => _filters.search = v,
                        ),
                    decoration: InputDecoration(
                      hintText:
                          'Search material, staff, production or ID',
                      hintStyle: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                      ),
                      suffixIcon:
                          _searchCtrl.text.isEmpty
                              ? null
                              : IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _apply(
                                    () =>
                                        _filters.search =
                                            '',
                                  );
                                },
                              ),
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                if (screenWidth(context) <
                    mobileScreen) ...[
                  const SizedBox(width: 5),
                  InkWell(
                    onTap:
                        () => setState(
                          () =>
                              _toolbarIsOpen =
                                  !_toolbarIsOpen,
                        ),
                    mouseCursor: SystemMouseCursors.click,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        10.0,
                        6,
                        6,
                        6,
                      ),
                      child: Row(
                        spacing: 1,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                            ),
                            _toolbarIsOpen
                                ? 'Hide'
                                : 'View',
                          ),
                          Icon(
                            _toolbarIsOpen
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_toolbarIsOpen ||
            screenWidth(context) > mobileScreen) ...[
          ReceiptsReportPeriodButton(
            theme: theme,
            period: _period,
            enabled: _env.canPickDate(),
            onChanged: _setPeriod,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 6.0,
              right: 5,
            ),
            child: ReportPill(
              theme: theme,
              icon: Icons.tune_rounded,
              label:
                  active == 0
                      ? 'Filters'
                      : 'Filters ($active)',
              highlighted: _showFilters || active > 0,
              onTap:
                  () => setState(
                    () => _showFilters = !_showFilters,
                  ),
            ),
          ),
          // A view option, not a filter: Reset All keeps it.
          UsageGroupByButton(
            theme: theme,
            value: _state.groupBy,
            departmentsEnabled: _departmentsEnabled,
            onChanged:
                (g) => _apply(() => _state.groupBy = g),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 5,
              right: 5,
            ),
            child: ReportExportButton(
              buildSpec: _exportSpec,
            ),
          ),
          if (_filters.hasAnything)
            ReportPill(
              theme: theme,
              icon: Icons.filter_alt_off,
              label: 'Reset All Filters',
              onTap: _resetAll,
              color: accent,
            ),
        ],
      ],
    );
  }

  Widget _filterPanel(ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 5,
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 12,
        children: [
          ...usageKeyFilterFields(
            theme: theme,
            filters: _filters,
            choices: _choices,
            departmentsEnabled: _departmentsEnabled,
            onApply: _apply,
          ),
          if (_canSeeQuantity)
            ReportRangeFields(
              label: 'Quantity range (primary unit)',
              minController: _qtyMinCtrl,
              maxController: _qtyMaxCtrl,
              errorText: _filters.quantityRangeError,
              onChange:
                  (a, b) => _apply(() {
                    _filters.quantityMin = a;
                    _filters.quantityMax = b;
                  }),
            ),
          if (_canSeeCost)
            ReportRangeFields(
              label: 'Cost range',
              minController: _costMinCtrl,
              maxController: _costMaxCtrl,
              errorText: _filters.costRangeError,
              onChange:
                  (a, b) => _apply(() {
                    _filters.costMin = a;
                    _filters.costMax = b;
                  }),
            ),
        ],
      ),
    );
  }

  Widget _notes() {
    final notes = usageRecordsNotes(
      period: _period,
      usages: _baseRows,
      recordRows: _recordRows,
    );
    if (notes.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 13,
              color: Colors.grey.shade600,
            ),
            Flexible(
              child: Text(
                notes.join('\n'),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // table
  // ---------------------------------------------------------------

  TextStyle _cellStyle(
    ThemeProvider theme, {
    bool bold = false,
    Color? color,
  }) => TextStyle(
    fontSize: theme.mobileTexts.b3.fontSize,
    fontWeight: bold ? FontWeight.bold : FontWeight.w500,
    color: color ?? Colors.black87,
  );

  Widget _txt(
    ThemeProvider theme,
    String text, {
    bool bold = false,
    Color? color,
    TextAlign? align,
    String? tooltip,
  }) {
    final t = Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: align,
      style: _cellStyle(theme, bold: bold, color: color),
    );
    return tooltip == null
        ? t
        : Tooltip(message: tooltip, child: t);
  }

  Widget _dash(ThemeProvider theme) =>
      _txt(theme, '—', color: Colors.grey);

  List<_Col> _columns(ThemeProvider theme) {
    Widget bold(String text) =>
        _txt(theme, text, bold: true);
    final single = _filters.singleMaterialKey != null;

    return [
      _Col(
        label: 'ID',
        width: 170,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.displayId,
              bold: true,
              align: TextAlign.start,
            ),
        total:
            (_) => _txt(
              theme,
              'TOTAL',
              bold: true,
              align: TextAlign.start,
            ),
      ),
      _Col(
        label: 'Date',
        width: 120,
        sort: UsageRecordsSortField.createdAt,
        cell:
            (r) => _txt(theme, formatDateTime(r.createdAt)),
      ),
      _Col(
        label: 'Time',
        width: 100,
        sort: UsageRecordsSortField.createdAt,
        cell: (r) => _txt(theme, formatTime(r.createdAt)),
      ),
      _Col(
        label: 'Material',
        width: 190,
        sort: UsageRecordsSortField.material,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.materialName,
              bold: true,
              align: TextAlign.start,
            ),
      ),
      if (_canSeeQuantity)
        _Col(
          label: 'Quantity',
          width: 170,
          sort: UsageRecordsSortField.quantity,
          cell:
              (r) => _txt(
                theme,
                usageRecordQuantityText(r, _number),
              ),
          total:
              (t) =>
                  t.totalQuantity == null
                      ? const SizedBox.shrink()
                      : bold(
                        '${_number(t.totalQuantity!)} ${t.quantityUnit ?? ''}'
                            .trim(),
                      ),
        ),
      if (_canSeeCost) ...[
        // Cost ÷ unit cost gives the quantity, so it needs both.
        if (_canSeeQuantity)
          _Col(
            label: 'Unit Cost',
            width: 140,
            sort: UsageRecordsSortField.unitCost,
            cell:
                (r) =>
                    r.unitCost == null
                        ? _dash(theme)
                        : _txt(
                          theme,
                          _money(r.unitCost!),
                          tooltip: 'Per ${r.primaryUnit}',
                        ),
            total:
                (t) =>
                    !single || t.averageUnitCost == null
                        ? const SizedBox.shrink()
                        : bold(_money(t.averageUnitCost!)),
          ),
        _Col(
          label: 'Cost',
          width: 150,
          sort: UsageRecordsSortField.cost,
          cell: (r) => bold(_money(r.cost)),
          total: (t) => bold(_money(t.totalCost)),
        ),
      ],
      _Col(
        label: 'Source',
        width: 120,
        sort: UsageRecordsSortField.source,
        cell: (r) => _txt(theme, r.source.label),
      ),
      _Col(
        label: 'Production',
        width: 230,
        align: TextAlign.start,
        cell:
            (r) =>
                r.productionLabel == null
                    ? _dash(theme)
                    : _txt(
                      theme,
                      r.productionLabel!,
                      align: TextAlign.start,
                      color:
                          r.productionOutputName == null
                              ? Colors.grey
                              : null,
                    ),
      ),
      if (_departmentsEnabled)
        _Col(
          label: 'Department',
          width: 160,
          align: TextAlign.start,
          cell:
              (r) => _txt(
                theme,
                r.departmentLabel,
                align: TextAlign.start,
                color:
                    r.departmentKey == null
                        ? Colors.grey
                        : null,
              ),
        ),
      _Col(
        label: 'Staff',
        width: 160,
        sort: UsageRecordsSortField.staff,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.staffLabel,
              align: TextAlign.start,
              color:
                  r.staffName == null ? Colors.grey : null,
            ),
      ),
      _Col(
        label: 'Managed',
        width: 100,
        cell:
            (r) => _txt(
              theme,
              r.managedLabel,
              color: r.managed ? null : Colors.grey,
            ),
      ),
    ];
  }

  Alignment _alignment(TextAlign a) =>
      a == TextAlign.start
          ? Alignment.centerLeft
          : (a == TextAlign.end
              ? Alignment.centerRight
              : Alignment.center);

  Widget _header(
    ThemeProvider theme, {
    required String label,
    required double width,
    required TextAlign align,
    required bool sortable,
    required bool isSorted,
    required bool ascending,
    required VoidCallback onTap,
  }) {
    final accent = theme.lightModeColor.prColor300;
    final content = Row(
      mainAxisAlignment:
          align == TextAlign.start
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: align,
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.bold,
              color: isSorted ? accent : Colors.black87,
            ),
          ),
        ),
        if (sortable)
          Icon(
            isSorted
                ? (ascending
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded)
                : Icons.unfold_more_rounded,
            size: 14,
            color: isSorted ? accent : Colors.grey,
          ),
      ],
    );
    final padded = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(
        alignment: _alignment(align),
        child: content,
      ),
    );
    return SizedBox(
      width: width,
      child:
          !sortable
              ? padded
              : InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: onTap,
                child: padded,
              ),
    );
  }

  Widget _cells<T>(
    List<T> cols,
    double Function(T c) width,
    TextAlign Function(T c) align,
    Widget Function(T c) cell,
  ) {
    return Row(
      children: [
        for (final c in cols)
          SizedBox(
            width: width(c),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Align(
                alignment: _alignment(align(c)),
                child: cell(c),
              ),
            ),
          ),
      ],
    );
  }

  Widget _row(
    ThemeProvider theme,
    List<_Col> cols,
    UsageRecordRow r,
    int i,
  ) {
    return Material(
      color: i.isEven ? Colors.white : Colors.grey.shade50,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        hoverColor: theme.lightModeColor.prColor300
            .withAlpha(20),
        onTap: () => _openRow(r),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade100,
              ),
            ),
          ),
          child: _cells<_Col>(
            cols,
            (c) => c.width,
            (c) => c.align,
            (c) => c.cell(r),
          ),
        ),
      ),
    );
  }

  /// Totals of the whole filtered set, not just this page.
  Widget _totalsRow(ThemeProvider theme, Widget content) {
    return Container(
      height: 46,
      color: theme.lightModeColor.prColor300.withAlpha(25),
      child: content,
    );
  }

  Widget _frame(
    ThemeProvider theme, {
    required double totalWidth,
    required Widget header,
    required int itemCount,
    required Widget Function(int i) item,
    required Widget totals,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w =
                totalWidth > constraints.maxWidth
                    ? totalWidth
                    : constraints.maxWidth;
            return Scrollbar(
              controller: _vScroll,
              thumbVisibility: true,
              notificationPredicate:
                  (n) => n.metrics.axis == Axis.vertical,
              child: Scrollbar(
                controller: _hScroll,
                thumbVisibility: true,
                notificationPredicate:
                    (n) =>
                        n.metrics.axis == Axis.horizontal,
                child: SingleChildScrollView(
                  controller: _hScroll,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: w,
                    height: constraints.maxHeight,
                    child: Column(
                      children: [
                        Container(
                          height: 48,
                          color: theme
                              .lightModeColor
                              .prColor300
                              .withAlpha(22),
                          child: header,
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ScrollConfiguration(
                            behavior:
                                ScrollConfiguration.of(
                                  context,
                                ).copyWith(
                                  scrollbars: false,
                                ),
                            child: ListView.builder(
                              controller: _vScroll,
                              itemCount: itemCount,
                              itemExtent: 52,
                              itemBuilder:
                                  (context, i) => item(i),
                            ),
                          ),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                        ),
                        totals,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _table(ThemeProvider theme, UsageRecordsPage res) {
    final cols = _columns(theme);
    return _frame(
      theme,
      totalWidth: cols.fold<double>(
        0,
        (s, c) => s + c.width,
      ),
      header: Row(
        children: [
          for (final c in cols)
            _header(
              theme,
              label: c.label,
              width: c.width,
              align: c.align,
              sortable: c.sort != null,
              isSorted:
                  c.sort != null &&
                  c.sort == _state.sortField,
              ascending: _state.ascending,
              onTap: () => _setSort(c.sort!),
            ),
        ],
      ),
      itemCount: res.rows.length,
      item: (i) => _row(theme, cols, res.rows[i], i),
      totals: _totalsRow(
        theme,
        _cells<_Col>(
          cols,
          (c) => c.width,
          (c) => c.align,
          (c) =>
              c.total?.call(res) ?? const SizedBox.shrink(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // grouped
  // ---------------------------------------------------------------

  List<_GCol> _groupColumns(ThemeProvider theme) {
    Widget bold(String text) =>
        _txt(theme, text, bold: true);
    final by = _state.groupBy;
    final byMaterial = by == UsageGroupBy.material;
    final showQty = _canSeeQuantity && byMaterial;

    return [
      _GCol(
        label: by.label,
        width: 220,
        sort: UsageGroupSortField.name,
        align: TextAlign.start,
        cell:
            (g) => _txt(
              theme,
              g.label,
              bold: true,
              align: TextAlign.start,
              color:
                  g.isNone || g.name == null
                      ? Colors.grey
                      : null,
            ),
        total:
            (_) => _txt(
              theme,
              'TOTAL',
              bold: true,
              align: TextAlign.start,
            ),
      ),
      _GCol(
        label: 'Records',
        width: 100,
        sort: UsageGroupSortField.count,
        cell: (g) => _txt(theme, '${g.count}'),
        total: (t) => bold('${t.totalRecords}'),
      ),
      if (showQty)
        _GCol(
          label: 'Qty Used',
          width: 150,
          sort: UsageGroupSortField.quantity,
          cell:
              (g) =>
                  g.quantity == null
                      ? _dash(theme)
                      : _txt(
                        theme,
                        '${_number(g.quantity!)} ${g.unit ?? ''}'
                            .trim(),
                      ),
        ),
      if (_canSeeCost)
        _GCol(
          label: 'Cost',
          width: 150,
          sort: UsageGroupSortField.cost,
          cell: (g) => bold(_money(g.cost)),
          total: (t) => bold(_money(t.totalCost)),
        ),
      if (_canSeeCost && showQty)
        _GCol(
          label: 'Avg Unit Cost',
          width: 150,
          sort: UsageGroupSortField.unitCost,
          cell:
              (g) =>
                  g.unitCost == null
                      ? _dash(theme)
                      : _txt(theme, _money(g.unitCost!)),
        ),
      _GCol(
        label: 'Last Used',
        width: 130,
        sort: UsageGroupSortField.lastDate,
        cell:
            (g) =>
                g.lastDate == null
                    ? _dash(theme)
                    : _txt(
                      theme,
                      formatDateTime(g.lastDate!),
                    ),
      ),
    ];
  }

  /// No row tap: a group has no single record to open.
  Widget _groupRow(
    List<_GCol> cols,
    UsageGroupRow g,
    int i,
  ) {
    return Container(
      decoration: BoxDecoration(
        color:
            i.isEven ? Colors.white : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: _cells<_GCol>(
        cols,
        (c) => c.width,
        (c) => c.align,
        (c) => c.cell(g),
      ),
    );
  }

  Widget _groupTable(
    ThemeProvider theme,
    UsageGroupPage res,
  ) {
    final cols = _groupColumns(theme);
    return _frame(
      theme,
      totalWidth: cols.fold<double>(
        0,
        (s, c) => s + c.width,
      ),
      header: Row(
        children: [
          for (final c in cols)
            _header(
              theme,
              label: c.label,
              width: c.width,
              align: c.align,
              sortable: c.sort != null,
              isSorted:
                  c.sort != null &&
                  c.sort == _state.groupSortField,
              ascending: _state.groupAscending,
              onTap: () => _setGroupSort(c.sort!),
            ),
        ],
      ),
      itemCount: res.rows.length,
      item: (i) => _groupRow(cols, res.rows[i], i),
      totals: _totalsRow(
        theme,
        _cells<_GCol>(
          cols,
          (c) => c.width,
          (c) => c.align,
          (c) =>
              c.total?.call(res) ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
