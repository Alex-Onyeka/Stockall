// What a report hands to the shared export builders: the title, the
// period and filters on screen, and one or more sections (a table or a
// block of figures). The PDF, Excel and roll builders only read this, so
// a report never builds a document itself.
//
// Pure Dart: no BuildContext and no providers, so it can be tested.

/// How a value is shown. Money uses the shop currency with two decimals
/// and is never shortened to K/M/B.
enum ExportFormat {
  text,
  integer,
  number,
  quantity,
  money,

  /// The value is already a percentage (12.5 means 12.5%).
  percent,
  date,
  time,
  dateTime,
}

enum ExportAlign { left, center, right }

extension ExportFormatInfo on ExportFormat {
  bool get isNumeric =>
      this == ExportFormat.integer ||
      this == ExportFormat.number ||
      this == ExportFormat.quantity ||
      this == ExportFormat.money ||
      this == ExportFormat.percent;

  bool get isDate =>
      this == ExportFormat.date ||
      this == ExportFormat.time ||
      this == ExportFormat.dateTime;

  ExportAlign get defaultAlign =>
      isNumeric ? ExportAlign.right : ExportAlign.left;
}

/// Which subscription check guards printing and downloading a report.
/// Every report uses [receiptPrint] for now
/// (`SalesAuthAction().printReceiptAction`). Moving a report to its own
/// `ReportAuth` flag later means changing only its spec's `gate`.
enum ReportPrintGate {
  receiptPrint,
  itemsReport,
  salesReport,
  customersReport,
  employeesReport,
  expensesReport,
  generalReport,
}

class ExportColumn<T> {
  final String id;
  final String label;
  final ExportFormat format;

  /// The typed value: num, DateTime, String or null. Excel stores this,
  /// so numbers stay numbers.
  final Object? Function(T row) value;

  /// Text shown instead of the formatted value, such as "12 Cartons" or
  /// "N/A". Excel still stores [value] when it is a number or date.
  final String Function(T row)? display;

  /// Relative width in the PDF table.
  final double width;
  final ExportAlign? align;

  /// False keeps the column out of the A4 PDF (it stays in Excel).
  final bool inPdf;

  /// False keeps the column out of Excel. With [inPdf] false too, the
  /// column is roll-only (a compact cell such as "Cola ×2").
  final bool inExcel;

  const ExportColumn({
    required this.id,
    required this.label,
    required this.value,
    this.format = ExportFormat.text,
    this.display,
    this.width = 1,
    this.align,
    this.inPdf = true,
    this.inExcel = true,
  });

  ExportAlign get effectiveAlign => align ?? format.defaultAlign;
}

/// Splits a table into Excel sheets and roll print sections. A row can
/// belong to several groups (an item in two categories). Rows with no key
/// go to [noneLabel].
class ExportSplit<T> {
  final String id;
  final String label;
  final List<String> Function(T row) keys;
  final String Function(String key) name;
  final String noneLabel;

  const ExportSplit({
    required this.id,
    required this.label,
    required this.keys,
    required this.name,
    required this.noneLabel,
  });
}

/// Compact roll columns, by column id. 58mm takes at most 2 columns and
/// 80mm at most 3. A sub-line prints small under each row.
class RollLayout {
  final List<String> cols58;
  final List<String> cols80;
  final List<String> sub58;
  final List<String> sub80;

  /// Optional column widths (flex) per paper, one per printed column.
  /// Ignored when the count doesn't match; the defaults are 3/2 on 58mm
  /// and 5/2/3 on 80mm.
  final List<int>? flex58;
  final List<int>? flex80;

  const RollLayout({
    required this.cols58,
    required this.cols80,
    this.sub58 = const [],
    this.sub80 = const [],
    this.flex58,
    this.flex80,
  });
}

class ExportFilter {
  final String label;
  final String value;

  const ExportFilter(this.label, this.value);
}

class ExportPeriod {
  /// The view's own range text, so the export reads like the screen.
  final String label;
  final DateTime? start;
  final DateTime? end;

  const ExportPeriod({required this.label, this.start, this.end});
}

class ExportMetric {
  final String label;
  final Object? value;
  final ExportFormat format;

  /// Optional comparison, such as "+12.5% vs previous period".
  final String? note;

  const ExportMetric({
    required this.label,
    required this.value,
    this.format = ExportFormat.money,
    this.note,
  });
}

/// Base type of everything a spec can hold.
abstract class ExportSection {
  String get title;
}

/// Headline figures (analysis and General pages).
class ExportSummarySection extends ExportSection {
  @override
  final String title;
  final List<ExportMetric> metrics;

  ExportSummarySection({required this.title, required this.metrics});
}

