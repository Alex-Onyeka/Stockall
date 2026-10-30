import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history_event_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/items_report_/item_history_report/class/item_history_report_logic.dart';

/// Page size required by the report specification.
const int storageItemHistoryReportPageSize = 100;

/// Key used by the Sales Item, Department and Other Staff filters for
/// the "not set" bucket.
const String storageItemHistoryReportNoneKey = '__none__';

/// Prefix of a staff key built from a name when the staff id is missing.
const String storageHistoryStaffNamePrefix = 'name:';

/// Events written into StorageItemHistory, in filter display order.
final List<String> storageItemHistoryKnownEvents = [
  StorageItemHistoryEventClass.stockIn,
  StorageItemHistoryEventClass.stockOut,
  StorageItemHistoryEventClass.returnEvent,
  StorageItemHistoryEventClass.purchase,
  StorageItemHistoryEventClass.purchaseDeleted,
  StorageItemHistoryEventClass.quantityUpdatedIncrease,
  StorageItemHistoryEventClass.quantityUpdatedDecrease,
  StorageItemHistoryEventClass.transferedIn,
  StorageItemHistoryEventClass.transferedOut,
  StorageItemHistoryEventClass.itemCreated,
  StorageItemHistoryEventClass.itemDuplicated,
  StorageItemHistoryEventClass.itemDeleted,
];

enum StorageItemHistorySortField {
  storageItemName,
  salesItemName,
  departmentName,
  title,
  event,
  source,
  destination,
  desc,
  quantityChange,
  unit,
  storageOldValue,
  storageNewValue,
  storagePrimaryUnit,
  salesOldValue,
  salesNewValue,
  createdAt,
  storekeeperName,
  otherStaffName,
  supplier,
  trackingNumber,
}

