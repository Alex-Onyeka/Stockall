import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/product_linking_helper.dart';

class DuplicationConfig {
  final DuplicationQuantityMode mode;
  final Map<String, double>? customQuantities;

  DuplicationConfig({
    required this.mode,
    this.customQuantities,
  });
}

/// Prompts the user to select how product quantities should be handled
/// during duplication (Existing quantity, Custom quantity, or Zero quantity).
Future<DuplicationConfig?> promptDuplicationQuantityOptions({
  required BuildContext context,
  required List<TempProductClass> products,
  String? destinationLabel,
}) async {
  final theme = returnTheme(context, listen: false);

  DuplicationQuantityMode? selectedMode;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return DialogTemplate(
        theme: theme,
        title: 'Quantity Options for Duplication',
        message: destinationLabel != null
            ? 'Choose how to initialize product quantities for duplicated products in $destinationLabel.'
            : 'Choose how to initialize product quantities for the duplicated products.',
        action: () {},
        showBottomActionButtons: false,
        widget: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              _DuplicationOptionCard(
              title: 'Option A: Existing Quantity',
              subtitle:
                  'Keep the current quantities for all duplicated products.',
              icon: Icons.inventory_2_rounded,
              color: Colors.blue,
              theme: theme,
              onTap: () {
                selectedMode = DuplicationQuantityMode.existingQuantity;
                Navigator.of(dialogContext).pop();
              },
            ),
            _DuplicationOptionCard(
              title: 'Option B: Custom Quantity',
              subtitle:
                  'Specify a custom starting quantity for each selected product.',
              icon: Icons.edit_note_rounded,
              color: Colors.purple,
              theme: theme,
              onTap: () {
                selectedMode = DuplicationQuantityMode.customQuantity;
                Navigator.of(dialogContext).pop();
              },
            ),
            _DuplicationOptionCard(
              title: 'Option C: Without Quantity (Zero)',
              subtitle:
                  'Duplicate product info only. Newly created products start with 0 quantity.',
              icon: Icons.exposure_zero_rounded,
              color: Colors.teal,
              theme: theme,
              onTap: () {
                selectedMode = DuplicationQuantityMode.zeroQuantity;
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
      ),
    );
    },
  );

  if (selectedMode == null) {
    return null; // User dismissed
  }

  if (selectedMode == DuplicationQuantityMode.customQuantity) {
    if (!context.mounted) return null;
    // Open custom quantity specification screen
    final customQuantities = await showDialog<Map<String, double>>(
      context: context,
      builder: (customContext) {
        return _CustomQuantityDialog(
          products: products,
        );
      },
    );

    if (customQuantities == null) {
      return null; // Canceled custom quantity entry
    }

    return DuplicationConfig(
      mode: DuplicationQuantityMode.customQuantity,
      customQuantities: customQuantities,
    );
  }

  return DuplicationConfig(mode: selectedMode!);
}

class _DuplicationOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final dynamic theme;
  final VoidCallback onTap;

  const _DuplicationOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: theme.mobileTexts.b2.fontSize,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: theme.mobileTexts.b4.fontSize,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomQuantityDialog extends StatefulWidget {
  final List<TempProductClass> products;

  const _CustomQuantityDialog({
    required this.products,
  });

  @override
  State<_CustomQuantityDialog> createState() => _CustomQuantityDialogState();
}

class _CustomQuantityDialogState extends State<_CustomQuantityDialog> {
  final Map<String, TextEditingController> _controllers = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    for (final p in widget.products) {
      final key = p.uuid ?? p.name;
      _controllers[key] = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onConfirm() {
    final Map<String, double> result = {};
    for (final p in widget.products) {
      final key = p.uuid ?? p.name;
      final text = _controllers[key]?.text.trim() ?? '0';
      final cleanText = text.replaceAll(',', '');
      final val = double.tryParse(cleanText);
      if (val == null || val < 0) {
        setState(() {
          _errorMessage = 'Please enter a valid quantity for ${p.name}.';
        });
        return;
      }
      result[p.uuid!] = val;
    }
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context, listen: false);
    final isMobile = screenWidth(context) < mobileScreen;

    return DialogTemplate(
      theme: theme,
      title: 'Specify Custom Quantities',
      message:
          'Set the starting quantity for each product to be created in the destination branch.',
      action: _onConfirm,
      actionButtonText: 'Proceed',
      cancelAction: () => Navigator.of(context).pop(),
      widget: SizedBox(
        width: 500,
        height: isMobile
            ? (screenHeight(context) * 0.55).clamp(260.0, 480.0)
            : 420,
        child: Column(
          children: [
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade700, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 12,
                  children: widget.products.map((p) {
                    final key = p.uuid ?? p.name;
                    final controller = _controllers[key]!;

                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: theme.mobileTexts.b3.fontSize,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Current: ${p.getActualQuantity() ?? 0} ${p.getProductUnit().name}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 110,
                          child: GeneralTextfieldOnly(
                            hint: 'Qty',
                            controller: controller,
                            lines: 1,
                            theme: theme,
                            onChanged: (_) {
                              if (_errorMessage != null) {
                                setState(() => _errorMessage = null);
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