class ExportTableSection<T> extends ExportSection {
  @override
  final String title;
  final List<ExportColumn<T>> columns;

  /// Every filtered, sorted row, not just the current page.
  final List<T> rows;

  /// Totals of the whole filtered set by column id, as the screen shows
  /// them. When null, [totalsFor] over [rows] is used.
  final Map<String, Object?>? totals;

  /// Totals for a subset of rows (a split sheet or a roll section).
  final Map<String, Object?> Function(List<T> rows)? totalsFor;
  final String totalsLabel;
  final List<ExportSplit<T>> splits;
  final RollLayout roll;
  final String emptyMessage;

  ExportTableSection({
    required this.title,
    required this.columns,
    required this.rows,
    required this.roll,
    this.totals,
    this.totalsFor,
    this.totalsLabel = 'TOTAL',
    this.splits = const [],
    this.emptyMessage = 'No records match the selected period and filters.',
  });

  // Type-erased access, so the builders can treat tables of any row type
  // the same way.

  int get rowCount => rows.length;

  List<Object?> get erasedRows => List<Object?>.of(rows);

  Object? valueOf(ExportColumn<T> column, Object? row) =>
      column.value(row as T);

  String? displayOf(ExportColumn<T> column, Object? row) =>
      column.display?.call(row as T);

  bool hasSplit(String splitId) => splits.any((s) => s.id == splitId);

  ExportSplit<T>? splitById(String splitId) {
    for (final s in splits) {
      if (s.id == splitId) return s;
    }
    return null;
  }

  List<String> splitKeysOf(ExportSplit<T> split, Object? row) =>
      split.keys(row as T);

  Map<String, Object?>? totalsOf(List<Object?> subset) =>
      totalsFor?.call(subset.cast<T>());

  /// Totals for the full table: [totals], or [totalsFor] over every row.
  Map<String, Object?>? get fullTotals => totals ?? totalsFor?.call(rows);
}

class ReportExportSpec {
  final String reportName;

  /// File names become `downloaded_<fileSlug>_<millis>.<ext>`.
  final String fileSlug;
  final ExportPeriod? period;
  final List<ExportFilter> filters;
  final String? sortedBy;
  final String? groupedBy;
  final List<ExportSection> sections;

  /// The notes the screen shows under its toolbar ("All time covers
  /// the receipts loaded on this device."), as the screen words them.
  final List<String> notes;

  /// Guards Print 80mm / 58mm.
  final ReportPrintGate gate;

  /// Guards Download PDF and Export Excel. Null means always available on
  /// a report the user can open.
  final ReportPrintGate? downloadGate;

  const ReportExportSpec({
    required this.reportName,
    required this.fileSlug,
    required this.sections,
    this.period,
    this.filters = const [],
    this.sortedBy,
    this.groupedBy,
    this.notes = const [],
    this.gate = ReportPrintGate.receiptPrint,
    this.downloadGate,
  });

  Iterable<ExportTableSection<dynamic>> get tables =>
      sections.whereType<ExportTableSection<dynamic>>();

  /// Rows across every table section.
  int get recordCount =>
      tables.fold<int>(0, (sum, t) => sum + t.rowCount);

  /// Splits offered by the first table that has any (the main table).
  List<({String id, String label})> get splitOptions {
    for (final t in tables) {
      if (t.splits.isNotEmpty) {
        return [for (final s in t.splits) (id: s.id, label: s.label)];
      }
    }
    return const [];
  }
}

/// Shop and user details, filled from providers by the caller.
class ExportContext {
  final String shopName;
  final String currencySymbol;
  final String generatedBy;
  final DateTime generatedAt;

  /// Address, phone and email lines, already joined by the caller.
  final List<String> shopDetails;

  const ExportContext({
    required this.shopName,
    required this.currencySymbol,
    required this.generatedBy,
    required this.generatedAt,
    this.shopDetails = const [],
  });
}

/// `downloaded_<slug>_<millisecondsSinceEpoch>`, without an extension
/// (savePdfDesktop, savePdfMobile and ExcelProvider.save add their own).
String reportExportBaseName(ReportExportSpec spec, {required DateTime now}) {
  final slug = spec.fileSlug
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  final safe = slug.isEmpty ? 'report' : slug;
  return 'downloaded_${safe}_${now.millisecondsSinceEpoch}';
}

/// `downloaded_<slug>_<millisecondsSinceEpoch>.<extension>`, the form most
/// existing downloads use.
String reportExportFileName(
  ReportExportSpec spec,
  String extension, {
  required DateTime now,
}) {
  return '${reportExportBaseName(spec, now: now)}.$extension';
}
