import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';

class DimensionUnitHelper {
  /// Square meters represented by 1 unit of the given linear dimension unit squared.
  /// E.g. mm -> (0.001)^2 = 1e-6
  ///      cm -> (0.01)^2 = 1e-4
  ///      m  -> (1.0)^2 = 1.0
  ///      in -> (0.0254)^2 = 0.00064516
  ///      ft -> (0.3048)^2 = 0.09290304
  ///      yd -> (0.9144)^2 = 0.83612736
  static double? sqMetersPerDimensionUnit(String unitName) {
    final lower = unitName.toLowerCase().trim();
    if (lower.contains('milli') || lower == 'mm') {
      return 0.000001; // 1e-6
    } else if (lower.contains('centi') || lower == 'cm') {
      return 0.0001; // 1e-4
    } else if (lower.contains('inch') || lower == 'in') {
      return 0.00064516;
    } else if (lower.contains('foot') ||
        lower.contains('feet') ||
        lower == 'ft') {
      return 0.09290304;
    } else if (lower.contains('yard') || lower == 'yd') {
      return 0.83612736;
    } else if (lower.contains('meter') || lower == 'm') {
      return 1.0;
    }
    return null;
  }

  /// Square meters represented by 1 unit of the product base unit.
  /// E.g. mm² -> 1e-6
  ///      cm² -> 1e-4
  ///      m²  -> 1.0
  ///      in² -> 0.00064516
  ///      ft² -> 0.09290304
  ///      yd² -> 0.83612736
  static double? sqMetersPerBaseUnit(String? baseUnit) {
    if (baseUnit == null || baseUnit.trim().isEmpty)
      return null;
    final lower = baseUnit.toLowerCase().trim();
    if (lower.contains('milli') ||
        lower.contains('mm²') ||
        lower.contains('mm2') ||
        lower.contains('sqmm') ||
        lower.contains('sq.mm') ||
        lower.contains('sq mm') ||
        lower == 'mm') {
      return 0.000001; // 1e-6
    } else if (lower.contains('centi') ||
        lower.contains('cm²') ||
        lower.contains('cm2') ||
        lower.contains('sqcm') ||
        lower.contains('sq.cm') ||
        lower.contains('sq cm') ||
        lower == 'cm') {
      return 0.0001; // 1e-4
    } else if (lower.contains('inch') ||
        lower.contains('in²') ||
        lower.contains('in2') ||
        lower.contains('sqin') ||
        lower.contains('sq.in') ||
        lower.contains('sq in') ||
        lower == 'in') {
      return 0.00064516;
    } else if (lower.contains('foot') ||
        lower.contains('feet') ||
        lower.contains('ft²') ||
        lower.contains('ft2') ||
        lower.contains('sqft') ||
        lower.contains('sq.ft') ||
        lower.contains('sq ft') ||
        lower == 'ft') {
      return 0.09290304;
    } else if (lower.contains('yard') ||
        lower.contains('yd²') ||
        lower.contains('yd2') ||
        lower.contains('sqyd') ||
        lower.contains('sq.yd') ||
        lower.contains('sq yd') ||
        lower == 'yd') {
      return 0.83612736;
    } else if (lower.contains('meter') ||
        lower.contains('m²') ||
        lower.contains('m2') ||
        lower.contains('sqm') ||
        lower.contains('sq.m') ||
        (!lower.contains('sq mm') &&
            (lower.contains('sq m') || lower == 'm'))) {
      return 1.0;
    }
    return null;
  }

  /// Whether the base unit represents a discrete sheet/piece unit (e.g. Slab, Sheet, Tile).
  static bool isPieceOrSheetBaseUnit(String? baseUnit) {
    if (baseUnit == null || baseUnit.trim().isEmpty)
      return false;
    final lower = baseUnit.toLowerCase().trim();
    const sheetKeywords = [
      'slab',
      'sheet',
      'tile',
      'piece',
      'pcs',
      'unit',
      'board',
      'panel',
      'roll',
      'plank',
      'block',
    ];
    return sheetKeywords.any((k) => lower.contains(k));
  }

