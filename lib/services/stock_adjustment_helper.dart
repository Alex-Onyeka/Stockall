import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/constants/calculations.dart';

/// Default history text when the user leaves the comment empty.
const String defaultQuantityAdjustmentDesc =
    'This Item Quantity Was Updated.';

/// Values computed for one item quantity edit (add to / replace).
///
/// Quantities named `*Area` are in the item's actual quantity
/// space (`getActualQuantity()`): base units for 1D items, area
/// for 2D items.
class QuantityAdjustment {
  final double oldStockArea;
  final double newStockArea;

  /// Absolute difference between [newStockArea] and [oldStockArea].
  final double deltaArea;

  /// Area of one stored sheet (`dimensionArea()`), 1 for 1D items.
  final double areaPerSheet;

  /// Quantity sent with the `QuantityUpdate` (always positive).
  final double rpcQuantityChange;

  /// Value to store in `TempProductClass.quantity`.
  final double newStoredQuantity;

  const QuantityAdjustment({
    required this.oldStockArea,
    required this.newStockArea,
    required this.deltaArea,
    required this.areaPerSheet,
    required this.rpcQuantityChange,
    required this.newStoredQuantity,
  });

  /// True when the edit would not change the stock.
  bool get isNoChange => deltaArea < 1e-9;

  bool get isIncrement => newStockArea >= oldStockArea;
}

/// Computes the new stock for an item quantity edit, the same way
/// the item details "Edit Unit Qtty" dialog does.
///
/// [customWidth] / [customHeight] only apply to a 2D item with a
/// sheet (non area) unit selected. They are used when
/// [useCustomDimensions] is true; otherwise the item's own
/// dimensions are used.
QuantityAdjustment computeQuantityAdjustment({
  required TempProductClass product,
  required String? unitUuid,
  required double enteredQuantity,
  required bool isAddToQuantity,
  required bool useCustomDimensions,
  double? customWidth,
  double? customHeight,
}) {
  final selectedUnit = product.getProductUnit(
    unitUuid: unitUuid,
  );
  final isAreaUnit =
      product.quantityType == 2 && selectedUnit.isAreaUnit;
  final isDimensionalSheet =
      product.quantityType == 2 && !isAreaUnit;

  final quantityInArea = selectedUnit.getQuantityEquivMultiplied(
    index: 1,
    product: product,
    newQuantity: enteredQuantity,
    customWidth:
        isDimensionalSheet
            ? useCustomDimensions
                ? customWidth
                : product.widthDimension
            : null,
    customHeight:
        isDimensionalSheet
            ? useCustomDimensions
                ? customHeight
                : product.heightDimension
            : null,
  );

  final oldStockArea = product.getActualQuantity() ?? 0;
  final newStockArea =
      isAddToQuantity
          ? oldStockArea + quantityInArea
          : quantityInArea;
  final deltaArea = (newStockArea - oldStockArea).abs();

  final areaPerSheet = product.dimensionArea();
  final usesSheetCount =
      product.quantityType == 2 &&
      product.hasDimensions &&
      areaPerSheet > 0;

  return QuantityAdjustment(
    oldStockArea: oldStockArea,
    newStockArea: newStockArea,
    deltaArea: deltaArea,
    areaPerSheet: areaPerSheet,
    rpcQuantityChange:
        usesSheetCount ? deltaArea / areaPerSheet : deltaArea,
    newStoredQuantity:
        usesSheetCount
            ? newStockArea / areaPerSheet
            : newStockArea,
  );
}

