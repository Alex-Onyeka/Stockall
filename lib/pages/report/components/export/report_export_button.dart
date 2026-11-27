// The one Export pill each report puts on its toolbar. Its menu is built
// when it opens, from a spec of what the screen shows right then:
//
//   Print 80mm  [▸ As shown / By <split> / All groupings]
//   Print 58mm  [▸ same]
//   Download PDF
//   Export Excel [▸ All in one sheet / One sheet per <split>]
//
// Printing is guarded by the spec's `gate`; PDF and Excel by
// `downloadGate` when it is set. Roll prints ask for confirmation with
// the record count. Work runs under a loading overlay, failures show a
// snackbar, and desktop/web saves confirm the file name.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/printer_settings_dialog.dart';
import 'package:stockall/main.dart'
    show returnShopProvider, returnTheme;
import 'package:stockall/pages/report/components/export/report_export_actions.dart';
import 'package:stockall/pages/report/components/export/report_export_backend.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/pos_printing/pos_print_rules.dart';
import 'package:stockall/services/printing/app_printer_service.dart';

/// Above this many records a roll print warns about paper use.
const int reportExportLongRollRows = 500;

const String reportExportNotOnPlan =
    'Not available on your plan';

/// Added to the print entry whose width matches the saved printer.
const String reportExportYourPrinter = ' · your printer';

class ReportExportButton extends StatefulWidget {
  /// Called when the menu opens, so the export matches the screen.
  final ReportExportSpec Function() buildSpec;
  final ReportExportBackend backend;
  final String label;

  /// True shows a print icon with [label] as its tooltip instead of the
  /// pill, for tight headers. The menu is the same.
  final bool iconOnly;

  /// Whether to show the explicit "Print 80mm" and "Print 58mm" entries.
  final bool showRollWidthEntries;

  const ReportExportButton({
    super.key,
    required this.buildSpec,
    this.backend = const DefaultReportExportBackend(),
    this.label = 'Export',
    this.iconOnly = false,
    this.showRollWidthEntries = true,
  });

  @override
  State<ReportExportButton> createState() =>
      _ReportExportButtonState();
}

