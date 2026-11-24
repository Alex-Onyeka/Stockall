// The one Export pill each report puts on its toolbar, with the Printer
// Settings button beside it. Its menu is built when it opens, from a spec
// of what the screen shows right then:
//
//   Print        [▸ As shown / By <split> / All groupings]
//   Print A4
//   Download PDF
//   Export Excel [▸ All in one sheet / One sheet per <split>]
//
// Print uses the roll width from Printer Settings.
//
// Printing is guarded by the spec's `gate`; PDF and Excel by
// `downloadGate` when it is set. Roll prints ask for confirmation with
// the record count. Work runs under a loading overlay, failures show a
// snackbar, and desktop/web saves confirm the file name.

import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/printer_settings_button.dart';
import 'package:stockall/constants/constants_main.dart' show mobileScreen;
import 'package:stockall/main.dart' show returnTheme;
import 'package:stockall/pages/report/components/export/report_export_actions.dart';
import 'package:stockall/pages/report/components/export/report_export_backend.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/pos_printing/printer_settings_panel.dart';

/// Above this many records a roll print warns about paper use.
const int reportExportLongRollRows = 500;

const String reportExportNotOnPlan =
    'Not available on your plan';

class ReportExportButton extends StatefulWidget {
  /// Called when the menu opens, so the export matches the screen.
  final ReportExportSpec Function() buildSpec;
  final ReportExportBackend backend;
  final String label;

  /// True shows a print icon with [label] as its tooltip instead of the
  /// pill, for tight headers. The menu is the same.
  final bool iconOnly;

  /// Shows the Printer Settings button next to the export button. With
  /// [iconOnly] it is the menu's last entry instead, so tight headers
  /// keep their width. Off where the screen has its own.
  final bool showPrinterSettings;

  /// True shows Printer Settings as an icon-only pill, for narrow cards.
  /// Null: icon only on phones, the labelled pill elsewhere.
  final bool? compactPrinterSettings;

  const ReportExportButton({
    super.key,
    required this.buildSpec,
    this.backend = const DefaultReportExportBackend(),
    this.label = 'Export',
    this.iconOnly = false,
    this.showPrinterSettings = true,
    this.compactPrinterSettings,
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
    const title = 'Print';
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
          child: const Text('As shown'),
        ),
        for (final s in splits)
          MenuItemButton(
            onPressed: () => _print(paper, [s.id]),
            child: Text('By ${s.label}'),
          ),
        if (splits.length > 1)
          MenuItemButton(
            onPressed:
                () => _print(paper, [
                  null,
                  for (final s in splits) s.id,
                ]),
            child: const Text('All groupings'),
          ),
      ],
      child: const Text(title),
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
          child: const Text('All in one sheet'),
        ),
        for (final s in splits)
          MenuItemButton(
            onPressed: () => _excel(s.id),
            child: Text('One sheet per ${s.label}'),
          ),
      ],
      child: const Text(title),
    );
  }

  List<Widget> _menuChildren() {
    final spec = _spec;
    if (spec == null) return const [];
    return [
      _printEntry(spec, _savedPaper ?? RollPaper.mm58),
      MenuItemButton(
        leadingIcon: const Icon(Icons.description_outlined, size: 16),
        onPressed: _printAllowed ? _printA4 : null,
        child: _title('Print A4', disabled: !_printAllowed),
      ),
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
      if (widget.showPrinterSettings && widget.iconOnly)
        MenuItemButton(
          leadingIcon: const Icon(Icons.settings_outlined, size: 16),
          onPressed: () {
            _menu.close();
            openPrinterSettings(context);
          },
          child: _title(printerSettingsLabel),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final export = _exportButton(context);
    if (!widget.showPrinterSettings || widget.iconOnly) return export;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: widget.iconOnly ? 0 : 6,
      children: [
        export,
        PrinterSettingsButton(
          // Phones: icon only, so tight toolbars and cards still fit.
          compact:
              widget.compactPrinterSettings ??
              MediaQuery.sizeOf(context).width < mobileScreen,
        ),
      ],
    );
  }

  Widget _exportButton(BuildContext context) {
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
                      icon: const Icon(Icons.print_outlined),
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

  void _printA4() {
    _menu.close();
    final spec = _spec;
    if (spec == null) return;
    _run(
      action: 'print a4',
      loading: 'Preparing print…',
      failure: "Couldn't print the report. Please try again.",
      task: (ctx, beforeUi) async {
        await _backend.printA4(context, spec, ctx, beforeUi: beforeUi);
        return null;
      },
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