  /// Calculates the area divisor factor needed to convert dimensions in [unitName] into [baseUnit].
  /// Formula: factor = (sqMetersPerBaseUnit) / (sqMetersPerDimensionUnit).
  /// E.g.
  ///   baseUnit = mm², unitName = mm -> factor = 1.0
  ///   baseUnit = cm², unitName = cm -> factor = 1.0
  ///   baseUnit = m²,  unitName = cm -> factor = 10,000.0
  ///   baseUnit = m²,  unitName = mm -> factor = 1,000,000.0
  ///   baseUnit = ft², unitName = in -> factor = 144.0
  ///   baseUnit = Slab (100x200), unitName = cm -> factor = 20,000.0
  static double getPresetConversion(
    String unitName, {
    String? baseUnit,
    double? maxWidth,
    double? maxHeight,
  }) {
    if (isPieceOrSheetBaseUnit(baseUnit) &&
        maxWidth != null &&
        maxHeight != null &&
        maxWidth > 0 &&
        maxHeight > 0) {
      return maxWidth * maxHeight;
    }

    final dimSqM = sqMetersPerDimensionUnit(unitName);
    final baseSqM = sqMetersPerBaseUnit(baseUnit);

    if (dimSqM != null && baseSqM != null) {
      final ratio = baseSqM / dimSqM;
      if ((ratio - ratio.roundToDouble()).abs() < 1e-6) {
        return ratio.roundToDouble();
      }
      return ratio;
    }

    // Default: if base unit is unknown, assume m²
    if (dimSqM != null) {
      final ratio = 1.0 / dimSqM;
      if ((ratio - ratio.roundToDouble()).abs() < 1e-6) {
        return ratio.roundToDouble();
      }
      return ratio;
    }

    return 1.0;
  }

  static String getPresetExplanation(
    String unitName,
    double conversion, {
    String? baseUnit,
    double? maxWidth,
    double? maxHeight,
  }) {
    final bUnit =
        (baseUnit != null && baseUnit.isNotEmpty)
            ? baseUnit
            : 'm² (base unit)';

    if (isPieceOrSheetBaseUnit(baseUnit) &&
        maxWidth != null &&
        maxHeight != null &&
        maxWidth > 0 &&
        maxHeight > 0) {
      return '1 $bUnit = ${formatConversionNumber(maxWidth)} $unitName × ${formatConversionNumber(maxHeight)} $unitName = ${formatConversionNumber(conversion)} $unitName²';
    }

    if (conversion == 1.0) {
      return '1 $unitName × 1 $unitName = 1 $bUnit';
    }

    if (conversion > 1.0) {
      final sqrtVal = math.sqrt(conversion);
      if ((sqrtVal - sqrtVal.roundToDouble()).abs() <
          1e-4) {
        final s = formatConversionNumber(
          sqrtVal.roundToDouble(),
        );
        return '$s $unitName × $s $unitName = ${formatConversionNumber(conversion)} $unitName² per $bUnit';
      }
      return '${formatConversionNumber(conversion)} $unitName² per $bUnit';
    }

    final multiplier = 1.0 / conversion;
    if ((multiplier - multiplier.roundToDouble()).abs() <
        1e-4) {
      final m = formatConversionNumber(
        multiplier.roundToDouble(),
      );
      return '1 $unitName² = $m $bUnit (divisor ${formatConversionNumber(conversion)})';
    }
    return 'Area divisor ${formatConversionNumber(conversion)} into $bUnit';
  }

  static String formatConversionNumber(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    }
    final s = number.toStringAsFixed(6);
    return s
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}

