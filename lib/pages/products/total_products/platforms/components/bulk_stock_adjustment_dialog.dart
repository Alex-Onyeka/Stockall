import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/components/item_comment_widget.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/stock_adjustment_helper.dart';

/// Entry point for "Stock Adjustment" on the All Items selection.
Future<void> launchBulkStockAdjustment({
  required BuildContext context,
  required Function(bool value) loadingAction,
}) async {
  final theme = returnTheme(context, listen: false);
  final selected = returnData().selectedProducts;

  if (selected.isEmpty) {
    showDialog(
      context: context,
      builder:
          (_) => InfoAlert(
            theme: theme,
            title: 'No Items Selected',
            message:
                'Please select one or more items to adjust their stock.',
          ),
    );
    return;
  }

  final split = splitForStockAdjustment(
    selected: List.of(selected),
    findLive: (uuid) => ProductsFunc().getSingleProduct(uuid: uuid),
    isLinkedToStorage: (product) => product.isPartOfStorage(),
  );

  if (split.allLinked) {
    showDialog(
      context: context,
      builder:
          (_) => InfoAlert(
            theme: theme,
            title: "Can't Adjust Stock",
            message: allLinkedToStorageMessage(
              split.linkedToStorage.length,
            ),
          ),
    );
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return BulkStockAdjustmentDialog(
        adjustable: split.adjustable,
        linkedToStorage: split.linkedToStorage,
        loadingAction: loadingAction,
        parentContext: context,
      );
    },
  );
}

/// One card's editable state.
class _AdjustmentCard {
  final TempProductClass product;
  final TextEditingController quantityController =
      TextEditingController();
  final TextEditingController widthController =
      TextEditingController();
  final TextEditingController heightController =
      TextEditingController();
  String? unitUuid;
  bool isAddToQuantity = true;

  /// 1 = "Enter Whole", 2 = "Enter Dimensions" (2D items).
  int quantityTypeTemp = 1;
  String? error;

  _AdjustmentCard(this.product)
    : unitUuid = product.getPrimaryUnit().uuid;

  ProductUnitsClass get selectedUnit =>
      product.getProductUnit(unitUuid: unitUuid);

  bool get isAreaUnit =>
      product.quantityType == 2 && selectedUnit.isAreaUnit;

  /// Same condition as the item details edit dialog.
  bool get showWholeOrDimensions =>
      product.quantityType == 2 &&
      !isAreaUnit &&
      product.hasDimensions;

  /// Same condition as the item details edit dialog.
  bool get showDimensionFields =>
      product.quantityType == 2 &&
      !isAreaUnit &&
      (quantityTypeTemp == 2 || !product.hasDimensions);

  StockAdjustmentCardInput get input => StockAdjustmentCardInput(
    quantityText: quantityController.text,
    unitUuid: unitUuid,
    isAddToQuantity: isAddToQuantity,
    quantityTypeTemp: quantityTypeTemp,
    widthText: widthController.text,
    heightText: heightController.text,
  );

  void dispose() {
    quantityController.dispose();
    widthController.dispose();
    heightController.dispose();
  }
}

class BulkStockAdjustmentDialog extends StatefulWidget {
  final List<TempProductClass> adjustable;
  final List<TempProductClass> linkedToStorage;
  final Function(bool value) loadingAction;

  /// The All Items page, used for the result alert once this
  /// dialog is closed.
  final BuildContext parentContext;

  const BulkStockAdjustmentDialog({
    super.key,
    required this.adjustable,
    required this.linkedToStorage,
    required this.loadingAction,
    required this.parentContext,
  });

  @override
  State<BulkStockAdjustmentDialog> createState() =>
      _BulkStockAdjustmentDialogState();
}