class _ReportExportButtonState
    extends State<ReportExportButton> {
  final MenuController _menu = MenuController();
  ReportExportSpec? _spec;
  bool _printAllowed = false;
  bool _downloadAllowed = false;
  RollPaper? _savedPaper;

  ReportExportBackend get _backend => widget.backend;

  String _paperLabel(RollPaper p) =>
      p == RollPaper.mm58 ? '58mm' : '80mm';

  void _open() {
    if (_menu.isOpen) {
      _menu.close();
      return;
    }
    final spec = widget.buildSpec();
    setState(() {
      _spec = spec;
      _printAllowed = _backend.isAllowed(
        context,
        spec.gate,
      );
      _downloadAllowed =
          spec.downloadGate == null ||
          _backend.isAllowed(context, spec.downloadGate!);
      _savedPaper = _backend.savedPaper();
    });
    _menu.open();
  }

  // ------------------------------------------------------------------
  // Menu
  // ------------------------------------------------------------------

  Widget _title(String text, {bool disabled = false}) {
    if (!disabled) {
      return Text(
        style: TextStyle(
          fontSize:
              returnTheme(
                context,
                listen: false,
              ).mobileTexts.b3.fontSize,
        ),
        text,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          style: TextStyle(
            fontSize:
                returnTheme(
                  context,
                  listen: false,
                ).mobileTexts.b3.fontSize,
          ),
          text,
        ),
        Text(
          reportExportNotOnPlan,
          style: TextStyle(
            fontSize:
                returnTheme(
                  context,
                  listen: false,
                ).mobileTexts.b4.fontSize,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _printEntry(
    ReportExportSpec spec,
    RollPaper paper,
  ) {
    final title =
        'Print ${_paperLabel(paper)}'
        '${paper == _savedPaper ? reportExportYourPrinter : ''}';
    const icon = Icon(Icons.print_outlined, size: 16);
    final splits = spec.splitOptions;

    if (!_printAllowed || splits.isEmpty) {
      return MenuItemButton(
        leadingIcon: icon,
        onPressed:
            _printAllowed
                ? () => _print(paper, const [null])
                : null,
        child: _title(title, disabled: !_printAllowed),
      );
    }
    return SubmenuButton(
      leadingIcon: icon,
      menuChildren: [
        MenuItemButton(
          onPressed: () => _print(paper, const [null]),
          child: _title('As shown'),
        ),
        for (final s in splits)
          MenuItemButton(
            onPressed: () => _print(paper, [s.id]),
            child: _title('By ${s.label}'),
          ),
        if (splits.length > 1)
          MenuItemButton(
            onPressed:
                () => _print(paper, [
                  null,
                  for (final s in splits) s.id,
                ]),
            child: _title('All groupings'),
          ),
      ],
      child: _title(title),
    );
  }

  Widget _excelEntry(ReportExportSpec spec) {
    const title = 'Export Excel';
    const icon = Icon(Icons.table_chart_outlined, size: 16);
    final splits = spec.splitOptions;

    if (!_downloadAllowed || splits.isEmpty) {
      return MenuItemButton(
        leadingIcon: icon,
        onPressed:
            _downloadAllowed ? () => _excel(null) : null,
        child: _title(title, disabled: !_downloadAllowed),
      );
    }
    return SubmenuButton(
      leadingIcon: icon,
      menuChildren: [
        MenuItemButton(
          onPressed: () => _excel(null),
          child: _title('All in one sheet'),
        ),
        for (final s in splits)
          MenuItemButton(
            onPressed: () => _excel(s.id),
            child: _title('One sheet per ${s.label}'),
          ),
      ],
      child: _title(title),
    );
  }

  List<Widget> _menuChildren() {
    final spec = _spec;
    if (spec == null) return const [];
    return [
      MenuItemButton(
        leadingIcon: const Icon(Icons.print, size: 16),
        onPressed:
            _printAllowed ? _printWithSettings : null,
        child: _title(
          'Print',
          disabled:
              !widget.showRollWidthEntries &&
              !_printAllowed,
        ),
      ),
      MenuItemButton(
        leadingIcon: const Icon(
          Icons.settings_outlined,
          size: 16,
        ),
        onPressed: () {
          _menu.close();
          showPrinterSettingsDialog(context);
        },
        child: _title('Printer Settings'),
      ),
      if (widget.showRollWidthEntries) ...[
        _printEntry(spec, RollPaper.mm80),
        _printEntry(spec, RollPaper.mm58),
      ],
      MenuItemButton(
        leadingIcon: const Icon(
          Icons.picture_as_pdf_outlined,
          size: 16,
        ),
        onPressed: _downloadAllowed ? _pdf : null,
        child: _title(
          'Download PDF',
          disabled: !_downloadAllowed,
        ),
      ),
      _excelEntry(spec),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    return MenuAnchor(
      controller: _menu,
      menuChildren: _menuChildren(),
      builder:
          (context, controller, child) =>
              widget.iconOnly
                  ? Tooltip(
                    message: widget.label,
                    child: IconButton(
                      icon: const Icon(
                        Icons.print_outlined,
                      ),
                      onPressed: _open,
                    ),
                  )
                  : ReportPill(
                    theme: theme,
                    icon: Icons.ios_share_rounded,
                    label: widget.label,
                    onTap: _open,
                  ),
    );
  }

  // ------------------------------------------------------------------
  // Actions
  // ------------------------------------------------------------------

  ThemeProvider get _theme =>
      returnTheme(context, listen: false);

  String _records(int n) {
    final count = ExportFormatter(currency: '').integer(n);
    return n == 1 ? '$count record' : '$count records';
  }

  Future<void> _printWithSettings() async {
    _menu.close();
    final spec = _spec;
    if (spec == null) return;
    final settings = await AppPrinterService.loadSettings();
    if (!mounted) return;
    if (!kIsWeb &&
        !settings.hasPrinter &&
        returnShopProvider().userShop()?.printType ==
            null) {
      final saved = await showPrinterSettingsDialog(
        context,
      );
      if (saved == null || !mounted) return;
    }
    final activeSettings =
        await AppPrinterService.loadSettings();
    if (!mounted) return;
    final count = spec.recordCount;
    final recordsText =
        count > 0 ? _records(count) : 'this record';

    if (activeSettings.documentType ==
        AppPrintDocumentType.a4) {
      showDialog<void>(
        context: context,
        builder:
            (dialog) => ConfirmationAlert(
              theme: _theme,
              title: 'Print Report',
              actionButtonText: 'Print',
              message:
                  'You are about to print $recordsText as an A4 document. '
                  'Are you sure you want to proceed?',
              action: () {
                Navigator.of(dialog).pop();
                _run(
                  action: 'print A4',
                  loading: 'Preparing print…',
                  failure:
                      "Couldn't print the report. Please try again.",
                  task: (ctx, beforeUi) async {
                    await DefaultReportExportBackend.printA4Report(
                      context,
                      spec,
                      ctx,
                      beforeUi: beforeUi,
                    );
                    return null;
                  },
                );
              },
            ),
      );
      return;
    }

    final paper =
        activeSettings.paper == PosPaper.mm80
            ? RollPaper.mm80
            : RollPaper.mm58;
    final long =
        count > reportExportLongRollRows
            ? ' This is a long print and will use a lot of paper.'
            : '';
    showDialog<void>(
      context: context,
      builder:
          (dialog) => ConfirmationAlert(
            theme: _theme,
            title: 'Print Report',
            actionButtonText: 'Print',
            message:
                'You are about to print $recordsText on '
                '${_paperLabel(paper)} roll paper.$long '
                'Are you sure you want to proceed?',
            action: () {
              Navigator.of(dialog).pop();
              _run(
                action: 'print ${_paperLabel(paper)}',
                loading: 'Preparing print…',
                failure:
                    "Couldn't print the report. Please try again.",
                task: (ctx, beforeUi) async {
                  await _backend.printRoll(
                    context,
                    spec,
                    ctx,
                    paper: paper,
                    groupings: const [null],
                    beforeUi: beforeUi,
                  );
                  return null;
                },
              );
            },
          ),
    );
  }

  void _print(RollPaper paper, List<String?> groupings) {
    _menu.close();
    final spec = _spec;
    if (spec == null) return;
    final count = spec.recordCount;

    if (count == 0) {
      showDialog<void>(
        context: context,
        builder:
            (dialog) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('No Matching Records'),
              content: const Text(
                'There are no records to print for the current period and '
                'filters.',
              ),
              actions: [
                TextButton(
                  onPressed:
                      () => Navigator.of(dialog).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    final long =
        count > reportExportLongRollRows
            ? ' This is a long print and will use a lot of paper.'
            : '';
    showDialog<void>(
      context: context,
      builder:
          (dialog) => ConfirmationAlert(
            theme: _theme,
            title: 'Print Report',
            actionButtonText: 'Print',
            message:
                'You are about to print ${_records(count)} on '
                '${_paperLabel(paper)} roll paper.$long '
                'Are you sure you want to proceed?',
            action: () {
              Navigator.of(dialog).pop();
              _run(
                action: 'print ${_paperLabel(paper)}',
                loading: 'Preparing print…',
                failure:
                    "Couldn't print the report. Please try again.",
                task: (ctx, beforeUi) async {
                  await _backend.printRoll(
                    context,
                    spec,
                    ctx,
                    paper: paper,
                    groupings: groupings,
                    beforeUi: beforeUi,
                  );
                  return null;
                },
              );
            },
          ),
    );
  }

  void _pdf() {
    _menu.close();
    final spec = _spec;
    if (spec == null) return;
    _run(
      action: 'pdf',
      loading: 'Preparing PDF…',
      failure: "Couldn't create the PDF. Please try again.",
      task:
          (ctx, beforeUi) => _backend.downloadPdf(
            context,
            spec,
            ctx,
            beforeUi: beforeUi,
          ),
    );
  }

  void _excel(String? splitId) {
    _menu.close();
    final spec = _spec;
    if (spec == null) return;

    if (splitId != null) {
      final groups = splitGroupCount(spec, splitId);
      if (groups > reportExportMaxSplitSheets) {
        final label =
            spec.splitOptions
                .firstWhere((s) => s.id == splitId)
                .label;
        showDialog<void>(
          context: context,
          builder:
              (dialog) => ConfirmationAlert(
                theme: _theme,
                title: 'Too Many Sheets',
                actionButtonText: 'Export One Sheet',
                message:
                    'One sheet per $label would create $groups sheets (the '
                    'limit is $reportExportMaxSplitSheets). Export everything '
                    'on one sheet instead?',
                action: () {
                  Navigator.of(dialog).pop();
                  _runExcel(spec, null);
                },
              ),
        );
        return;
      }
    }
    _runExcel(spec, splitId);
  }

  void _runExcel(ReportExportSpec spec, String? splitId) {
    _run(
      action: 'excel',
      loading: 'Preparing Excel file…',
      failure:
          "Couldn't create the Excel file. Please try again.",
      task:
          (ctx, beforeUi) => _backend.exportExcel(
            context,
            spec,
            ctx,
            splitId: splitId,
            beforeUi: beforeUi,
          ),
    );
  }

  /// Runs [task] under the loading overlay. The task gets a callback that
  /// closes the overlay before it shows any platform UI.
  Future<void> _run({
    required String action,
    required String loading,
    required String failure,
    required Future<ReportSaveResult?> Function(
      ExportContext ctx,
      VoidCallback beforeUi,
    )
    task,
  }) async {
    final close = _showLoading(loading);
    try {
      final result = await task(
        _backend.exportContext(),
        close,
      );
      close();
      if (result != null && result.showSaved) {
        _snack('Saved ${result.fileName}');
      }
    } catch (e, st) {
      close();
      _backend.logError(action, e, st);
      _snack(
        e is ReportExportException ? e.message : failure,
      );
    }
  }

  /// Pushes the overlay and returns a callback that removes it (safe to
  /// call more than once, and removes only the overlay's own route).
  VoidCallback _showLoading(String message) {
    final navigator = Navigator.of(
      context,
      rootNavigator: true,
    );
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => PopScope(
            canPop: false,
            child: Center(
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 14,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                        ),
                      ),
                      Text(message),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
    navigator.push(route);
    var closed = false;
    return () {
      if (closed) return;
      closed = true;
      if (route.isActive) navigator.removeRoute(route);
    };
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
