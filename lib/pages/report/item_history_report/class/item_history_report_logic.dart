import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/constants/calculations.dart';

/// Page size required by the report specification.
const int itemHistoryReportPageSize = 100;

/// Key used by the Department filter for the "unassigned" bucket.
const String itemHistoryReportNoneKey = '__none__';

enum QuantityDirectionFilter {
  all,
  increase,
  decrease,
  zeroChange,
}

enum ItemHistorySortField {
  itemName,
  title,
  event,
  source,
  destination,
  desc,
  quantityChange,
  oldValue,
  newValue,
  createdAt,
  staffName,
  departmentName,
  unit,
  primaryUnit,
  isManaged,
}

class ItemHistoryReportFilters {
  String search = '';
  String? itemUuid;
  String? event;
  String? staffId;
  DateTimeRange? dateRange;
  String? source;
  String? destination;
  String? departmentUuid;
  bool? isManaged;
  QuantityDirectionFilter quantityDirection = QuantityDirectionFilter.all;

  bool get hasAnything =>
      search.trim().isNotEmpty ||
      itemUuid != null ||
      event != null ||
      staffId != null ||
      dateRange != null ||
      source != null ||
      destination != null ||
      departmentUuid != null ||
      isManaged != null ||
      quantityDirection != QuantityDirectionFilter.all;

  int get activeCount {
    int c = 0;
    if (itemUuid != null) c++;
    if (event != null) c++;
    if (staffId != null) c++;
    if (dateRange != null) c++;
    if (source != null) c++;
    if (destination != null) c++;
    if (departmentUuid != null) c++;
    if (isManaged != null) c++;
    if (quantityDirection != QuantityDirectionFilter.all) c++;
    return c;
  }

  void clearAll() {
    search = '';
    itemUuid = null;
    event = null;
    staffId = null;
    dateRange = null;
    source = null;
    destination = null;
    departmentUuid = null;
    isManaged = null;
    quantityDirection = QuantityDirectionFilter.all;
  }

  bool matchesSearch(ItemHistory h, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    bool check(String? s) => s != null && s.toLowerCase().contains(q);

    return check(h.title) ||
        check(h.itemName) ||
        check(h.event) ||
        check(h.source) ||
        check(h.destination) ||
        check(h.desc) ||
        check(h.staffName) ||
        check(h.departmentName) ||
        check(h.oldValue) ||
        check(h.newValue) ||
        check(h.unit) ||
        check(h.primaryUnit);
  }

  bool matches(ItemHistory h, {required bool departmentsEnabled}) {
    if (!matchesSearch(h, search.trim())) return false;

    if (itemUuid != null && h.itemUuid != itemUuid) return false;

    if (event != null && h.event != event) return false;

    if (staffId != null && h.staffId != staffId) return false;

    if (dateRange != null) {
      if (!isDateTimeInBusinessWindow(
        dateTime: h.createdAt,
        rangeStartDate: dateRange!.start,
        rangeEndDate: dateRange!.end,
      )) {
        return false;
      }
    }

    if (source != null && h.source != source) return false;

    if (destination != null && h.destination != destination) return false;

    if (departmentsEnabled && departmentUuid != null) {
      if (departmentUuid == itemHistoryReportNoneKey) {
        if (h.departmentUuid != null && h.departmentUuid!.isNotEmpty) {
          return false;
        }
      } else {
        if (h.departmentUuid != departmentUuid) return false;
      }
    }

    if (isManaged != null && h.isManaged != isManaged) return false;

    if (quantityDirection != QuantityDirectionFilter.all) {
      final qty = h.quantityChange;
      switch (quantityDirection) {
        case QuantityDirectionFilter.increase:
          if (qty == 0) return false;
          if (h.isIncreased == false) return false;
          if (h.isIncreased != true && (qty == null || qty <= 0)) return false;
          break;
        case QuantityDirectionFilter.decrease:
          if (qty == 0) return false;
          if (h.isIncreased == true) return false;
          if (h.isIncreased != false && (qty == null || qty >= 0)) return false;
          break;
        case QuantityDirectionFilter.zeroChange:
          if (qty != 0) return false;
          break;
        case QuantityDirectionFilter.all:
          break;
      }
    }

    return true;
  }
}

class ItemHistoryReportPageResult {
  final List<ItemHistory> rows;
  final int totalCount;
  final int page;
  final int totalPages;