class _BulkStockAdjustmentDialogState
    extends State<BulkStockAdjustmentDialog> {
  late final List<_AdjustmentCard> _cards =
      widget.adjustable.map(_AdjustmentCard.new).toList();

  // Disposed by ItemCommentWidget.
  final TextEditingController _commentController =
      TextEditingController();

  @override
  void dispose() {
    for (final card in _cards) {
      card.dispose();
    }
    super.dispose();
  }

  void _proceed() {
    final theme = returnTheme(context, listen: false);
    final review = reviewStockAdjustmentCards([
      for (final card in _cards)
        (product: card.product, input: card.input),
    ]);

    setState(() {
      for (final card in _cards) {
        card.error = review.errors[card.product.uuid];
      }
    });
    if (review.hasErrors) return;

    if (review.formError != null) {
      showDialog(
        context: context,
        builder:
            (_) => InfoAlert(
              theme: theme,
              title: 'Nothing to Adjust',
              message: review.formError!,
            ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (confirmContext) {
        return ConfirmationAlert(
          theme: theme,
          title: 'Adjust Stock?',
          message: stockAdjustmentConfirmationMessage(
            adjustCount: review.lines.length,
            setToZeroCount: review.setToZeroCount,
            skippedLinkedCount: widget.linkedToStorage.length,
          ),
          action: () {
            Navigator.of(confirmContext).pop();
            _execute(review.lines);
          },
        );
      },
    );
  }

  Future<void> _execute(List<StockAdjustmentLine> lines) async {
    final theme = returnTheme(context, listen: false);
    final comment = _commentController.text;
    final parentContext = widget.parentContext;
    final loadingAction = widget.loadingAction;

    Navigator.of(context).pop();
    loadingAction(true);

    final result = await returnData().adjustProductsQuantity(
      lines,
      comment: comment,
    );

    if (!parentContext.mounted) return;
    loadingAction(false);

    final summary = stockAdjustmentSummary(result);
    showDialog(
      context: parentContext,
      builder:
          (_) => InfoAlert(
            theme: theme,
            title: summary.title,
            message: summary.message,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context, listen: false);
    final isMobile = screenWidth(context) < mobileScreen;

    return DialogTemplate(
      theme: theme,
      title: 'Stock Adjustment',
      message:
          'Enter the new quantity for each item. Leave blank to skip.',
      action: _proceed,
      actionButtonText: 'Proceed',
      cancelAction: () => Navigator.of(context).pop(),
      widget: SizedBox(
        width: 500,
        height:
            isMobile
                ? (screenHeight(context) * 0.6).clamp(300.0, 520.0)
                : 460,
        child: Column(
          children: [
            if (widget.linkedToStorage.isNotEmpty)
              _LinkedBanner(
                theme: theme,
                count: widget.linkedToStorage.length,
              ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 12,
                  children: [
                    for (final card in _cards)
                      _AdjustmentCardView(
                        theme: theme,
                        card: card,
                        onChanged: () => setState(() {}),
                      ),
                    for (final product in widget.linkedToStorage)
                      _LinkedCardView(
                        theme: theme,
                        product: product,
                      ),
                    ItemCommentWidget(
                      commentController: _commentController,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _currentStockText(
  TempProductClass product,
  ProductUnitsClass unit,
) {
  if (product.getActualQuantity() == null) {
    return 'Current: Not set';
  }
  final quantity = unit.getQuantityEquivDivided(
    index: 1,
    product: product,
  );
  return 'Current: ${formatLargeNumberDouble(quantity)} ${unit.name}';
}

class _LinkedBanner extends StatelessWidget {
  final ThemeProvider theme;
  final int count;

  const _LinkedBanner({required this.theme, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.orange.shade800,
            size: 17,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              linkedToStorageBannerMessage(count),
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdjustmentCardView extends StatelessWidget {
  final ThemeProvider theme;
  final _AdjustmentCard card;
  final VoidCallback onChanged;

  const _AdjustmentCardView({
    required this.theme,
    required this.card,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final product = card.product;
    final selectedUnit = card.selectedUnit;
    final units = product.getUnitsList();
    final hasError = card.error != null;
    final dimensionLabel =
        product.dimensionUnit ?? selectedUnit.name;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasError ? Colors.red.shade300 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: theme.mobileTexts.b3.fontSize,
                  ),
                ),
              ),
              Text(
                _currentStockText(product, selectedUnit),
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                flex: 3,
                child: _NumberField(
                  theme: theme,
                  controller: card.quantityController,
                  hint: '${selectedUnit.name} Quantity',
                  hasError: hasError,
                  onChanged: () {
                    if (card.error != null) {
                      card.error = null;
                      onChanged();
                    }
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value:
                          units.any((u) => u.uuid == card.unitUuid)
                              ? card.unitUuid
                              : units.first.uuid,
                      isExpanded: true,
                      items:
                          units.map((u) {
                            return DropdownMenuItem<String>(
                              value: u.uuid,
                              child: Text(
                                u.name,
                                style: TextStyle(
                                  fontSize:
                                      theme.mobileTexts.b4.fontSize,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (newUuid) {
                        if (newUuid == null ||
                            newUuid == card.unitUuid) {
                          return;
                        }
                        // Keeps the typed number, as the item
                        // details edit dialog does.
                        card.unitUuid = newUuid;
                        if (card.isAreaUnit) {
                          card.quantityTypeTemp = 1;
                          card.widthController.clear();
                          card.heightController.clear();
                        }
                        card.error = null;
                        onChanged();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 5,
            children: [
              _ChoiceOption(
                theme: theme,
                text: 'Add to Quantity',
                isSelected: card.isAddToQuantity,
                onTap: () {
                  card.isAddToQuantity = true;
                  card.error = null;
                  onChanged();
                },
              ),
              _ChoiceOption(
                theme: theme,
                text: 'Replace Quantity',
                isSelected: !card.isAddToQuantity,
                onTap: () {
                  card.isAddToQuantity = false;
                  card.error = null;
                  onChanged();
                },
              ),
            ],
          ),
          if (card.showWholeOrDimensions)
            Wrap(
              spacing: 5,
              children: [
                _ChoiceOption(
                  theme: theme,
                  text: 'Enter Whole',
                  isSelected: card.quantityTypeTemp == 1,
                  onTap: () {
                    card.quantityTypeTemp = 1;
                    card.widthController.clear();
                    card.heightController.clear();
                    card.error = null;
                    onChanged();
                  },
                ),
                _ChoiceOption(
                  theme: theme,
                  text: 'Enter Dimensions',
                  isSelected: card.quantityTypeTemp == 2,
                  onTap: () {
                    card.quantityTypeTemp = 2;
                    card.error = null;
                    onChanged();
                  },
                ),
              ],
            ),
          if (card.showDimensionFields)
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: _NumberField(
                    theme: theme,
                    controller: card.widthController,
                    hint:
                        product.widthDimension != null
                            ? '$dimensionLabel Width (max ${formatDimension(product.widthDimension!)})'
                            : '$dimensionLabel Width',
                    hasError: hasError,
                    onChanged: () {
                      if (card.error != null) {
                        card.error = null;
                        onChanged();
                      }
                    },
                  ),
                ),
                Expanded(
                  child: _NumberField(
                    theme: theme,
                    controller: card.heightController,
                    hint:
                        product.heightDimension != null
                            ? '$dimensionLabel Height (max ${formatDimension(product.heightDimension!)})'
                            : '$dimensionLabel Height',
                    hasError: hasError,
                    onChanged: () {
                      if (card.error != null) {
                        card.error = null;
                        onChanged();
                      }
                    },
                  ),
                ),
              ],
            ),
          if (hasError)
            Text(
              card.error!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: theme.mobileTexts.b4.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class _LinkedCardView extends StatelessWidget {
  final ThemeProvider theme;
  final TempProductClass product;

  const _LinkedCardView({required this.theme, required this.product});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: theme.mobileTexts.b3.fontSize,
                    ),
                  ),
                ),
                Text(
                  _currentStockText(product, product.getPrimaryUnit()),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              spacing: 6,
              children: [
                Icon(
                  Icons.link_rounded,
                  size: 16,
                  color: Colors.grey.shade800,
                ),
                Expanded(
                  child: Text(
                    'Linked to storage: transfer from storage instead.',
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b4.fontSize,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final ThemeProvider theme;
  final TextEditingController controller;
  final String hint;
  final bool hasError;
  final VoidCallback onChanged;

  const _NumberField({
    required this.theme,
    required this.controller,
    required this.hint,
    required this.hasError,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: hasError ? Colors.red.shade400 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        style: TextStyle(
          fontSize: theme.mobileTexts.b4.fontSize,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: theme.mobileTexts.b4.fontSize,
            fontWeight: FontWeight.normal,
            color: Colors.grey.shade400,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }
}

/// Check-circle option, drawn like the item details edit dialog's.
class _ChoiceOption extends StatelessWidget {
  final ThemeProvider theme;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceOption({
    required this.theme,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        !isSelected ? Colors.grey : Colors.transparent,
                  ),
                  color:
                      isSelected
                          ? theme.lightModeColor.prColor250
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  size: 14,
                  color: Colors.white,
                  Icons.check,
                ),
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
