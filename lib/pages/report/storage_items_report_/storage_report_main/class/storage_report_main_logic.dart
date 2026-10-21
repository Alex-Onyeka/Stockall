import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history_event_class.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';

/// Page size required by the report specification.
const int storageReportPageSize = 100;

enum StorageSortField {
  name,
  quantity,
  primaryUnit,
  openingStock,
  closingStock,
  stockChange,
  costPrice,
  totalCostValue,
  quantityType,
  createdAt,
  itemsInSalesCount,
  quantityInSales,
  totalQuantity,
}

/// One displayed line of the storage report. Quantities are normalised to the
/// storage item's PRIMARY unit.
class StorageReportRow {
  final TempStorageProducts storageProduct;
  final String name;
  final String primaryUnit;

  /// Quantity expressed in the storage item's primary unit.
  final double? quantity;

  /// Cost price of one primary unit.
  final double? costPrice;

  /// quantity x costPrice (null when either is null).
  final double? totalCostValue;

  final bool isTwoDimensional;
  final DateTime? createdAt;

  /// Sales items where `storageUuid == storageProduct.uuid`.
  final List<TempProductClass> salesProducts;
  final List<String> salesItemNames;

  /// Total quantity of linked sales items converted to the primary unit of this storage item.
  final double quantityInSales;

  /// Converted total sales quantity plus storage item quantity.
  final double totalQuantity;

  StorageReportRow({
    required this.storageProduct,
    required this.name,
    required this.primaryUnit,
    required this.quantity,
    required this.costPrice,
    required this.totalCostValue,
    required this.isTwoDimensional,
    required this.createdAt,
    required this.salesProducts,
    required this.salesItemNames,
    required this.quantityInSales,
    required this.totalQuantity,
  });

  String get uuid => storageProduct.uuid ?? '';

  String get quantityTypeLabel =>
      isTwoDimensional ? '2-Dimensional' : 'Simple';

  String get itemsInSalesLabel =>
      salesItemNames.isEmpty
          ? '—'
          : salesItemNames.join(', ');

  int get salesCount => salesProducts.length;
}

/// Builds [StorageReportRow]s from storage products and sales products.
class StorageReportRowBuilder {
  static StorageReportRow build({
    required TempStorageProducts storage,
    required List<TempProductClass> allSalesProducts,
  }) {
    ProductUnitsClass primaryUnit;
    try {
      primaryUnit = storage.getPrimaryUnit();
    } catch (_) {
      primaryUnit = ProductUnitsClass(
        uuid: '${storage.uuid ?? ''}_primary_unit',
        staffUuid: '',
        createdAt: DateTime.now(),
        staffName: '',
        conversion: 1,
        name:
            storage.unit == 'Others'
                ? 'Unit(s)'
                : storage.unit ?? 'Unit(s)',
        isPrimary: true,
        productUuid: storage.uuid ?? '',
        dimensionType:
            storage.quantityType == 2
                ? ProductUnitsClass.sheetUnit
                : null,
      );
    }
    final is2D = storage.quantityType == 2;

    // Normalise storage quantity to primary unit
    double? qty;
    if (storage.quantity != null) {
      qty = storage.unitFromActual(
        primaryUnit,
        storage.getActualQuantity() ?? 0,
      );
      if (!qty.isFinite) qty = 0;
    }

    final cost = storage.costPrice;
    final totalCost =
        (qty != null && cost != null) ? qty * cost : null;

    // Filter sales items linked to this storage item
    final storageUuid = storage.uuid;
    final linkedSales =
        (storageUuid != null && storageUuid.isNotEmpty)
            ? allSalesProducts
                .where((p) => p.storageUuid == storageUuid)
                .toList()
            : <TempProductClass>[];

    final salesNames =
        linkedSales.map((p) => p.name).toList();

    // Convert each sales item quantity to storage primary unit
    double salesQtyConverted = 0.0;
    for (final sp in linkedSales) {
      final actual = sp.getActualQuantity() ?? 0;
      final converted = storage.unitFromActual(
        primaryUnit,
        actual,
      );
      if (converted.isFinite) {
        salesQtyConverted += converted;
      }
    }

    final totalQty = (qty ?? 0.0) + salesQtyConverted;

    return StorageReportRow(
      storageProduct: storage,
      name: storage.name,
      primaryUnit: primaryUnit.name,
      quantity: qty,
      costPrice: cost,
      totalCostValue: totalCost,
      isTwoDimensional: is2D,
      createdAt: storage.createdAt,
      salesProducts: linkedSales,
      salesItemNames: salesNames,
      quantityInSales: salesQtyConverted,
      totalQuantity: totalQty,
    );
  }

