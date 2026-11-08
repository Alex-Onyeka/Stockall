import 'package:flutter/material.dart';
import 'package:stockall/classes/payment_entry/payment_method.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/main.dart';

class ManagePaymentMethodsDialog extends StatefulWidget {
  const ManagePaymentMethodsDialog({super.key});

  @override
  State<ManagePaymentMethodsDialog> createState() =>
      _ManagePaymentMethodsDialogState();
}

class _ManagePaymentMethodsDialogState
    extends State<ManagePaymentMethodsDialog> {
  final TextEditingController _bankNameController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _accountNameController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  Future<void> _addMethod() async {
    final bankName = _bankNameController.text.trim();
    if (bankName.isEmpty) return;

    final accNum = _accountNumberController.text.trim();
    final accName = _accountNameController.text.trim();

    setState(() => _isLoading = true);
    await returnShopProvider().addCustomPaymentMethod(
      PaymentMethod(
        bankName: bankName,
        accountNumber: accNum.isNotEmpty ? accNum : null,
        accountName: accName.isNotEmpty ? accName : null,
      ),
    );
    _bankNameController.clear();
    _accountNumberController.clear();
    _accountNameController.clear();
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

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    final shopProvider = returnShopProvider(
      context: context,
      listen: true,
    );
    final methods = shopProvider.getCustomPaymentMethods();

    return DialogTemplate(
      theme: theme,
      title: 'Payment Methods & Bank Accounts',
      message:
          'Configure your bank accounts and payment channels to track receipts and split payments accurately.',
      showBottomActionButtons: false,
      action: () {},
      widget: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _bankNameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText:
                    'e.g. Zenith Bank, GTBank, Moniepoint',
                labelText: 'Bank Name *',
                hintStyle: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  color: Colors.grey.shade500,
                ),
                labelStyle: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.lightModeColor.prColor250,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _accountNumberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 1029384756',
                      labelText:
                          'Account Number (Optional)',
                      hintStyle: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        color: Colors.grey.shade500,
                      ),
                      labelStyle: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        borderSide: BorderSide(
                          color:
                              theme
                                  .lightModeColor
                                  .prColor250,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _accountNameController,
                    textCapitalization:
                        TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'e.g. Acme Ltd',
                      labelText: 'Account Name (Optional)',
                      hintStyle: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        color: Colors.grey.shade500,
                      ),
                      labelStyle: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        borderSide: BorderSide(
                          color:
                              theme
                                  .lightModeColor
                                  .prColor250,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 120,
                child: MainButtonP(
                  themeProvider: theme,
                  text: _isLoading ? '...' : '+ Add Bank',
                  action: _isLoading ? null : _addMethod,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Active Bank Accounts / Channels:',
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
                            'No custom bank accounts configured yet.\nThe app currently uses the default "Bank" option.',
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
                              ListTile(
                                dense: true,
                                leading: Icon(
                                  Icons
                                      .account_balance_outlined,
                                  size: 22,
                                  color:
                                      theme
                                          .lightModeColor
                                          .prColor250,
                                ),
                                title: Text(
                                  methods[i].bankName,
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                                subtitle:
                                    (methods[i]
                                                    .accountNumber
                                                    ?.isNotEmpty ==
                                                true ||
                                            methods[i]
                                                    .accountName
                                                    ?.isNotEmpty ==
                                                true)
                                        ? Text(
                                          [
                                            if (methods[i]
                                                    .accountNumber
                                                    ?.isNotEmpty ==
                                                true)
                                              'Acc: ${methods[i].accountNumber}',
                                            if (methods[i]
                                                    .accountName
                                                    ?.isNotEmpty ==
                                                true)
                                              methods[i]
                                                  .accountName!,
                                          ].join(' • '),
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b4
                                                    .fontSize,
                                            color:
                                                Colors
                                                    .grey
                                                    .shade600,
                                          ),
                                        )
                                        : null,
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons
                                        .delete_outline_rounded,
                                    size: 18,
                                    color: Colors.redAccent,
                                  ),
                                  tooltip: 'Remove',
                                  onPressed:
                                      _isLoading
                                          ? null
                                          : () =>
                                              _removeMethod(
                                                methods[i]
                                                    .uuid,
                                              ),
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