/// Builds the item history record for an item quantity edit, the
/// same way the item details "Edit Unit Qtty" dialog does.
///
/// Staff, date, department and uuid are filled in later by
/// `ItemHistoryProvider.createItemHistory`; item name and uuid by
/// `DataProvider.updateProduct`.
ItemHistory buildQuantityAdjustmentHistory({
  required TempProductClass product,
  required String? unitUuid,
  required QuantityAdjustment adjustment,
  required String? comment,
  required int shopId,
}) {
  final isIncrement = adjustment.isIncrement;
  final selectedUnit = product.getProductUnit(
    unitUuid: unitUuid,
  );
  final primaryUnit = product.getProductUnit();

  return ItemHistory(
    primaryUnit: primaryUnit.name,
    unit: selectedUnit.name,
    shopId: shopId,
    title:
        'Item Quantity ${isIncrement ? "Increased" : 'Reduced'}',
    quantityChange: selectedUnit.getQuantityEquivDivided(
      index: 1,
      newQuantity:
          (adjustment.newStockArea - adjustment.oldStockArea),
      product: product,
    ),
    event:
        isIncrement
            ? ItemHistoryEventClass.quantityUpdatedIncrease
            : ItemHistoryEventClass.quantityUpdatedDecrease,
    isManaged: product.isManaged,
    source:
        isIncrement
            ? ItemHistoryEventClass.manualSource
            : ItemHistoryEventClass.productSource,
    destination:
        isIncrement
            ? ItemHistoryEventClass.productDestination
            : ItemHistoryEventClass.manualDestination,
    newValue: formatLargeNumberDouble(
      primaryUnit.getQuantityEquivDivided(
        index: 1,
        newQuantity: adjustment.newStockArea,
        product: product,
      ),
    ),
    desc:
        comment != null && comment.isNotEmpty
            ? comment
            : defaultQuantityAdjustmentDesc,
    isIncreased: isIncrement,
    oldValue: formatLargeNumberDouble(
      primaryUnit.getQuantityEquivDivided(
        index: 1,
        newQuantity: adjustment.oldStockArea,
        product: product,
      ),
    ),
  );
}

/// One item's input in a bulk stock adjustment.
class StockAdjustmentLine {
  final String productUuid;

  /// Shown in skip / failure messages.
  final String itemName;
  final String? unitUuid;

  /// Entered quantity in the selected unit.
  final double enteredQuantity;
  final bool isAddToQuantity;

  /// 2D sheet units only: use [customWidth] / [customHeight]
  /// instead of the item's own dimensions.
  final bool useCustomDimensions;
  final double? customWidth;
  final double? customHeight;

  const StockAdjustmentLine({
    required this.productUuid,
    required this.itemName,
    required this.unitUuid,
    required this.enteredQuantity,
    required this.isAddToQuantity,
    required this.useCustomDimensions,
    this.customWidth,
    this.customHeight,
  });
}

/// Outcome of a bulk stock adjustment, by item name.
class StockAdjustmentResult {
  final List<String> adjusted;

  /// Items left unchanged (no change, or linked to storage).
  final List<String> skipped;

  /// "Item name: reason" for each item that failed.
  final List<String> failed;

  const StockAdjustmentResult({
    required this.adjusted,
    required this.skipped,
    required this.failed,
  });

  bool get hasFailures => failed.isNotEmpty;
}

/// Computes [line] against [product] (see [computeQuantityAdjustment]).
QuantityAdjustment computeLineAdjustment(
  TempProductClass product,
  StockAdjustmentLine line,
) {
  return computeQuantityAdjustment(
    product: product,
    unitUuid: line.unitUuid,
    enteredQuantity: line.enteredQuantity,
    isAddToQuantity: line.isAddToQuantity,
    useCustomDimensions: line.useCustomDimensions,
    customWidth: line.customWidth,
    customHeight: line.customHeight,
  );
}

// ---------------------------------------------------------------
// Bulk stock adjustment: card validation and review
// ---------------------------------------------------------------

const String stockAdjustmentInvalidNumber = 'Enter a valid number.';
const String stockAdjustmentNegative = 'Quantity cannot be negative.';
const String stockAdjustmentAddZero =
    'Enter more than 0, or clear the field to skip.';
const String stockAdjustmentNothingEntered =
    'Enter a quantity for at least one item.';

