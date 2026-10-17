import 'package:flutter/material.dart';

// Shared copies of the Items Report's filter fields, for the report
// tables.

/// Parses a typed amount; thousand separators are ignored.
double? reportParseNumber(String v) =>
    double.tryParse(v.replaceAll(',', '').trim());

/// Small grey caption above a filter field.
class ReportLabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final double width;

  const ReportLabeledField({
    super.key,
    required this.label,
    required this.child,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class ReportNumField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  /// Allows a minus sign, e.g. for loss amounts.
  final bool allowNegative;

  const ReportNumField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.allowNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.numberWithOptions(
          decimal: true,
          signed: allowNegative,
        ),
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

/// Min / Max pair. [errorText] is shown under the fields.
class ReportRangeFields extends StatelessWidget {
  final String label;
  final TextEditingController minController;
  final TextEditingController maxController;
  final void Function(double? min, double? max) onChange;
  final bool allowNegative;
  final String? errorText;
  final double width;

  const ReportRangeFields({
    super.key,
    required this.label,
    required this.minController,
    required this.maxController,
    required this.onChange,
    this.allowNegative = false,
    this.errorText,
    this.width = 240,
  });

  @override
  Widget build(BuildContext context) {
    void emit() => onChange(
      reportParseNumber(minController.text),
      reportParseNumber(maxController.text),
    );
    return ReportLabeledField(
      label: label,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Row(
            spacing: 6,
            children: [
              Expanded(
                child: ReportNumField(
                  controller: minController,
                  hint: 'Min',
                  allowNegative: allowNegative,
                  onChanged: (_) => emit(),
                ),
              ),
              Expanded(
                child: ReportNumField(
                  controller: maxController,
                  hint: 'Max',
                  allowNegative: allowNegative,
                  onChanged: (_) => emit(),
                ),
              ),
            ],
          ),
          if (errorText != null)
            Text(
              errorText!,
              style: TextStyle(
                fontSize: 10,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
