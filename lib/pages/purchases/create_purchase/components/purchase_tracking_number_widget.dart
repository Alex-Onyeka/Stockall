import 'package:flutter/material.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/main.dart';

class PurchaseTrackingNumberWidget extends StatefulWidget {
  const PurchaseTrackingNumberWidget({super.key});

  @override
  State<PurchaseTrackingNumberWidget> createState() =>
      _PurchaseTrackingNumberWidgetState();
}

class _PurchaseTrackingNumberWidgetState
    extends State<PurchaseTrackingNumberWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: returnPurchaseActionProvider().trackingNumber ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = returnPurchaseActionProvider(context: context);
    final currentVal = provider.trackingNumber ?? '';
    if (_controller.text != currentVal &&
        _controller.text.trim() != currentVal) {
      _controller.text = currentVal;
    }
    final theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: SizedBox(
        height: 40,
        child: GeneralTextfieldOnly(
          hint: 'Tracking Number (Optional)',
          controller: _controller,
          lines: 1,
          theme: theme,
          autoFocus: false,
          onChanged: (value) {
            returnPurchaseActionProvider().setTrackingNumber(value);
          },
        ),
      ),
    );
  }
}