  const ItemHistoryReportPageResult({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * itemHistoryReportPageSize + 1;
  int get lastIndex =>
      firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

class ItemHistoryReportQuery {
  static String formatEventName(String event) {
    switch (event) {
      case 'return':
        return 'Return';
      case 'sale':
        return 'Sale';
      case 'deliver':
        return 'Deliver';
      case 'purchase':
        return 'Purchase';
      case 'transfered_in':
        return 'Transferred In';
      case 'transfered_out':
        return 'Transferred Out';
      case 'produced':
        return 'Produced';
      case 'production_deleted':
        return 'Production Deleted';
      case 'created':
        return 'Created';
      case 'deleted':
        return 'Deleted';
      case 'duplicated':
        return 'Duplicated';
      case 'quantity_increase':
        return 'Quantity Increase';
      case 'quantity_decrease':
        return 'Quantity Decrease';
      default:
        return event
            .split('_')
            .map((w) =>
                w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
            .join(' ');
    }
  }

  static String formatSourceOrDestination(String text) {
    if (text.isEmpty) return '—';
    return text
        .split('_')
        .map((w) =>
            w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  static int _cmp<T extends Comparable>(T? a, T? b, bool asc) {
    // Null values always sink to the bottom, in both directions.
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    final c = a.compareTo(b);
    return asc ? c : -c;
  }

  static int _cmpNumericOrString(String? a, String? b, bool asc) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    final aClean = a.replaceAll(',', '').trim();
    final bClean = b.replaceAll(',', '').trim();
    final aNum = double.tryParse(aClean);
    final bNum = double.tryParse(bClean);
    if (aNum != null && bNum != null) {
      final c = aNum.compareTo(bNum);
      return asc ? c : -c;
    }
    final c = a.toLowerCase().compareTo(b.toLowerCase());
    return asc ? c : -c;
  }

  static List<ItemHistory> filterAndSort({
    required List<ItemHistory> rows,
    required ItemHistoryReportFilters filters,
    required ItemHistorySortField sortField,
    required bool ascending,
    required bool departmentsEnabled,
  }) {
    final out = rows
        .where((h) => filters.matches(h, departmentsEnabled: departmentsEnabled))
        .toList();

    int compare(ItemHistory a, ItemHistory b) {
      int c;
      switch (sortField) {
        case ItemHistorySortField.itemName:
          c = _cmp(
            a.itemName?.toLowerCase(),
            b.itemName?.toLowerCase(),
            ascending,
          );
          break;
        case ItemHistorySortField.title:
          c = _cmp(
            a.title.toLowerCase(),
            b.title.toLowerCase(),
            ascending,
          );
          break;
        case ItemHistorySortField.event:
          c = _cmp(
            a.event?.toLowerCase(),
            b.event?.toLowerCase(),
            ascending,
          );
          break;
        case ItemHistorySortField.source:
          c = _cmp(
            a.source?.toLowerCase(),
            b.source?.toLowerCase(),
            ascending,
          );
          break;
        case ItemHistorySortField.destination:
          c = _cmp(
            a.destination?.toLowerCase(),
            b.destination?.toLowerCase(),
            ascending,
          );
          break;
        case ItemHistorySortField.desc:
          c = _cmp(
            a.desc?.toLowerCase(),
            b.desc?.toLowerCase(),
            ascending,
          );
          break;
        case ItemHistorySortField.quantityChange:
          c = _cmp(
            a.quantityChange,
            b.quantityChange,
            ascending,
          );
          break;
        case ItemHistorySortField.oldValue:
          c = _cmpNumericOrString(
            a.oldValue,
            b.oldValue,
            ascending,
          );
          break;
        case ItemHistorySortField.newValue:
          c = _cmpNumericOrString(
            a.newValue,
            b.newValue,
            ascending,
          );
          break;
        case ItemHistorySortField.createdAt:
          c = _cmp(
            a.createdAt,
            b.createdAt,
            ascending,
          );
          break;
        case ItemHistorySortField.staffName:
          c = _cmp(
            a.staffName?.toLowerCase(),
            b.staffName?.toLowerCase(),
            ascending,
          );
          break;
        case ItemHistorySortField.departmentName:
          c = _cmp(
            a.departmentName?.toLowerCase(),
            b.departmentName?.toLowerCase(),
            ascending,
          );
          break;
        case ItemHistorySortField.unit:
          c = _cmp(
            a.unit?.toLowerCase(),
            b.unit?.toLowerCase(),
            ascending,
          );
          break;
        case ItemHistorySortField.primaryUnit:
          c = _cmp(
            a.primaryUnit?.toLowerCase(),
            b.primaryUnit?.toLowerCase(),
            ascending,
          );
          break;
        case ItemHistorySortField.isManaged:
          final aVal = a.isManaged == null ? null : (a.isManaged! ? 1 : 0);
          final bVal = b.isManaged == null ? null : (b.isManaged! ? 1 : 0);
          c = _cmp(aVal, bVal, ascending);
          break;
      }
      if (c != 0) return c;

      // Deterministic tie-breaker: newer records first, then uuid.
      final d = _cmp(a.createdAt, b.createdAt, false);
      if (d != 0) return d;
      return (a.uuid ?? '').compareTo(b.uuid ?? '');
    }

    out.sort(compare);
    return out;
  }

  static ItemHistoryReportPageResult paginate(
    List<ItemHistory> sorted,
    int requestedPage,
  ) {
    final total = sorted.length;
    final pages = total == 0 ? 1 : (total / itemHistoryReportPageSize).ceil();
    final page = requestedPage.clamp(1, pages);
    final start = (page - 1) * itemHistoryReportPageSize;
    final end = (start + itemHistoryReportPageSize) > total
        ? total
        : start + itemHistoryReportPageSize;
    return ItemHistoryReportPageResult(
      rows: total == 0 ? const [] : sorted.sublist(start, end),
      totalCount: total,
      page: page,
      totalPages: pages,
    );
  }
}
