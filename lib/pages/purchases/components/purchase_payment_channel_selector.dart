import 'package:flutter/material.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/components/alert_dialogues/manage_payment_methods_dialog.dart';
import 'package:stockall/main.dart';

/// Reusable Cash / Bank (+ custom bank account) payment channel
/// selector for recording purchase payments.
class PurchasePaymentChannelSelector extends StatelessWidget {
  final int paymentOption; // 0 = Cash, 1 = Bank
  final String? selectedBankName;
  final ValueChanged<int> onOptionChanged;
  final ValueChanged<String?> onBankSelected;

  const PurchasePaymentChannelSelector({
    super.key,
    required this.paymentOption,
    required this.selectedBankName,
    required this.onOptionChanged,
    required this.onBankSelected,
  });

  static String resolvePaymentMethod({
    required int paymentOption,
    String? selectedBankName,
  }) {
    if (paymentOption == 0) return PaymentMethods.cash;
    if (selectedBankName != null && selectedBankName.trim().isNotEmpty) {
      return selectedBankName.trim();
    }
    return PaymentMethods.bank;
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context, listen: false);
    final customMethods =
        returnShopProvider(context: context).getCustomPaymentMethods();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Text(
          'Select Payment Channel',
          style: TextStyle(
            fontSize: theme.mobileTexts.b3.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        _buildOptionTile(
          context: context,
          title: 'Cash',
          subtitle: 'Pay with cash',
          isSelected: paymentOption == 0,
          onTap: () => onOptionChanged(0),
        ),
        _buildOptionTile(
          context: context,
          title:
              paymentOption == 1 && selectedBankName != null
                  ? 'Bank ($selectedBankName)'
                  : 'Bank',
          subtitle: 'Pay via bank transfer or custom channel',
          isSelected: paymentOption == 1,
          onTap: () => onOptionChanged(1),
        ),
        if (paymentOption == 1)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (customMethods.isNotEmpty) ...[
                  Text(
                    'Select Bank Account:',
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: customMethods.map((bMethod) {
                      // Older records saved "Bank (account)".
                      final isSelected = bMethod.matchesLabel(
                        selectedBankName,
                      );
                      return ChoiceChip(
                        avatar: Icon(
                          bMethod.icon,
                          size: 16,
                          color:
                              isSelected
                                  ? Colors.white
                                  : theme.lightModeColor.prColor250,
                        ),
                        label: Text(
                          bMethod.displayName,
                          style: TextStyle(
                            fontSize: theme.mobileTexts.b4.fontSize,
                            color:
                                isSelected ? Colors.white : Colors.black87,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: theme.lightModeColor.prColor250,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? theme.lightModeColor.prColor250
                                    : Colors.grey.shade300,
                          ),
                        ),
                        onSelected: (val) {
                          onBankSelected(val ? bMethod.displayName : null);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: Icon(
                        Icons.add_circle_outline,
                        size: 16,
                        color: theme.lightModeColor.prColor250,
                      ),
                      label: Text(
                        customMethods.isEmpty
                            ? '+ Add Channel'
                            : 'Manage Channels',
                        style: TextStyle(
                          fontSize: theme.mobileTexts.b4.fontSize,
                          color: theme.lightModeColor.prColor250,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => const ManagePaymentMethodsDialog(),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = returnTheme(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: theme.mobileTexts.b4.fontSize,
                          color: theme.lightModeColor.secColor200,
                        ),
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  activeColor: theme.lightModeColor.prColor250,
                  shape: const CircleBorder(),
                  side: BorderSide(
                    width: 1,
                    color: theme.lightModeColor.secColor200,
                  ),
                  value: isSelected,
                  onChanged: (_) => onTap(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
