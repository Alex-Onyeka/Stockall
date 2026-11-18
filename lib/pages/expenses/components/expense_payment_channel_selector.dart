import 'package:flutter/material.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/pages/purchases/components/purchase_payment_channel_selector.dart';

/// Reuses Stockall's existing [PurchasePaymentChannelSelector] and shop
/// custom payment methods for expense payment channels.
class ExpensePaymentChannelSelector extends StatefulWidget {
  final String? initialChannel;
  final ValueChanged<String> onChannelChanged;

  const ExpensePaymentChannelSelector({
    super.key,
    this.initialChannel,
    required this.onChannelChanged,
  });

  @override
  State<ExpensePaymentChannelSelector> createState() =>
      _ExpensePaymentChannelSelectorState();
}

class _ExpensePaymentChannelSelectorState
    extends State<ExpensePaymentChannelSelector> {
  late int _paymentOption;
  String? _selectedBankName;

  @override
  void initState() {
    super.initState();
    _initFromChannel(widget.initialChannel);
  }

  void _initFromChannel(String? channel) {
    final trimmed = channel?.trim();
    if (trimmed == null ||
        trimmed.isEmpty ||
        trimmed == PaymentMethods.cash) {
      _paymentOption = 0;
      _selectedBankName = null;
    } else if (trimmed == PaymentMethods.bank) {
      _paymentOption = 1;
      _selectedBankName = null;
    } else {
      _paymentOption = 1;
      _selectedBankName = trimmed;
    }
  }

  void _emit() {
    widget.onChannelChanged(
      PurchasePaymentChannelSelector.resolvePaymentMethod(
        paymentOption: _paymentOption,
        selectedBankName: _selectedBankName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PurchasePaymentChannelSelector(
      paymentOption: _paymentOption,
      selectedBankName: _selectedBankName,
      onOptionChanged: (option) {
        setState(() {
          _paymentOption = option;
          if (option == 0) {
            _selectedBankName = null;
          }
        });
        _emit();
      },
      onBankSelected: (bankName) {
        setState(() {
          _selectedBankName = bankName;
        });
        _emit();
      },
    );
  }
}