/// Error for custom 2D dimensions, with the item details edit
/// dialog's rule and messages; null when they are valid.
String? stockAdjustmentDimensionError({
  required TempProductClass product,
  required double? width,
  required double? height,
}) {
  if (width == null ||
      height == null ||
      !width.isFinite ||
      !height.isFinite ||
      width <= 0 ||
      height <= 0 ||
      (product.widthDimension != null &&
          width > product.widthDimension!) ||
      (product.heightDimension != null &&
          height > product.heightDimension!)) {
    return product.hasDimensions
        ? 'Enter positive dimensions no larger than the original slab / sheet.'
        : 'Enter positive Width and Height for this item.';
  }
  return null;
}

/// True when a 2D item needs custom width / height for this edit:
/// a sheet (non area) unit, and either "Enter Dimensions" mode or
/// an item without its own dimensions.
bool stockAdjustmentNeedsDimensions({
  required TempProductClass product,
  required String? unitUuid,
  required bool useCustomDimensions,
}) {
  final unit = product.getProductUnit(unitUuid: unitUuid);
  return product.quantityType == 2 &&
      !unit.isAreaUnit &&
      (useCustomDimensions || !product.hasDimensions);
}

/// What the user entered on one bulk adjustment card.
class StockAdjustmentCardInput {
  final String quantityText;
  final String? unitUuid;
  final bool isAddToQuantity;

  /// 1 = "Enter Whole", 2 = "Enter Dimensions" (2D items).
  final int quantityTypeTemp;
  final String widthText;
  final String heightText;

  const StockAdjustmentCardInput({
    required this.quantityText,
    required this.unitUuid,
    required this.isAddToQuantity,
    this.quantityTypeTemp = 1,
    this.widthText = '',
    this.heightText = '',
  });
}

/// Result of checking one card: a [line] to apply, an [error], or
/// neither (the card is blank and is skipped).
class StockAdjustmentCardCheck {
  final StockAdjustmentLine? line;
  final String? error;

  const StockAdjustmentCardCheck._({this.line, this.error});

  bool get isSkipped => line == null && error == null;
}

double? _parseNumber(String text) =>
    double.tryParse(text.replaceAll(',', '').trim());

/// Checks one bulk adjustment card. A blank quantity skips the item.
StockAdjustmentCardCheck validateStockAdjustmentCard({
  required TempProductClass product,
  required StockAdjustmentCardInput input,
}) {
  final text = input.quantityText.replaceAll(',', '').trim();
  if (text.isEmpty) {
    return const StockAdjustmentCardCheck._();
  }
  final value = double.tryParse(text);
  if (value == null || !value.isFinite) {
    return const StockAdjustmentCardCheck._(
      error: stockAdjustmentInvalidNumber,
    );
  }
  if (value < 0) {
    return const StockAdjustmentCardCheck._(
      error: stockAdjustmentNegative,
    );
  }
  if (input.isAddToQuantity && value == 0) {
    return const StockAdjustmentCardCheck._(
      error: stockAdjustmentAddZero,
    );
  }

  final useCustomDimensions =
      input.quantityTypeTemp == 2 || !product.hasDimensions;
  double? width;
  double? height;
  if (stockAdjustmentNeedsDimensions(
    product: product,
    unitUuid: input.unitUuid,
    useCustomDimensions: input.quantityTypeTemp == 2,
  )) {
    width = _parseNumber(input.widthText);
    height = _parseNumber(input.heightText);
    final dimensionError = stockAdjustmentDimensionError(
      product: product,
      width: width,
      height: height,
    );
    if (dimensionError != null) {
      return StockAdjustmentCardCheck._(error: dimensionError);
    }
  }

  return StockAdjustmentCardCheck._(
    line: StockAdjustmentLine(
      productUuid: product.uuid!,
      itemName: product.name,
      unitUuid: input.unitUuid,
      enteredQuantity: value,
      isAddToQuantity: input.isAddToQuantity,
      useCustomDimensions: useCustomDimensions,
      customWidth: width,
      customHeight: height,
    ),
  );
}

/// All cards checked together when the user presses Proceed.
class StockAdjustmentReview {
  /// Lines that change stock, in card order.
  final List<StockAdjustmentLine> lines;

