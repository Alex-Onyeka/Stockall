import 'package:flutter/material.dart';
import 'package:stockall/classes/payment_entry/payment_method.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class ManagePaymentMethodsDialog extends StatefulWidget {
  const ManagePaymentMethodsDialog({super.key});

  @override
  State<ManagePaymentMethodsDialog> createState() =>
      _ManagePaymentMethodsDialogState();
}

class _ManagePaymentMethodsDialogState
    extends State<ManagePaymentMethodsDialog> {
  int _selectedType = PaymentChannelType.bank;
  final TextEditingController _bankNameController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _accountNameController =
      TextEditingController();
  final TextEditingController _noteController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addMethod() async {
    final name = _bankNameController.text.trim();
    if (name.isEmpty) return;

    final accNum = _accountNumberController.text.trim();
    final accName = _accountNameController.text.trim();
    final note = _noteController.text.trim();

    setState(() => _isLoading = true);
    await returnShopProvider().addCustomPaymentMethod(
      PaymentMethod(
        bankName: name,
        accountNumber: accNum.isNotEmpty ? accNum : null,
        accountName: accName.isNotEmpty ? accName : null,
        type: _selectedType,
        note: note.isNotEmpty ? note : null,
      ),
    );
    _bankNameController.clear();
    _accountNumberController.clear();
    _accountNameController.clear();
    _noteController.clear();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeMethod(String uuid) async {
    setState(() => _isLoading = true);
    await returnShopProvider().removeCustomPaymentMethod(
      uuid,
    );
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateMethod(PaymentMethod method) async {
    setState(() => _isLoading = true);
    await returnShopProvider().updateCustomPaymentMethod(
      method,
    );
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTypeSelector({
    required int selectedType,
    required ValueChanged<int> onSelected,
    required ThemeProvider theme,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children:
          [
            PaymentChannelType.bank,
            PaymentChannelType.pos,
            PaymentChannelType.others,
          ].map((type) {
            final isSelected = selectedType == type;
            final label = PaymentChannelType.getLabel(type);
            final icon = PaymentChannelType.getIcon(type);
            return ChoiceChip(
              avatar: Icon(
                icon,
                size: 16,
                color:
                    isSelected
                        ? Colors.white
                        : theme.lightModeColor.prColor250,
              ),
              label: Text(
                label,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  color:
                      isSelected
                          ? Colors.white
                          : Colors.black87,
                  fontWeight:
                      isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor:
                  theme.lightModeColor.prColor250,
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color:
                      isSelected
                          ? theme.lightModeColor.prColor250
                          : Colors.grey.shade300,
                ),
              ),
              onSelected: (_) => onSelected(type),
              mouseCursor: SystemMouseCursors.click,
            );
          }).toList(),
    );
  }

  Widget _buildFields({
    required int type,
    required TextEditingController nameController,
    required TextEditingController accountNumberController,
    required TextEditingController accountNameController,
    required TextEditingController noteController,
    required ThemeProvider theme,
  }) {
    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(
        color: theme.lightModeColor.prColor250,
      ),
    );

    InputDecoration inputDeco({
      required String labelText,
      required String hintText,
    }) {
      return InputDecoration(
        isDense: true,
        hintText: hintText,
        labelText: labelText,
        hintStyle: TextStyle(
          fontSize: theme.mobileTexts.b4.fontSize,
          color: Colors.grey.shade500,
        ),
        labelStyle: TextStyle(
          fontSize: theme.mobileTexts.b3.fontSize,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: outlineBorder,
        enabledBorder: outlineBorder,
        focusedBorder: focusedBorder,
      );
    }

    if (type == PaymentChannelType.bank) {
      // 1: Bank -> Bank Name, Account Number, Account Name
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.bold,
            ),
            decoration: inputDeco(
              labelText: 'Bank Name *',
              hintText:
                  'e.g. Zenith Bank, GTBank, First Bank',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: accountNumberController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: inputDeco(
                    labelText: 'Account Number (Optional)',
                    hintText: 'e.g. 1029384756',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: accountNameController,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: inputDeco(
                    labelText: 'Account Name (Optional)',
                    hintText: 'e.g. Acme Ltd',
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (type == PaymentChannelType.pos) {
      // 1: POS -> Bank/Provider Name, Account Number, Account Name
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.bold,
            ),
            decoration: inputDeco(
              labelText: 'Bank / Provider Name *',
              hintText: 'e.g. Moniepoint, OPay, Zenith POS',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: accountNumberController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: inputDeco(
                    labelText:
                        'Account / Terminal No. (Optional)',
                    hintText:
                        'e.g. 1029384756 or Terminal ID',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: accountNameController,
                  textCapitalization:
                      TextCapitalization.words,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: inputDeco(
                    labelText: 'Account Name (Optional)',
                    hintText: 'e.g. Store POS, Acme Ltd',
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // 2: Others -> Name, Others (text field)
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.bold,
            ),
            decoration: inputDeco(
              labelText: 'Name *',
              hintText:
                  'e.g. PayPal, Store Credit, Cheque, Transfer',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: noteController,
            textCapitalization:
                TextCapitalization.sentences,
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.bold,
            ),
            decoration: inputDeco(
              labelText: 'Others (Optional)',
              hintText:
                  'e.g. Reference, instruction, or note',
            ),
          ),
        ],
      );
    }
  }

  Widget _buildSubtitle(
    PaymentMethod method,
    ThemeProvider theme,
  ) {
    String text = '';
    if (method.type == PaymentChannelType.bank) {
      final parts = [
        if (method.accountNumber?.isNotEmpty == true)
          'Acc: ${method.accountNumber}',
        if (method.accountName?.isNotEmpty == true)
          method.accountName!,
      ];
      text = parts.join(' • ');
    } else if (method.type == PaymentChannelType.pos) {
      final parts = [
        if (method.accountNumber?.isNotEmpty == true)
          'Acc/Term: ${method.accountNumber}',
        if (method.accountName?.isNotEmpty == true)
          method.accountName!,
      ];
      text = parts.join(' • ');
    } else {
      final parts = [
        if (method.note?.isNotEmpty == true) method.note!,
        if (method.accountNumber?.isNotEmpty == true)
          method.accountNumber!,
      ];
      text = parts.join(' • ');
    }

    if (text.isNotEmpty) {
      return Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: theme.mobileTexts.b4.fontSize,
          color: Colors.grey.shade600,
        ),
      );
    }
    return Text(
      'Not Set',
      style: TextStyle(
        fontStyle: FontStyle.italic,
        fontSize: theme.mobileTexts.b4.fontSize,
        color: Colors.red.shade300,
      ),
    );
  }

  void _showEditDialog(PaymentMethod method) {
    final theme = returnTheme(context, listen: false);
    int editType = method.type;
    final editNameController = TextEditingController(
      text: method.bankName,
    );
    final editAccountNumberController =
        TextEditingController(
          text: method.accountNumber ?? '',
        );
    final editAccountNameController = TextEditingController(
      text: method.accountName ?? '',
    );
    final editNoteController = TextEditingController(
      text: method.note ?? '',
    );

    showDialog(
      context: context,
      builder: (editDialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return DialogTemplate(
              theme: theme,
              title: 'Update Payment Channel',
              message:
                  'Modify the details of this payment channel.',
              actionButtonText: 'Update',
              action: () {
                final newName =
                    editNameController.text.trim();
                if (newName.isEmpty) return;
                final newAccNum =
                    editAccountNumberController.text.trim();
                final newAccName =
                    editAccountNameController.text.trim();
                final newNote =
                    editNoteController.text.trim();

                showDialog(
                  context: editDialogContext,
                  builder: (confirmContext) {
                    return ConfirmationAlert(
                      theme: theme,
                      title: 'Update Payment Channel',
                      message:
                          'You are about to Update a Payment Channel. Are you sure you want to Proceed?',
                      action: () async {
                        Navigator.of(confirmContext).pop();
                        Navigator.of(
                          editDialogContext,
                        ).pop();

                        final updated = method.copyWith(
                          bankName: newName,
                          accountNumber:
                              newAccNum.isNotEmpty
                                  ? newAccNum
                                  : null,
                          accountName:
                              newAccName.isNotEmpty
                                  ? newAccName
                                  : null,
                          type: editType,
                          note:
                              newNote.isNotEmpty
                                  ? newNote
                                  : null,
                        );

                        await _updateMethod(updated);
                      },
                    );
                  },
                );
              },
              widget: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Channel Type:',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildTypeSelector(
                      selectedType: editType,
                      theme: theme,
                      onSelected: (val) {
                        setDialogState(() {
                          editType = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFields(
                      type: editType,
                      nameController: editNameController,
                      accountNumberController:
                          editAccountNumberController,
                      accountNameController:
                          editAccountNameController,
                      noteController: editNoteController,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    final shopProvider = returnShopProvider(
      context: context,
      listen: true,
    );
    final methods = shopProvider.getCustomPaymentMethods();

    String addButtonText;
    if (_selectedType == PaymentChannelType.bank) {
      addButtonText = '+ Add Bank';
    } else if (_selectedType == PaymentChannelType.pos) {
      addButtonText = '+ Add POS Machine';
    } else {
      addButtonText = '+ Add Payment Channel';
    }

    return DialogTemplate(
      theme: theme,
      title: 'Payment Channels',
      message:
          'Configure your bank accounts, POS terminals, and other payment channels.',
      showBottomActionButtons: false,
      action: () {},
      widget: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Channel Type:',
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            _buildTypeSelector(
              selectedType: _selectedType,
              theme: theme,
              onSelected: (val) {
                setState(() {
                  _selectedType = val;
                });
              },
            ),
            const SizedBox(height: 12),
            _buildFields(
              type: _selectedType,
              nameController: _bankNameController,
              accountNumberController:
                  _accountNumberController,
              accountNameController: _accountNameController,
              noteController: _noteController,
              theme: theme,
            ),
            const SizedBox(height: 12),
            MainButtonP(
              themeProvider: theme,
              text: _isLoading ? '...' : addButtonText,
              action:
                  _isLoading
                      ? null
                      : () {
                        final name =
                            _bankNameController.text.trim();
                        if (name.isEmpty) return;
                        showDialog(
                          context: context,
                          builder: (confirmContext) {
                            return ConfirmationAlert(
                              theme: theme,
                              message:
                                  'You are about to Create a new Payment Channel. Are you sure you want to Proceed?',
                              title: 'Add Payment Channel',
                              action: () {
                                Navigator.of(
                                  confirmContext,
                                ).pop();
                                _addMethod();
                              },
                            );
                          },
                        );
                      },
            ),
            const SizedBox(height: 16),
            Text(
              'Active Payment Channels:',
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(
                maxHeight: 240,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child:
                  methods.isEmpty
                      ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No custom payment channels configured yet.\nThe app currently uses the default options.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      )
                      : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (
                              int i = 0;
                              i < methods.length;
                              i++
                            ) ...[
                              if (i > 0)
                                Divider(
                                  height: 1,
                                  color:
                                      Colors.grey.shade200,
                                ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.all(
                                            6,
                                          ),
                                      decoration: BoxDecoration(
                                        color: theme
                                            .lightModeColor
                                            .prColor250
                                            .withValues(
                                              alpha: 0.1,
                                            ),
                                        borderRadius:
                                            BorderRadius.circular(
                                              6,
                                            ),
                                      ),
                                      child: Icon(
                                        methods[i].icon,
                                        size: 18,
                                        color:
                                            theme
                                                .lightModeColor
                                                .prColor250,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        mainAxisSize:
                                            MainAxisSize
                                                .min,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  methods[i]
                                                      .bankName,
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b3.fontSize,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                                  overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal:
                                                      6,
                                                  vertical:
                                                      2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade200,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        4,
                                                      ),
                                                ),
                                                child: Text(
                                                  methods[i]
                                                      .typeLabel,
                                                  style: TextStyle(
                                                    fontSize:
                                                        10,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color:
                                                        Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          _buildSubtitle(
                                            methods[i],
                                            theme,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      spacing: 2,
                                      children: [
                                        IconButton(
                                          mouseCursor:
                                              SystemMouseCursors
                                                  .click,
                                          visualDensity:
                                              VisualDensity
                                                  .compact,
                                          padding:
                                              EdgeInsets
                                                  .zero,
                                          constraints:
                                              const BoxConstraints(
                                                minWidth:
                                                    40,
                                                minHeight:
                                                    40,
                                              ),
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 18,
                                            color:
                                                Colors.grey,
                                          ),
                                          tooltip:
                                              'Update Channel',
                                          onPressed:
                                              _isLoading
                                                  ? null
                                                  : () => _showEditDialog(
                                                    methods[i],
                                                  ),
                                        ),
                                        IconButton(
                                          mouseCursor:
                                              SystemMouseCursors
                                                  .click,
                                          visualDensity:
                                              VisualDensity
                                                  .compact,
                                          padding:
                                              EdgeInsets
                                                  .zero,
                                          constraints:
                                              const BoxConstraints(
                                                minWidth:
                                                    40,
                                                minHeight:
                                                    40,
                                              ),
                                          icon: const Icon(
                                            Icons
                                                .delete_outline_rounded,
                                            size: 18,
                                            color:
                                                Colors
                                                    .redAccent,
                                          ),
                                          tooltip: 'Remove',
                                          onPressed:
                                              _isLoading
                                                  ? null
                                                  : () {
                                                    showDialog(
                                                      context:
                                                          context,
                                                      builder: (
                                                        confirmContext,
                                                      ) {
                                                        return ConfirmationAlert(
                                                          theme:
                                                              theme,
                                                          message:
                                                              'You are about to Delete a Payment Channel. Are you sure you want to Proceed?',
                                                          title:
                                                              'Delete Payment Channel',
                                                          action: () {
                                                            Navigator.of(
                                                              confirmContext,
                                                            ).pop();
                                                            _removeMethod(
                                                              methods[i].uuid,
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed:
                    () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: theme.mobileTexts.b3.fontSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
