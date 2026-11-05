// Ready-made splits for report specs (Excel sheets and roll sections).
// They take accessors rather than report types, so any report can use
// them.

import 'package:stockall/pages/report/components/export/report_export_spec.dart';

/// By category. Only category ids found in [names] count, so deleted
/// categories don't make empty sheets; a row with none goes to
/// "No Category". A row in two categories appears under both.
ExportSplit<T> categorySplit<T>({
  required List<String> Function(T row) categoryIds,
  required Map<String, String> names,
}) {
  return ExportSplit<T>(
    id: 'category',
    label: 'Category',
    noneLabel: 'No Category',
    keys: (row) => [
      for (final id in categoryIds(row))
        if (names.containsKey(id)) id,
    ],
    name: (key) => names[key] ?? key,
  );
}

/// By department. A department id not in [names] counts as none.
ExportSplit<T> departmentSplit<T>({
  required String? Function(T row) departmentId,
  required Map<String, String> names,
}) {
  return ExportSplit<T>(
    id: 'department',
    label: 'Department',
    noneLabel: 'No Department',
    keys: (row) {
      final id = departmentId(row);
      return id != null && names.containsKey(id) ? [id] : const [];
    },
    name: (key) => names[key] ?? key,
  );
}

/// By any single field, with group names taken from the rows themselves
/// (the first non-empty name seen for each key).
ExportSplit<T> fieldSplit<T>({
  required String id,
  required String label,
  required String noneLabel,
  required List<T> rows,
  required String? Function(T row) key,
  required String? Function(T row) name,
}) {
  final names = <String, String>{};
  for (final r in rows) {
    final k = key(r)?.trim();
    if (k == null || k.isEmpty) continue;
    final n = name(r)?.trim();
    if (n != null && n.isNotEmpty) names.putIfAbsent(k, () => n);
  }
  return ExportSplit<T>(
    id: id,
    label: label,
    noneLabel: noneLabel,
    keys: (row) {
      final k = key(row)?.trim();
      return k == null || k.isEmpty ? const [] : [k];
    },
    name: (k) => names[k] ?? k,
  );
}

ExportSplit<T> staffSplit<T>({
  required List<T> rows,
  required String? Function(T row) staffId,
  required String? Function(T row) staffName,
}) => fieldSplit<T>(
  id: 'staff',
  label: 'Staff',
  noneLabel: 'No Staff',
  rows: rows,
  key: staffId,
  name: staffName,
);

ExportSplit<T> customerSplit<T>({
  required List<T> rows,
  required String? Function(T row) customerId,
  required String? Function(T row) customerName,
}) => fieldSplit<T>(
  id: 'customer',
  label: 'Customer',
  noneLabel: 'No Customer',
  rows: rows,
  key: customerId,
  name: customerName,
);

ExportSplit<T> supplierSplit<T>({
  required List<T> rows,
  required String? Function(T row) supplierId,
  required String? Function(T row) supplierName,
}) => fieldSplit<T>(
  id: 'supplier',
  label: 'Supplier',
  noneLabel: 'No Supplier',
  rows: rows,
  key: supplierId,
  name: supplierName,
);

/// By a label that is its own key, such as a payment channel or status.
ExportSplit<T> labelSplit<T>({
  required String id,
  required String label,
  required String noneLabel,
  required String? Function(T row) value,
}) {
  return ExportSplit<T>(
    id: id,
    label: label,
    noneLabel: noneLabel,
    keys: (row) {
      final v = value(row)?.trim();
      return v == null || v.isEmpty ? const [] : [v];
    },
    name: (key) => key,
  );
}

ExportSplit<T> channelSplit<T>({required String? Function(T row) channel}) =>
    labelSplit<T>(
      id: 'channel',
      label: 'Channel',
      noneLabel: 'No Channel',
      value: channel,
    );

ExportSplit<T> statusSplit<T>({required String? Function(T row) status}) =>
    labelSplit<T>(
      id: 'status',
      label: 'Status',
      noneLabel: 'No Status',
      value: status,
    );
