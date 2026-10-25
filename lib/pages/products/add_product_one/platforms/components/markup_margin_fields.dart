import 'package:flutter/material.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class MarkupMarginFields extends StatefulWidget {
  final TextEditingController sellingPriceController;
  final TextEditingController? costPriceController;
  final double? fixedCostPrice;
  final ThemeProvider theme;

  const MarkupMarginFields({
    super.key,
    required this.sellingPriceController,
    this.costPriceController,
    this.fixedCostPrice,
    required this.theme,
  });

  @override
  State<MarkupMarginFields> createState() =>
      _MarkupMarginFieldsState();
}

class _MarkupMarginFieldsState
    extends State<MarkupMarginFields> {
  late final TextEditingController _markupController;
  late final TextEditingController _marginController;
  late final FocusNode _markupFocusNode;
  late final FocusNode _marginFocusNode;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _markupController = TextEditingController();
    _marginController = TextEditingController();
    _markupFocusNode = FocusNode();
    _marginFocusNode = FocusNode();

    _updateFromSellingPrice();

    widget.sellingPriceController.addListener(
      _onSellingPriceChanged,
    );
    widget.costPriceController?.addListener(
      _onCostPriceChanged,
    );
  }

  @override
  void didUpdateWidget(
    covariant MarkupMarginFields oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sellingPriceController !=
        widget.sellingPriceController) {
      oldWidget.sellingPriceController.removeListener(
        _onSellingPriceChanged,
      );
      widget.sellingPriceController.addListener(
        _onSellingPriceChanged,
      );
    }
    if (oldWidget.costPriceController !=
        widget.costPriceController) {
      oldWidget.costPriceController?.removeListener(
        _onCostPriceChanged,
      );
      widget.costPriceController?.addListener(
        _onCostPriceChanged,
      );
    }
    if (oldWidget.fixedCostPrice != widget.fixedCostPrice) {
      _updateFromSellingPrice();
    }
  }

  @override
  void dispose() {
    widget.sellingPriceController.removeListener(
      _onSellingPriceChanged,
    );
    widget.costPriceController?.removeListener(
      _onCostPriceChanged,
    );
    _markupController.dispose();
    _marginController.dispose();
    _markupFocusNode.dispose();
    _marginFocusNode.dispose();
    super.dispose();
  }

  double? _getCostPrice() {
    if (widget.fixedCostPrice != null) {
      return widget.fixedCostPrice;
    }
    if (widget.costPriceController != null) {
      final text =
          widget.costPriceController!.text
              .replaceAll(',', '')
              .trim();
      if (text.isEmpty) return null;
      return double.tryParse(text);
    }
    return null;
  }

  void _onSellingPriceChanged() {
    if (_isUpdating) return;
    if (_markupFocusNode.hasFocus ||
        _marginFocusNode.hasFocus)
      return;
    _updateFromSellingPrice();
  }

  void _onCostPriceChanged() {
    if (_isUpdating) return;
    setState(() {
      _updateFromSellingPrice();
    });
  }

  void _updateFromSellingPrice() {
    final cost = _getCostPrice();
    if (cost == null || cost <= 0) {
      _isUpdating = true;
      _markupController.text = '';
      _marginController.text = '';
      _isUpdating = false;
      return;
    }

    final sellingText =
        widget.sellingPriceController.text
            .replaceAll(',', '')
            .trim();
    if (sellingText.isEmpty) {
      _isUpdating = true;
      _markupController.text = '';
      _marginController.text = '';
      _isUpdating = false;
      return;
    }

    final sp = double.tryParse(sellingText);
    if (sp == null) {
      _isUpdating = true;
      _markupController.text = '';
      _marginController.text = '';
      _isUpdating = false;
      return;
    }

    final markup = calculateMarkup(
      costPrice: cost,
      sellingPrice: sp,
    );
    final margin = calculateMargin(
      costPrice: cost,
      sellingPrice: sp,
    );

    _isUpdating = true;
    _markupController.text =
        markup != null ? formatPercentage(markup) : '';
    _marginController.text =
        margin != null ? formatPercentage(margin) : '';
    _isUpdating = false;
  }

  void _onMarkupChanged(String value) {
    if (_isUpdating) return;
    final cost = _getCostPrice();
    if (cost == null || cost <= 0) return;

    final trimmed = value.trim();
    if (trimmed.isEmpty ||
        trimmed == '-' ||
        trimmed == '.') {
      _isUpdating = true;
      _marginController.text = '';
      _isUpdating = false;
      return;
    }

    final markup = double.tryParse(trimmed);
    if (markup == null) return;

    final sp = calculateSellingPriceFromMarkup(
      costPrice: cost,
      markup: markup,
    );
    if (sp == null) return;

    final margin = calculateMargin(
      costPrice: cost,
      sellingPrice: sp,
    );

    _isUpdating = true;
    widget
        .sellingPriceController
        .text = _formatSellingPrice(sp);
    _marginController.text =
        margin != null ? formatPercentage(margin) : '';
    _isUpdating = false;
  }

  void _onMarginChanged(String value) {
    if (_isUpdating) return;
    final cost = _getCostPrice();
    if (cost == null || cost <= 0) return;

    final trimmed = value.trim();
    if (trimmed.isEmpty ||
        trimmed == '-' ||
        trimmed == '.') {
      _isUpdating = true;
      _markupController.text = '';
      _isUpdating = false;
      return;
    }

    final margin = double.tryParse(trimmed);
    if (margin == null || margin >= 100) return;

    final sp = calculateSellingPriceFromMargin(
      costPrice: cost,
      margin: margin,
    );
    if (sp == null) return;

    final markup = calculateMarkup(
      costPrice: cost,
      sellingPrice: sp,
    );

    _isUpdating = true;
    widget
        .sellingPriceController
        .text = _formatSellingPrice(sp);
    _markupController.text =
        markup != null ? formatPercentage(markup) : '';
    _isUpdating = false;
  }

  String _formatSellingPrice(double value) {
    if (value.isNaN || value.isInfinite || value < 0)
      return '0';
    final rounded = double.parse(value.toStringAsFixed(2));
    if (rounded == rounded.roundToDouble()) {
      return rounded.toInt().toString();
    }
    return rounded.toString();
  }

  Widget _buildField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: widget.theme.mobileTexts.b4.fontSize,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          focusNode: focusNode,
          controller: controller,
          onTap: () {
            if (returnShopProvider().isOnScreenKeyboardOn()) {
              showOnScreenKeyboard();
            }
          },
          onChanged: (val) {
            onChanged(val);
            setState(() {});
          },
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          autocorrect: false,
          enableSuggestions: false,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.normal,
            color: Colors.grey.shade800,
          ),
          decoration: InputDecoration(
            isCollapsed: true,
            suffixIcon: const Padding(
              padding: EdgeInsets.only(right: 8, left: 2),
              child: Center(
                widthFactor: 1.0,
                child: Text(
                  '%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.normal,
              fontSize: 11.5,
            ),
            hintText: hint,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade400,
                width: 0.8,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.theme.lightModeColor.prColor300,
                width: 1.1,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }

  bool isOpen = false;
  @override
  Widget build(BuildContext context) {
    final cost = _getCostPrice();
    if (cost == null || cost <= 0) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              isOpen = !isOpen;
            });
          },
          mouseCursor: SystemMouseCursors.click,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            spacing: 5,
            children: [
              Text(
                style: TextStyle(
                  fontSize: widget.theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                isOpen ? '' : 'Markup/Margin',
              ),
              Icon(
                isOpen
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
            ],
          ),
        ),
        Visibility(
          visible: isOpen,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildField(
                    title: 'Markup (%)',
                    hint: '0',
                    controller: _markupController,
                    focusNode: _markupFocusNode,
                    onChanged: _onMarkupChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    title: 'Margin (%)',
                    hint: '0',
                    controller: _marginController,
                    focusNode: _marginFocusNode,
                    onChanged: _onMarginChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
