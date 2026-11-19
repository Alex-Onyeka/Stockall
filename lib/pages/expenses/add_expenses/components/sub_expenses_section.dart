import 'package:flutter/material.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_expenses/sub_expense.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/components/expense_payment_channel_selector.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Sub-expense rows of the expense form: one tile per row, an add
/// button, and the derived total with its per-channel split.
class SubExpensesSection extends StatelessWidget {
  final ThemeProvider theme;
  final List<SubExpense> subExpenses;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onRemove;

  const SubExpensesSection({
    super.key,
    required this.theme,
    required this.subExpenses,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (subExpenses.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.call_split_outlined),
          label: const Text('Add Sub-expense'),
        ),
      );
    }

    final entries = SubExpense.paymentEntriesOf(subExpenses);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Text(
          'Sub-expenses',
          style: TextStyle(
            fontSize: theme.mobileTexts.b3.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        for (var i = 0; i < subExpenses.length; i++)
          _SubExpenseTile(
            theme: theme,
            sub: subExpenses[i],
            onEdit: () => onEdit(i),
            onRemove: () => onRemove(i),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add Another Sub-expense'),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                'Total: ${formatMoneyMid(amount: SubExpense.totalOf(subExpenses), context: context)}',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                entries
                    .map(
                      (e) =>
                          '${e.method}: ${formatMoneyMid(amount: e.amount, context: context)}',
                    )
                    .join(', '),
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubExpenseTile extends StatelessWidget {
  final ThemeProvider theme;
  final SubExpense sub;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _SubExpenseTile({
    required this.theme,
    required this.sub,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final details = [
      if (sub.quantity != null)
        'Qty ${formatLargeNumberDouble(sub.quantity!)}',
      sub.paymentChannel,
    ].join(' · ');
    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onEdit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      sub.name,
                      style: TextStyle(
                        fontSize: theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      details,
                      style: TextStyle(
                        fontSize: theme.mobileTexts.b3.fontSize,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            formatMoneyMid(amount: sub.amount, context: context),
            style: TextStyle(
              fontSize: theme.mobileTexts.b2.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            tooltip: 'Remove',
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: Colors.red.shade400,
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

/// Opens the sub-expense editor: a dialog on desktop, a bottom sheet
/// on mobile. Returns the saved row, or null when cancelled.
Future<SubExpense?> showSubExpenseEditor({
  required BuildContext context,
  required bool isDesktop,
  SubExpense? initial,
}) {
  final editor = _SubExpenseEditor(initial: initial);
  if (isDesktop) {
    return showDialog<SubExpense>(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
              child: editor,
            ),
          ),
    );
  }
  return showModalBottomSheet<SubExpense>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder:
        (sheetContext) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.9,
            ),
            child: editor,
          ),
        ),
  );
}

class _SubExpenseEditor extends StatefulWidget {
  final SubExpense? initial;

  const _SubExpenseEditor({this.initial});

  @override
  State<_SubExpenseEditor> createState() => _SubExpenseEditorState();
}

class _SubExpenseEditorState extends State<_SubExpenseEditor> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _costController = TextEditingController();
  final _quantityController = TextEditingController();
  String _channel = PaymentMethods.cash;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _nameController.text = initial.name;
      _descController.text = initial.description ?? '';
      if (initial.amount > 0) {
        _costController.text = initial.amount.toString();
      }
      if (initial.quantity != null) {
        _quantityController.text = initial.quantity.toString();
      }
      _channel = initial.paymentChannel;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final cost =
        double.tryParse(_costController.text.replaceAll(',', '')) ?? 0;
    if (name.isEmpty || cost <= 0) {
      showDialog(
        context: context,
        builder:
            (_) => InfoAlert(
              theme: returnTheme(context, listen: false),
              title: 'Invalid Sub-expense',
              message:
                  'Sub-expense name cannot be empty and cost must be greater than zero.',
            ),
      );
      return;
    }
    final desc = _descController.text.trim();
    Navigator.of(context).pop(
      SubExpense(
        uuid: widget.initial?.uuid.isNotEmpty == true
            ? widget.initial!.uuid
            : uuidGen(),
        name: name,
        description: desc.isEmpty ? null : desc,
        amount: cost,
        quantity: double.tryParse(
          _quantityController.text.replaceAll(',', ''),
        ),
        paymentChannel: _channel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context, listen: false);
    final isEditing =
        widget.initial != null && widget.initial!.name.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEditing ? 'Edit Sub-expense' : 'Add Sub-expense',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: theme.mobileTexts.h4.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GeneralTextField(
                    title: 'Name',
                    hint: 'e.g. Transportation',
                    controller: _nameController,
                    lines: 1,
                    theme: theme,
                  ),
                  const SizedBox(height: 15),
                  GeneralTextField(
                    title: 'Description (Optional)',
                    hint: 'Enter Sub-expense Description',
                    controller: _descController,
                    lines: 2,
                    theme: theme,
                  ),
                  const SizedBox(height: 15),
                  MoneyTextfield(
                    title: 'Cost (${currencySymbol(context: context)})',
                    hint: 'Enter Cost',
                    controller: _costController,
                    theme: theme,
                  ),
                  const SizedBox(height: 15),
                  EditCartTextField(
                    title: 'Quantity (Optional)',
                    hint: 'Enter Quantity',
                    controller: _quantityController,
                    theme: theme,
                  ),
                  const SizedBox(height: 10),
                  ExpensePaymentChannelSelector(
                    initialChannel: _channel,
                    onChannelChanged: (channel) {
                      _channel = channel;
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          MainButtonP(
            themeProvider: theme,
            text: isEditing ? 'Update Sub-expense' : 'Save Sub-expense',
            action: _save,
          ),
        ],
      ),
    );
  }
}