  /// Card errors by product uuid.
  final Map<String, String> errors;

  /// Lines that leave the item with no stock.
  final int setToZeroCount;

  /// Set when nothing was entered (all cards blank or no change).
  final String? formError;

  const StockAdjustmentReview({
    required this.lines,
    required this.errors,
    required this.setToZeroCount,
    required this.formError,
  });

  bool get hasErrors => errors.isNotEmpty;
}

StockAdjustmentReview reviewStockAdjustmentCards(
  List<({TempProductClass product, StockAdjustmentCardInput input})>
  cards,
) {
  final lines = <StockAdjustmentLine>[];
  final errors = <String, String>{};
  var setToZeroCount = 0;

  for (final card in cards) {
    final check = validateStockAdjustmentCard(
      product: card.product,
      input: card.input,
    );
    if (check.error != null) {
      errors[card.product.uuid!] = check.error!;
      continue;
    }
    final line = check.line;
    if (line == null) continue;

    final adjustment = computeLineAdjustment(card.product, line);
    if (adjustment.isNoChange) continue;

    lines.add(line);
    if (adjustment.newStockArea.abs() < 1e-9) {
      setToZeroCount++;
    }
  }

  return StockAdjustmentReview(
    lines: lines,
    errors: errors,
    setToZeroCount: setToZeroCount,
    formError:
        errors.isEmpty && lines.isEmpty
            ? stockAdjustmentNothingEntered
            : null,
  );
}

// ---------------------------------------------------------------
// Bulk stock adjustment: launcher split
// ---------------------------------------------------------------

/// Selected items split into those that can be adjusted and those
/// whose stock only comes from storage transfers.
class StockAdjustmentSelection {
  final List<TempProductClass> adjustable;
  final List<TempProductClass> linkedToStorage;

  const StockAdjustmentSelection({
    required this.adjustable,
    required this.linkedToStorage,
  });

  bool get allLinked =>
      adjustable.isEmpty && linkedToStorage.isNotEmpty;
}

/// Splits the selection using the live copy of each item ([findLive],
/// falling back to the selected object) and [isLinkedToStorage]
/// (`TempProductClass.isPartOfStorage` in the app). Items selected
/// twice are kept once.
StockAdjustmentSelection splitForStockAdjustment({
  required List<TempProductClass> selected,
  required TempProductClass? Function(String uuid) findLive,
  required bool Function(TempProductClass product) isLinkedToStorage,
}) {
  final adjustable = <TempProductClass>[];
  final linked = <TempProductClass>[];
  final seen = <String>{};

  for (final item in selected) {
    final uuid = item.uuid;
    if (uuid != null && !seen.add(uuid)) continue;
    final live = (uuid != null ? findLive(uuid) : null) ?? item;
    if (isLinkedToStorage(live)) {
      linked.add(live);
    } else {
      adjustable.add(live);
    }
  }

  return StockAdjustmentSelection(
    adjustable: adjustable,
    linkedToStorage: linked,
  );
}

// ---------------------------------------------------------------
// Bulk stock adjustment: execution plan
// ---------------------------------------------------------------

class PlannedStockAdjustment {
  /// Live item the adjustment was computed on.
  final TempProductClass product;
  final StockAdjustmentLine line;
  final QuantityAdjustment adjustment;

  const PlannedStockAdjustment({
    required this.product,
    required this.line,
    required this.adjustment,
  });
}

class StockAdjustmentPlan {
  final List<PlannedStockAdjustment> toApply;
  final List<String> skipped;
  final List<String> failed;

  const StockAdjustmentPlan({
    required this.toApply,
    required this.skipped,
    required this.failed,
  });
}