String? _clean(String? s) {
  final t = s?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

/// Staff keys. The storekeeper id can be missing on records downloaded
/// from the server, so a key falls back to the staff name.
class StorageHistoryStaff {
  static String? _key(String? id, String? name) {
    final cleanId = _clean(id);
    if (cleanId != null) return cleanId;
    final cleanName = _clean(name);
    if (cleanName != null) {
      return '$storageHistoryStaffNamePrefix${cleanName.toLowerCase()}';
    }
    return null;
  }

  /// The person on the storage side (the creator of the record).
  static String? storekeeperKey(StorageItemHistory h) =>
      _key(h.storageStaffId, h.storageStaffName);

  /// The person at the other end (receiving or returning).
  static String? otherStaffKey(StorageItemHistory h) =>
      _key(h.salesStaffUuid, h.salesStaffName);
}

/// Restricts records to the current shop and to the departments the user
/// may see. Department scoping uses the SALES department; records with no
/// sales department (stock-in, purchase, update, created, deleted) stay
/// visible to everyone who can open the report.
List<StorageItemHistory> scopeStorageItemHistories({
  required List<StorageItemHistory> all,
  required int shopId,
  required bool departmentsEnabled,
  required bool canViewAllDepartments,
  required String? currentDepartmentUuid,
}) {
  return all.where((h) {
    if (h.shopId != shopId) return false;
    if (!departmentsEnabled || canViewAllDepartments) return true;
    final dept = _clean(h.salesDepartmentUuid);
    return dept == null || dept == currentDepartmentUuid;
  }).toList();
}

/// The current name of an item when it differs from the history
/// snapshot; null when the names match or the item no longer exists.
String? currentNameIfDifferent({
  required String? snapshotName,
  required String? currentName,
}) {
  final current = _clean(currentName);
  if (current == null) return null;
  final snapshot = _clean(snapshotName);
  if (snapshot != null &&
      snapshot.toLowerCase() == current.toLowerCase()) {
    return null;
  }
  return current;
}

class StorageItemHistoryReportFilters {
  String search = '';
  String? storageItemUuid;
  String? salesItemUuid;
  String? departmentUuid;
  String? storekeeperKey;
  String? otherStaffKey;
  String? event;
  String? source;
  String? destination;
  QuantityDirectionFilter quantityDirection = QuantityDirectionFilter.all;

  /// Null means All time. The date has its own toolbar button, so it is
  /// not counted in [activeCount] and is kept by [clearAll].
  DateTimeRange? dateRange;

  bool get hasAnything => search.trim().isNotEmpty || activeCount > 0;

  int get activeCount {
    int c = 0;
    if (storageItemUuid != null) c++;
    if (salesItemUuid != null) c++;
    if (departmentUuid != null) c++;
    if (storekeeperKey != null) c++;
    if (otherStaffKey != null) c++;
    if (event != null) c++;
    if (source != null) c++;
    if (destination != null) c++;
    if (quantityDirection != QuantityDirectionFilter.all) c++;
    return c;
  }

  void clearAll() {
    search = '';
    storageItemUuid = null;
    salesItemUuid = null;
    departmentUuid = null;
    storekeeperKey = null;
    otherStaffKey = null;
    event = null;
    source = null;
    destination = null;
    quantityDirection = QuantityDirectionFilter.all;
  }

  bool matchesSearch(StorageItemHistory h, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    bool check(String? s) => s != null && s.toLowerCase().contains(q);

    return check(h.title) ||
        check(h.storageItemName) ||
        check(h.salesItemName) ||
        check(h.salesDepartmentName) ||
        check(h.storageStaffName) ||
        check(h.salesStaffName) ||
        check(h.event) ||
        (h.event != null &&
            check(StorageItemHistoryReportQuery.formatEventName(h.event!))) ||
        check(h.source) ||
        check(h.destination) ||
        check(h.desc) ||
        check(h.storageItemOldValue) ||
        check(h.storageItemNewValue) ||
        check(h.salesItemOldValue) ||
        check(h.salesItemNewValue) ||
        check(h.storageUnit) ||
        check(h.storagePrimaryUnit) ||
        check(h.salesUnit) ||
        check(h.salesPrimaryUnit);
  }

  bool _matchesKey(String? filterKey, String? value) {
    if (filterKey == null) return true;
    if (filterKey == storageItemHistoryReportNoneKey) {
      return _clean(value) == null;
    }
    return value == filterKey;
  }

  bool matches(
    StorageItemHistory h, {
    required bool departmentsEnabled,
  }) {
    if (!matchesSearch(h, search.trim())) return false;

    if (storageItemUuid != null && h.storageItemUuid != storageItemUuid) {
      return false;
    }

    if (!_matchesKey(salesItemUuid, h.salesItemUuid)) return false;

    if (departmentsEnabled &&
        !_matchesKey(departmentUuid, h.salesDepartmentUuid)) {
      return false;
    }

    if (storekeeperKey != null &&
        StorageHistoryStaff.storekeeperKey(h) != storekeeperKey) {
      return false;
    }

    if (otherStaffKey != null) {
      final key = StorageHistoryStaff.otherStaffKey(h);
      if (otherStaffKey == storageItemHistoryReportNoneKey) {
        if (key != null) return false;
      } else if (key != otherStaffKey) {
        return false;
      }
    }

    if (event != null && h.event != event) return false;

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

class StorageItemHistoryReportPageResult {
  final List<StorageItemHistory> rows;
  final int totalCount;
  final int page;
  final int totalPages;

  const StorageItemHistoryReportPageResult({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * storageItemHistoryReportPageSize + 1;
  int get lastIndex =>
      firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

class StorageItemHistoryReportQuery {
  static String formatEventName(String event) {
    switch (event) {
      case 'stock_in':
        return 'Stock In';
      case 'stock_out':
        return 'Stock Out';
      case 'return':
        return 'Return';
      case 'purchase':
        return 'Purchase';
      case 'purchase_deleted':
        return 'Purchase Deleted';
      case 'transfered_in':
        return 'Transferred In';
      case 'transfered_out':
        return 'Transferred Out';
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
        return ItemHistoryReportQuery.formatSourceOrDestination(event);
    }
  }

  static String formatSourceOrDestination(String text) {
    if (text == StorageItemHistoryEventClass.unKnownSource) return 'Not Set';
    return ItemHistoryReportQuery.formatSourceOrDestination(text);
  }

  /// The unit of [StorageItemHistory.quantityChange]; null when the
  /// record has no usable unit (e.g. 'Not Set' on created items).
  static String? quantityChangeUnit(StorageItemHistory h) {
    final u = _clean(h.storageUnit);
    if (u == null || u.toLowerCase() == 'not set') return null;
    final cleanSelected = stripDimensionLabel(u);
    final cleanPrim = stripDimensionLabel(h.storagePrimaryUnit ?? '');
    if (cleanPrim.isEmpty ||
        cleanSelected.trim().toLowerCase() ==
            cleanPrim.trim().toLowerCase()) {
      return cleanSelected;
    }
    final bracketMatch = RegExp(r'\(([^)]+)\)').firstMatch(cleanSelected);
    if (bracketMatch != null) {
      return cleanSelected;
    }
    final oldVal = double.tryParse(h.storageItemOldValue ?? '');
    final newVal = double.tryParse(h.storageItemNewValue ?? '');
    if (oldVal != null && newVal != null) {
      final diff = (newVal - oldVal).abs();
      return formatHistoryUnit(
        selectedUnit: cleanSelected,
        primaryUnit: cleanPrim,
        primaryQuantity: diff,
      );
    }
    return cleanSelected;
  }

  static int _cmp<T extends Comparable>(T? a, T? b, bool asc) {
    // Null values always sink to the bottom, in both directions.
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    final c = a.compareTo(b);
    return asc ? c : -c;
  }

  static int _cmpText(String? a, String? b, bool asc) =>
      _cmp(_clean(a)?.toLowerCase(), _clean(b)?.toLowerCase(), asc);

  static int _cmpNumericOrString(String? a, String? b, bool asc) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    final aNum = double.tryParse(a.replaceAll(',', '').trim());
    final bNum = double.tryParse(b.replaceAll(',', '').trim());
    if (aNum != null && bNum != null) {
      final c = aNum.compareTo(bNum);
      return asc ? c : -c;
    }
    final c = a.toLowerCase().compareTo(b.toLowerCase());
    return asc ? c : -c;
  }

  static List<StorageItemHistory> filterAndSort({
    required List<StorageItemHistory> rows,
    required StorageItemHistoryReportFilters filters,
    required StorageItemHistorySortField sortField,
    required bool ascending,
    required bool departmentsEnabled,
  }) {
    final out = rows
        .where(
          (h) => filters.matches(h, departmentsEnabled: departmentsEnabled),
        )
        .toList();

    int compare(StorageItemHistory a, StorageItemHistory b) {
      int c;
      switch (sortField) {
        case StorageItemHistorySortField.storageItemName:
          c = _cmpText(a.storageItemName, b.storageItemName, ascending);
          break;
        case StorageItemHistorySortField.salesItemName:
          c = _cmpText(a.salesItemName, b.salesItemName, ascending);
          break;
        case StorageItemHistorySortField.departmentName:
          c = _cmpText(
            a.salesDepartmentName,
            b.salesDepartmentName,
            ascending,
          );
          break;
        case StorageItemHistorySortField.title:
          c = _cmpText(a.title, b.title, ascending);
          break;
        case StorageItemHistorySortField.event:
          c = _cmpText(a.event, b.event, ascending);
          break;
        case StorageItemHistorySortField.source:
          c = _cmpText(a.source, b.source, ascending);
          break;
        case StorageItemHistorySortField.destination:
          c = _cmpText(a.destination, b.destination, ascending);
          break;
        case StorageItemHistorySortField.desc:
          c = _cmpText(a.desc, b.desc, ascending);
          break;
        case StorageItemHistorySortField.quantityChange:
          c = _cmp(a.quantityChange, b.quantityChange, ascending);
          break;
        case StorageItemHistorySortField.unit:
          c = _cmp(
            quantityChangeUnit(a)?.toLowerCase(),
            quantityChangeUnit(b)?.toLowerCase(),
            ascending,
          );
          break;
        case StorageItemHistorySortField.storageOldValue:
          c = _cmpNumericOrString(
            a.storageItemOldValue,
            b.storageItemOldValue,
            ascending,
          );
          break;
        case StorageItemHistorySortField.storageNewValue:
          c = _cmpNumericOrString(
            a.storageItemNewValue,
            b.storageItemNewValue,
            ascending,
          );
          break;
        case StorageItemHistorySortField.storagePrimaryUnit:
          c = _cmpText(
            a.storagePrimaryUnit,
            b.storagePrimaryUnit,
            ascending,
          );
          break;
        case StorageItemHistorySortField.salesOldValue:
          c = _cmpNumericOrString(
            a.salesItemOldValue,
            b.salesItemOldValue,
            ascending,
          );
          break;
        case StorageItemHistorySortField.salesNewValue:
          c = _cmpNumericOrString(
            a.salesItemNewValue,
            b.salesItemNewValue,
            ascending,
          );
          break;
        case StorageItemHistorySortField.createdAt:
          c = _cmp(a.createdAt, b.createdAt, ascending);
          break;
        case StorageItemHistorySortField.storekeeperName:
          c = _cmpText(a.storageStaffName, b.storageStaffName, ascending);
          break;
        case StorageItemHistorySortField.otherStaffName:
          c = _cmpText(a.salesStaffName, b.salesStaffName, ascending);
          break;
        case StorageItemHistorySortField.supplier:
          c = _cmpText(a.supplier, b.supplier, ascending);
          break;
        case StorageItemHistorySortField.trackingNumber:
          c = _cmpText(a.trackingNumber, b.trackingNumber, ascending);
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

  static StorageItemHistoryReportPageResult paginate(
    List<StorageItemHistory> sorted,
    int requestedPage,
  ) {
    final total = sorted.length;
    final pages =
        total == 0 ? 1 : (total / storageItemHistoryReportPageSize).ceil();
    final page = requestedPage.clamp(1, pages);
    final start = (page - 1) * storageItemHistoryReportPageSize;
    final end = (start + storageItemHistoryReportPageSize) > total
        ? total
        : start + storageItemHistoryReportPageSize;
    return StorageItemHistoryReportPageResult(
      rows: total == 0 ? const [] : sorted.sublist(start, end),
      totalCount: total,
      page: page,
      totalPages: pages,
    );
  }
}