  static List<StorageReportRow> buildAll({
    required List<TempStorageProducts> storageProducts,
    required List<TempProductClass> salesProducts,
  }) {
    final rows = <StorageReportRow>[];
    for (final sp in storageProducts) {
      try {
        rows.add(
          build(
            storage: sp,
            allSalesProducts: salesProducts,
          ),
        );
      } catch (_) {
        // A single malformed item must never break the report.
      }
    }
    return rows;
  }
}

/// All user-selectable filters for Storage Report Table.
/// Storage item has no category, no department, no inventory management, no selling price.
/// Only: search, cost price range, quantity range, number of sales items.
class StorageReportFilters {
  String search = '';
  double? costMin;
  double? costMax;
  double? quantityMin;
  double? quantityMax;
  int? salesItemsCountMin;
  int? salesItemsCountMax;

  int get activeCount =>
      (costMin != null || costMax != null ? 1 : 0) +
      (quantityMin != null || quantityMax != null ? 1 : 0) +
      (salesItemsCountMin != null ||
              salesItemsCountMax != null
          ? 1
          : 0);

  bool get hasAnything =>
      activeCount > 0 || search.trim().isNotEmpty;

  void clearAll() {
    search = '';
    clearFiltersOnly();
  }

  void clearFiltersOnly() {
    costMin = null;
    costMax = null;
    quantityMin = null;
    quantityMax = null;
    salesItemsCountMin = null;
    salesItemsCountMax = null;
  }

  bool matches(
    StorageReportRow r, {
    required bool costFilterAllowed,
  }) {
    final q = search.trim().toLowerCase();
    if (q.isNotEmpty) {
      final nameHit = r.name.toLowerCase().contains(q);
      final salesHit = r.salesItemNames.any(
        (sn) => sn.toLowerCase().contains(q),
      );
      if (!nameHit && !salesHit) return false;
    }

    if (costFilterAllowed) {
      if (costMin != null &&
          (r.costPrice == null ||
              r.costPrice! < costMin!)) {
        return false;
      }
      if (costMax != null &&
          (r.costPrice == null ||
              r.costPrice! > costMax!)) {
        return false;
      }
    }

    if (quantityMin != null &&
        (r.quantity == null ||
            r.quantity! < quantityMin!)) {
      return false;
    }
    if (quantityMax != null &&
        (r.quantity == null ||
            r.quantity! > quantityMax!)) {
      return false;
    }

    if (salesItemsCountMin != null &&
        r.salesCount < salesItemsCountMin!) {
      return false;
    }
    if (salesItemsCountMax != null &&
        r.salesCount > salesItemsCountMax!) {
      return false;
    }

    return true;
  }
}

/// Holds opening stock, closing stock, and stock change for a storage item over a date range.
class StorageStockMovement {
  final double? opening;
  final double? closing;

  const StorageStockMovement({
    required this.opening,
    required this.closing,
  });

  double? get change {
    if (opening == null || closing == null) return null;
    return closing! - opening!;
  }
}