/// Rechecks every line against the live item just before writing:
/// items that are gone, now linked to storage, lost the selected
/// unit, no longer fit the entered dimensions, or would not change
/// are left out.
StockAdjustmentPlan planStockAdjustments({
  required List<StockAdjustmentLine> lines,
  required TempProductClass? Function(String uuid) findLive,
  required bool Function(TempProductClass product) isLinkedToStorage,
}) {
  final toApply = <PlannedStockAdjustment>[];
  final skipped = <String>[];
  final failed = <String>[];
  final seen = <String>{};

  for (final line in lines) {
    if (!seen.add(line.productUuid)) {
      skipped.add('${line.itemName}: listed more than once');
      continue;
    }
    final live = findLive(line.productUuid);
    if (live == null) {
      failed.add('${line.itemName}: item no longer exists');
      continue;
    }
    final name = live.name;
    if (isLinkedToStorage(live)) {
      skipped.add('$name: linked to storage');
      continue;
    }
    if (line.unitUuid != null &&
        !live.getUnitsList().any(
          (unit) => unit.uuid == line.unitUuid,
        )) {
      failed.add('$name: selected unit no longer exists');
      continue;
    }
    if (stockAdjustmentNeedsDimensions(
      product: live,
      unitUuid: line.unitUuid,
      useCustomDimensions: line.useCustomDimensions,
    )) {
      final dimensionError = stockAdjustmentDimensionError(
        product: live,
        width: line.customWidth,
        height: line.customHeight,
      );
      if (dimensionError != null) {
        failed.add('$name: $dimensionError');
        continue;
      }
    }

    final adjustment = computeLineAdjustment(live, line);
    if (adjustment.isNoChange) {
      skipped.add('$name: no change');
      continue;
    }
    toApply.add(
      PlannedStockAdjustment(
        product: live,
        line: line,
        adjustment: adjustment,
      ),
    );
  }

  return StockAdjustmentPlan(
    toApply: toApply,
    skipped: skipped,
    failed: failed,
  );
}

// ---------------------------------------------------------------
// Bulk stock adjustment: messages
// ---------------------------------------------------------------

String _itemCount(int count) =>
    '$count item${count == 1 ? '' : 's'}';

String allLinkedToStorageMessage(int count) {
  if (count == 1) {
    return 'The selected item is linked to a storage item. '
        'Its stock can only change through storage transfers. '
        'Transfer from storage instead.';
  }
  return 'All $count selected items are linked to a storage item. '
      'Their stock can only change through storage transfers. '
      'Transfer from storage instead.';
}

String linkedToStorageBannerMessage(int count) {
  return '${_itemCount(count)} '
      '${count == 1 ? 'is' : 'are'} linked to storage and will be skipped.';
}

String stockAdjustmentConfirmationMessage({
  required int adjustCount,
  required int setToZeroCount,
  required int skippedLinkedCount,
}) {
  final message = StringBuffer(
    'You are about to adjust stock for ${_itemCount(adjustCount)}.',
  );
  if (setToZeroCount > 0) {
    message.write(
      ' ${_itemCount(setToZeroCount)} will be set to zero.',
    );
  }
  if (skippedLinkedCount > 0) {
    message.write(
      ' $skippedLinkedCount storage-linked '
      'item${skippedLinkedCount == 1 ? '' : 's'} will be skipped.',
    );
  }
  message.write(' Are you sure you want to proceed?');
  return message.toString();
}

({String title, String message}) stockAdjustmentSummary(
  StockAdjustmentResult result,
) {
  final adjusted = result.adjusted.length;
  final failed = result.failed.length;
  final String title;
  if (adjusted > 0) {
    title = failed == 0 ? 'Stock Adjusted' : 'Partial Adjustment';
  } else {
    title =
        failed > 0 ? 'Stock Adjustment Failed' : 'Nothing Adjusted';
  }

  final message = StringBuffer(
    adjusted > 0
        ? 'Adjusted stock for ${_itemCount(adjusted)}.'
        : 'No item was adjusted.',
  );
  if (failed > 0) {
    message.write(
      '\n\nFailed ($failed):\n${result.failed.join('\n')}',
    );
  }
  if (result.skipped.isNotEmpty) {
    message.write(
      '\n\nSkipped (${result.skipped.length}):\n'
      '${result.skipped.join('\n')}',
    );
  }
  return (title: title, message: message.toString());
}