void showDimensionUnitAction({
  required BuildContext context,
  String? initialUnit,
  double? initialConversion,
  String? baseUnit,
  double? maxWidth,
  double? maxHeight,
  required Function(String unit, double conversion) onSave,
  Function()? onClear,
}) {
  final theme = returnTheme(context, listen: false);
  final nameController = TextEditingController(
    text: initialUnit ?? '',
  );

  double startingConversion =
      initialConversion ??
      (initialUnit != null && initialUnit.isNotEmpty
          ? DimensionUnitHelper.getPresetConversion(
            initialUnit,
            baseUnit: baseUnit,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          )
          : DimensionUnitHelper.getPresetConversion(
            'Centimeter(s)',
            baseUnit: baseUnit,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          ));

  final conversionController = TextEditingController(
    text:
        (initialConversion != null && initialConversion > 0)
            ? DimensionUnitHelper.formatConversionNumber(
              initialConversion,
            )
            : (initialUnit != null &&
                initialUnit.isNotEmpty)
            ? DimensionUnitHelper.formatConversionNumber(
              startingConversion,
            )
            : '',
  );

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final unitName =
              nameController.text.trim().isEmpty
                  ? 'unit'
                  : nameController.text.trim();
          final convText =
              conversionController.text
                  .replaceAll(',', '')
                  .trim();
          final convValue =
              double.tryParse(convText) ?? 1.0;
          final effectiveConv =
              convValue > 0 ? convValue : 1.0;

          final sampleW =
              (maxWidth != null && maxWidth > 0)
                  ? maxWidth
                  : 100.0;
          final sampleH =
              (maxHeight != null && maxHeight > 0)
                  ? maxHeight
                  : 200.0;
          final sampleArea = sampleW * sampleH;
          final convertedResult =
              sampleArea / effectiveConv;
          final baseUnitDisplay =
              (baseUnit != null && baseUnit.isNotEmpty)
                  ? baseUnit
                  : 'm² (base unit)';
          final explanation =
              DimensionUnitHelper.getPresetExplanation(
                unitName,
                effectiveConv,
                baseUnit: baseUnit,
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              );

          void handleSave() {
            final name = nameController.text.trim();
            final conv = double.tryParse(
              conversionController.text
                  .replaceAll(',', '')
                  .trim(),
            );
            if (name.isEmpty ||
                conv == null ||
                !conv.isFinite ||
                conv <= 0) {
              showDialog(
                context: context,
                builder: (context) {
                  return InfoAlert(
                    theme: theme,
                    title: 'Invalid Dimension Unit',
                    message:
                        'Please enter a valid unit name and a positive conversion factor.',
                  );
                },
              );
              return;
            }
            onSave(name, conv);
            Navigator.of(dialogContext).pop();
          }

          return DialogTemplate(
            theme: theme,
            title: 'Set Dimension Unit',
            message:
                'Configure unit and conversion for 2D dimensions',
            actionButtonText: 'Save',
            topRightWidget:
                (initialUnit != null ||
                        nameController.text.isNotEmpty)
                    ? TextButton(
                      onPressed: () {
                        onClear?.call();
                        Navigator.of(dialogContext).pop();
                      },
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : null,
            action: () async {
              handleSave();
            },
            widget: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(
                          6,
                        ),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Target Base Unit (Conversion = 1): ',
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              baseUnit != null &&
                                      baseUnit.isNotEmpty
                                  ? baseUnit
                                  : 'Not set (defaults to m²)',
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b4
                                        .fontSize,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: GeneralTextField(
                            title: 'Dimension Unit Name *',
                            hint:
                                'e.g. Centimeter(s), Millimeter(s)',
                            controller: nameController,
                            lines: 1,
                            theme: theme,
                            onChanged: (_) {
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            onTap: () {
                              dimensionUnitsBottomSheet(
                                context,
                                () {
                                  final selected =
                                      returnData(
                                        context: context,
                                        listen: false,
                                      ).selectedDimensionUnit;
                                  if (selected != null) {
                                    nameController.text =
                                        selected;
                                    final preset =
                                        DimensionUnitHelper.getPresetConversion(
                                          selected,
                                          baseUnit:
                                              baseUnit,
                                          maxWidth:
                                              maxWidth,
                                          maxHeight:
                                              maxHeight,
                                        );
                                    conversionController
                                            .text =
                                        DimensionUnitHelper.formatConversionNumber(
                                          preset,
                                        );
                                    setState(() {});
                                  }
                                },
                              );
                            },
                            borderRadius:
                                BorderRadius.circular(5),
                            mouseCursor:
                                SystemMouseCursors.click,
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(
                                    10,
                                    8,
                                    8,
                                    8,
                                  ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      Colors.grey.shade400,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                      5,
                                    ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Select',
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b4
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(
                                    Icons
                                        .keyboard_arrow_down,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    EditCartTextField(
                      title: 'Area Conversion Factor *',
                      hint:
                          'e.g. ${DimensionUnitHelper.formatConversionNumber(DimensionUnitHelper.getPresetConversion('Centimeter(s)', baseUnit: baseUnit, maxWidth: maxWidth, maxHeight: maxHeight))} for $unitName² → $baseUnitDisplay',
                      controller: conversionController,
                      theme: theme,
                      autoFocus: false,
                      onChanged: (_) {
                        setState(() {});
                      },
                      onSubmitted: (_) {
                        handleSave();
                      },
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme
                            .lightModeColor
                            .prColor250
                            .withAlpha(15),
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        border: Border.all(
                          color: theme
                              .lightModeColor
                              .prColor250
                              .withAlpha(40),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calculate_outlined,
                                size: 16,
                                color:
                                    theme
                                        .lightModeColor
                                        .prColor250,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Calculation Preview',
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      theme
                                          .lightModeColor
                                          .prColor250,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Dimensions: ${DimensionUnitHelper.formatConversionNumber(sampleW)} $unitName × ${DimensionUnitHelper.formatConversionNumber(sampleH)} $unitName = ${formatLargeNumberDouble(sampleArea)} $unitName²',
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Area in base unit: ${formatLargeNumberDouble(sampleArea)} ÷ ${formatLargeNumberDouble(effectiveConv)} = ${formatLargeNumberDouble(convertedResult)} $baseUnitDisplay',
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            explanation,
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