/// Reconstructs the storage stock balance from StorageItemHistory records.
class StorageStockMovementCalculator {
  static final Set<String> _stockEvents = {
    StorageItemHistoryEventClass.returnEvent,
    StorageItemHistoryEventClass.purchase,
    StorageItemHistoryEventClass.purchaseDeleted,
    StorageItemHistoryEventClass.transferedIn,
    StorageItemHistoryEventClass.transferedOut,
    StorageItemHistoryEventClass.itemCreated,
    StorageItemHistoryEventClass.stockIn,
    StorageItemHistoryEventClass.stockOut,
    StorageItemHistoryEventClass.quantityUpdatedIncrease,
    StorageItemHistoryEventClass.quantityUpdatedDecrease,
  };

  static double? _parse(String? v) {
    if (v == null) return null;
    return double.tryParse(v.replaceAll(',', '').trim());
  }

  static bool isApplicable(
    StorageItemHistory h,
    StorageReportRow row,
  ) {
    if (h.createdAt == null) return false;
    if (h.event == null ||
        !_stockEvents.contains(h.event)) {
      return false;
    }
    if (_parse(h.storageItemOldValue) == null ||
        _parse(h.storageItemNewValue) == null) {
      return false;
    }
    final pu = h.storagePrimaryUnit;
    if (pu != null &&
        pu.trim().isNotEmpty &&
        pu.trim().toLowerCase() !=
            row.primaryUnit.trim().toLowerCase()) {
      return false;
    }
    return true;
  }

  static DateTime _alignCutoff(
    DateTime dt,
    DateTime cutoff,
  ) {
    if (dt.isUtc == cutoff.isUtc) return cutoff;
    return dt.isUtc
        ? DateTime.utc(
          cutoff.year,
          cutoff.month,
          cutoff.day,
          cutoff.hour,
          cutoff.minute,
          cutoff.second,
          cutoff.millisecond,
          cutoff.microsecond,
        )
        : DateTime(
          cutoff.year,
          cutoff.month,
          cutoff.day,
          cutoff.hour,
          cutoff.minute,
          cutoff.second,
          cutoff.millisecond,
          cutoff.microsecond,
        );
  }

  static StorageStockMovement calculate({
    required StorageReportRow row,
    required List<StorageItemHistory> histories,
    required DateTime startCutoff,
    required DateTime endCutoff,
  }) {
    final usable =
        histories
            .where((h) => isApplicable(h, row))
            .toList()
          ..sort(
            (a, b) => a.createdAt!.compareTo(b.createdAt!),
          );

    // 1) Opening Stock: balance immediately before startCutoff
    double? opening;
    bool openingFound = false;
    for (final h in usable) {
      final start = _alignCutoff(h.createdAt!, startCutoff);
      if (!h.createdAt!.isBefore(start)) {
        opening = _parse(h.storageItemOldValue);
        openingFound = true;
        break;
      }
    }
    if (!openingFound) {
      if (usable.isNotEmpty) {
        opening = _parse(usable.last.storageItemNewValue);
      } else {
        final created = row.createdAt;
        final start =
            created != null
                ? _alignCutoff(created, startCutoff)
                : startCutoff;
        if (created != null && !created.isBefore(start)) {
          opening = 0;
        } else {
          opening = row.quantity;
        }
      }
    }

    // 2) Closing Stock: newValue of the last history recorded in [startCutoff, endCutoff]
    double? closing;
    final inRange =
        usable.where((h) {
          final start = _alignCutoff(
            h.createdAt!,
            startCutoff,
          );
          final end = _alignCutoff(h.createdAt!, endCutoff);
          return !h.createdAt!.isBefore(start) &&
              !h.createdAt!.isAfter(end);
        }).toList();

    if (inRange.isNotEmpty) {
      closing = _parse(inRange.last.storageItemNewValue);
    } else {
      closing = opening;
    }

    return StorageStockMovement(
      opening: opening,
      closing: closing,
    );
  }
}

/// Result of [StorageReportQuery.paginate].
class StorageReportPageResult {
  final List<StorageReportRow> rows;
  final int totalCount;
  final int page;
  final int totalPages;

  const StorageReportPageResult({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });

  int get firstIndex =>
      totalCount == 0
          ? 0
          : (page - 1) * storageReportPageSize + 1;
  int get lastIndex =>
      firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

class StorageReportQuery {
  static int _cmp<T extends Comparable>(
    T? a,
    T? b,
    bool asc,
  ) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    final c = a.compareTo(b);
    return asc ? c : -c;
  }

  static List<StorageReportRow> filterAndSort({
    required List<StorageReportRow> rows,
    required StorageReportFilters filters,
    required StorageSortField sortField,
    required bool ascending,
    required bool costFilterAllowed,
    double? Function(StorageReportRow)? opening,
    double? Function(StorageReportRow)? closing,
    double? Function(StorageReportRow)? stockChange,
  }) {
    final out =
        rows
            .where(
              (r) => filters.matches(
                r,
                costFilterAllowed: costFilterAllowed,
              ),
            )
            .toList();

    int compare(StorageReportRow a, StorageReportRow b) {
      int c;
      switch (sortField) {
        case StorageSortField.name:
          c = _cmp(
            a.name.toLowerCase(),
            b.name.toLowerCase(),
            ascending,
          );
          break;
        case StorageSortField.quantity:
          c = _cmp(a.quantity, b.quantity, ascending);
          break;
        case StorageSortField.primaryUnit:
          c = _cmp(
            a.primaryUnit.toLowerCase(),
            b.primaryUnit.toLowerCase(),
            ascending,
          );
          break;
        case StorageSortField.openingStock:
          c = _cmp(
            opening?.call(a),
            opening?.call(b),
            ascending,
          );
          break;
        case StorageSortField.closingStock:
          c = _cmp(
            closing?.call(a),
            closing?.call(b),
            ascending,
          );
          break;
        case StorageSortField.stockChange:
          c = _cmp(
            stockChange?.call(a),
            stockChange?.call(b),
            ascending,
          );
          break;
        case StorageSortField.costPrice:
          c = _cmp(a.costPrice, b.costPrice, ascending);
          break;
        case StorageSortField.totalCostValue:
          c = _cmp(
            a.totalCostValue,
            b.totalCostValue,
            ascending,
          );
          break;
        case StorageSortField.quantityType:
          c = _cmp(
            a.isTwoDimensional ? 1 : 0,
            b.isTwoDimensional ? 1 : 0,
            ascending,
          );
          break;
        case StorageSortField.createdAt:
          c = _cmp(a.createdAt, b.createdAt, ascending);
          break;
        case StorageSortField.itemsInSalesCount:
          c = _cmp(a.salesCount, b.salesCount, ascending);
          if (c == 0) {
            c = _cmp(
              a.itemsInSalesLabel.toLowerCase(),
              b.itemsInSalesLabel.toLowerCase(),
              ascending,
            );
          }
          break;
        case StorageSortField.quantityInSales:
          c = _cmp(
            a.quantityInSales,
            b.quantityInSales,
            ascending,
          );
          break;
        case StorageSortField.totalQuantity:
          c = _cmp(
            a.totalQuantity,
            b.totalQuantity,
            ascending,
          );
          break;
      }
      if (c != 0) return c;
      final n = a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      );
      return n != 0 ? n : a.uuid.compareTo(b.uuid);
    }

    out.sort(compare);
    return out;
  }

  static StorageReportPageResult paginate(
    List<StorageReportRow> sorted,
    int requestedPage,
  ) {
    final total = sorted.length;
    final pages =
        total == 0
            ? 1
            : (total / storageReportPageSize).ceil();
    final page = requestedPage.clamp(1, pages);
    final start = (page - 1) * storageReportPageSize;
    final end =
        (start + storageReportPageSize) > total
            ? total
            : start + storageReportPageSize;
    return StorageReportPageResult(
      rows:
          total == 0
              ? const []
              : sorted.sublist(start, end),
      totalCount: total,
      page: page,
      totalPages: pages,
    );
  }
}
